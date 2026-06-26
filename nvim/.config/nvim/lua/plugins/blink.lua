return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},

		opts = {

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = {
					auto_show = true,
				},

				menu = {
					auto_show = true,
					scrollbar = false,
					border = "rounded",

					-- 弹窗内容：显示补全源
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "source_name" },
						},
					},
				},
			},

			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			signature = {
				enabled = true,
				trigger = {
					enabled = false,
				},
				window = {
					max_width = 80,
					max_height = 4,
				},
			},

			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},

			keymap = {
				preset = "none",

				-- 手动打开补全菜单
				["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },
				["<C-p>"] = { "show", "select_prev", "fallback_to_mappings" },

				-- 关闭补全菜单
				["<C-e>"] = { "hide", "fallback" },

				-- Tab 和 Enter 都接受补全
				["<Tab>"] = { "accept", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				-- 上下方向键也保留，方便你切换候选
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },

				-- 文档窗口滚动
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },

				-- snippet 占位跳转
				["<C-j>"] = { "snippet_forward", "fallback" },
				["<C-k>"] = { "snippet_backward", "fallback" },

				-- 手动显示 / 关闭签名提示
				["<C-]>"] = { "show_signature", "hide_signature", "fallback" },
			},
		},

		opts_extend = { "sources.default" },
	},
}
