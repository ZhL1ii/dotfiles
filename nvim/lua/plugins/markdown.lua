return {
	-- markdown 终端内预览
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},

	-- markdown 大纲插件
	{
		"stevearc/aerial.nvim",
		opts = {
			backends = {
				"treesitter",
				"lsp",
				"markdown",
				"man",
			},

			layout = {
				default_direction = "right",
				width = 32,
				min_width = 24,
			},

			show_guides = true,
			filter_kind = false,
		},

		keys = {
			{
				"<leader>mo",
				"<cmd>AerialToggle<cr>",
				desc = "Markdown Outline",
			},
			{
				"<leader>mn",
				"<cmd>AerialNext<cr>",
				desc = "Next Markdown Heading",
			},
			{
				"<leader>mN",
				"<cmd>AerialPrev<cr>",
				desc = "Previous Markdown Heading",
			},
		},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},

	-- markdown 浏览器预览
	{
		"iamcco/markdown-preview.nvim",
		cmd = {
			"MarkdownPreview",
			"MarkdownPreviewStop",
			"MarkdownPreviewToggle",
		},
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_refresh_slow = 0
			vim.g.mkdp_command_for_global = 0
			vim.g.mkdp_open_to_the_world = 0
			vim.g.mkdp_browser = ""
			vim.g.mkdp_echo_preview_url = 1
			vim.g.mkdp_page_title = "${name}"
		end,
		keys = {
			{
				"<leader>mp",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "Markdown Preview",
			},
		},
	},
}
