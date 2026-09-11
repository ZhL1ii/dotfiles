return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local npairs = require("nvim-autopairs")

		npairs.setup({})

		local function snippet_active()
			return vim.snippet and vim.snippet.active()
		end

		local function termcodes(keys)
			return vim.api.nvim_replace_termcodes(keys, true, false, true)
		end

		local function install_snippet_bracket_map(bufnr)
			vim.keymap.set("i", "[", function()
				if snippet_active() then
					return termcodes("[]<Left>")
				end

				return npairs.autopairs_map(bufnr, "[")
			end, {
				buffer = bufnr,
				desc = "Autopairs: Open bracket",
				expr = true,
				replace_keycodes = false,
			})
		end

		install_snippet_bracket_map(vim.api.nvim_get_current_buf())

		vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
			group = vim.api.nvim_create_augroup("SnippetBracketAutopairs", { clear = true }),
			callback = function(event)
				install_snippet_bracket_map(event.buf)
			end,
		})
	end,
}
