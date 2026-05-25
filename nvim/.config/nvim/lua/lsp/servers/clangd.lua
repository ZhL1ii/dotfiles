local M = {}

function M.get()
	return {
		cmd = {
			"clangd",

			-- 后台建立索引
			"--background-index",

			-- 显示更详细的补全结果
			"--completion-style=detailed",

			-- 补全时自动插入头文件 include
			"--header-insertion=iwyu",

			-- 允许 clangd 使用 compile_commands.json
			-- "--compile-commands-dir=bulid",
		},

		-- C/C++ 项目根目录判断
		root_markers = {
			"compile_commands.json",
			"compile_flags.txt",
			".clangd",
			".git",
		},
	}
end

return M
