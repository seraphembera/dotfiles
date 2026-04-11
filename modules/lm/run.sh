#!/bin/bash

# 要清除的代理变量列表
PROXY_VARS=("http_proxy" "https_proxy" "socks_proxy" "all_proxy")

# 保存当前环境变量的值
declare -A saved_values
for var in "${PROXY_VARS[@]}"; do
  saved_values["$var"]="${!var}"
done

# 清除这些环境变量
for var in "${PROXY_VARS[@]}"; do
  unset "$var"
done

echo "已清除代理环境变量，正在启动客户端..."

# 启动客户端（前台运行，脚本会等待它退出）
"/home/seraphembera/software/bundle/lm"

# 客户端退出后，恢复之前保存的环境变量
echo "客户端已退出，恢复代理环境变量..."
for var in "${PROXY_VARS[@]}"; do
  if [[ -n "${saved_values[$var]}" ]]; then
    export "$var"="${saved_values[$var]}"
  fi
done

echo "恢复完成。"
