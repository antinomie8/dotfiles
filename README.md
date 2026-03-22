```
git clone https://github.com/anonymousgrasshopper/dotfiles ~/.config/dotfiles && ~/.config/dotfiles/install.sh
```

| Problem | Solution |
| ---- | ---- |
| `man oec` gives an error | `sudo localectl set-locale LANG=en_US.UTF-8` |
| modify sudo prompt | `sudo visudo` and add line `Defaults passprompt=" Password for %u: "` |
| `pacman -Syu` error about marginal trust signatures | `sudo pacman -Sy archlinux-keyring` |


### Things to do after installing
- `rustup default stable`
- `go telemetry off`
<!-- - `build-fzf-tab-module` # does not respect LS_COLORS -->

- [get a plymouth theme](https://github.com/adi1090x/plymouth-themes)

- change `configs/hypr/hypridle.conf` keyboard device if necessary
- change `configs/hypr/hyprland/general.conf` monitor width and terminal cell size if necessary

#### Systemd
- `systemctl --user enable --now hypridle.service`
- `systemctl --user enable --now hyprpolkitagent.service`
- `systemctl --user enable --now hyprsunset.service`
