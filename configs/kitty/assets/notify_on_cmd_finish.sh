#!/bin/sh

status="$1"
command="$2"
if [ "$status" = 0 ]; then
	icon=~/.config/kitty/assets/icons/checkmark.svg
else
	icon=~/.config/kitty/assets/icons/crossmark.svg
fi
notify-send --app-name "kitty" --icon="$icon" "$command" "command $command finished with status $status"
