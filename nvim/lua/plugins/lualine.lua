return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	opts = {
		options = {
			theme = "auto",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
		},
		-- 当前文件树是 neo-tree，使用对应 extension 让状态栏在侧边栏里显示正确。
		extensions = { "neo-tree" },
		sections = {
			lualine_b = { "branch", "diff" },
			lualine_x = {
				"filesize",
				"encoding",
				"filetype",
			},
		},
	},
}
