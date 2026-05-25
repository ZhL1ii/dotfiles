local function telescope_builtin(name, opts)
	return function()
		require("telescope.builtin")[name](opts or {})
	end
end

return {
	"nvim-telescope/telescope.nvim",
	version = "0.1.x",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
	},
	keys = {
		{ "<leader>ff", telescope_builtin("find_files"), desc = "Find: Files" },
		{ "<leader>fg", telescope_builtin("live_grep"), desc = "Find: Grep text" },
		{ "<leader>fb", telescope_builtin("buffers"), desc = "Find: Buffers" },
		{ "<leader>fr", telescope_builtin("oldfiles"), desc = "Find: Recent files" },
		{ "<leader>fh", telescope_builtin("help_tags"), desc = "Find: Help tags" },
		{ "<leader>fc", telescope_builtin("commands"), desc = "Find: Commands" },
		{ "<leader>fd", telescope_builtin("diagnostics"), desc = "Find: Diagnostics" },
		{ "<leader>fs", telescope_builtin("lsp_document_symbols"), desc = "Find: Document symbols" },
		{ "<leader>fS", telescope_builtin("lsp_dynamic_workspace_symbols"), desc = "Find: Workspace symbols" },
	},
	opts = function()
		return {
			defaults = {
				-- 输入框使用更熟悉的顶部布局，结果和预览区域保持清晰分离。
				prompt_prefix = "  ",
				selection_caret = "> ",
				-- 打开面板后先进入 normal 模式，可直接用 j/k 选择结果；按 i/a 再输入搜索词。
				initial_mode = "normal",
				sorting_strategy = "ascending",
				layout_strategy = "horizontal",

				-- 控制 Telescope 弹窗尺寸；预览区占 55%，适合读代码上下文。
				layout_config = {
					width = 0.9,
					height = 0.82,
					prompt_position = "top",
					horizontal = {
						preview_width = 0.55,
					},
				},

				-- 搜索结果中隐藏常见依赖和产物目录，减少无效噪音。
				file_ignore_patterns = {
					"node_modules/",
					"%.git/",
					"dist/",
					"build/",
					"target/",
				},
			},
			pickers = {
				find_files = {
					-- 默认显示隐藏文件，但仍遵守 file_ignore_patterns。
					hidden = true,
				},
				buffers = {
					-- Buffer 列表按最近使用排序，更适合频繁切换文件。
					sort_mru = true,
					ignore_current_buffer = true,
				},
				diagnostics = {
					-- diagnostics 按严重程度排序，错误优先显示。
					severity_sort = true,
				},
			},
			extensions = {
				fzf = {
					-- 使用原生 fzf 排序器提升大项目搜索响应速度。
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		}
	end,
	config = function(_, opts)
		local telescope = require("telescope")

		telescope.setup(opts)

		-- fzf-native 是可选加速扩展；编译失败或未安装时不影响 Telescope 主功能。
		pcall(telescope.load_extension, "fzf")
	end,
}
