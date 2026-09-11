return {
	"numToStr/Comment.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<D-/>",
			"<Plug>(comment_toggle_linewise_current)",
			mode = "n",
			desc = "Comment: Toggle line",
		},
		{
			"<D-/>",
			"<Plug>(comment_toggle_linewise_visual)",
			mode = "x",
			desc = "Comment: Toggle selection",
		},
		{
			"<leader>/",
			"<Plug>(comment_toggle_linewise_current)",
			mode = "n",
			desc = "Comment: Toggle line",
		},
		{
			"<leader>/",
			"<Plug>(comment_toggle_linewise_visual)",
			mode = "x",
			desc = "Comment: Toggle selection",
		},
	},
}
