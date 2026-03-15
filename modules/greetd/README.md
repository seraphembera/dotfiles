# 安装greetd
``` bash
# 安装
sudo pacman -S greetd greetd-tuigreet
```
# 编辑配置
``` bash
sudo vim /etc/greetd/config.toml
```
配置示例：
``` toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --remember --cmd start-hyprland"
user = "greeter"
```

# 启用服务
```
sudo systemctl enable --now greetd.service
```
