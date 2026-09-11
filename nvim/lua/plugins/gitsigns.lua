local function on_attach(bufnr)
	local gitsigns = require("gitsigns")

	-- 统一创建当前 buffer 的 gitsigns 快捷键，避免影响非 Git 文件。
	local function map(mode, lhs, rhs, desc, opts)
		opts = opts or {}
		opts.buffer = bufnr
		opts.desc = desc
		opts.silent = true
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	-- diff 模式下保留 Neovim 原生 ]h 行为；普通编辑时跳到下一个 Git hunk。
	map("n", "]h", function()
		if vim.wo.diff then
			return "]h"
		end
		vim.schedule(gitsigns.next_hunk)
		return "<Ignore>"
	end, "Git: Next hunk", { expr = true })

	-- diff 模式下保留 Neovim 原生 [h 行为；普通编辑时跳到上一个 Git hunk。
	map("n", "[h", function()
		if vim.wo.diff then
			return "[h"
		end
		vim.schedule(gitsigns.prev_hunk)
		return "<Ignore>"
	end, "Git: Previous hunk", { expr = true })

	map("n", "<leader>gp", gitsigns.preview_hunk, "Git: Preview hunk")
	map("n", "<leader>gs", gitsigns.stage_hunk, "Git: Stage hunk")
	map("n", "<leader>gr", gitsigns.reset_hunk, "Git: Reset hunk")
	-- 显示当前行完整 blame 信息，包含提交详情。
	map("n", "<leader>gb", function()
		gitsigns.blame_line({ full = true })
	end, "Git: Blame line")
end

local function gitsigns_action(action, opts)
	return function()
		require("gitsigns")[action](opts)
	end
end

return {
	"lewis6991/gitsigns.nvim",
	-- 读写文件时再加载，启动阶段不提前初始化 Git 状态。
	event = { "BufReadPre", "BufNewFile" },
	-- 注册全局快捷键描述，让 which-key 在按 <leader> 时能显示 Git 分组和子命令。
	keys = {
		{ "<leader>gp", gitsigns_action("preview_hunk"), desc = "Git: Preview hunk" },
		{ "<leader>gs", gitsigns_action("stage_hunk"), desc = "Git: Stage hunk" },
		{ "<leader>gr", gitsigns_action("reset_hunk"), desc = "Git: Reset hunk" },
		{ "<leader>gb", gitsigns_action("blame_line", { full = true }), desc = "Git: Blame line" },
	},
	opts = {
		-- 默认不持续显示 blame，按 <leader>gb 时再查看当前行归属。
		current_line_blame = false,
		on_attach = on_attach,
	},
}
