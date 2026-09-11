-- 提供所有LSP server共用的 capabilities
local M = {}

function M.get()
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	-- blink.cmp 会补充 snippet、completion resolve 等能力，让 server 返回更完整的补全项。
	local ok, blink = pcall(require, "blink.cmp")
	if ok and blink.get_lsp_capabilities then
		capabilities = blink.get_lsp_capabilities(capabilities)
	end

	return capabilities
end

return M
