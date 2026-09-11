if vim.g.neovide then
	vim.g.neovide_theme = "dark"
	vim.o.guifont = "Lilex Nerd Font Mono:h16"
end

-- 缩放字体
if vim.g.neovide then
	vim.g.neovide_scale_factor = 1.0

	local function change_scale_factor(delta)
		vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
	end

	-- 放大
	vim.keymap.set("n", "<D-=>", function()
		change_scale_factor(0.1)
	end, { desc = "Neovide font zoom in" })

	-- 缩小
	vim.keymap.set("n", "<D-->", function()
		change_scale_factor(-0.1)
	end, { desc = "Neovide font zoom out" })

	-- 重置
	vim.keymap.set("n", "<D-0>", function()
		vim.g.neovide_scale_factor = 1.0
	end, { desc = "Neovide font zoom reset" })
end
