# general environment variables
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export TERMINAL="kitty -1"
export BROWSER="firefox"

# program-specific variables
export CPLUS_INCLUDE_PATH="$HOME/Informatique/Library"
export MANPAGER="nvim +Man!"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep.conf"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf.conf"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export MBSYNCRC="$XDG_CONFIG_HOME/isync/mbsyncrc"
export ASYMPTOTE_HOME="$XDG_CONFIG_HOME/asy"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"

# Path
path=(
	$HOME/.local/bin
	$path
	/usr/local/texlive/2024/bin/x86_64-linux
)
fpath=(
	$ZDOTDIR/functions
	$fpath
)

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath
