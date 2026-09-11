local M = {}

M.auto = true

M.linters_by_ft = {
	java = { "checkstyle" },
}

-- 你的个人全局 Checkstyle 配置。
-- 普通个人项目没有自己的规则时，就用这个文件兜底。
M.global_config = vim.fn.expand("~/.config/checkstyle/checkstyle.xml")

local function current_file()
	-- 当前 buffer 对应的真实文件路径。
	return vim.api.nvim_buf_get_name(0)
end

local function find_upward(name)
	-- 从当前文件位置开始，向父目录查找指定文件。
	-- 例如从 src/main/java/App.java 往上找 checkstyle.xml / pom.xml / build.gradle。
	return vim.fs.find(name, {
		upward = true,
		path = current_file(),
	})[1]
end

local function file_contains(path, pattern)
	-- 文件不存在或不可读时，认为没有匹配。
	if not path or vim.fn.filereadable(path) ~= 1 then
		return false
	end

	-- 读取文件内容，用 Lua pattern 粗略判断是否启用了 Checkstyle。
	local lines = vim.fn.readfile(path)
	local content = table.concat(lines, "\n")

	return content:find(pattern) ~= nil
end

function M.project_config()
	-- 项目自己的 checkstyle.xml 优先级最高。
	-- 团队项目如果提交了规则文件，就不要用个人全局规则。
	return find_upward("checkstyle.xml")
end

function M.project_uses_build_tool()
	-- Maven：pom.xml 里出现 maven-checkstyle-plugin，认为项目由 Maven 管理 Checkstyle。
	local pom = find_upward("pom.xml")
	if file_contains(pom, "maven%-checkstyle%-plugin") then
		return true
	end

	-- Gradle Groovy DSL：build.gradle 里出现 checkstyle，认为项目由 Gradle 管理 Checkstyle。
	local build_gradle = find_upward("build.gradle")
	if file_contains(build_gradle, "checkstyle") then
		return true
	end

	-- Gradle Kotlin DSL：build.gradle.kts 里出现 checkstyle，认为项目由 Gradle 管理 Checkstyle。
	local build_gradle_kts = find_upward("build.gradle.kts")
	if file_contains(build_gradle_kts, "checkstyle") then
		return true
	end

	return false
end

function M.config_file()
	-- 规则选择顺序：
	-- 1. 项目 checkstyle.xml
	-- 2. 全局 ~/.config/checkstyle/checkstyle.xml
	return M.project_config() or M.global_config
end

function M.should_lint()
	-- 非 Java 文件不需要走 Java Checkstyle 的特殊判断。
	if vim.bo.filetype ~= "java" then
		return true
	end

	-- 项目里有 checkstyle.xml：使用项目规则。
	if M.project_config() then
		return true
	end

	-- 项目构建工具已经管理 Checkstyle，但没有独立 checkstyle.xml：
	-- 这里跳过 nvim-lint 的全局 Checkstyle，避免个人规则污染团队项目。
	if M.project_uses_build_tool() then
		return false
	end

	-- 没有项目规则，也没有构建工具规则：
	-- 只有全局配置存在时才运行 Checkstyle。
	return vim.fn.filereadable(M.global_config) == 1
end

function M.linter()
	return {
		cmd = "checkstyle",
		stdin = false,

		args = function()
			return {
				-- 指定 Checkstyle 规则文件。
				"-c",
				M.config_file(),

				-- 使用 XML 输出，方便 nvim-lint 稳定解析。
				"-f",
				"xml",

				-- 只检查当前 Java 文件。
				current_file(),
			}
		end,

		parser = require("lint.parser").from_pattern(
			[[<error line="(%d+)" column="(%d+)" severity="([^"]+)" message="([^"]+)"]],
			{ "lnum", "col", "severity", "message" },
			{
				source = "checkstyle",
				severity = function(severity)
					if severity == "error" then
						return vim.diagnostic.severity.ERROR
					end

					if severity == "warning" then
						return vim.diagnostic.severity.WARN
					end

					if severity == "info" then
						return vim.diagnostic.severity.INFO
					end

					return vim.diagnostic.severity.HINT
				end,
			}
		),
	}
end

function M.register(lint)
	lint.linters.checkstyle = M.linter()
end

return M
