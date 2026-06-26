local M = {}

local function executable(path)
	return path and vim.fn.executable(path) == 1
end

local function joinpath(...)
	return table.concat({ ... }, "/")
end

local function is_inside(path, root_dir)
	if not root_dir or not path then
		return false
	end

	path = vim.fs.normalize(path)
	root_dir = vim.fs.normalize(root_dir)

	-- 只信任当前项目内的已激活虚拟环境，避免把别的项目环境传给 Pyright。
	return path == root_dir or vim.startswith(path, root_dir .. "/")
end

local function venv_python(venv)
	if not venv then
		return
	end

	local python = joinpath(venv, "bin", "python")
	if executable(python) then
		return python
	end
end

local function find_python(root_dir)
	-- 优先级：项目内已激活环境 > 项目目录常见虚拟环境 > 外部已激活环境。
	if is_inside(vim.env.VIRTUAL_ENV, root_dir) then
		local python = venv_python(vim.env.VIRTUAL_ENV)
		if python then
			return python
		end
	end

	if root_dir then
		for _, name in ipairs({ ".venv", "venv" }) do
			local python = venv_python(joinpath(root_dir, name))
			if python then
				return python
			end
		end
	end

	return venv_python(vim.env.VIRTUAL_ENV) or venv_python(vim.env.CONDA_PREFIX)
end

local function apply_python_path(config, root_dir)
	local python = find_python(root_dir)
	if not python then
		return
	end

	-- pythonPath 让 Pyright 使用项目解释器解析 site-packages，例如 numpy、cv2。
	config.settings = config.settings or {}
	config.settings.python = config.settings.python or {}
	config.settings.python.pythonPath = python
end

function M.get()
	return {
		on_new_config = function(config, root_dir)
			apply_python_path(config, root_dir)
		end,
		settings = {
			python = {
				analysis = {
					-- 自动搜索当前项目的 import 路径
					autoSearchPaths = true,

					-- 使用库代码辅助类型推断
					useLibraryCodeForTypes = true,

					-- 诊断模式：只检查打开的文件
					diagnosticMode = "openFilesOnly",

					-- Ruff 已负责 unused 类 lint，Pyright 保留类型检查和 import 解析即可。
					diagnosticSeverityOverrides = {
						reportUnusedImport = "none",
						reportUnusedVariable = "none",
						reportUnusedFunction = "none",
						reportUnusedClass = "none",
					},
				},
			},
		},
	}
end

return M
