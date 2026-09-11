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
-- 1. 本机编辑时使用系统原生剪贴板，保证 `p`/`P` 粘贴没有延迟。
-- 2. SSH/远程编辑时用 OSC52 把 yank 的内容写回本机剪贴板。
-- 3. 不用 OSC52 读取剪贴板，因为很多终端会弹安全确认，甚至等待到卡住。
local function executable(cmd)
	return vim.fn.executable(cmd) == 1
end

-- Neovim 的剪贴板 provider 依赖外部工具。
-- 如果这些工具存在，就让 Neovim 使用它们完整处理复制和粘贴。
local function has_native_clipboard()
	return (vim.fn.has("mac") == 1 and executable("pbcopy") and executable("pbpaste"))
		or (vim.env.WAYLAND_DISPLAY ~= nil and executable("wl-copy") and executable("wl-paste"))
		or (vim.env.WAYLAND_DISPLAY ~= nil and executable("waycopy") and executable("waypaste"))
		or (vim.env.DISPLAY ~= nil and executable("xsel"))
		or (vim.env.DISPLAY ~= nil and executable("xclip"))
		or executable("win32yank.exe")
		or (executable("clip") and executable("powershell"))
		or executable("termux-clipboard-set")
end

if has_native_clipboard() then
	-- `unnamedplus` 会让普通 yank/paste 默认使用系统剪贴板 `+`。
	vim.opt.clipboard = "unnamedplus"
else
	-- 远程/纯终端环境下：
	-- 使用 OSC52 只做“写入剪贴板”。这样 `y` 能复制到本机系统剪贴板，
	-- 但 `p` 不会尝试向终端读取剪贴板，从而避免验证弹窗和卡顿。
	local osc52 = require("vim.ui.clipboard.osc52")

	-- 保存本次 Neovim 会话里最近一次复制的内容。
	-- paste provider 会读这个缓存，而不是读终端剪贴板。
	local cache = {
		["+"] = { {}, "v" },
		["*"] = { {}, "v" },
	}

	local function copy(reg)
		local osc52_copy = osc52.copy(reg)

		return function(lines, regtype)
			cache[reg] = { vim.deepcopy(lines), regtype }
			osc52_copy(lines, regtype)
		end
	end

	-- 返回缓存内容，保持 `"+p` / `"*p` 可用；
	-- 但它只能粘贴本会话复制过的内容，不会读取本机系统剪贴板。
	local function paste(reg)
		return function()
			return cache[reg]
		end
	end

	vim.g.clipboard = {
		name = "OSC 52 copy-only",
		copy = {
			["+"] = copy("+"),
			["*"] = copy("*"),
		},
		paste = {
			["+"] = paste("+"),
			["*"] = paste("*"),
		},
	}

	-- 远程模式不启用 `unnamedplus`：
	-- 普通 `p` 继续使用 Neovim 默认寄存器，避免每次粘贴都触发剪贴板 provider。
	vim.opt.clipboard = ""

	-- 因为上面关闭了 `unnamedplus`，普通 `y` 默认只会写入 Neovim 寄存器。
	-- 这个 autocmd 把未指定寄存器的 yank 同步到 OSC52，实现“远程 y，本机可粘贴”。
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("Osc52Yank", { clear = true }),
		callback = function()
			if vim.v.event.operator == "y" and vim.v.event.regname == "" then
				vim.g.clipboard.copy["+"](vim.v.event.regcontents, vim.v.event.regtype)
			end
		end,
	})
end
