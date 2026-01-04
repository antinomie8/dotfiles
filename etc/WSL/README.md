# Installation instruction for Windows
-  [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install) and
install the Arch Linux WSL (`wsl --install archlinux`)
- Inside of the Arch WSL, `pacman -S sudo git zsh`, create a root password (`passwd`)
and a user (`useradd -m -G wheel -s /bin/zsh Antoine`) with their password, execute `visudo`
and uncomment the ` %wheel   ALL=(ALL)   ALL` line.
- `git clone https://github.com/anonymousgrasshopper/dotfiles ~/.config/dotfiles && ~/.config/dotfiles/install.sh`,
run `etc/install.sh`.

- Install [Vcxsrv](https://vcxsrv.com/) ([download link](https://sourceforge.net/projects/vcxsrv/files/latest/download)).

- If you want audio support in WSL, [this
link](https://www.reddit.com/r/bashonubuntuonwindows/comments/hrn1lz/wsl_sound_through_pulseaudio_solved/)
explains how to setup PulseAudio just for that.

- Disable the [windows keybindings](https://www.top-password.com/blog/disable-windows-key-shortcuts-hotkeys-in-windows-10/), the [Win+g](https://stackoverflow.com/questions/51502871/how-to-block-wing-keyboard-event) and [Win+L](https://superuser.com/questions/1059511/how-to-disable-winl-in-windows-10) keybindings to avoid conflicts with i3wm.

- For installing the Bibata cursor theme : `yay -S bibata-cursor-theme-bin` and
`sudo mv /usr/share/icons/Bibata-Modern-Classic /usr/share/icons/default` is the quickest way to do so.

- You may want to disable external shell completions in Neovim: run `:h
blink-cmp-recipes` and search for WSL.
