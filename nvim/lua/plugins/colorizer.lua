return {
	"catgoose/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },

	opts = {
		filetypes = {
			"css",
			"scss",
			"sass",
			"less",
			"html",
			"astro",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},

		options = {
			parsers = {
				-- 同时启用 HEX、RGB、HSL、OKLCH、CSS 变量等
				css = true,

				-- 避免普通单词 blue、red 等也被着色
				names = {
					enable = false,
				},
			},

			display = {
				-- 在颜色编码前显示一个对应颜色的方块
				mode = "virtualtext",

				virtualtext = {
					char = "■",
					position = "before",
					hl_mode = "foreground",
				},
			},
		},
	},
}
