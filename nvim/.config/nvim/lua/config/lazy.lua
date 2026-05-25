local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	-- 首次启动时自动拉取 lazy.nvim，后续启动直接复用本地插件管理器。
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end

-- 先把 lazy.nvim 加入 runtimepath，下面才能 require("lazy")。
vim.opt.rtp:prepend(lazypath)
-- 设置leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
	spec = {
		-- 所有插件声明统一放在 lua/plugins/*.lua。
		{ import = "plugins" },
	},
	install = {
		-- 插件安装失败或主题未就绪时，用内置主题兜底。
		colorscheme = { "habamax" },
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		enabled = false,
		notify = false,
	},
})
