return {
	"lukas-reineke/indent-blankline.nvim",
	event = "VeryLazy",
	main = "ibl",
	opts = {
		indent = {
			char = "▏",
			tab_char = "▏",
		},

		scope = {
			char = "▏",
			enabled = false,
			show_start = false,
			show_end = false,
		},
	},
}
