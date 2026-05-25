return {
	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		cmd = "ConformInfo",
		opts = {
			-- 不同文件类型对应的formatter
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_organize_imports", "black" },
				go = { "goimports", "gofumpt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
			},

			formatters = {
				clang_format = {
					prepend_args = function(_, ctx)
						local project_config = vim.fs.find({ ".clang-format", "_clang-format" }, {
							upward = true,
							path = ctx.filename,
							stop = vim.env.HOME,
						})[1]

						if project_config then
							return {}
						end

						return { "--style=file:" .. vim.fn.expand("~/.config/.clang-format") }
					end,
				},
			},

			-- 保存时自动格式化
			format_on_save = function(bufnr)
				-- 只在可写文件上启用自动化格式化
				if vim.bo[bufnr].buftype ~= "" then
					return
				end
				return {
					timeout_ms = 3000,
					lsp_format = "fallback",
				}
			end,
		},

		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({
						async = true,
						lsp_format = "fallback",
					})
				end,
				desc = "Format Buffer",
			},
		},
	},
}
