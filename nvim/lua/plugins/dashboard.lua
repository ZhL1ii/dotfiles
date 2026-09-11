local function dashboard_find_file()
	-- 使用 vim.ui.input 保持和 noice 等 UI 插件的输入体验一致。
	vim.ui.input({ prompt = "Find file: ", completion = "file" }, function(input)
		if not input or input == "" then
			return
		end

		vim.cmd("edit " .. vim.fn.fnameescape(input))
	end)
end

local function dashboard_find_text()
	vim.ui.input({ prompt = "Find text: " }, function(input)
		if not input or input == "" then
			return
		end

		local ok, builtin = pcall(require, "telescope.builtin")
		if ok then
			-- Telescope 可用时优先走 live_grep，避免 vimgrep 在大项目里阻塞太久。
			builtin.live_grep({ default_text = input })
			return
		end

		-- Telescope 未加载或不可用时，回退到 Neovim 原生 quickfix 搜索。
		vim.cmd("vimgrep /" .. vim.fn.escape(input, "/\\") .. "/gj **/*")
		vim.cmd("copen")
	end)
end

local function get_hl_color(name, attr)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	if not ok or not hl or not hl[attr] then
		return nil
	end

	return string.format("#%06x", hl[attr])
end

local function set_dashboard_highlights()
	local accent = get_hl_color("Directory", "fg") or "#2e7de9"
	local button = get_hl_color("Function", "fg") or accent
	local footer = get_hl_color("Comment", "fg") or accent
	local shortcut = get_hl_color("DiagnosticWarn", "fg") or "#8c6c3e"

	vim.api.nvim_set_hl(0, "DashboardHeader", { fg = accent })
	vim.api.nvim_set_hl(0, "DashboardAccent", { fg = button })
	vim.api.nvim_set_hl(0, "DashboardButton", { fg = button })
	vim.api.nvim_set_hl(0, "DashboardFooter", { fg = footer })
	vim.api.nvim_set_hl(0, "DashboardShortcut", { fg = shortcut, bold = true })
end

-- 提前注册命令，保证 dashboard 按钮在 alpha 懒加载前后都能调用。
vim.api.nvim_create_user_command("DashboardFindFile", dashboard_find_file, {})
vim.api.nvim_create_user_command("DashboardFindText", dashboard_find_text, {})

return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = function()
		local dashboard = require("alpha.themes.dashboard")

		set_dashboard_highlights()

		local function button(shortcut, icon, label, command)
			local item = dashboard.button(shortcut, icon .. "  " .. label, command)
			item.opts.hl = "DashboardButton"
			item.opts.hl_shortcut = "DashboardShortcut"
			item.opts.align_shortcut = "right"
			item.opts.width = 52

			return item
		end

		dashboard.section.header.val = {
			"██╗   ██╗██╗███╗   ███╗ ██████╗██████╗  █████╗ ███████╗████████╗",
			"██║   ██║██║████╗ ████║██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝",
			"██║   ██║██║██╔████╔██║██║     ██████╔╝███████║█████╗     ██║   ",
			"╚██╗ ██╔╝██║██║╚██╔╝██║██║     ██╔══██╗██╔══██║██╔══╝     ██║   ",
			" ╚████╔╝ ██║██║ ╚═╝ ██║╚██████╗██║  ██║██║  ██║██║        ██║   ",
			"  ╚═══╝  ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ",
		}
		dashboard.section.header.opts = {
			hl = "DashboardHeader",
			position = "center",
		}

		dashboard.section.buttons.val = {
			button("f", "󰈞", "Find file", "<cmd>DashboardFindFile<cr>"),
			button("n", "󰈔", "New file", "<cmd>ene | startinsert<cr>"),
			button("r", "󰋚", "Recent files", "<cmd>Telescope oldfiles<cr>"),
			button("g", "󰱽", "Find text", "<cmd>DashboardFindText<cr>"),
			button("c", "", "Config", "<cmd>edit $MYVIMRC<cr>"),
			button(
				"m",
				"󰏖",
				"Tools",
				"<cmd>lua require('lazy').load({ plugins = { 'mason.nvim' } }); vim.cmd('Mason')<cr>"
			),
			button("l", "󰒲", "Lazy", "<cmd>Lazy<cr>"),
			button("q", "󰩈", "Quit", "<cmd>qa<cr>"),
		}

		local stats = require("lazy").stats()
		local loaded = stats.loaded or 0
		local ms = math.floor((stats.startuptime or 0) * 100 + 0.5) / 100

		-- footer 只展示当前启动统计，不参与插件加载逻辑。
		dashboard.section.footer.val = "  Neovim loaded " .. loaded .. " plugins in " .. ms .. "ms"
		dashboard.section.footer.opts = {
			hl = "DashboardFooter",
			position = "center",
		}

		dashboard.config.layout = {
			{ type = "padding", val = 8 },
			dashboard.section.header,
			{ type = "padding", val = 4 },
			dashboard.section.buttons,
			{ type = "padding", val = 1 },
			dashboard.section.footer,
		}

		return dashboard
	end,
	config = function(_, dashboard)
		require("alpha").setup(dashboard.config)

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("DashboardColors", { clear = true }),
			callback = set_dashboard_highlights,
		})

		local dashboard_group = vim.api.nvim_create_augroup("DashboardTabline", { clear = true })
		local previous_showtabline

		-- dashboard 页面隐藏 bufferline，离开后恢复用户原来的 tabline 设置。
		vim.api.nvim_create_autocmd("FileType", {
			group = dashboard_group,
			pattern = "alpha",
			callback = function()
				previous_showtabline = vim.opt.showtabline:get()
				vim.opt.showtabline = 0
			end,
		})

		vim.api.nvim_create_autocmd("BufUnload", {
			group = dashboard_group,
			callback = function(event)
				if vim.bo[event.buf].filetype == "alpha" and previous_showtabline ~= nil then
					vim.opt.showtabline = previous_showtabline
					previous_showtabline = nil
				end
			end,
		})
	end,
}
