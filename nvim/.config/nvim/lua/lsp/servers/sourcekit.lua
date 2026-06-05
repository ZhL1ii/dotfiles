local M = {}

-- build-server、SwiftPM 和 compile_commands.json 都是普通文件或目录 marker。
-- 向上查找可以避免把 SourceKit-LSP 附着到过小的子目录。
local function find_upward(filename, names)
	local path = vim.fs.dirname(filename)

	while path do
		-- 先检查当前目录是否包含任一项目 marker，命中后直接把当前目录作为 root。
		for _, name in ipairs(names) do
			if vim.uv.fs_stat(vim.fs.joinpath(path, name)) then
				return path
			end
		end

		-- 未命中时逐级回到父目录；到文件系统根目录后停止，避免无限循环。
		local parent = vim.fs.dirname(path)
		if not parent or parent == path then
			return nil
		end

		path = parent
	end
end

-- Xcode 工程根通常由 .xcodeproj / .xcworkspace 目录表示，不能按普通文件名精确匹配。
local function find_xcode_root(filename)
	local path = vim.fs.dirname(filename)

	while path do
		local entries = vim.fs.dir(path)
		if entries then
			-- 遍历目录条目以匹配 Xcode project 或 workspace 目录。
			for name, entry_type in entries do
				if entry_type == "directory" and (name:match("%.xcodeproj$") or name:match("%.xcworkspace$")) then
					return path
				end
			end
		end

		local parent = vim.fs.dirname(path)
		if not parent or parent == path then
			return nil
		end

		path = parent
	end
end

-- 没有语言专属 marker 时回退到 Git 根，保证零散 Swift 文件仍能获得 LSP 能力。
local function find_git_root(filename)
	local git_dir = vim.fs.find(".git", { path = filename, upward = true })[1]
	return git_dir and vim.fs.dirname(git_dir) or nil
end

function M.get()
	return {
		cmd = { "sourcekit-lsp" },

		-- SourceKit-LSP 同时支持 Swift 和 C 系语言。这里只显式保留上游默认 filetype，
		-- 让它在 SwiftPM、Xcode project/workspace 和 build-server 项目里都能自动附着。
		filetypes = { "swift", "objc", "objcpp", "c", "cpp" },

		root_dir = function(bufnr, on_dir)
			local filename = vim.api.nvim_buf_get_name(bufnr)

			-- 优先 build-server 标记，SourceKit-LSP 可直接读取构建图。
			local build_server_root = find_upward(filename, { "buildServer.json" })

			-- 再尝试 BSP 目录，兼容 SwiftPM 生成的 build server 项目。
			local bsp_root = find_upward(filename, { ".bsp" })

			-- Xcode 工程和 workspace 用目录后缀识别，不能只按固定文件名查找。
			local xcode_root = find_xcode_root(filename)

			-- SwiftPM 和 compile_commands.json 是常见的独立项目根。
			local package_root = find_upward(filename, { "compile_commands.json", "Package.swift" })

			-- 最后回退到 Git 根，覆盖没有显式构建 marker 的零散 Swift 文件。
			local git_root = find_git_root(filename)

			on_dir(build_server_root or bsp_root or xcode_root or package_root or git_root)
		end,

		get_language_id = function(_, filetype)
			local language_ids = {
				objc = "objective-c",
				objcpp = "objective-cpp",
			}

			return language_ids[filetype] or filetype
		end,

		-- SourceKit-LSP 支持动态文件监听和 pull diagnostics，这里显式打开对应能力。
		capabilities = {
			workspace = {
				didChangeWatchedFiles = {
					dynamicRegistration = true,
				},
			},
			textDocument = {
				diagnostic = {
					dynamicRegistration = true,
					relatedDocumentSupport = true,
				},
			},
		},
	}
end

return M
