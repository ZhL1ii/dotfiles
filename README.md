# Dotfiles

个人开发环境配置，包含 Neovim、终端、命令行工具，以及 macOS 窗口管理相关配置。

## 安装

```sh
bash ./install.sh
```

脚本会把配置软链接到 `${XDG_CONFIG_HOME:-~/.config}`。
macOS 会额外安装 Aerospace、Karabiner、SketchyBar、skhd 和 yabai 的配置；Linux 只安装通用配置。

## 内容

- 通用：Neovim、Kitty、Ghostty、Yazi、fzf、yamllint、Starship、herdr
- macOS：Aerospace、Karabiner、SketchyBar、skhd、yabai
