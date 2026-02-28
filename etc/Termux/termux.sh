#!/usr/bin/env bash

# colors
ERROR='\e[38;5;196m'
BLUE='\e[38;5;39m'
GREEN='\e[38;5;46m'
WHITE='\e[37m'
COLOR_RESET='\e[0m'

# check script is being runned on Termux
if [[ -z $TERMUX_VERSION ]]; then
	echo -e "${ERROR} \$TERMUX_VERSION variable is not set. Are you really on Termux ?${COLOR_RESET}"
	exit 1
fi

# cd to the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit 1

# util function for getting user input
function get_answer() {
	local answer
	read -r answer
	case "$answer" in
	[yY][eE][sS] | [yY])
		return 0
		;;
	*)
		return 1
		;;
	esac
}
# util function for checking if a program is in $PATH
function program() {
	if type "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# specific things to do on operating systems using pacman as a package manager
packages=("7zip" "asymptote" "bat" "clang" "cmake" "cronie" "eza" "fd" "fzf"
	"git" "git-delta" "gh" "hexyl" "imagemagick"
	"lazygit" "lynx" "nasm" "ncdu" "neovim" "notmuch"
	"python" "ripgrep" "rsync" "tmux"
	"unzip" "wget" "yazi" "zoxide" "zsh"
	"lua-language-server" "stylua" "shellcheck" "shfmt") # Neovim
if program pkg; then
	echo -en "${BLUE}Would you like to synchronize the required packages with pkg ? (y/n) ${WHITE}"
	if get_answer; then
		pkg install "${packages[@]}"
	else
		echo -e "${GREEN}Make sure the following packages are installed :"
		echo -e "${WHITE}${packages[*]}${COLOR_RESET}"
	fi
else
	echo -e "${GREEN}Make sure the following packages are installed :"
	echo -e "${WHITE}${packages[*]}${COLOR_RESET}"
fi
printf '\n'

cp font.ttf ~/.termux/font.ttf
cp color.properties ~/.termux/color.properties
