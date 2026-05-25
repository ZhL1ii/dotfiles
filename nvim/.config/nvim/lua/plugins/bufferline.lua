local buffer = require("utils.buffer")

return {
	"akinsho/bufferline.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		options = {
			mode = "buffers",
			numbers = "ordinal",
			always_show_bufferline = true,

			show_buffer_icons = true,
			show_buffer_close_icons = false,
			show_close_icon = false,
			show_modified_icon = true,

			diagnostics = "nvim_lsp",
			separator_style = { "▕", "▕" },
			indicator = {
				style = "none",
			},

			close_command = buffer.delete,
			right_mouse_command = buffer.delete,

			offsets = {
				{
					filetype = "neo-tree",
					text = "󰙅 Files",
					text_align = "center",
					separator = false,
				},
			},

			max_name_length = 20,
			max_prefix_length = 15,
			truncate_names = true,
			enforce_regular_tabs = true,
			tab_size = 20,
			sort_by = "insert_after_current",
		},
	},

	keys = {
		{ "<leader>bh", "<cmd>BufferLineCyclePrev<CR>", desc = "Buffer: Previous", silent = true },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Buffer: Previous", silent = true },

		{ "<leader>bl", "<cmd>BufferLineCycleNext<CR>", desc = "Buffer: Next", silent = true },
		{ "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Buffer: Next", silent = true },

		{ "<leader>bp", "<cmd>BufferLinePick<CR>", desc = "Buffer: Pick", silent = true },

		{ "<leader>bd", buffer.delete_current, desc = "Buffer: Delete", silent = true },
		{ "<leader>bD", buffer.force_delete_current, desc = "Buffer: Force Delete", silent = true },
		{ "<leader>bo", buffer.delete_others, desc = "Buffer: Delete Others", silent = true },
		{ "<leader>ba", buffer.delete_all, desc = "Buffer: Delete All", silent = true },
	},

	lazy = false,
}
