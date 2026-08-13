local function sync_tab_background()
	local normal = vim.api.nvim_get_hl(0, {
		name = "NeoTreeNormal",
		link = false,
	})

	for _, group in ipairs({
		"NeoTreeTabActive",
		"NeoTreeTabInactive",
		"NeoTreeTabSeparatorActive",
		"NeoTreeTabSeparatorInactive",
	}) do
		local hl = vim.api.nvim_get_hl(0, {
			name = group,
			link = false,
		})

		hl.bg = normal.bg
		vim.api.nvim_set_hl(0, group, hl)
	end
end

local function get_path(state)
	local node = state.tree:get_node()
	return node and (node.path or node:get_id())
end

local function copy_path(modifier)
	return function(state)
		local path = get_path(state)
		if not path then
			return
		end

		path = vim.fn.fnamemodify(path, modifier)
		vim.fn.setreg("+", path)
		vim.notify("Copied: " .. path)
	end
end

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",

		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle filesystem reveal left<cr>",
				desc = "Explore",
			},
		},

		opts = {
			sources = {
				"filesystem",
				"buffers",
				"git_status",
			},

			source_selector = {
				winbar = true,
				statusline = false,

				sources = {
					{ source = "filesystem", display_name = "󰉓 Files" },
					{ source = "buffers", display_name = "󰈙 Bufs" },
					{ source = "git_status", display_name = "󰊢 Git" },
				},

				content_layout = "center",
				show_saparator_on_edge = false,
			},

			buffers = {
				show_unloaded = true,

				components = {
					bufnr = function()
						return {}
					end,
				},
			},

			commands = {
				open_with_default_app = function(state)
					local path = get_path(state)
					if path then
						vim.ui.open(path)
					end
				end,

				copy_absolute_path = copy_path(":p"),
				copy_relative_path = copy_path(":."),
			},

			window = {
				width = 30,
				mappings = {
					["H"] = "prev_source",
					["L"] = "next_source",
				},
			},

			popup_border_style = "rounded",

			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
				},
				follow_current_file = {
					enabled = true,
				},

				window = {
					mappings = {
						["l"] = "open",
						["h"] = "close_node",
						["ya"] = "copy_absolute_path",
						["yr"] = "copy_relative_path",
						["<C-o>"] = "open_with_default_app",
						["."] = "toggle_hidden",
						["<CR>"] = "set_root",
						["<BS>"] = "navigate_up",
						["/"] = {
							"fuzzy_finder",
							config = {
								title = " 󰉓 Search ",
							},
						},
					},
				},
			},
		},

		config = function(_, opts)
			require("neo-tree").setup(opts)

			-- 第一次加载 neo-tree 时同步配色
			vim.schedule(sync_tab_background)

			-- 每次切换 colorscheme 后重新同步
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("NeoTreeTabBackground", { clear = true }),
				callback = function()
					vim.schedule(sync_tab_background)
				end,
			})
		end,
	},
}
