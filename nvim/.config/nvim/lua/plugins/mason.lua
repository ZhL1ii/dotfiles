return {
	{
		"mason-org/mason.nvim",
		-- mason-lspconfig 和 mason-tool-installer 都依赖 Mason 已完成 setup。
		lazy = false,
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = {
				"lua_ls",
				"pyright",
				"ts_ls",
				"clangd",
				"gopls",
				"jdtls",
			},
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		opts = {
			-- mason-lspconfig 只负责安装 LSP server。
			-- formatter 和 linter 这类普通命令行工具，用 mason-tool-installer 管理更合适。
			ensure_installed = {
				-- formatter：给 conform.nvim 使用
				"stylua",
				"black",
				"gofumpt",
				"goimports",
				"clang-format",
				"prettier",

				-- linter：给 nvim-lint 使用
				-- "luacheck",
				"ruff",
				"eslint_d",
				"golangci-lint",
				"shellcheck",
				"yamllint",

				-- Java linter
				"checkstyle",
			},

			-- 启动 Neovim 时自动检查缺失工具并安装。
			-- 若不自动安装，可以改成 false，然后手动执行 :MasonToolsInstall。
			auto_update = false,
			run_on_start = true,
		},
	},
}
