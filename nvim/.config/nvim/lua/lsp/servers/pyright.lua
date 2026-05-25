local M = {}

function M.get()
	return {
		settings = {
			python = {
				analysis = {
					-- 自动搜索当前项目的 import 路径
					autoSearchPaths = true,

					-- 使用库代码辅助类型推断
					useLibraryCodeForTypes = true,

					-- 诊断模式：只检查打开的文件
					diagnosticMode = "openFilesOnly",
				},
			},
		},
	}
end

return M
