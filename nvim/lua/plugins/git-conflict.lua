return {
	"akinsho/git-conflict.nvim",
	-- 使用插件发布的稳定版本，避免 main 分支变动导致冲突处理快捷键失效。
	version = "*",
	-- 只在真正打开/新建文件时加载；冲突标记也只会出现在普通文件 buffer 里。
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		-- 在包含冲突标记的文件中快速跳转，体验接近 VSCode 的“下一个/上一个冲突”。
		{ "]x", "<cmd>GitConflictNextConflict<cr>", desc = "Git: Next conflict" },
		{ "[x", "<cmd>GitConflictPrevConflict<cr>", desc = "Git: Previous conflict" },

		-- 以下 choose 操作会直接替换当前冲突块，请确认光标所在冲突后再执行。
		-- ours 表示保留当前分支版本，通常是 <<<<<<< HEAD 这一侧。
		{ "<leader>gco", "<cmd>GitConflictChooseOurs<cr>", desc = "Git conflict: Choose ours" },
		-- theirs 表示保留被合入分支版本，通常是 >>>>>>> 分隔符对应的另一侧。
		{ "<leader>gct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Git conflict: Choose theirs" },
		-- both 会保留两边内容并移除冲突标记，适合需要手动再整理的场景。
		{ "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", desc = "Git conflict: Choose both" },
		-- none 会删除冲突两侧内容，只留下冲突块外部文本，适合两边都不要的场景。
		{ "<leader>gc0", "<cmd>GitConflictChooseNone<cr>", desc = "Git conflict: Choose none" },
		-- 把当前文件/仓库中检测到的冲突放进 quickfix，便于批量定位。
		{ "<leader>gcl", "<cmd>GitConflictListQf<cr>", desc = "Git conflict: List conflicts" },
	},
	opts = {
		-- 保留默认命令，如 :GitConflictChooseOurs，方便命令模式处理冲突。
		default_commands = true,
		-- 快捷键在 keys 中显式注册，which-key 能显示完整描述。
		default_mappings = false,
		-- 不关闭 LSP 诊断；冲突期间如果有语法错误，仍然能看到诊断提示。
		disable_diagnostics = false,
		highlights = {
			-- incoming/current 使用内置 Diff 高亮组，自动跟随当前主题配色。
			incoming = "DiffAdd",
			current = "DiffText",
		},
	},
}
