#!/usr/bin/env bash

set -uo pipefail

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
function copy() {
	if ! [[ -e "$1" ]]; then
		echo -e "${WARNING} $1 not found"
		return 1
	fi
	local sudo=""
	if [[ "$2" != "$HOME"* && "$2" != "~"* ]]; then
		sudo="sudo"
	fi
	local target_loc="$2/$(basename "$1")"

	[[ -d "$2" ]] || $sudo mkdir -p "$2" 2>/dev/null

	if [[ ! -e $target_loc ]]; then
		$sudo cp -r "$1" "$2/" 2>/dev/null ||
			echo -e "${ERROR} ${WHITE}You need to manually move ${SUCCESS}$1${WHITE} to ${SUCCESS}$2${COLOR_RESET}"
	elif ! diff --brief -r --exclude='*.pdf' "$1" "$target_loc" >/dev/null 2>&1; then
		echo -en "${INFO}Would you like to delete your current ${SUCCESS}$(basename "$1")${INFO} \
to replace it with the one in this repo ? (y/n) ${COLOR_RESET}"
		local answer
		read -r answer
		case "$answer" in
			[yY][eE][sS] | [yY])
				$sudo cp -r "$1" "$2/" 2>/dev/null ||
					echo -e "${ERROR} ${WHITE}You need to manually move ${SUCCESS}$1${WHITE} to ${SUCCESS}$2${COLOR_RESET}"
				;;
		esac
	fi
}

# util function for checking if a program is in $PATH
function program() {
	if command -v "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# place system-wide configuration files
function copy_if_installed() {
	if program "$1"; then
		shift
		copy "$@"
	fi
}
copy_if_installed pacman arch/pacman.conf /etc
copy_if_installed loginctl systemd/logind.conf /etc/systemd
copy_if_installed hyprland icons/Bibata ~/.local/share/icons
copy_if_installed pdflatex texmf ~/.local/share
copy_if_installed firefox firefox/autoconfig.js /usr/lib/firefox/defaults/pref
copy_if_installed firefox firefox/firefox.cfg /usr/lib/firefox
copy_if_installed xkbcli X11/frhrm.xkb /usr/share/X11/xkb/symbols/frhrm

# copy desktop files and icons
find icons/hicolor -type f -print0 | while IFS= read -r -d '' file; do
	filename="$(basename "$file")"
	name="${filename%.*}"
	[[ "$name" == "mail" ]] && program="nvim" || program="$name"
	copy_if_installed "$program" "$file" ~/.local/share/icons/hicolor/"$(dirname "$file")"
done
for file in desktop/*; do
	filename="$(basename "$file")"
	name="${filename%.*}"
	[[ "$name" == "mail" ]] && program="nvim" || program="$name"
	copy_if_installed "$program" "$file" ~/.local/share/applications
done

for package in typst/*; do
	copy_if_installed typst "$package" ~/.local/share/typst/packages
done

[[ -n "${CPLUS_INCLUDE_PATH:-}" ]] && copy dbg.h "$CPLUS_INCLUDE_PATH"

if [[ ! -f ~/.local/share/cargo/bin/blackscreen ]]; then
	(cd blackscreen && cargo install --path .)
fi

if program systemctl; then
	# install systemd user units
	for file in systemd/user/*; do
		copy "$file" ~/.config/systemd/user
		if [[ "$file" = *.timer || ("$file" =~ ^(.*)\.service$ && ! -f "${BASH_REMATCH[1]}.timer") ]]; then
			unit="$(basename "$file")"
			if [[ $(systemctl --user is-active "$unit") == 'inactive' ]]; then
				echo "enabling $unit systemd user unit"
				systemctl --user enable --now "$unit"
			fi
		fi
	done

	# install and enable paccache
	if program pacman && ! systemctl status paccache.timer >/dev/null 2>&1; then
		echo -en "${INFO}Would you like to use paccache to automatically clean up the package cache ? (y/n) ${COLOR_RESET}"
		if get_answer; then
			program paccache || sudo pacman -S pacman-contrib
			[[ -f /etc/systemd/system/paccache.timer ]] || sudo cp arch/paccache.timer /etc/systemd/system/paccache.timer
			sudo systemctl enable --now paccache.timer
		fi
	fi
fi

# Windows and WSL specific files
if [[ -n "${WSLENV:-}" ]]; then
	# get the Windows username
	while true; do
		echo -en "${INFO}What is your Windows username ? ${WHITE}"
		read -r win_username
		if [[ -z "$win_username" ]]; then
			echo -e "Skipping Windows-specific setup.${COLOR_RESET}"
			break
		elif [[ -d "/mnt/c/Users/$win_username" ]]; then
			break
		else
			echo -e "${ERROR}Home directory not found. Try again..."
		fi
	done

	if [[ -n "$win_username" ]]; then
		# list the files to copy and their destination
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
			copy X11/i3 ~/.config
			copy X11/rofi ~/.config
			program picom && copy picom.conf /etc/xdg
			for i in "${!wsl_scripts[@]}"; do
				copy "$i" "${wsl_scripts[$i]}"
			done
		)
	fi
fi

echo -e "${SUCCESS}Completed !"
