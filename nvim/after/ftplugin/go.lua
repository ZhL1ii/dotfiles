for _, lhs in ipairs({ "[[", "[]", "]]", "][" }) do
	pcall(vim.keymap.del, "s", lhs, { buffer = true })
end
