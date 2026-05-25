local last_task_id

-- 找回最近一次通过本配置启动的任务。
-- Overseer 的 task 对象是运行时状态，这里只保存 id，避免保存过期对象。
local function find_last_task()
	if not last_task_id then
		return nil
	end

	-- include_ephemeral=true 会把临时命令任务也纳入查找范围。
	for _, task in ipairs(require("overseer").list_tasks({ include_ephemeral = true })) do
		if task.id == last_task_id then
			return task
		end
	end
end

local function run_task()
	local overseer = require("overseer")

	-- 使用 Overseer 的任务选择器，自动识别 npm、make、cargo、.vscode/tasks.json 等任务。
	overseer.run_task({}, function(task)
		if task then
			-- 记录最近任务，供 <leader>rR 重跑和 <leader>rq 停止使用。
			last_task_id = task.id
			-- 任务启动后自动打开底部列表，但不抢走当前编辑窗口焦点。
			overseer.open({ direction = "bottom", enter = false })
		end
	end)
end

local function run_shell_task()
	-- 临时输入一条 shell 命令并交给 Overseer 管理。
	-- 适合没有 package.json / Makefile 任务时快速跑一次命令。
	vim.ui.input({ prompt = "Task command: " }, function(cmd)
		if not cmd or cmd == "" then
			return
		end

		local overseer = require("overseer")
		local task = overseer.new_task({
			-- cmd 可以是字符串，Overseer 会交给 shell 执行。
			cmd = cmd,
			-- 用命令本身作为任务名，任务列表里更容易识别。
			name = cmd,
			-- default 组件提供常规输出、状态和退出码处理。
			components = { "default" },
		})

		last_task_id = task.id
		-- new_task 只创建任务对象；start 才真正开始运行。
		task:start()
		overseer.open({ direction = "bottom", enter = false })
	end)
end

local function restart_last_task()
	local task = find_last_task()

	-- 没有最近任务时直接提示，避免快捷键静默失败。
	if not task then
		vim.notify("Overseer: no task to restart", vim.log.levels.WARN)
		return
	end

	-- true 表示任务正在运行时先停止再重启，适合 dev/test watch 场景。
	task:restart(true)
	require("overseer").open({ direction = "bottom", enter = false })
end

local function stop_last_task()
	local task = find_last_task()

	-- 只停止本配置记录的最近任务，不误停其他正在运行的任务。
	if not task then
		vim.notify("Overseer: no task to stop", vim.log.levels.WARN)
		return
	end

	task:stop()
end

return {
	"stevearc/overseer.nvim",
	-- 通过命令或快捷键按需加载，平时启动 Neovim 不提前初始化任务系统。
	cmd = {
		"OverseerOpen",
		"OverseerClose",
		"OverseerToggle",
		"OverseerRun",
		"OverseerShell",
		"OverseerTaskAction",
	},
	keys = {
		-- 从项目可识别任务中选择，例如 npm scripts、make、cargo、vscode tasks。
		{ "<leader>rr", run_task, desc = "Run: Task" },
		-- 手动输入一条命令并作为 Overseer 任务运行。
		{ "<leader>rc", run_shell_task, desc = "Run: Command" },
		-- 打开任务列表，查看任务状态、退出码和输出。
		{ "<leader>ro", "<cmd>OverseerToggle bottom<cr>", desc = "Run: Toggle list" },
		-- 对当前选中的任务执行操作，例如 restart、stop、open output。
		{ "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Run: Action" },
		-- 快速重跑最近一次任务，适合反复执行 build/test。
		{ "<leader>rR", restart_last_task, desc = "Run: Restart last" },
		-- 快速停止最近一次任务，适合停止 dev server 或 watch。
		{ "<leader>rq", stop_last_task, desc = "Run: Stop last" },
	},
	opts = {
		-- 任务输出使用 terminal buffer，适合保留颜色和交互式命令输出。
		output = {
			use_terminal = true,
			preserve_output = false,
		},

		task_list = {
			-- 任务列表从底部打开，和底部终端/quickfix 的阅读方向一致。
			direction = "bottom",
			min_height = 8,
			max_height = { 20, 0.3 },
		},

		-- 输入参数和任务输出浮窗统一圆角，和现有 noice/trouble 风格接近。
		form = {
			border = "rounded",
		},
		task_win = {
			border = "rounded",
		},
	},
}
