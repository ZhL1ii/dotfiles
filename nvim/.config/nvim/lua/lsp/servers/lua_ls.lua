local M = {}

function M.get()
	return {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},

				diagnostics = {
					globals = { "vim" },
				},

				workspace = {
					checkThirdParty = false,
				},

				completion = {
					callSnippet = "Replace",
				},

				telemetry = {
					enable = false,
				},
			},
		},
	}
end

return M
