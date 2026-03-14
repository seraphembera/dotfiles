# 安装clash
```bash
sudo pacman -S clash
```

# 配置订阅连接
1. 先在终端启动`clash`，第一次启动会创建配置文件。
2. 把`config.yaml`文件替换成机场的文件，可以通过手机导出复制到电脑，文件目录是`~/.config/clash`。
3. 把`~/.config/clash`目录下的文件复制到`/etc/clash`。

# 添加环境变量
以下添加到`.zshrc`：
``` bash
export http_proxy=127.0.0.1:7890
export https_proxy=127.0.0.1:7890
export socks_proxy=127.0.0.1:7891
```

# 配置守护进程
编辑`/etc/systemd/system/clash.service`
``` bash
sudo vim /etc/systemd/system/clash.service
```
加入如下行：
```
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/clash -d /etc/clash

[Install]
WantedBy=multi-user.target
```
然后添加到守护进程：
``` bash
sudo systemctl enable clash
```