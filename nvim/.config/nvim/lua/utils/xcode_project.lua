local M = {}

local function is_xcode_marker(name, entry_type)
	return entry_type == "directory" and (name:match("%.xcodeproj$") or name:match("%.xcworkspace$"))
end

---Find the nearest directory that contains an Xcode project or workspace.
---@param path string File or directory path from which to search upward.
---@return string? root
function M.find_root(path)
	if not path or path == "" then
		return nil
	end

	local stat = vim.uv.fs_stat(path)
	local directory = stat and stat.type == "directory" and path or vim.fs.dirname(path)

	while directory and directory ~= "" do
		for name, entry_type in vim.fs.dir(directory) do
			if is_xcode_marker(name, entry_type) then
				return directory
			end
		end

		local parent = vim.fs.dirname(directory)
		if parent == directory then
			break
		end
		directory = parent
	end

	return nil
end

---Find the Xcode root associated with a buffer.
---@param bufnr? integer
---@return string? root
function M.root_for_buffer(bufnr)
	return M.find_root(vim.api.nvim_buf_get_name(bufnr or 0))
end

---Set Neovim's global working directory to the current buffer's Xcode root.
---@param bufnr? integer
---@return string? root The discovered root, or nil when the buffer is not in an Xcode project.
function M.ensure_cwd(bufnr)
	local root = M.root_for_buffer(bufnr)
	if not root then
		return nil
	end

	if vim.fs.normalize(vim.fn.getcwd()) ~= vim.fs.normalize(root) then
		local ok = pcall(vim.api.nvim_set_current_dir, root)
		if not ok then
			return nil
		end
	end

	return root
end

return M
