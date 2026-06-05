# AGENTS.md

这是一份个人 dotfiles 仓库的维护说明。修改时以“稳定、可回滚、不破坏日常环境”为最高优先级；不要把它当成通用模板仓库来重构。

## 项目定位

- 本仓库按应用保存 `$HOME/.config` 下的配置目录，主要内容是 Neovim、Starship、tmux、Yazi 和 AeroSpace。
- 这些配置直接影响作者的日常开发环境。任何变更都应小而明确，优先保持现有键位、主题、启动性能和跨终端行为。
- 不要引入自动安装脚本、全局 bootstrap 脚本或大范围 dotfiles 管理框架，除非用户明确要求。

## 目录职责

- `nvim/.config/nvim/`：Neovim 配置主体，使用 Lua 和 lazy.nvim。
- `starship/.config/starship/`：Starship prompt 配置。`starship.toml` 是当前主配置，`day.toml` 和 `moon.toml` 是主题变体。
- `tmux/.config/tmux/tmux.conf`：tmux 配置，使用 TPM 插件管理。
- `yazi/.config/yazi/`：Yazi 文件管理器配置，包括主配置、键位和主题。
- `aerospace/.config/aerospace/aerospace/`：AeroSpace 窗口管理配置，包含本机显示器名、SketchyBar 和 JankyBorders 集成。
- `karabiner/`：当前为空目录，除非用户要求，不要主动填充。

## Neovim 维护规则

- `init.lua` 只负责加载入口模块，避免把具体配置塞进根入口。
- `lua/config/` 放基础行为：启动 lazy.nvim、全局键位、编辑选项、autocmd、Neovide。
- `lua/plugins/` 只放 lazy.nvim 插件声明。新增插件时优先创建独立文件，保持一个文件负责一个功能域。
- `lua/lsp/` 放 LSP 统一入口、公共 capabilities、on_attach 和各语言 server 配置。
- `lua/lint/` 放 nvim-lint 的语言 linter 模块。新增 linter 时沿用当前模块接口：
  - `M.linters_by_ft`
  - 可选 `M.auto = false`
  - 可选 `M.should_lint()`
  - 可选 `M.register(lint)`
- `lazy-lock.json` 是插件锁文件。只有实际执行插件更新、安装或 lazy.nvim 写入锁文件后，才修改它。
- 保持 LSP、formatter、linter 的职责分离：LSP 负责补全/跳转/重构/部分诊断；Conform 负责格式化；nvim-lint 负责外部静态检查。
- 避免让重量级 linter 自动频繁运行。当前 Go 的 `golangci-lint` 和 C/C++ 的 `clangtidy` 是手动 lint，除非用户明确要求，不要改成自动。
- Neovim 版本按当前环境理解为 0.12 系列。使用新 API 前确认兼容性，尤其是 `vim.lsp.config`、`vim.lsp.enable`、Treesitter 和 Markdown 相关逻辑。

## 样式与格式化

- Lua 文件使用 Stylua 配置：`nvim/.config/nvim/.stylua.toml`。
  - `indent_type = "Tabs"`
  - `indent_width = 2`
  - Unix line endings
  - 双引号优先
- 不要手动把 Lua 文件改成空格缩进；格式化后应服从 Stylua。
- TOML 文件保持现有缩进和分组风格。Yazi 配置中已有 schema 注释，修改时保留。
- Shell/tmux 配置保持简洁注释和分区结构。
- 可以保留中文注释；本仓库已有大量中文说明。新增注释应解释意图，不要重复代码含义。

## 注释编写规范

- 注释优先解释“为什么这样做”和“这段逻辑服务什么场景”，不要只复述语法或变量名。
- 脚本类配置（Lua、Shell 等）的注释应贴近相关语句或逻辑片段；不要只在函数顶部写一大段说明，而让内部复杂逻辑缺少上下文。
- 函数顶部可以用一到两行说明职责和整体意图；函数内部遇到关键局部变量、循环、条件分支、回调、fallback 链条时，应在相邻位置补充短注释。
- 对长 `or` 链、优先级匹配、逐级查找、平台差异、工具缺失兜底等逻辑，优先拆成有语义的局部变量，并给每一步写一句说明其顺序或目的。
- 遍历目录、扫描配置、注册快捷键、绑定 autocmd、调用外部工具等操作，应说明触发条件、匹配对象或副作用。例如目录遍历要说明在匹配什么，fallback 要说明为什么放在最后。
- 注释不需要覆盖每一行简单赋值；对显而易见的选项值、普通表结构和重复模式，保持简洁。
- 文本类配置（TOML、YAML 等）的注释以配置块用途、作用范围、约束条件为主，不必逐行解释字段。
- 新增示例代码时，示例应符合本仓库风格；Lua 示例使用 tab 缩进，避免引入与当前配置无关的大段伪代码。

## 推荐验证命令

根据修改范围选择最小必要检查：

```sh
nvim --headless -u nvim/.config/nvim/init.lua +qa
```

```sh
starship explain --config starship/.config/starship/starship.toml
```

```sh
tmux -f tmux/.config/tmux/tmux.conf start-server \; source-file tmux/.config/tmux/tmux.conf \; kill-server
```

```sh
yazi --debug
```

```sh
aerospace --config-path aerospace/.config/aerospace/aerospace/aerospace.toml list-workspaces --all
```

说明：

- 如果某个命令会启动长期进程、打开 UI 或依赖本机服务，只做语法/配置加载层面的验证。
- 如果工具不存在，明确说明未验证，不要用未安装的替代工具伪造结论。
- 不要为了验证而联网安装依赖，除非用户明确同意。

## 个人化配置保护

- AeroSpace 的显示器名、workspace 集合、app-id、SketchyBar trigger、JankyBorders 命令都属于个人环境绑定配置。修改前先确认是否与用户目标直接相关。
- tmux 的 prefix、Vim 方向键导航、Yazi passthrough、OSC 52 剪贴板、Neovide 字体和缩放键位都是日常体验配置，不要随意重排。
- Starship prompt 使用 Nerd Font 图标和 powerline 分隔符；不要为了“通用兼容性”主动替换成纯 ASCII。
- `.gitignore` 当前只排除本机生成物和日志。新增忽略规则时应针对具体生成目录，不要加入过宽规则导致真实配置被漏提交。

## 变更原则

- 先读相关配置，再改文件。不要凭插件默认配置猜测当前行为。
- 小改动优先：能改一个模块就不要重排整个目录。
- 避免无关升级：不要顺手更新插件锁、主题、键位或 schema。
- 新增插件前确认：
  - 是否已有插件能完成同类功能。
  - 是否会增加启动期加载成本。
  - 是否需要 Mason、外部 CLI 或系统服务配合。
  - 是否需要在 `which-key` 中补充分组或描述。
- 新增快捷键时避免覆盖现有 `<leader>` 分组。当前常用分组包括 `b/c/d/e/f/g/l/q/r/t/x/m`。
- 新增语言支持时同步考虑四处配置：Treesitter parser、Mason 安装项、LSP server、formatter/linter。
- 对团队项目可能有自己规则的工具，优先尊重项目本地配置。例如当前 `clang_format` 和 `checkstyle` 都有“项目配置优先，个人全局配置兜底”的逻辑。

## 提交前检查清单

- `git status --short` 确认只包含本次相关文件；不要回滚用户已有改动。
- 涉及 Lua 时，运行 Stylua 或至少确认缩进符合 `.stylua.toml`。
- 涉及 Neovim 启动链路时，运行 headless 启动检查。
- 涉及 Starship/tmux/Yazi/AeroSpace 时，运行对应工具的最小加载检查。
- 若修改了插件声明，确认 `lazy-lock.json` 是否应随变更一起更新。
- 若新增本机生成目录或日志，更新 `.gitignore`，不要提交缓存、插件安装目录或运行日志。
