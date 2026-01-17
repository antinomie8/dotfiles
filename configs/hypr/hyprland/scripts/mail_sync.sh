#!/usr/bin/env zsh

cd ~/.config/imapnotify || exit
for file in *; do
	notify-send ${file:r}
	mbsync ${file:r}
	systemctl --user enable --now goimapnotify@${file:r}.service
done
