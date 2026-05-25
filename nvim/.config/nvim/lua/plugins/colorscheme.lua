local themes = {
	day = {
		colorscheme = "catppuccin-latte",
		background = "light",
	},
	moon = {
		colorscheme = "tokyonight-moon",
		background = "dark",
	},
}

local current_theme = "day"

local function set_theme(name)
	local theme = themes[name]
	if not theme then
		vim.notify(("Unknown theme: %s"):format(name), vim.log.levels.ERROR)
		return
	end

	if current_theme == name and vim.g.colors_name == theme.colorscheme then
		return
	end

	current_theme = name
	vim.o.background = theme.background
	vim.cmd.colorscheme(theme.colorscheme)
end

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			background = {
				light = "latte",
				dark = "mocha",
			},
			transparent_background = not vim.g.neovide,
		},
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			transparent = not vim.g.neovide,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
				terminal_colors = true,
			},
		},
		config = function(_, opts)
			-- 主题只在这里初始化，避免 Neovide 或其他入口重复 setup。
			require("catppuccin").setup({
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = not vim.g.neovide,
			})
			require("tokyonight").setup(opts)
			vim.api.nvim_create_user_command("ThemeDay", function()
				set_theme("day")
			end, {})
			vim.api.nvim_create_user_command("ThemeMoon", function()
				set_theme("moon")
			end, {})
			vim.api.nvim_create_user_command("ThemeToggle", function()
				set_theme(current_theme == "day" and "moon" or "day")
			end, {})
			set_theme(current_theme)
		end,
	},
}
