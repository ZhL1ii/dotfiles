local keymap = vim.keymap

-- 除去空格本来的移动光标功能
keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file", silent = true })
keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight", silent = true })
keymap.set("n", "<leader>qq", "<cmd>q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>qQ", "<cmd>qall<CR>", { desc = "Quit All" })
keymap.set("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy", silent = true })

-- 切换窗口
keymap.set("n", "<C-h>", "<C-w>h", { desc = "切到左边窗口" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "切到下边窗口" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "切到上边窗口" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "切到右边窗口" })

keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "退出终端输入模式" })
