if vim.g.neovide then
	-- 字体
	vim.o.guifont = "Maple Mono NF CN:h15"

	-- 去掉 Neovide 自己绘制的边框
	vim.g.neovide_show_border = false

	-- 去掉四周多余留白
	vim.g.neovide_padding_top = 0
	vim.g.neovide_padding_bottom = 0
	vim.g.neovide_padding_left = 0
	vim.g.neovide_padding_right = 0

	-- 字体缩放
	vim.g.neovide_scale_factor = 1.0

	local function change_scale_factor(delta)
		vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + delta
	end

	vim.keymap.set("n", "<D-=>", function()
		change_scale_factor(0.1)
	end, { desc = "Neovide font zoom in" })

	vim.keymap.set("n", "<D-->", function()
		change_scale_factor(-0.1)
	end, { desc = "Neovide font zoom out" })

	vim.keymap.set("n", "<D-0>", function()
		vim.g.neovide_scale_factor = 1.0
	end, { desc = "Neovide font zoom reset" })

	-- 平滑滚动
	vim.g.neovide_scroll_animation_length = 0.15

	-- 光标移动动画
	vim.g.neovide_cursor_animation_length = 0.08
	vim.g.neovide_cursor_trail_size = 0.3
end
