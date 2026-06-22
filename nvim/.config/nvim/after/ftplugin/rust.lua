local bufnr = vim.api.nvim_get_current_buf()

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, {
		buffer = bufnr,
		silent = true,
		desc = desc,
	})
end

-- rustaceanvim 的 RustLsp command 来自 rust 文件类型插件，能调用 rust-analyzer 的扩展能力。
map("n", "K", function()
	vim.cmd.RustLsp({ "hover", "actions" })
end, "Rust: Hover actions")

-- grouped code action 能展示 rust-analyzer 的分组动作，比普通 LSP code action 更适合 Rust。
map({ "n", "v" }, "<leader>cA", function()
	vim.cmd.RustLsp("codeAction")
end, "Rust: Code action")

-- 展开当前光标附近的宏，排查 derive/proc-macro 生成代码时很有用。
map("n", "<leader>rm", function()
	vim.cmd.RustLsp("expandMacro")
end, "Rust: Expand macro")

-- 重建 proc-macro 缓存；宏依赖更新后诊断异常时可手动刷新。
map("n", "<leader>rp", function()
	vim.cmd.RustLsp("rebuildProcMacros")
end, "Rust: Rebuild proc macros")
