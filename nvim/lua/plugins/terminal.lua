local lazygit_terms = {}

-- 返回当前工作目录所在的 Git 根目录。
-- 如果当前目录不在 Git 仓库里，就退回到 Neovim 当前 cwd。
local function current_git_root()
	local cwd = vim.fn.getcwd()
	local root = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })[1]

	if vim.v.shell_error == 0 and root and root ~= "" then
		return root
	end

	return cwd
end

local function toggle_lazygit()
	-- lazygit 是外部命令，不由 toggleterm 安装；没装时给出明确提示。
	if vim.fn.executable("lazygit") ~= 1 then
		vim.notify("lazygit is not installed", vim.log.levels.WARN)
		return
	end

	-- Terminal 是 toggleterm 提供的可编程终端对象。
	-- 这里不用普通 ToggleTerm 命令，是为了给 lazygit 单独指定目录和复用规则。
	local Terminal = require("toggleterm.terminal").Terminal
	local root = current_git_root()

	-- 每个 Git 项目复用一个 lazygit 终端，避免切项目后目录混乱。
	lazygit_terms[root] = lazygit_terms[root]
		or Terminal:new({
			cmd = "lazygit",
			dir = root,
			direction = "float",
			display_name = "lazygit",
			-- hidden=true 表示这个终端不会出现在普通 buffer 列表里。
			hidden = true,
			-- 退出 lazygit 后关闭终端窗口；下次按快捷键会重新创建。
			close_on_exit = true,
		})

	lazygit_terms[root]:toggle()
end

-- 生成不同方向的 ToggleTerm 快捷键回调。
-- 这样 float / horizontal / vertical 共用同一段逻辑，只传方向参数。
local function toggle_terminal(direction)
	return function()
		vim.cmd("ToggleTerm direction=" .. direction .. " name=terminal")
	end
end

return {
	"akinsho/toggleterm.nvim",
	-- 使用当前稳定主版本，避免直接追 main 分支带来的破坏性变更。
	version = "*",
	-- 只有执行这些命令或按下面快捷键时才加载插件，减少启动时开销。
	cmd = {
		"ToggleTerm",
		"ToggleTermToggleAll",
		"TermExec",
		"TermNew",
		"TermSelect",
	},
	keys = {
		-- 日常临时命令优先用浮动终端，不改变当前窗口布局。
		{ "<leader>tt", toggle_terminal("float"), desc = "Terminal: Float" },
		-- 适合运行会持续输出的命令，例如 dev server 或 test watch。
		{ "<leader>th", toggle_terminal("horizontal"), desc = "Terminal: Horizontal" },
		-- 适合一边看代码一边操作 shell。
		{ "<leader>tv", toggle_terminal("vertical"), desc = "Terminal: Vertical" },
		-- 新建一个独立终端，避免覆盖当前正在运行的进程。
		{ "<leader>tn", "<cmd>TermNew<cr>", desc = "Terminal: New" },
		-- 在已有多个终端之间选择，适合同时跑多个服务时切换。
		{ "<leader>tT", "<cmd>TermSelect<cr>", desc = "Terminal: Select" },
		-- 打开项目级 lazygit；没安装 lazygit 时只提示，不影响其他终端功能。
		{ "<leader>tg", toggle_lazygit, desc = "Terminal: Lazygit" },

		-- 终端输入模式里不能用 <leader>，因为你的 leader 是空格，会干扰 shell 输入。
		-- <C-t> 先退出 terminal-mode，再隐藏当前终端窗口。
		{ "<C-t>", [[<C-\><C-n><cmd>ToggleTerm<cr>]], mode = "t", desc = "Terminal: Hide current" },
	},
	opts = {
		-- 水平终端固定高度，垂直终端占屏幕 35%；浮动终端使用 float_opts 控制尺寸。
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			end

			if term.direction == "vertical" then
				return math.floor(vim.o.columns * 0.35)
			end

			return 20
		end,

		-- 打开终端后直接进入插入模式，适合马上输入 shell 命令。
		start_in_insert = true,

		-- 记住上次终端窗口大小和模式，反复切换时体验更稳定。
		persist_size = true,
		-- 不记住 Normal/Insert 模式；每次打开终端都重新进入可输入状态。
		-- 这样用 <C-t> 隐藏终端后，下次打开不会停在 Normal 模式。
		persist_mode = false,

		-- 命令退出后自动关闭终端窗口，长驻进程隐藏后仍会继续运行。
		close_on_exit = true,
		-- 终端输出新增内容时自动滚到底部，适合看 build/test 日志。
		auto_scroll = true,
		-- 使用 Neovim 当前 shell，保持和你的系统 shell 配置一致。
		shell = vim.o.shell,

		-- 浮动终端占主要视野，但保留边缘上下文。
		direction = "float",
		float_opts = {
			border = "rounded",
			width = function()
				return math.floor(vim.o.columns * 0.9)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.82)
			end,
		},
	},
}
