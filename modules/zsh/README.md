# 安装zsh
``` bash
sudo pacman -S zsh
chsh -s $(which zsh) # 将Zsh设置为默认shell
```
> [!TIP]
> 使用`cat /etc/shells`查看系统可以用的`shell`

# 安装oh-my-zsh
``` bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

# 安装powerlevel10k
``` bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```
然后打开`.zshrc`，把`ZSH_THEME`改成`"powerlevel10k/powerlevel10k"`

# 安装zsh-autosuggestions
``` bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
在`.zshrc`中添加插件：
```
plugins=( 
    # other plugins...
    zsh-autosuggestions
)
```