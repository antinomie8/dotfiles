```
git clone https://github.com/anonymousgrasshopper/dotfiles ~/.config/dotfiles && ~/.config/dotfiles/install.sh
```

| Problem | Solution |
| ---- | ---- |
| `man oec` gives an error | `sudo localectl set-locale LANG=en_US.UTF-8` |
| modify sudo prompt | `sudo visudo` and add line `Defaults passprompt=" Password for %u: "` |

### Things to do after installing
- `rustup default stable`
<!-- - `build-fzf-tab-module` # does not respect LS_COLORS -->
##### Systemd
- `exec-once = systemctl --user enable --now hypridle.service`
- `exec-once = systemctl --user enable --now hyprpolkitagent.service`
