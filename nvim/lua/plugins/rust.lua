return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false,
	init = function()
		-- rustaceanvim 会自己初始化 rust-analyzer，这里复用现有 LSP 公共能力和键位。
		-- 不在 lsp/init.lua 里启用 rust_analyzer，避免同一个 server 被注册两次。
		vim.g.rustaceanvim = {
			server = {
				capabilities = require("lsp.capabilities").get(),
				on_attach = require("lsp.on_attach").get(),
				default_settings = {
					["rust-analyzer"] = {
						cargo = {
							-- build.rs 和 proc-macro 展开依赖 cargo 元数据，开启后诊断和补全更接近真实项目。
							buildScripts = {
								enable = true,
							},
						},
						check = {
							-- 保存后诊断使用 cargo check；后续如果需要更严格检查，再单独切到 clippy。
							command = "check",
						},
						procMacro = {
							enable = true,
						},
					},
				},
			},
		}
	end,
}
