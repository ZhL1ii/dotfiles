return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },

		config = function()
			local lint = require("lint")

			local linter_modules = {
				require("lint.ruff"),
				require("lint.eslint_d"),
				require("lint.shellcheck"),
				require("lint.yamllint"),
				require("lint.checkstyle"),
				require("lint.golangcilint"),
				require("lint.clangtidy"),
			}

			-- 按文件类型指定要调用的 linter。
			-- LSP 负责补全、跳转、重构和部分诊断；这里的 linter 负责运行外部静态检查工具。
			-- 注意：表里的名字是 nvim-lint 内置 linter 的名字，不一定等于 Mason 包名。
			local auto_linters_by_ft = {}
			local manual_linters_by_ft = {}
			local should_lint_by_ft = {}

			local function add_linters(target, linters_by_ft)
				for filetype, names in pairs(linters_by_ft or {}) do
					target[filetype] = target[filetype] or {}
					vim.list_extend(target[filetype], names)
				end
			end

			for _, linter_module in ipairs(linter_modules) do
				if linter_module.register then
					linter_module.register(lint)
				end

				if linter_module.auto == false then
					add_linters(manual_linters_by_ft, linter_module.linters_by_ft)
				else
					add_linters(auto_linters_by_ft, linter_module.linters_by_ft)
				end

				if linter_module.should_lint then
					for filetype in pairs(linter_module.linters_by_ft or {}) do
						should_lint_by_ft[filetype] = linter_module.should_lint
					end
				end
			end

			lint.linters_by_ft = vim.tbl_deep_extend("force", auto_linters_by_ft, manual_linters_by_ft)

			local function linter_cmd(linter)
				if type(linter.cmd) == "function" then
					local ok, cmd = pcall(linter.cmd)
					if ok then
						return cmd
					end
					return nil
				end

				return linter.cmd
			end

			local function available_linters(names)
				return vim.tbl_filter(function(name)
					local linter = lint.linters[name]
					local cmd = linter and linter.cmd and linter_cmd(linter)
					return cmd and vim.fn.executable(cmd) == 1
				end, names)
			end

			local function try_lint(linters_by_ft)
				local names = linters_by_ft[vim.bo.filetype]

				-- 当前 filetype 没有配置 linter 时直接返回，避免无意义调用。
				if not names then
					return
				end

				local should_lint = should_lint_by_ft[vim.bo.filetype]
				if should_lint and not should_lint() then
					return
				end

				-- 只运行当前机器上已经安装的 linter。
				-- 这样打开配置了 linter、但工具还没安装的文件时，不会反复弹错误提示。
				local available = available_linters(names)

				if #available > 0 then
					lint.try_lint(available)
				end
			end

			-- 创建一个自动命令组，避免重复创建
			local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					-- 触发当前 buffer 对应 filetype 的 lint。
					-- BufWritePost：保存后检查最终文件内容。
					-- InsertLeave：离开插入模式后检查，反馈较及时。
					-- BufEnter：切换窗口/文件时刷新诊断。
					try_lint(auto_linters_by_ft)
				end,
			})

			-- 手动触发 lint 的快捷键
			vim.keymap.set("n", "<leader>ll", function()
				try_lint(lint.linters_by_ft)
			end, {
				desc = "Run lint for current file",
			})
		end,
	},
}
