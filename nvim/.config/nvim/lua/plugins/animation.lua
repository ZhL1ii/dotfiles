return {
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		opts = {
			mappings = {
				"<C-u>",
				"<C-d>",
				"<C-b>",
				"<C-f>",
				"<C-y>",
				"<C-e>",
				"zt",
				"zz",
				"zb",
			},

			hide_cursor = true,
			stop_eof = false,
			respect_scrolloff = false,
			cursor_scrolls_alone = true,
			duration_multiplier = 1.0,
			easing = "sine",
			performance_mode = false,
		},
	},
}
