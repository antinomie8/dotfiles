###################################################################################################
############################################# ZSHENV ##############################################
###################################################################################################

# general environment variables
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export BROWSER="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"

# program-specific variables
export PASSWORD_STORE_DIR="$HOME/.local/share/password-store"
export PYTHON_HISTORY="$HOME/.local/state/python/history"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep.conf"
export CPLUS_INCLUDE_PATH="$HOME/Informatique/Library"
export NPM_CONFIG_USERCONFIG="$HOME/.config/npm/npmrc"
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf.conf"
export RUSTUP_HOME="$HOME/.local/share/rustup"
export MBSYNCRC="$HOME/.config/isync/mbsyncrc"
export CARGO_HOME="$HOME/.local/share/cargo"
export GNUPGHOME="$HOME/.local/share/gnupg"
export WGETRC="$HOME/.config/wget/wgetrc"
export TEXMFHOME="$HOME/.config/texmf"
export GOPATH="$HOME/.local/share/go"
export MANPAGER="nvim +Man!"

# Path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/usr/local/texlive/2024/bin/x86_64-linux"

# XDG environment variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DOWNLOAD_DIR="$HOME/Téléchargements"

# WSL graphics
# export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
