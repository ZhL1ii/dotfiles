local M = {}

local function executable_java(home)
	if not home or home == "" then
		return nil
	end

	-- 候选值来自 JDK home；jdtls 需要的是其中的 bin/java 可执行文件。
	local java = vim.fs.joinpath(home, "bin", "java")
	if vim.fn.executable(java) == 1 then
		return java
	end

	return nil
end

local function find_jdtls_java()
	-- 显式环境变量优先，方便在不同机器上按需覆盖 jdtls 的运行时 JDK。
	local env_candidates = {
		vim.env.JDTLS_JAVA_HOME,
		vim.env.JAVA21_HOME,
	}

	for _, home in ipairs(env_candidates) do
		local java = executable_java(home)
		if java then
			return java
		end
	end

	-- SDKMAN 在 Linux/macOS 都可能使用；这里只匹配 21 开头的 JDK，避免拿到 Java 17 的 current。
	local sdkman_java_dir = vim.fs.joinpath(vim.env.HOME or "", ".sdkman", "candidates", "java")
	for _, home in ipairs(vim.fn.glob(vim.fs.joinpath(sdkman_java_dir, "21*"), true, true)) do
		local java = executable_java(home)
		if java then
			return java
		end
	end

	-- Homebrew 的 openjdk@21 在 Apple Silicon 和 Intel Mac 上路径不同。
	local brew_candidates = {
		"/opt/homebrew/opt/openjdk@21",
		"/usr/local/opt/openjdk@21",
	}

	for _, home in ipairs(brew_candidates) do
		local java = executable_java(home)
		if java then
			return java
		end
	end

	-- macOS 原生 JDK 安装位置；放在最后，避免覆盖用户更明确的 SDKMAN/Homebrew 选择。
	for _, home in ipairs(vim.fn.glob("/Library/Java/JavaVirtualMachines/*21*/Contents/Home", true, true)) do
		local java = executable_java(home)
		if java then
			return java
		end
	end

	return nil
end

function M.get()
	local opts = {
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

	local java = find_jdtls_java()
	if java then
		-- 只约束 jdtls 语言服务器的运行时；项目编译版本继续交给 Maven/Gradle/toolchain。
		opts.cmd = {
			"jdtls",
			"--java-executable",
			java,
		}
	end

	return opts
end

return M
