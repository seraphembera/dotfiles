# 安装kitty和nerd-font
``` bash
sudo pacman -S kitty ttf-jetbrains-mono-nerd
```

# 配置主题
``` bash
kitten themes
```

# 配置字体和透明度
```
kitten choose-fonts # 选择jetbrains-mono-nerd
```
在`.config/kitty/kitty.conf`添加：
```
# 字体大小
font_size 14
# 透明度
background_opacity 0.9
```