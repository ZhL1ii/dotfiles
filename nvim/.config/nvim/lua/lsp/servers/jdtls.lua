local M = {}

function M.get()
	return {
		-- jdtls 通过 root_dir 判断项目根目录。
		-- Java 项目常见根标志包括 Maven、Gradle、Git。
		root_markers = {
			"pom.xml",
			"build.gradle",
			"build.gradle.kts",
			"settings.gradle",
			"settings.gradle.kts",
			".git",
		},

		settings = {
			java = {
				-- Java 代码自动补全 import 后，按常见规范整理 import 顺序
				completion = {
					importOrder = {
						"java",
						"javax",
						"com",
						"org",
					},
				},

				-- 保存/执行 code action 时可以清理 import
				sources = {
					organizeImports = {
						starThreshold = 9999,
						staticStarThreshold = 9999,
					},
				},

				-- 开启一些常用 code lens
				referencesCodeLens = {
					enabled = true,
				},

				implementationsCodeLens = {
					enabled = true,
				},

				-- Maven/Gradle 项目导入相关配置
				configuration = {
					updateBuildConfiguration = "interactive",
				},

				-- 让 jdtls 提供更完整的语义高亮能力
				signatureHelp = {
					enabled = true,
				},

				-- 编译器诊断级别
				-- generatedSources：忽略 generated source 里的诊断，避免第三方生成代码干扰
				errors = {
					incompleteClasspath = {
						severity = "warning",
					},
				},
			},
		},

		-- Java 文件常用命令。
		-- 这些命令来自 jdtls/lsp 的 code action；不额外依赖 nvim-jdtls。
		commands = {
			JavaOrganizeImports = {
				function()
					vim.lsp.buf.code_action({
						context = {
							only = { "source.organizeImports" },
							diagnostics = {},
						},
						apply = true,
					})
				end,
				description = "Java: Organize imports",
			},
		},
	}
end

return M
