```
git clone https://github.com/anonymousgrasshopper/dotfiles ~/.config/dotfiles && ~/.config/dotfiles/install.sh
```

| Problem | Solution |
| ---- | ---- |
| `man oec` gives an error | `sudo localectl set-locale LANG=en_US.UTF-8` |
| need typing password for unlocking keyring | [modify /etc/pam.d/login](https://wiki.archlinux.org/title/GNOME/Keyring#PAM_step) |
| modify sudo prompt | `sudo visudo` and add line `Defaults passprompt=" Password for %u: "` |
