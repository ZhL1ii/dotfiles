return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- 调用自己封装的 LSP 入口
			require("lsp").setup()
		end,
	},
}
