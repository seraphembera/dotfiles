# Hyprland 配置

当前配置面向 Hyprland 0.55 及以上版本，主配置文件为
`config/hyprland.lua`。`config/hyprland.conf` 仅保留旧版 hyprlang
配置和 Pivot 兼容记录，不再作为 Hyprland 0.55+ 的入口。

## 依赖

```bash
paru -S --needed hyprland-git hyprpaper kitty thunar rofi-wayland \
  waybar fcitx5 playerctl pipewire wireplumber
```

本机当前使用 `hyprland-git 0.56.0`。Lua 配置依赖 Hyprland 0.55+
提供的配置接口；使用较旧的稳定版软件包时，请先确认其是否支持
`hyprland.lua`。

## 安装

在仓库根目录执行：

```bash
./modules/hyprland/install.sh ~/.config/hypr
```

安装脚本会把 `modules/hyprland/config` 链接到
`~/.config/hypr`。若已经使用本仓库的链接，重复执行即可更新。

启动 Hyprland 前可以单独校验配置：

```bash
hyprland --verify-config -c ~/.config/hypr/hyprland.lua
```

在已运行的 Hyprland 会话中重新加载：

```bash
hyprctl reload
```

## 当前行为

- 默认终端：Kitty
- 默认文件管理器：Thunar
- 程序启动器：Rofi
- 自动启动：Hyprpaper、Waybar、Fcitx 5
- 窗口布局：Dwindle
- 三指水平滑动：切换工作区
- Pivot：若 `~/.config/pivot/hyprland.conf` 存在，读取其中的
  `env = NAME,VALUE` 环境变量；文件不存在时直接跳过

## 快捷键

| 快捷键 | 操作 |
| --- | --- |
| `Alt + Enter` | 打开终端 |
| `Alt + E` | 打开文件管理器 |
| `Alt + Space` | 打开或关闭 Rofi |
| `Alt + Shift + Q` | 关闭当前窗口 |
| `Alt + Shift + R` | 重新加载 Hyprland |
| `Alt + M` | 退出 Hyprland |
| `Alt + V` | 切换窗口浮动状态 |
| `Alt + H/J/K/L` | 向左/下/上/右移动焦点 |
| `Alt + Shift + H/J/K/L` | 调整当前窗口大小 |
| `Alt + 0-9` | 切换工作区 |
| `Alt + Shift + 0-9` | 移动窗口到工作区 |
| `Alt + S` | 切换特殊工作区 `magic` |
| `Alt + Shift + S` | 移动窗口到特殊工作区 `magic` |
| `Alt + 鼠标左键拖动` | 移动窗口 |
| `Alt + 鼠标右键拖动` | 调整窗口大小 |

音量键优先使用 `wpctl`，并在不可用时回退到 `pactl`；媒体键由
`playerctl` 处理。当前未配置亮度键，因为系统没有安装
`brightnessctl`。
