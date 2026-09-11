local M = {}

function M.get()
	return {
		root_markers = {
			"package.json",
			"tsconfig.json",
			"jsconfig.json",
			".git",
		},
	}
end

return M
