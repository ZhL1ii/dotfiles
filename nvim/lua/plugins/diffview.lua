local function diffview_command(command)
	return function()
		-- 用函数包一层，lazy.nvim 触发快捷键时再执行命令，避免启动期提前加载插件。
		vim.cmd(command)
	end
end

return {
	"sindrets/diffview.nvim",
	-- 通过命令懒加载；平时编辑文件时不初始化 Diffview。
	cmd = {
		"DiffviewOpen",
		"DiffviewFileHistory",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
	},
	dependencies = {
		-- Diffview 依赖 plenary 提供通用 Lua 工具函数。
		"nvim-lua/plenary.nvim",
		-- 文件列表中显示图标；你当前配置里其他插件也在复用这个依赖。
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		-- 打开当前 Git 工作区的 diff 视图；处于 merge/rebase 冲突时会展示冲突视图。
		{ "<leader>gd", diffview_command("DiffviewOpen"), desc = "Git: Open diff view" },
		-- 查看当前文件的提交历史，适合定位某一行/某个文件最近是怎么变的。
		{ "<leader>gh", diffview_command("DiffviewFileHistory %"), desc = "Git: Current file history" },
		-- 查看整个仓库的提交历史，适合从提交维度浏览改动。
		{ "<leader>gH", diffview_command("DiffviewFileHistory"), desc = "Git: Repository history" },
		-- 关闭 Diffview 创建的 tabpage/window，回到正常编辑界面。
		{ "<leader>gq", diffview_command("DiffviewClose"), desc = "Git: Close diff view" },
	},
	opts = {
		-- 开启更细粒度的 diff 高亮，能更清楚看出行内具体变化。
		enhanced_diff_hl = true,
		-- 文件面板使用 devicons 图标，和 neo-tree/telescope 的视觉风格保持一致。
		use_icons = true,
		view = {
			merge_tool = {
				-- 三方混合视图：同时展示 ours、base、theirs，并保留可编辑结果区。
				-- 处理复杂冲突时比单纯在文件里找 <<<<<<< 标记更接近 IDE 体验。
				layout = "diff3_mixed",
			},
		},
	},
}
