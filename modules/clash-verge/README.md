# 安装clash-verge
``` bash
yay -S clash-verge
```

# 配置全局代理
## 在终端使用代理
在`.zshrc`中添加以下内容：
```
export http_proxy=127.0.0.1:7897
export https_proxy=127.0.0.1:7897
export socks_proxy=127.0.0.1:7897
export all_proxy=127.0.0.1:7897
export PATH="$HOME/.local/bin:$PATH"
```

## 配置系统环境变量
打开`/etc/environment`，添加：
```
http_proxy=127.0.0.1:7897
https_proxy=127.0.0.1:7897
socks_proxy=127.0.0.1:7897
all_proxy=127.0.0.1:7897
```
