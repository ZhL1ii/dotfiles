return {
	"kawre/leetcode.nvim",
	cmd = "Leet",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},

	opts = {
		lang = "golang",

		cn = {
			enabled = true,
			translator = true,
			translate_problems = true,
		},
	},
}
