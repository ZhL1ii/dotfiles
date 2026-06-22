local M = {}

function M.get()
	return {
		-- TOML 项目优先识别 Taplo 配置，其次识别 Cargo 项目和普通 git 项目。
		root_markers = {
			"taplo.toml",
			".taplo.toml",
			"Cargo.toml",
			".git",
		},
	}
end

return M
