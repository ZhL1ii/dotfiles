local function set_indent(size, is_expandtab)
	vim.opt_local.tabstop = size
	vim.opt_local.shiftwidth = size
	vim.opt_local.softtabstop = size
	vim.opt_local.expandtab = is_expandtab
end

vim.filetype.add({
	-- gopls 支持 gotmpl；显式注册后 LSP health 不再提示 unknown filetype。
	extension = {
		gotmpl = "gotmpl",
	},
	pattern = {
		[".*%.go%.tmpl"] = "gotmpl",
	},
})

-- alpha/dashboard 等特殊 buffer 会关闭当前窗口的行号；进入普通文件时恢复。
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
	pattern = "*",
	callback = function()
		if vim.bo.buftype == "" then
			vim.wo.number = true
			vim.wo.relativenumber = true
			vim.wo.signcolumn = "yes"
		end
	end,
})

-- 关闭自动续注释
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- 4空格缩进语言
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "objc", "objcpp", "python", "java" },
	callback = function()
		set_indent(4, true)
	end,
})

-- C/C++ 编辑时使用 Vim 自带 cindent，未完成代码块里比 Treesitter indent 更稳定。
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp", "objc", "objcpp" },
	callback = function()
		vim.opt_local.cindent = true
		vim.opt_local.smartindent = false
		vim.opt_local.indentexpr = ""
		vim.opt_local.cinoptions = ":0,l1,t0,g0,(0,u0,W4"
	end,
})

-- 2空格缩进语言
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "javascript", "typescript", "json", "yaml", "markdown" },
	callback = function()
		set_indent(2, true)
	end,
})

-- go语言
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		set_indent(4, false)
	end,
})
