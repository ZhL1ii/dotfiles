local xcode_project = require("utils.xcode_project")

local function run_xcodebuild(command)
	-- Setup 和 Picker 会启动异步回调；保持项目根 cwd，后续 build-server 写入才不会回到启动目录。
	xcode_project.ensure_cwd()
	vim.cmd(command)
end

return {
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim",
		},
		init = function()
			local group = vim.api.nvim_create_augroup("xcode-project-cwd", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				group = group,
				callback = function(args)
					xcode_project.ensure_cwd(args.buf)
				end,
			})
		end,
		cmd = {
			"XcodebuildSetup",
			"XcodebuildPicker",
			"XcodebuildBuild",
			"XcodebuildCleanBuild",
			"XcodebuildBuildRun",
			"XcodebuildCancel",
			"XcodebuildToggleLogs",
			"XcodebuildShowConfig",
		},
		keys = {
			{ "<leader>Xa", function() run_xcodebuild("XcodebuildPicker") end, desc = "Xcode: Actions" },
			{ "<leader>Xb", function() run_xcodebuild("XcodebuildBuild") end, desc = "Xcode: Build" },
			{ "<leader>XB", function() run_xcodebuild("XcodebuildCleanBuild") end, desc = "Xcode: Clean Build" },
			{ "<leader>Xr", function() run_xcodebuild("XcodebuildBuildRun") end, desc = "Xcode: Build and Run" },
			{ "<leader>Xc", function() run_xcodebuild("XcodebuildCancel") end, desc = "Xcode: Cancel" },
			{ "<leader>Xl", function() run_xcodebuild("XcodebuildToggleLogs") end, desc = "Xcode: Toggle Logs" },
			{ "<leader>Xs", function() run_xcodebuild("XcodebuildSetup") end, desc = "Xcode: Project Setup" },
			{ "<leader>Xi", function() run_xcodebuild("XcodebuildShowConfig") end, desc = "Xcode: Show Project Settings" },
		},
		opts = {
			-- 每个 Xcode 项目的状态都放在 Neovim 数据目录，不在仓库创建 .nvim/xcodebuild。
			project_config = {
				store_in_project_dir = false,
				-- 切换项目根时重新读取该项目保存的 scheme、destination 和构建状态。
				reload_on_cwd_change = true,
			},

			logs = {
				logs_formatter = "xcbeautify --disable-colored-output --disable-logging",
				auto_open_on_success_build = false,
				auto_open_on_failed_build = false,
				auto_focus = false,
			},

			quickfix = {
				show_errors_on_quickfixlist = true,
				show_warnings_on_quickfixlist = true,
			},

			-- SourceKit-LSP 的 Xcode 编译图只由 xcode-build-server 维护。
			integrations = {
				pymobiledevice = { enabled = false },
				xcode_build_server = {
					enabled = true,
					guess_scheme = false,
				},
				nvim_tree = { enabled = false },
				neo_tree = { enabled = false },
				oil_nvim = { enabled = false },
				quick = { enabled = false },
				codelldb = { enabled = false },
			},

			-- CielBar 目前没有测试 target；首期不启用测试视图或 Preview / DAP 工作流。
			console_logs = { enabled = false },
			test_explorer = { enabled = false },
		},
	},
}
