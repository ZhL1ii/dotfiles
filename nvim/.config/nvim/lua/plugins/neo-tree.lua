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

-- 复制 Neo-tree 当前光标选中节点的路径。
-- state 由 Neo-tree command 注入；modifier 使用 fnamemodify 的路径格式，如 ":." 或 ":p"。
local function copy_selected_path(state, modifier, label)
	-- Neo-tree 的 buffer 没有真实文件路径，必须从树状态里取当前选中的节点。
	local node = state.tree:get_node()
	if not node then
		vim.notify("Neo-tree: no node selected", vim.log.levels.WARN)
		return
	end

	-- node.path 是文件系统节点的首选路径；get_id() 作为兜底，兼容少数只暴露 id 的节点。
	local path = node.path or node:get_id()
	if not path or path == "" then
		vim.notify("Neo-tree: selected node has no path", vim.log.levels.WARN)
		return
	end

	-- modifier 决定复制相对路径还是绝对路径，最终统一写入系统剪贴板寄存器。
	local copied_path = vim.fn.fnamemodify(path, modifier)
	vim.fn.setreg("+", copied_path)
	vim.notify("Copied " .. label .. ": " .. copied_path)
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
				copy_absolute_path = function(state)
					-- ":p" 保留完整路径，适合复制给外部工具或需要脱离当前工作目录的场景。
					copy_selected_path(state, ":p", "absolute path")
				end,
				copy_relative_path = function(state)
					-- ":." 按 Neovim 当前工作目录压成相对路径，适合复制到项目内文档或终端命令。
					copy_selected_path(state, ":.", "relative path")
				end,
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
					["<leader>ya"] = "copy_absolute_path",
					["<leader>yr"] = "copy_relative_path",
				},
			},
		},
	},
}
