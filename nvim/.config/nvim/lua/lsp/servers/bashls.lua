local M = {}

function M.get()
	return {
		-- 与 bash-language-server 的默认文件匹配范围保持一致，让 .bash、.inc、
		-- .command 等项目内脚本也能参与工作区分析。
		settings = {
			bashIde = {
				globPattern = "*@(.sh|.inc|.bash|.command)",
			},
		},
	}
end

return M
