local M = {}

function M.get()
	return {
		settings = {
			Lua = {
				runtime = {
					-- 使用 LuaJIT 编译
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					-- 把 Neovim 运行时文件加入工作区，方便识别 vim API
					library = vim.api.nvim_get_runtime_file("", true),
					-- 第三方库检查先关掉，减少无关提示
					checkThirdParty = false,
				},
				completion = {
					-- 函数补全时自动补参数片段
					callSnippet = "Replace",
				},
				telemetry = {
					-- 关闭遥测
					enable = false,
				},
			},
		},
	}
end

return M
