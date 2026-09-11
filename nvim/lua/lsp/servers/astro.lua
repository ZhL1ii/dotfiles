local M = {}

function M.get()
	return {
		root_markers = {
			"package.json",
			"tsconfig.json",
			"jsconfig.json",
			"astro.config.mjs",
			"astro.config.js",
			"astro.config.cjs",
			"astro.config.ts",
			".git",
		},
	}
end

return M
