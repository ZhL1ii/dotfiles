local function open_with_default_app(state)
	local node = state.tree:get_node()
	if not node or node.type ~= "file" then
		vim.notify("Neo-tree: no file selected", vim.log.levels.WARN)
		return
	end

	local path = node.path or node:get_id()
	if not path or path == "" then
		vim.notify("Neo-tree: selected file has no path", vim.log.levels.WARN)
		return
	end

	if vim.ui and vim.ui.open then
		local ok, err = pcall(vim.ui.open, path)
		if not ok then
			vim.notify("Neo-tree: failed to open file: " .. tostring(err), vim.log.levels.ERROR)
		end
		return
	end

	local cmd
	if vim.fn.has("macunix") == 1 then
		cmd = { "open", path }
	elseif vim.fn.has("win32") == 1 then
		cmd = { "cmd.exe", "/c", "start", "", path }
	else
		cmd = { "xdg-open", path }
	end

	local job_id = vim.fn.jobstart(cmd, { detach = true })
	if job_id <= 0 then
		vim.notify("Neo-tree: failed to open file with default app", vim.log.levels.ERROR)
	end
end

local function refresh_neotree_git_status()
	local ok, manager = pcall(require, "neo-tree.sources.manager")
	if not ok then
		return
	end

	manager.refresh("filesystem")
	manager.refresh("git_status")
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
			{ "<leader>e", "<cmd>Neotree toggle filesystem reveal left<cr>", desc = "Explore: Toggle file tree" },
		},
		init = function()
			vim.api.nvim_create_autocmd({ "FocusGained", "TermClose" }, {
				group = vim.api.nvim_create_augroup("UserNeoTreeGitRefresh", { clear = true }),
				callback = refresh_neotree_git_status,
			})
		end,
		opts = {
			commands = {
				open_with_default_app = open_with_default_app,
			},
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					visible = true,
				},
				follow_current_file = {
					enabled = true,
				},
				hijack_netrw_behavior = "open_default",
			},
			window = {
				width = 30,
				mappings = {
					["bs"] = "noop",
					["<C-o>"] = "open_with_default_app",
					["l"] = "open",
					["h"] = "close_node",
				},
			},
		},
	},
}
