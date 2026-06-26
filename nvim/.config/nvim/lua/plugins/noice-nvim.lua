return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		{
			"rcarriga/nvim-notify",
			opts = {
				background_colour = "#000000",
			},
		},
	},

	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
		},

		lsp = {
			progress = {
				enabled = false,
			},

			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},

			hover = {
				enabled = true,
				silent = true,
			},

			signature = {
				enabled = false,
			},
		},

		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			lsp_doc_border = true,
		},

		views = {
			cmdline_popup = {
				position = {
					row = "35%",
					col = "50%",
				},
			},
			cmdline_popupmenu = {
				position = {
					col = "auto",
				},
			},
		},

		popupmenu = {
			enabled = true,
			backend = "nui",
		},

		messages = {
			enabled = true,
			view = "notify",
			view_error = "notify",
			view_warn = "notify",
			view_history = "messages",
			view_search = "virtualtext",
		},
	},
}
