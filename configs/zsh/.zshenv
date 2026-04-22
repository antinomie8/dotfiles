# general environment variables
export LANG="en_US.UTF-8"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export TERMINAL="kitty -1"
export BROWSER="firefox"

# XDG environment variables
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"

# program-specific variables
export CPLUS_INCLUDE_PATH="$HOME/Informatique/Library"
export MANPAGER="nvim +Man!"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep.conf"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME/fzf.conf"
export ZSH_PATINA_CONFIG_PATH="$ZDOTDIR/plugins/zsh-patina.toml"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export MBSYNCRC="$XDG_CONFIG_HOME/isync/mbsyncrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export ELAN_HOME="$XDG_DATA_HOME/elan"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/pycache"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export ASYMPTOTE_HOME="$XDG_CONFIG_HOME/asy"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFHOME="$XDG_DATA_HOME/texmf"

# Path
path=(
	$HOME/.local/bin
	$HOME/.local/share/cargo/bin
	$path
	/usr/local/texlive/2024/bin/x86_64-linux
)
fpath=(
	$ZDOTDIR/functions
	$ZDOTDIR/functions/completions
	$HOME/.local/share/zsh/completions
	$fpath
)

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath
