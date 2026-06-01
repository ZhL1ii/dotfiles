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

local theme_state_file = vim.fn.stdpath("state") .. "/theme"

local function read_saved_theme()
	if not vim.uv.fs_stat(theme_state_file) then
		return "day"
	end

	local ok, lines = pcall(vim.fn.readfile, theme_state_file, "", 1)
	if not ok then
		return "day"
	end
	local name = lines[1]

	if themes[name] then
		return name
	end

	return "day"
end

local function save_theme(name)
	vim.fn.mkdir(vim.fn.fnamemodify(theme_state_file, ":h"), "p")
	vim.fn.writefile({ name }, theme_state_file)
end

local current_theme = read_saved_theme()

local function set_theme(name, persist)
	local theme = themes[name]
	if not theme then
		vim.notify(("Unknown theme: %s"):format(name), vim.log.levels.ERROR)
		return
	end

	if current_theme == name and vim.g.colors_name == theme.colorscheme then
		if persist then
			save_theme(name)
		end
		return
	end

	current_theme = name
	vim.o.background = theme.background
	vim.cmd.colorscheme(theme.colorscheme)
	if persist then
		save_theme(name)
	end
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
				set_theme("day", true)
			end, {})
			vim.api.nvim_create_user_command("ThemeMoon", function()
				set_theme("moon", true)
			end, {})
			vim.api.nvim_create_user_command("ThemeToggle", function()
				set_theme(current_theme == "day" and "moon" or "day", true)
			end, {})
			set_theme(current_theme)
		end,
	},
}
