return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		preset = "modern",
		delay = 120,
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Debug" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Git" },
			{ "<leader>l", group = "Lint" },
			{ "<leader>q", group = "Quit" },
			{ "<leader>r", group = "Run" },
			{ "<leader>t", group = "Terminal" },
			{ "<leader>x", group = "Diagnostics" },
			{ "<leader>m", group = "Markdown" },
		},

		notify = true,

		win = {
			no_overlap = false,
			width = 35,
			height = { min = 4, max = 20 },
			col = -1,
			row = -1,
			border = "rounded",
			padding = { 1, 2 },
			title = true,
			title_pos = "center",
		},

		layout = {
			width = 42,
			spacing = 3,
		},
	},

	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps",
		},
	},
}
