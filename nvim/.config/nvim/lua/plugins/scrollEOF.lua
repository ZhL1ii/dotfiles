return {
	"Aasim-A/scrollEOF.nvim",
	event = { "CursorMoved", "WinScrolled" },
	opts = {
		insert_mode = true,
		floating = false,
		disabled_filetypes = {
			"terminal",
			"TelescopePrompt",
			"lazy",
			"noice",
			"NvimTree",
			"neo-tree",
			"dashboard",
			"alpha",
		},
		disabled_modes = { "t", "nt" },
	},
}
