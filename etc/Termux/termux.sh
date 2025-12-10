#!/usr/bin/env bash

# colors
RED='\x1b[38;2;232;36;36m'     #e82424
YELLOW='\x1b[38;2;255;158;59m' #ff9e3b
GREEN='\x1b[38;2;106;149;137m' #6a9589
BLUE='\x1b[38;2;126;156;216m'  #7e9cD8
WHITE='\x1b[38;2;220;215;186m' #dcd7ba

# cd to the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit

# parse arguments
while [[ $# -ge 1 ]]; do
	if [[ "$1" == "--overwrite" || "$1" == "-o" ]]; then
		OVERWRITE=1
		break
	else
		shift 1
	fi
done

# util function for getting user input
function get_answer {
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
function program {
	if type "$1" >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

usr=/data/data/com.termux/files/usr/
etc=$usr/etc

# warn the user if the script is being runned as root
if [[ "$EUID" == 0 && ! "$SCRIPT_DIR" =~ ^/root ]]; then
	echo -e "${YELLOW} Running this script as root might cause permission issues."
	echo -en "${YELLOW}  Do you really want to continue ? (y/n) ${WHITE}"
	if ! get_answer; then
		echo -e "${RED}  Aborting..."
		exit 1
	fi
fi

# check wether the default shell is zsh or not
if [[ ! "$SHELL" =~ /zsh$ ]]; then
	if [[ -f /bin/zsh ]]; then
		echo -en "${BLUE}Do you want to make zsh your default shell ? (y/n) ${WHITE}"
		if get_answer; then
			chsh --shell /bin/zsh
		fi
	else
		echo -e "${WHITE}Install zsh and make it your default shell :"
		echo -e "${GREEN}> ${BLUE}chsh $USER"
		echo -e "${GREEN}> ${BLUE}/bin/zsh"
	fi
	printf '\n'
fi

# configure /etc/zsh files for avoiding dotfiles clutter in home directory
function add_line {
	if [[ -f "$2" ]]; then
		if ! grep --silent "$1" "$2"; then
			echo "$1" | tee -a "$2" >/dev/null
		fi
	else
		[[ -d "$(dirname "$2")" ]] || mkdir -p "$(dirname "$2")"
		touch "$2"
		echo "$1" | tee -a "$2" >/dev/null
	fi
}
add_line "export ZDOTDIR=\$HOME/.config/zsh" $etc/zsh/zshenv
add_line "zsh-newuser-install() { :; }" $etc/zsh/zshrc

# specific things to do on operating systems using pacman as a package manager
packages=("7zip" "asymptote" "bat" "btop" "clang" "cronie" "eza" "fd" "feh" "firefox" "fzf"
	"gcc" "git" "git-delta" "github-cli" "hexyl" "i3-wm" "imagemagick" "kitty"
	"lazygit" "lynx" "man-db" "nasm" "ncdu" "neovim" "notmuch" "npm" "obsidian" "picom"
	"python" "ripgrep" "rofi" "rsync" "texlive-langfrench" "tldr" "tmux" "tree-sitter-cli"
	"rustup" "unzip" "wget" "xdotool" "yazi" "zathura" "zathura-pdf-mupdf" "zoxide" "zsh"
	"lua-language-server" "stylua" "bash-language-server" "shellcheck" "shfmt" "prettier" # Neovim
	"ttf-jetbrains-mono-nerd")
if program pkg; then
	echo -en "${BLUE}Would you like to synchronize the required packages with pkg ? (y/n) ${WHITE}"
	if get_answer; then
		if ! program pdflatex; then
			echo -en "${BLUE}Do you also want to install the TexLive LaTeX distribution ? (y/n) ${WHITE}"
			if get_answer; then
				packages+=("texlive")
			fi
		fi
		pkg install "${packages[@]}"
	else
		echo -e "${GREEN}Make sure the following packages are installed :"
		echo -e "${WHITE}${packages[*]}"
	fi
else
	echo -e "${GREEN}Make sure the following packages are installed :"
	echo -e "${WHITE}${packages[*]}"
	# TexLive
	if ! program pdflatex; then
		echo -e "${WHITE}Follow instructions at ${BLUE}https://www.tug.org/texlive/quickinstall.html${BLUE} to install TexLive."
		printf '\n'
	fi
fi
printf '\n'

# copy scripts to ~/.local/bin
(
	cd scripts || {
		echo -e "${RED}Error:${WHITE} scripts directory is not present in $SCRIPT_DIR"
		exit 1
	}
	[[ -d "$HOME/.local/bin" ]] || mkdir -p "$HOME/.local/bin"
	for file in *; do
		if [[ ! -f "$HOME/.local/bin/$file" ]]; then
			cp "$file" "$HOME/.local/bin/"
			chmod +x "$HOME/.local/bin/$file"
		elif ! cmp --silent "$file" "$HOME/.local/bin/$file"; then
			if [[ -z $OVERWRITE ]]; then
				echo -en "${BLUE}Would you like to delete your current ${GREEN}$file${BLUE} script to replace it with the one in this repo ? (y/n) ${WHITE}"
			fi
			if [[ -n $OVERWRITE ]] || get_answer; then
				cp "$file" "$HOME/.local/bin/"
				chmod +x "$HOME/.local/bin/$file"
			fi
		fi
	done
	printf '\n'
)

# copy config directories to ~/.config
(
	[[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
	cd "$SCRIPT_DIR/configs" || {
		echo -e "${RED}Error:${WHITE} configs directory is not present in $SCRIPT_DIR"
		exit 1
	}
	for item in *; do
		if [[ ! -e "$HOME/.config/$item" ]]; then
			cp -r "$item" "$HOME/.config/"
		else
			difference=false
			while read -r -d ''; do # check wether the version in the repo and in ~/.config differ or not
				if ! diff --ignore-matching-lines='\S*@\S*' --ignore-matching-lines='export.*API_KEY=' \
					"$REPLY" "$HOME/.config/$REPLY" >/dev/null 2>&1; then # ignore obfuscated e-mail adresses
					difference=true
					break
				fi
			done < <(if [[ -d "$item" ]]; then find "$item" -path "./.git/*" -prune -o -type f -print0; else echo -ne "$item\0"; fi)
			if $difference; then
				if [[ ! $OVERWRITE ]]; then
					echo -en "${BLUE}Would you like to :
	${BLUE}- 1 :${WHITE} create a backup of your current ${GREEN}$item${WHITE} config before replacing it
	${BLUE}- 2 :${WHITE} delete your current ${GREEN}$item${WHITE} config and replace it
	${BLUE}- 3 :${WHITE} skip this step and keep your current ${GREEN}$item${WHITE} config ?
${RED}Enter a number (default 3) :${WHITE} "
					read -r answer
				else
					answer=2
				fi
				case "$answer" in
				1)
					if [[ -d "$HOME/.config/$item.bak" || -f "$HOME/.config/$item.bak" ]]; then
						rm -rf "$HOME/.config/$item.bak"
					fi
					mv "$HOME/.config/$item" "$HOME/.config/$item.bak"
					cp -r "$item" "$HOME/.config/"
					;;
				2)
					rm -rf "$HOME/.config/$item"
					cp -r "$item" "$HOME/.config/"
					;;
				*)
					echo -e "${WHITE}Skipping..."
					;;
				esac
			fi
		fi
	done
	printf '\n'
)

# install oly
(
	if ! program oly; then
		echo -en "${BLUE}Do you want to install oly (y/n) ? ${WHITE}"
		if get_answer; then
			if ! program git || ! program cmake; then
				installed=true
				if program pacman; then
					pacman -S --needed git cmake
				fi
				if ! program cmake; then
					echo "${RED} cmake is required in order to build oly."
					installed=false
				fi
				if ! program git; then
					echo "${RED} git is required to clone oly."
					installed=false
				fi
				if ! $installed; then
					exit
				fi
			fi
			git clone https://github.com/anonymousgrasshopper/oly "${TMPDIR:-/tmp}"/oly_build
			if cd "${TMPDIR:-/tmp}"/oly_build; then
				cmake -DCMAKE_BUILD_TYPE=Release build
				cmake --build build
				cp build/bin/oly $usr/local/bin/oly
				cp -r assets/typst ~/.local/
				[[ -d $usr/local/share/zsh/site-functions ]] || mkdir -p $usr/local/share/zsh/site-functions/
				cp assets/extras/_oly $usr/local/share/zsh/site-functions/
				rm -rf "${TMPDIR:-/tmp}"/oly_build
				printf '\n'
				cd "$SCRIPT_DIR" || exit
			else
				echo "${RED} Cloning oly failed. Check your internet connection and try again."
			fi
		fi
	fi
)

# setup rust toolchain
if program rustup && ! program cargo; then
	rustup default stable
fi

# rebuild bat cache
if program bat && ! bat --list-themes | grep --silent "Kanagawa"; then
	bat cache --build
fi

# modify yazi cache directory
[[ -f ~/.config/yazi/yazi.toml ]] && sed -i 's@/home/Antoine@'"$HOME"'@g' ~/.config/yazi/yazi.toml

# run etc/install.sh
echo -en "${BLUE}Do you want to run ${GREEN}./etc/install.sh${BLUE} ? (y/n) ${WHITE}"
if get_answer; then
	printf '\n'
	./etc/install.sh
fi
