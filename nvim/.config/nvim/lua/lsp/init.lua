local M = {}

local function setup_diagnostics()
	vim.diagnostic.config({
		-- 插入模式不实时刷新
		update_in_insert = false,

		-- 同一行多个诊断时,按严重程度排序
		severity_sort = true,

		-- 保留下划线
		underline = true,

		-- virtual text开启
		virtual_text = {
			spacing = 4,
			source = "if_many",
			prefix = "●",
		},

		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅚",
				[vim.diagnostic.severity.WARN] = "󰀪",
				[vim.diagnostic.severity.INFO] = "󰋽",
				[vim.diagnostic.severity.HINT] = "󰌶",
			},
		},

		-- float window 统一样式
		float = {
			border = "rounded",
			source = "if_many",
			header = "",
			prefix = "",
			focusable = false,
			severity_sort = true,
		},
	})
end

function M.setup()
	-- 启动诊断显示
	setup_diagnostics()

	-- 所有LSP公共配置
	local common_opts = {
		capabilities = require("lsp.capabilities").get(),
		on_attach = require("lsp.on_attach").get(),
	}

	-- 需要启用的LSP列表
	local servers = {
		lua_ls = "lsp.servers.lua_ls",
		pyright = "lsp.servers.pyright",
		ts_ls = "lsp.servers.ts_ls",
		clangd = "lsp.servers.clangd",
		gopls = "lsp.servers.gopls",
		jdtls = "lsp.servers.jdtls",
		sourcekit = "lsp.servers.sourcekit",
		taplo = "lsp.servers.taplo",
	}

	for server_name, module_name in pairs(servers) do
		-- 每个server自己的配置
		local server_opts = require(module_name).get()

		--合并公共配置和语言专属配置
		local opts = vim.tbl_deep_extend("force", common_opts, server_opts)

		-- 注册 server
		vim.lsp.config(server_name, opts)

		-- 启用server
		vim.lsp.enable(server_name)
	end
end

return M
