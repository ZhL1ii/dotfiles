local M = {}

M.themes = {
	["catppuccin-latte"] = {
		name = "Catppuccin Latte",
		background = "light",
	},

	["tokyonight-moon"] = {
		name = "TokyoNight Moon",
		background = "dark",
	},
}

M.default = "catppuccin-latte"

local state_file = vim.fn.stdpath("state") .. "/theme"

local function read()
	local ok, lines = pcall(vim.fn.readfile, state_file, "", 1)

	if not ok or not lines[1] or not M.themes[lines[1]] then
		return M.default
	end

	return lines[1]
end

local function save(name)
	vim.fn.writefile({ name }, state_file)
end

function M.apply(name, persist)
	local theme = M.themes[name]

	if not theme then
		vim.notify(("Unknown colorscheme: %s"):format(name), vim.log.levels.ERROR)
		return
	end

	vim.o.background = theme.background
	vim.cmd.colorscheme(name)

	if persist then
		save(name)
	end
end

function M.load()
	M.apply(read(), false)
end

function M.saved()
	return read()
end

return M
