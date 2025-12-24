#!/bin/bash

# colors
RED='\x1b[38;2;232;36;36m'     #e82424
YELLOW='\x1b[38;2;255;158;59m' #ff9e3b
GREEN='\x1b[38;2;106;149;137m' #6a9589
BLUE='\x1b[38;2;126;156;216m'  #7e9cd8
WHITE='\x1b[38;2;220;215;186m' #dcd7ba
COLOR_RESET='\x1b[0m'

# change dir to the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit

# $1: file to copy relative to $SCRIPT_DIR, $2: destination
function copy_item {
	[[ -f "$1" || -d "$1" ]] || {
		echo -e "${YELLOW} $1 not found"
		return 1
	}
	[[ "$2" == "$HOME"* ]] && sudo="" || sudo="sudo"
	[[ -d "$2" ]] || $sudo mkdir -p "$2" 2>/dev/null
	if [[ ! -f "$2/$1" && ! -d "$2/$1" ]]; then
		$sudo cp -r "$1" "$2/" 2>/dev/null || echo -e "${RED} ${WHITE}You need to manually move ${GREEN}$1${WHITE} to ${GREEN}$2${COLOR_RESET}"
	elif ! cmp --silent "$1" "$2/$1"; then
		echo -en "${BLUE}Would you like to delete your current ${GREEN}$1${BLUE} to replace it with the one in this repo ? (y/n) ${COLOR_RESET}"
		read -r answer
		case "$answer" in
		[yY][eE][sS] | [yY])
			$sudo cp -r "$1" "$2/" 2>/dev/null || echo -e "${RED} ${WHITE}You need to manually move ${GREEN}$1${WHITE} to ${GREEN}$2${COLOR_RESET}"
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
program picom && copy_item picom.conf /etc/xdg
program hyprland && copy_item Bibata "$HOME"/.local/share/icons
program neomutt && copy_item neomutt.desktop /usr/share/applications
program neomutt && copy_item neomutt.png "$HOME"/.local/share/icons/hicolor/325x325/apps
[[ -f /etc/systemd/journald.conf ]] && copy_item journald.conf /etc/systemd
[[ -n "$CPLUS_INCLUDE_PATH" ]] && copy_item dbg.h "$CPLUS_INCLUDE_PATH"

# Windows and WSL specific files
if [[ -n "$WSLENV" ]]; then
	# get the Windows username
	while true; do
		echo -en "${BLUE}What is your Windows username ? ${WHITE}"
		read -r win_username
		if [[ -n "$win_username" && -d "/mnt/c/Users/$win_username" ]]; then
			break
		else
			echo -e "${RED}Home directory not found. Try again..."
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
		for i in "${!wsl_scripts[@]}"; do
			copy_item "$i" "${wsl_scripts[$i]}"
		done
	)
fi

printf '\n'
echo -e "${GREEN}Completed !"
