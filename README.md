```
git clone https://github.com/antinomie8/dotfiles ~/.config/dotfiles && ~/.config/dotfiles/install.sh
```

| Problem | Solution |
| ---- | ---- |
| `man oec` gives an error | `sudo localectl set-locale LANG=en_US.UTF-8` |
| `pacman -Syu` marginal trust signatures error | `sudo pacman -Sy archlinux-keyring` |
| `notmuch` hangs on every command | kill all notmuch processes and remove `flintlock` in `.notmuch/xapian` |


### Things to do after installing
- `rustup default stable`
- `go telemetry off`
- `just --completions zsh > ~/.local/share/zsh/completions/_just`
<!-- - `build-fzf-tab-module` # does not respect LS_COLORS -->

- change `configs/hypr/hypridle.conf` keyboard device if necessary
- change `configs/hypr/hyprland/general.conf` monitor width and terminal cell size if necessary

- `sudo visudo` and add line `Defaults passprompt=" Password for %u: "`
- [get a plymouth theme](https://github.com/adi1090x/plymouth-themes)

#### Systemd
- `systemctl --user enable --now hypridle.service`
- `systemctl --user enable --now hyprpolkitagent.service`
- `systemctl --user enable --now hyprsunset.service`
