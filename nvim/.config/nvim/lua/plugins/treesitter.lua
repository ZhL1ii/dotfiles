return {
	"nvim-treesitter/nvim-treesitter",

	-- `master` 已冻结且只兼容旧版 Neovim/CLI；新版 `main` 支持 Neovim 0.12 和
	-- tree-sitter-cli 0.26+。
	branch = "main",
	lazy = false,
	build = ":TSUpdate",

	config = function()
		local treesitter = require("nvim-treesitter")
		local ensure_installed = {
			"astro",
			"bash",
			"c",
			"cpp",
			"go",
			"java",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"rust",
			"swift",
			"toml",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}

		-- 新版插件要求 tree-sitter CLI 来编译 parser。缺少时保留已有 parser，
		-- 并给出一次明确提示，而不是每次打开 buffer 都尝试失败。
		if vim.fn.executable("tree-sitter") == 1 then
			treesitter.install(ensure_installed)
		else
			vim.notify("tree-sitter CLI 未安装；跳过 parser 安装", vim.log.levels.WARN)
		end

		local markdown_filetypes = {
			markdown = true,
		}
		local indent_disabled_filetypes = {
			c = true,
			cpp = true,
			markdown = true,
			python = true,
			-- Neovim 将 .sh / Bash 文件识别为 sh；内置 GetShIndent 比 Tree-sitter
			-- 的实验性缩进可靠，尤其是在 if/then、case 等未完成结构中。
			sh = true,
			yaml = true,
		}

		-- Neovim 0.12.2 在 Markdown 的注入查询中可能传入没有 range 的 node，
		-- 因此 Markdown 保持内置高亮；其他语言继续使用 Tree-sitter。
		local get_node_text = vim.treesitter.get_node_text
		vim.treesitter.get_node_text = function(node, source, opts)
			local ok, text = pcall(get_node_text, node, source, opts)
			if ok then
				return text
			end

			if tostring(text):find("attempt to call method 'range' %(a nil value%)", 1, false) then
				return ""
			end

			error(text)
		end

		local treesitter_augroup = vim.api.nvim_create_augroup("nvim-treesitter", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = treesitter_augroup,
			pattern = "*",
			callback = function(args)
				local filetype = vim.bo[args.buf].filetype

				if markdown_filetypes[filetype] then
					pcall(vim.treesitter.stop, args.buf)
					vim.wo[0].foldmethod = "manual"
					vim.wo[0].foldexpr = "0"
					return
				end

				-- 高亮和折叠是 Neovim 内置 Tree-sitter 功能；没有对应 parser 时静默回退。
				-- 只有成功加载 parser 才能使用 Tree-sitter 的 indentexpr。否则该表达式会
				-- 覆盖 autoindent / 内置 ftplugin 缩进，并把新行错误地放回第 0 列。
				local parser_started = pcall(vim.treesitter.start, args.buf)
				vim.wo[0].foldmethod = "expr"
				vim.wo[0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

				-- 新版 nvim-treesitter 仍提供实验性的 Tree-sitter 缩进。
				if parser_started and not indent_disabled_filetypes[filetype] then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- 保留 Tree-sitter 提供的折叠结构，但打开文件时始终展开代码。
		-- Neovim 默认 foldlevel=0；若不关闭 foldenable，所有语法折叠会默认收起。
		vim.opt.foldenable = false
	end,
}
