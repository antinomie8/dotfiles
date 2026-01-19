#!/bin/bash

# colors
ERROR='\e[38;5;196m'
WARNING='\e[38;5;226m'
INFO='\e[38;5;39m'
SUCCESS='\e[38;5;46m'
WHITE='\e[37m'
COLOR_RESET='\e[0m'

# change dir to the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit

# $1: file to copy relative to $SCRIPT_DIR, $2: destination
function copy_item {
	if ! [[ -e "$1" ]]; then
		echo -e "${WARNING} $1 not found"
		return 1
	fi
	if [[ "$2" == "$HOME"* || ${2:0} == '~' ]]; then
		local sudo=""
	else
		local sudo="sudo"
	fi
	[[ -d "$2" ]] || $sudo mkdir -p "$2" 2>/dev/null
	if [[ ! -f "$2/$1" && ! -d "$2/$1" ]]; then
		$sudo cp -r "$1" "$2/" 2>/dev/null || echo -e "${ERROR} ${WHITE}You need to manually move ${SUCCESS}$1${WHITE} to ${SUCCESS}$2${COLOR_RESET}"
	elif ! diff --brief -r "$1" "$2/$1" >/dev/null 2>&1; then
		echo -en "${INFO}Would you like to delete your current ${SUCCESS}$1${INFO} to replace it with the one in this repo ? (y/n) ${COLOR_RESET}"
		local answer
		read -r answer
		case "$answer" in
		[yY][eE][sS] | [yY])
			$sudo cp -r "$1" "$2/" 2>/dev/null || echo -e "${ERROR} ${WHITE}You need to manually move ${SUCCESS}$1${WHITE} to ${SUCCESS}$2${COLOR_RESET}"
			;;
		esac
	fi
}

# place system-wide configuration files
function program {
	if type "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}
program pacman && copy_item pacman.conf /etc
program pacman && copy_item paccache.timer /etc/systemd/system
program hyprland && copy_item icons/Bibata ~/.local/share/icons
program typst && copy_item oly_typst_package ~/.local/share/typst/packages/local
program firefox && copy_item autoconfig.js /usr/lib/firefox/defaults/pref
program firefox && copy_item firefox.cfg /usr/lib/firefox
program yazi && copy_item desktop/yazi.desktop ~/.local/share/applications
program yazi && copy_item icons/hicolor/1254x1260/apps/yazi.png ~/.local/share/icons/hicolor/1254:1260/apps
program neomutt && copy_item desktop/neomutt.desktop ~/.local/share/applications
program neomutt && copy_item icons/hicolor/325x325/apps/neomutt.png ~/.local/share/icons/hicolor/325x325/apps
program nvim && copy_item desktop/mail.desktop ~/.local/share/applications
program nvim && copy_item icons/hicolor/scalable/apps/mail.svg ~/.local/share/icons/hicolor/scalable/apps
[[ -n "$CPLUS_INCLUDE_PATH" ]] && copy_item dbg.hpp "$CPLUS_INCLUDE_PATH"
if program systemctl; then
	for file in systemd/user/*; do
		if [[ ! -f "$file" ]]; then
			copy_item "$file" ~/.config/systemd/user
			echo "enabling $(basename "$file") systemd user unit"
			systemctl --user enable "$file"
		fi
	done
fi

# Windows and WSL specific files
if [[ -n "$WSLENV" ]]; then
	# get the Windows username
	while true; do
		echo -en "${INFO}What is your Windows username ? ${WHITE}"
		read -r win_username
		if [[ -n "$win_username" && -d "/mnt/c/Users/$win_username" ]]; then
			break
		else
			echo -e "${ERROR}Home directory not found. Try again..."
		fi
	done

	# list the files to copy and ther destination
	(
		cd WSL || exit 1
		declare -A wsl_scripts
		wsl_scripts=(
			["startup.sh"]="$HOME/.local/bin"
			["arch.vbs"]="/mnt/c/Users/$win_username/Desktop"
			["dvorak.vbs"]="/mnt/c/Users/$win_username/Desktop"
			["HomeRowMods.kbd"]="/mnt/c/Program Files/Kmonad"
			["kmonad.exe"]="/mnt/c/Program Files/Kmonad"
			["HomeRowMods.vbs"]="/mnt/c/Users/$win_username/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"
			["capslock.ahk"]="/mnt/c/Users/$win_username/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup"
		)
		for script in *.xlaunch; do
			wsl_scripts["$script"]="/mnt/c/Program Files/VcXsrv/"
		done

		# move each file to their destination
		copy_item X11/i3 ~/.config
		copy_item X11/rofi ~/.config
		program picom && copy_item picom.conf /etc/xdg
		for i in "${!wsl_scripts[@]}"; do
			copy_item "$i" "${wsl_scripts[$i]}"
		done
	)
fi

echo -e "${SUCCESS}Completed !"
