local opt = vim.opt

-- 基本显示
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"

-- 缩进
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- 分屏行为
opt.splitright = true
opt.splitbelow = true

-- 交互
opt.scrolloff = 12
opt.sidescrolloff = 30
opt.mouse = "a"

-- 光标闪烁
vim.opt.guicursor = {
	"n-v-c:block-blinkwait200-blinkon250-blinkoff250",
	"i-ci-ve:ver25-blinkwait200-blinkon250-blinkoff250",
	"r-cr:hor20-blinkwait200-blinkon250-blinkoff250",
}

-- 空白行
opt.fillchars:append({
	eob = " ",
})

-- 剪切板
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}

vim.opt.clipboard = "unnamedplus"
