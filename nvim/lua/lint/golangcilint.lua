local M = {}

-- gopls 已经会发布诊断，这个重量级 linter 只手动运行，避免编辑时重复提示。
M.auto = false

M.linters_by_ft = {
	go = { "golangcilint" },
}

return M
