#!/usr/bin/env bash

# colors
ERROR='\e[38;5;196m'
WARNING='\e[38;5;226m'
BLUE='\e[38;5;39m'
GREEN='\e[38;5;46m'
WHITE='\e[37m'
COLOR_RESET='\e[0m'

# cd to the script's directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
cd "$SCRIPT_DIR" || exit 1

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
	command -v "$1" >/dev/null 2>&1
}

# warn the user if the script is being runned as root
if [[ "$EUID" -eq 0 && ! "$SCRIPT_DIR" = /root && ! "$SCRIPT_DIR" = /root/* ]]; then
	echo -e "${WARNING} Running this script as root might cause permission issues."
	echo -en "${WARNING}  Do you really want to continue ? (y/n) ${COLOR_RESET}"
	if ! get_answer; then
		echo -e "${ERROR}  Aborting...${COLOR_RESET}"
		exit 1
	fi
fi

# install packages
readarray -t packages < <(grep -vE '^\s*($|#)' packages.txt) # ignore comments and blank lines
if program pacman; then
	# Install yay (AUR helper)
	if ! program yay; then
		echo -en "${BLUE}Do you want to install the Yet Another Yogurt AUR helper (y/n) ? ${COLOR_RESET}"
		if get_answer; then
			sudo pacman -S --needed git base-devel binutils fakeroot debugedit
			git clone https://aur.archlinux.org/yay.git /tmp/yay
			if cd /tmp/yay; then
				makepkg -si
				rm -rf /tmp/yay
				cd "$SCRIPT_DIR" || exit
			else
				echo "${ERROR} Cloning yay failed. Check your internet connection and try again.${COLOR_RESET}"
			fi
		fi
	fi

	# install required packages
	if program yay; then
		package_manager="yay"
		packages+=("cppman" "cpulimit" "dbg-macro" "hyprtime" "runapp" "thundery"
			"xdg-desktop-portal-termfilechooser-hunkyburrito-git" "elan")    # misc
		packages+=("zsh-abbr" "zsh-patina-git")                            # shell
		packages+=("ttf-juliamono" "otf-garamond-math")                    # fonts
		packages+=("codelldb-bin" "texlab" "tex-fmt" "asm-lsp" "typstyle") # Neovim
		packages+=("kitty-git" "neovim-nightly-bin" "yazi-nightly-bin")
	else
		package_manager="sudo pacman"
		packages+=("kitty" "neovim" "yazi")
	fi
	echo -en "${BLUE}Would you like to synchronize the required packages with ${package_manager##* } ? (y/n) ${COLOR_RESET}"
	if get_answer; then
		if ! program pdflatex; then
			echo -en "${BLUE}Do you also want to install the TexLive LaTeX distribution ? (y/n) ${COLOR_RESET}"
			if get_answer; then
				packages+=("texlive" "texlive-langfrench")
			fi
		fi
		$package_manager -S --needed --noconfirm "${packages[@]}"
	else
		echo -e "${GREEN}Make sure the following packages are installed :${COLOR_RESET}"
		echo -e "${WHITE}${packages[*]}${COLOR_RESET}"
	fi

	# install, enable and start paccache
	if ! systemctl status paccache.timer >/dev/null 2>&1; then
		echo -en "${BLUE}Would you like to use paccache to automatically clean up the package cache ? (y/n) ${COLOR_RESET}"
		if get_answer; then
			program paccache || sudo pacman -S pacman-contrib
			[[ -f /etc/systemd/system/paccache.timer ]] || cat <./etc/paccache.timer >/etc/systemd/system/paccache.timer
			sudo systemctl enable paccache.timer
			sudo systemctl start paccache.timer
		fi
	fi
elif [[ -n $TERMUX_VERSION ]]; then
	echo -en "${BLUE}It appears you are running Termux. Do you want to run ${GREEN}./etc/Termux/termux.sh${BLUE} ? (y/n) ${COLOR_RESET}"
	if get_answer; then
		echo
		./etc/Termux/termux.sh
	fi
	if ! program sudo; then
		function sudo() {
			"$@"
		}
	fi
else
	echo -e "${GREEN}Make sure the following packages are installed :"
	echo -e "${WHITE}${packages[*]}${COLOR_RESET}"
	# TexLive
	if ! program pdflatex; then
		echo -e "${BLUE}Follow instructions at ${GREEN}https://www.tug.org/texlive/quickinstall.html${BLUE} to install TexLive.${COLOR_RESET}"
		echo
	fi
fi
echo

# configure /etc/zsh files for avoiding dotfiles clutter in home directory
function add_line() {
	local line="$1"
	local dest="$2"
	[[ -n $TERMUX_VERSION ]] && dest="$PREFIX$dest"
	if [[ -f "$dest" ]]; then
		if ! grep --silent "$line" "$dest"; then
			echo "$line" | sudo tee -a "$dest" >/dev/null
		fi
	else
		[[ -d "$(dirname "$dest")" ]] || sudo mkdir -p "$(dirname "$dest")"
		sudo touch "$dest"
		echo "$line" | sudo tee -a "$dest" >/dev/null
	fi
}
add_line "export ZDOTDIR=\$HOME/.config/zsh" /etc/zsh/zshenv
add_line "zsh-newuser-install() { :; }" /etc/zsh/zshrc

# configure Pulseaudio to avoid having its cookies in ~/.config
if [[ -f /etc/pulse/client.conf ]] &&
	! grep --silent -E "cookie-file = /.+/.cache/pulse/cookie" /etc/pulse/client.conf; then
	printf "\ncookie-file = %s/.cache/pulse/cookie" "$HOME" | sudo tee -a /etc/pulse/client.conf >/dev/null
fi

# check wether the default shell is zsh or not
if [[ ! "$SHELL" = */zsh ]]; then
	if program zsh; then
		echo -en "${BLUE}Do you want to make zsh your default shell ? (y/n) ${COLOR_RESET}"
		if get_answer; then
			chsh --shell "$(which zsh)"
		fi
	else
		echo -e "${WHITE}Install zsh and make it your default shell :"
		echo -e "${GREEN}> ${BLUE}chsh $USER"
		echo -e "${GREEN}> ${BLUE}\$(which zsh)${COLOR_RESET}"
	fi
	echo
fi

# check the user has a home directory
if [[ -z "$HOME" ]]; then
	echo "${ERROR}Looks like you don't have a home directory. Create one ? (y/n) ${COLOR_RESET}"
	if get_answer && program mkhomedir_helper; then
		sudo mkhomedir_helper "$USER"
	else
		echo "${ERROR}Aborting...${COLOR_RESET}"
	fi
	[[ -z "$HOME" ]] && exit 1
fi

# copy scripts to ~/.local/bin
(
	cd scripts || {
		echo -e "${ERROR}Error:${WHITE} scripts directory is not present in $SCRIPT_DIR${COLOR_RESET}"
		exit 1
	}
	[[ -d "$HOME/.local/bin" ]] || mkdir -p "$HOME/.local/bin"
	first=true
	for file in *; do
		if [[ ! -f "$HOME/.local/bin/$file" ]]; then
			cp "$file" "$HOME/.local/bin/"
			chmod +x "$HOME/.local/bin/$file"
		elif ! cmp --silent "$file" "$HOME/.local/bin/$file"; then
			if [[ -z $OVERWRITE ]]; then
				if [[ $first == true ]]; then
					echo
					first=false
				fi
				echo -en '\e[A\e[2K' # cursor one line up and clear line
				echo -en "${BLUE}Would you like to delete your current ${GREEN}$file${BLUE} script to replace it with the one in this repo ? (y/n) ${COLOR_RESET}"
			fi
			if [[ -n $OVERWRITE ]] || get_answer; then
				cp "$file" "$HOME/.local/bin/"
				chmod +x "$HOME/.local/bin/$file"
			fi
		fi
	done
	echo
)

# copy config directories to ~/.config
(
	[[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
	cd "$SCRIPT_DIR/configs" || {
		echo -e "${ERROR}Error:${WHITE} configs directory is not present in $SCRIPT_DIR${COLOR_RESET}"
		exit 1
	}
	first=true
	for item in *; do
		if [[ ! -e "$HOME/.config/$item" ]]; then
			cp -r "$item" "$HOME/.config/"
		else
			[[ -d "$item" ]] && recursive="-r" || recursive=""
			if
				! diff --brief $recursive \
					--exclude='.git' \
					--exclude='lockfile.json' \
					--exclude=".qmlls.ini" \
					--exclude='*@*\.*' \
					--ignore-matching-lines='\S*@\S*\.\S*' \
					--ignore-matching-lines='^export.*API_KEY=' \
					"$item" "$HOME/.config/$item" >/dev/null 2>&1
			then
				if [[ -z $OVERWRITE ]]; then
					if [[ $first == true ]]; then
						echo -en "${BLUE}Would you like to :"
						printf '\n\n\n\n'
						echo -en "${ERROR}Enter a number (default 3) :${COLOR_RESET} "
						echo
						printf "\e[A" # move the cursor on line up
						first=false
					fi
					printf "\e[3A" # move the cursor up three lines
					echo -e "\033[2K\r  ${BLUE}- 1 :${WHITE} create a backup of your current ${GREEN}$item${WHITE} config before replacing it"
					echo -e "\033[2K\r  ${BLUE}- 2 :${WHITE} delete your current ${GREEN}$item${WHITE} config and replace it"
					echo -e "\033[2K\r  ${BLUE}- 3 :${WHITE} skip this step and keep your current ${GREEN}$item${WHITE} config ?"
					echo -en "\e[29C" # move cursor after the prompt
					echo -ne '\033[P' # clear character under cursor
					read -r answer
					printf "\e[A" # move the cursor one line up
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
				esac
			fi
		fi
	done
	if [[ $first == false ]]; then # additional newline since the cursor got up
		echo
	fi
	echo
)

# install oly
(
	if ! program oly; then
		echo -en "${BLUE}Do you want to install oly (y/n) ? ${COLOR_RESET}"
		if get_answer; then
			if ! program git || ! program cmake; then
				installed=true
				if program pacman; then
					sudo pacman -S --needed git cmake
				fi
				if ! program cmake; then
					echo -e "${ERROR} cmake is required in order to build oly.${COLOR_RESET}"
					installed=false
				fi
				if ! program git; then
					echo -e "${ERROR} git is required to clone oly.${COLOR_RESET}"
					installed=false
				fi
				if ! $installed; then
					exit
				fi
			fi
			curl -fsSL https://raw.githubusercontent.com/antinomie8/oly/main/install.sh | bash
			echo
		fi
	fi
)

# rebuild bat cache
if program bat && ! bat --list-themes | grep --silent "Kanagawa"; then
	bat cache --build
	echo
fi

# check gnupg directory exists and is properly configured
if [[ ! -d ~/.local/share/gnupg ]]; then
	mkdir -p ~/.local/share/gnupg
	chmod 700 ~/.local/share/gnupg
	gpg --list-keys
	echo
fi

# create python history dir
if [[ -n "$PYTHON_HISTORY" && ! -d "$(dirname "$PYTHON_HISTORY")" ]]; then
	mkdir -p "$(dirname "$PYTHON_HISTORY")"
fi

# run etc/install.sh
echo -en "${BLUE}Do you want to run ${GREEN}./etc/install.sh${BLUE} ? (y/n) ${COLOR_RESET}"
if get_answer; then
	echo
	source ./etc/install.sh
fi
