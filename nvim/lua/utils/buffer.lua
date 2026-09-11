local M = {}

-- 判断是否是普通文件 buffer
local function is_regular_buffer(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr) -- 判断buffer编号是否有效
		and vim.bo[bufnr].buflisted -- buflisted == true的buffer通常才会出现在bufferline里
		and vim.bo[bufnr].buftype == "" -- 一般普通文件buffer的buftype = ""
		and vim.bo[bufnr].filetype ~= "neo-tree" -- 排除neo-tree
end

-- 从所有 buffer 里找一个普通文件 buffer，但不要找 exclude_buf
local function find_regular_buffer(exclude_buf)
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if bufnr ~= exclude_buf and is_regular_buffer(bufnr) then
			return bufnr
		end
	end
end

-- 如果找不到左边 buffer，就随便找一个还能用的普通文件 buffer
local function find_window_showing_buffer(bufnr)
	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(winid) == bufnr then
			return winid
		end
	end
end

-- 判断当前 tab 里是不是有多个普通文件窗口？
local function has_multiple_regular_windows()
	local count = 0

	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if is_regular_buffer(vim.api.nvim_win_get_buf(winid)) then
			count = count + 1
			if count > 1 then
				return true
			end
		end
	end

	return false
end

-- 如果在分屏环境下按关闭 buffer，那就先关当前窗口，而不是删 buffer
local function find_left_buffer(current_buf)
	local ok, bufferline = pcall(require, "bufferline")
	if not ok then
		return nil
	end

	local ok_elements, result = pcall(bufferline.get_elements)
	if not ok_elements or not result or not result.elements then
		return nil
	end

	local left_buf

	for _, element in ipairs(result.elements) do
		local bufnr = element.id

		if bufnr == current_buf then
			return left_buf
		end

		if is_regular_buffer(bufnr) then
			left_buf = bufnr
		end
	end
end

-- 找当前 buffer 左边最近的那个普通 buffer，优化关闭逻辑
local function list_regular_buffers(exclude_buf)
	local buffers = {}

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if bufnr ~= exclude_buf and is_regular_buffer(bufnr) then
			table.insert(buffers, bufnr)
		end
	end

	return buffers
end

function M.delete(bufnr)
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = bufnr or vim.api.nvim_get_current_buf()

	if not is_regular_buffer(current_buf) then
		return
	end

	if current_buf == vim.api.nvim_win_get_buf(current_win) and has_multiple_regular_windows() then
		vim.api.nvim_win_close(current_win, false)
		return
	end

	if vim.bo[current_buf].modified then
		vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
		return
	end

	local target_buf = find_left_buffer(current_buf) or find_regular_buffer(current_buf)
	local target_win = find_window_showing_buffer(current_buf)

	if not target_win and vim.api.nvim_win_get_buf(current_win) == current_buf then
		target_win = current_win
	end

	if target_win then
		if target_buf then
			vim.api.nvim_win_set_buf(target_win, target_buf)
		else
			local placeholder = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(target_win, placeholder)
		end
	end

	vim.api.nvim_buf_delete(current_buf, {})
end

function M.delete_current()
	M.delete()
end

function M.force_delete_current()
	local current_buf = vim.api.nvim_get_current_buf()

	if vim.api.nvim_buf_is_valid(current_buf) then
		vim.api.nvim_buf_delete(current_buf, { force = true })
	end
end

local function delete_buffers(buffers)
	for _, bufnr in ipairs(buffers) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			if vim.bo[bufnr].modified then
				vim.notify("Skipped modified buffer: " .. vim.api.nvim_buf_get_name(bufnr), vim.log.levels.WARN)
			else
				pcall(vim.api.nvim_buf_delete, bufnr, {})
			end
		end
	end
end

function M.delete_others()
	local current_buf = vim.api.nvim_get_current_buf()
	local buffers = list_regular_buffers(current_buf)

	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local win_buf = vim.api.nvim_win_get_buf(winid)

		if win_buf ~= current_buf and is_regular_buffer(win_buf) then
			vim.api.nvim_win_set_buf(winid, current_buf)
		end
	end

	delete_buffers(buffers)
end

function M.delete_all()
	local buffers = list_regular_buffers()

	if #buffers == 0 then
		return
	end

	local placeholder = vim.api.nvim_create_buf(false, true)

	for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if is_regular_buffer(vim.api.nvim_win_get_buf(winid)) then
			vim.api.nvim_win_set_buf(winid, placeholder)
		end
	end

	delete_buffers(buffers)
end

return M
