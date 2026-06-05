local keymap = vim.keymap

-- 复制当前普通 buffer 对应文件的路径。
-- modifier 使用 fnamemodify 的路径格式；label 只用于通知里区分复制结果。
local function copy_current_file_path(modifier, label)
	-- %:p 先拿绝对路径，后面再按 modifier 转换，避免相对路径受 buffer 名称形态影响。
	local path = vim.fn.expand("%:p")

	if path == "" then
		vim.notify("Current buffer has no file path", vim.log.levels.WARN)
		return
	end

	-- 相对路径始终基于当前工作目录；绝对路径直接复用 %:p 的结果，避免重复转换。
	local copied_path = modifier == ":." and vim.fn.fnamemodify(path, ":.") or path
	vim.fn.setreg("+", copied_path)
	vim.notify("Copied " .. label .. ": " .. copied_path)
end

-- 除去空格本来的移动光标功能
keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file", silent = true })
keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight", silent = true })
keymap.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>qQ", "<cmd>qall<CR>", { desc = "Quit All" })
keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy", silent = true })
keymap.set("n", "<leader>yr", function()
	copy_current_file_path(":.", "relative path")
end, { desc = "Yank: Relative file path", silent = true })
keymap.set("n", "<leader>ya", function()
	copy_current_file_path(":p", "absolute path")
end, { desc = "Yank: Absolute file path", silent = true })

-- 切换窗口
keymap.set("n", "<C-h>", "<C-w>h", { desc = "切到左边窗口" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "切到下边窗口" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "切到上边窗口" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "切到右边窗口" })

keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "退出终端输入模式" })
