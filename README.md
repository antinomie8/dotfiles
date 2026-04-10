```
git clone https://github.com/antinomie8/dotfiles ~/.config/dotfiles && ~/.config/dotfiles/install.sh
```

| Problem | Solution |
| ---- | ---- |
| `man oec` gives an error | `sudo localectl set-locale LANG=en_US.UTF-8` |
| `pacman -Syu` marginal trust signatures error | `sudo pacman -Sy archlinux-keyring` |
| `notmuch` hangs on every command | kill all notmuch processes/reboot and remove `flintlock` in `.notmuch/xapian` |
| `asymptote` refuses to render `geometry.asy` constructs | ensure `autoimport` is not used |


### Things to do after installing
- `elan toolchain install leanprover/lean4:stable && elan default stable`
- `rustup default stable`
- `go telemetry off`
- `just --completions zsh > ~/.local/share/zsh/completions/_just`
<!-- - `build-fzf-tab-module` # does not respect LS_COLORS -->

- change `configs/hypr/hypridle.conf` keyboard device and its path in
  `configs/kmonad.kbd` if necessary
- change `configs/hypr/hyprland/general.conf` monitor width and terminal cell size if necessary

- `sudo visudo` and add line `Defaults passprompt=" Password for %u: "`
- [get a plymouth theme](https://github.com/adi1090x/plymouth-themes)

#### Systemd
- `systemctl --user enable --now hypridle.service`
- `systemctl --user enable --now hyprpolkitagent.service`
- `systemctl --user enable --now hyprsunset.service`

#### uv
- `uv tool install git+https://github.com/sharkdp/shell-functools`
