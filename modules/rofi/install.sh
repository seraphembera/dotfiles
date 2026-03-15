#!/bin/bash

# ============================================
# Arch Linux Dotfiles 安装脚本 (路径参数版)
# 用法: ./install.sh [选项] <目标路径>
# 示例: ./install.sh ~/.config/zsh/
#       ./install.sh -y ~/.config/hypr/
#       ./install.sh -u ~/.config/waybar/
# ============================================

set -euo pipefail

# 颜色定义 (Arch 风格)
readonly R='\033[0m'
readonly B='\033[1;34m'
readonly C='\033[1;36m'
readonly G='\033[1;32m'
readonly Y='\033[1;33m'
readonly RED='\033[1;31m'

info()  { echo -e "${B}[*]${R} $1"; }
ok()    { echo -e "${G}[✓]${R} $1"; }
warn()  { echo -e "${Y}[!]${R} $1"; }
err()   { echo -e "${RED}[✗]${R} $1"; }

section() {
    echo ""
    echo -e "${C}:: $1${R}"
    echo ""
}

# 使用帮助
show_help() {
    cat << EOF
Arch Linux Dotfiles 安装脚本

${B}用法:${R}
    $0 [选项] <目标路径>

${B}参数:${R}
    <目标路径>          配置的目标位置 (如 ~/.config/zsh, ~/.config/hypr)
                        脚本会将当前目录的 ./config/ 链接到该路径

${B}选项:${R}
    -h, --help          显示此帮助信息
    -y, --yes           自动确认所有操作 (非交互模式)
    -u, --uninstall     卸载/移除指定路径的配置链接
    -d, --dry-run       模拟运行，不实际执行操作

${B}示例:${R}
    $0 ~/.config/zsh/          安装 zsh 配置到 ~/.config/zsh/
    $0 -y ~/.config/hypr/      自动安装 hypr 配置 (不询问)
    $0 -u ~/.config/waybar/    卸载 waybar 配置
    $0 -d ~/.config/nvim/      预览将要创建的链接

${B}说明:${R}
    源目录: 脚本所在目录的 ./config/ 文件夹
    目标: 你指定的路径 (通常位于 ~/.config/<应用名>/)
EOF
}

# 变量初始化
TARGET_PATH=""
AUTO_YES=false
UNINSTALL=false
DRY_RUN=false

# 路径规范化 (展开 ~ 并转为绝对路径)
normalize_path() {
    local path="$1"
    # 展开 ~
    path="${path/#\~/$HOME}"
    # 去除末尾的 / (保留根目录 / 的情况)
    [[ "$path" != "/" ]] && path="${path%/}"
    # 转为绝对路径
    if [[ "$path" != /* ]]; then
        path="$(pwd)/$path"
    fi
    echo "$path"
}

# 参数解析
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -y|--yes)
                AUTO_YES=true
                shift
                ;;
            -u|--uninstall)
                UNINSTALL=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -*)
                err "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                if [ -n "$TARGET_PATH" ]; then
                    err "只能指定一个目标路径"
                    exit 1
                fi
                TARGET_PATH="$1"
                shift
                ;;
        esac
    done

    # 验证目标路径
    if [ -z "$TARGET_PATH" ]; then
        err "缺少目标路径参数"
        info "用法: $0 <目标路径>  (例如: $0 ~/.config/zsh/)"
        exit 1
    fi

    # 规范化路径
    TARGET_PATH=$(normalize_path "$TARGET_PATH")
    
    # 安全检查：防止路径遍历到系统关键目录
    if [[ "$TARGET_PATH" == "/" ]] || [[ "$TARGET_PATH" == "/home" ]] || [[ "$TARGET_PATH" == "$HOME" ]]; then
        err "危险操作：禁止直接安装到系统根目录或家目录"
        exit 1
    fi
}

# 检查 stow
ensure_stow() {
    if command -v stow &>/dev/null; then
        return 0
    fi
    
    warn "Stow 未安装"
    if ! sudo -n true 2>/dev/null; then
        info "需要 sudo 权限安装 stow"
        sudo -v || { err "获取权限失败"; exit 1; }
    fi
    
    info "正在安装 stow..."
    sudo pacman -S --noconfirm --needed stow || {
        err "安装失败"
        exit 1
    }
    ok "Stow 已安装"
}

# 检查源目录
check_source() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source_dir="$script_dir/config"
    
    if [ ! -d "$source_dir" ]; then
        err "未找到源目录: ./config/"
        err "请确保目录结构为:"
        echo -e "    ${C}.${R}"
        echo -e "    ${C}├── config/${R}          ← 配置文件放在这里"
        echo -e "    ${C}│   ├── config${R}"
        echo -e "    ${C}│   └── style.css${R}"
        echo -e "    ${C}└── install.sh${R}"
        exit 1
    fi
    
    if [ -z "$(ls -A "$source_dir" 2>/dev/null)" ]; then
        err "源目录 ./config/ 为空"
        exit 1
    fi
    
    echo "$source_dir"
}

# 安装逻辑
do_install() {
    local source_dir="$1"
    local target="$TARGET_PATH"
    local parent_dir=$(dirname "$target")
    
    section "部署配置"
    info "源目录:   ${C}$source_dir${R}"
    info "目标路径: ${C}$target${R}"
    
    # 确保父目录存在
    if [ ! -d "$parent_dir" ]; then
        info "创建父目录: $parent_dir"
        mkdir -p "$parent_dir"
    fi
    
    # 检查目标状态
    if [ -e "$target" ]; then
        if [ -L "$target" ]; then
            # 是符号链接
            local current=$(readlink -f "$target" 2>/dev/null || readlink "$target")
            if [ "$current" = "$source_dir" ]; then
                info "目标已是本仓库的符号链接，执行更新..."
            else
                warn "目标已是符号链接，但指向其他位置:"
                echo -e "    当前: ${Y}$current${R}"
                echo -e "    期望: ${G}$source_dir${R}"
                if [ "$AUTO_YES" = false ]; then
                    read -p "$(echo -e "${Y}[!]${R} 是否强制替换? [y/N]: ")" confirm
                    [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
                else
                    info "自动模式: 强制替换"
                fi
                rm "$target"
                # 创建临时目录用于 stow
                mkdir -p "$target"
            fi
        elif [ -d "$target" ]; then
            # 是实体目录 - 检查是否为空或包含文件
            local file_count=$(find "$target" -maxdepth 1 -type f | wc -l)
            local dir_count=$(find "$target" -maxdepth 1 -type d | wc -l)
            # 减去 . 和 ..
            dir_count=$((dir_count - 2))
            
            if [ "$file_count" -eq 0 ] && [ "$dir_count" -eq 0 ]; then
                info "目标为空目录，直接用于安装"
            else
                warn "目标目录已存在且包含 ${file_count} 个文件和 ${dir_count} 个子目录"
                ls -la "$target" | head -n 6 | sed 's/^/    /'
                [ $((file_count + dir_count)) -gt 3 ] && echo -e "    ..."
                
                if [ "$AUTO_YES" = true ]; then
                    # 自动模式：备份
                    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
                    mv "$target" "$backup"
                    ok "自动备份至: ${backup#$HOME/}"
                    mkdir -p "$target"
                else
                    echo ""
                    echo -e "    ${Y}[1]${R} 备份现有目录并替换 (推荐)"
                    echo -e "    ${Y}[2]${R} 合并到现有目录 (stow 将创建链接)"
                    echo -e "    ${Y}[3]${R} 删除现有目录 (危险)"
                    echo -e "    ${Y}[4]${R} 取消"
                    read -p "$(echo -e "${C}::${R} 请选择 [1-4]: ")" choice
                    
                    case "$choice" in
                        1)
                            local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
                            mv "$target" "$backup"
                            ok "已备份: ${backup#$HOME/}"
                            mkdir -p "$target"
                            ;;
                        2)
                            info "将合并到现有目录 (如有同名文件可能冲突)"
                            ;;
                        3)
                            read -p "$(echo -e "${RED}::${R} 输入 'delete' 确认永久删除: ")" confirm
                            [ "$confirm" = "delete" ] || { info "已取消"; exit 0; }
                            rm -rf "$target"
                            mkdir -p "$target"
                            ;;
                        *)
                            info "已取消"
                            exit 0
                            ;;
                    esac
                fi
            fi
        else
            # 是文件（非目录非链接）
            warn "目标位置是文件而非目录"
            if [ "$AUTO_YES" = false ]; then
                read -p "$(echo -e "${Y}[!]${R} 是否备份该文件并继续? [y/N]: ")" confirm
                [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
            fi
            mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$target"
        fi
    else
        # 目标不存在，创建目录
        info "创建目标目录"
        mkdir -p "$target"
    fi
    
    # 执行 stow
    if [ "$DRY_RUN" = true ]; then
        section "模拟运行 (-d)"
        info "以下链接将被创建:"
        stow -n -v -t "$target" -d "$(dirname "$source_dir")" "$(basename "$source_dir")" 2>&1 | \
            grep "LINK:" | while read line; do
                echo -e "  ${G}→${R} ${line#*: }"
            done
        return 0
    fi
    
    info "正在创建符号链接..."
    cd "$(dirname "$source_dir")"
    
    if stow -v -t "$target" "$(basename "$source_dir")" 2>&1 | while read line; do
        case "$line" in
            *LINK*)   echo -e "  ${G}→${R} ${line#*: }" ;;
            *UNLINK*) echo -e "  ${Y}~${R} ${line#*: }" ;;
            *)        [ -n "$line" ] && echo "    $line" ;;
        esac
    done; then
        ok "配置部署成功"
        echo ""
        info "目标路径: ${C}$target${R}"
        info "链接数量: $(find "$target" -maxdepth 1 -type l | wc -l) 个"
        
        # 如果目标不在 ~/.config 下，给予提示
        if [[ ! "$target" =~ ^"$HOME/.config" ]]; then
            warn "目标路径不在 ~/.config/ 下，应用可能无法自动识别配置"
        fi
    else
        err "部署失败"
        exit 1
    fi
}

# 卸载逻辑
do_uninstall() {
    local source_dir="$1"
    local target="$TARGET_PATH"
    
    section "卸载配置"
    info "目标路径: ${C}$target${R}"
    
    if [ ! -e "$target" ]; then
        err "目标不存在: $target"
        exit 1
    fi
    
    if [ ! -d "$target" ]; then
        err "目标不是目录"
        exit 1
    fi
    
    # 检查是否包含我们的链接
    cd "$(dirname "$source_dir")"
    
    if [ "$DRY_RUN" = true ]; then
        info "模拟卸载..."
        stow -n -D -t "$target" "$(basename "$source_dir")"
        return 0
    fi
    
    info "正在移除符号链接..."
    if stow -D -t "$target" "$(basename "$source_dir")" 2>&1 | while read line; do
        case "$line" in
            *UNLINK*) echo -e "  ${Y}~${R} ${line#*: }" ;;
            *)        [ -n "$line" ] && echo "    $line" ;;
        esac
    done; then
        ok "已移除配置链接"
        
        # 如果目录为空则询问是否删除
        if [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
            if [ "$AUTO_YES" = true ]; then
                rmdir "$target"
                ok "已删除空目录"
            else
                read -p "$(echo -e "${Y}[!]${R} 是否删除空目录 ${C}${target#$HOME/}${R}? [Y/n]: ")" confirm
                if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
                    rmdir "$target"
                    ok "已删除空目录"
                fi
            fi
        else
            info "保留目录内其他文件"
        fi
    else
        err "卸载失败"
        exit 1
    fi
}

# 主函数
main() {
    parse_args "$@"
    ensure_stow
    
    local source_dir=$(check_source)
    
    if [ "$UNINSTALL" = true ]; then
        do_uninstall "$source_dir"
    else
        do_install "$source_dir"
    fi
}

# 信号处理
trap 'err "脚本被中断"; exit 130' INT TERM

main "$@"