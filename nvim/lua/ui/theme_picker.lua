local M = {}

function M.open()
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local theme = require("config.theme")

	require("telescope.builtin").colorscheme({
		enable_preview = true,
		ignore_builtins = true,
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()

				if not selection then
					return
				end

				if not theme.themes[selection.value] then
					vim.notify(("Unsupported persistent theme: %s"):format(selection.value), vim.log.levels.WARN)
					return
				end

				actions.close(prompt_bufnr)
				theme.apply(selection.value, true)
			end)

			return true
		end,
	})
end

return M
