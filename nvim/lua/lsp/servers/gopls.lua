local M = {}

function M.get()
	return {
		settings = {
			gopls = {
				-- 开启静态分析
				analyses = {
					ST1000 = false,
					unusedparams = true,
					shadow = true,
				},

				-- 使用 gofumpt 风格，格式化更严格
				gofumpt = true,

				-- 开启静态检查
				staticcheck = true,

				-- 补全未导入包里的符号时，自动补 import
				completeUnimported = true,

				-- 使用占位符补全函数参数
				usePlaceholders = true,

				-- 提示参数名、变量类型等 inline hints
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
			},
		},
	}
end

return M
