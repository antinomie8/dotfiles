# terminal emulator specific settings
[[ "$TERM" == "xterm-kitty" && -f "$ZDOTDIR/kitty.zsh" ]] && source "$ZDOTDIR/kitty.zsh"

# source Powerlevel10k's instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# setup the plugin manager
[[ -d $ZSH_CACHE_DIR ]] || mkdir -p $ZSH_CACHE_DIR
ANTIDOTE_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/antidote/"
if [[ ! -d $ANTIDOTE_HOME ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote $ANTIDOTE_HOME
fi
source $ANTIDOTE_HOME/antidote.zsh
antidote load $ZDOTDIR/plugins


eval "$(dircolors "$ZDOTDIR/dircolors")" # colorize completion menu entries
export LS_COLORS=$LS_COLORS":.*=38;2;114;113;105:" # dotfiles in gray

# completions
zstyle ':completion:*'                 use-cache on
zstyle ':completion:*'                 cache-path ~/.cache/zsh/completion-cache
zstyle ':completion:*'                 matcher-list "m:{a-z}={A-Za-z}"
zstyle ':completion:*'                 complete-options true
zstyle ':completion:*'                 menu no
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:git-checkout:*'  sort false
zstyle ':completion:*:git-rebase:*'    sort false
zstyle ':completion:*:descriptions'    format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# preview
zstyle ':fzf-tab:*:*'                         fzf-flags   '--style=default' '--no-scrollbar' '--info=right'
zstyle ':fzf-tab:complete:*'                  fzf-preview '~/.local/bin/fzf_preview_wrapper ${realpath:-$word}'
zstyle ':fzf-tab:complete:(\\|*/|)man:*'      fzf-preview 'man $word'
zstyle ':fzf-tab:complete:help:*'             fzf-preview 'help $word'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:*:options'          fzf-preview ''
zstyle ':fzf-tab:complete:*:argument-1'       fzf-preview ''

# git
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*'                fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*'               fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag" git show --color=always $word ;;
	* git show --color=always $word | delta ;;
esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
esac'

# load completions
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"
autoload -Uz compinit
compinit -d $ZSH_COMPDUMP


# options
setopt extendedglob         # extend glob patterns
setopt dot_glob             # let globs match dotfiles
setopt globdots             # show dotfiles on tab completion
setopt autocd               # cd in a directory by typing its name
setopt auto_pushd           # automatically push the last directory on the directory stack
setopt cdable_vars          # cd to a directory by typing its path relative to $HOME
setopt pushd_silent         # do not print the directory stack after pushd or popd
setopt correct              # correction for invalid command names
setopt rcquotes             # escape single quotes with '' instead of '\'' in singly quoted strings
setopt c_bases              # use 0x for displaying hexadecimal numbers
setopt octal_zeroes         # use 0 for displaying octal numbers
setopt interactive_comments # enable comments in interactive shells


# history
HISTSIZE=10000
HISTFILE=$HOME/.local/state/zsh/zsh_history
[[ -f $HISTFILE ]] || mkdir -p $(dirname $HISTFILE)
SAVEHIST=$HISTSIZE
HISTDUP=erase
HIST_STAMPS="dd/mm/yyyy"
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


# Vi mode and cursor style
bindkey -v # enable vi keybindings
KEYTIMEOUT=1 # time in ms to wait for key sequences
zle_highlight=(region:bg="#223249" fg=15) # visual mode highlight color

function zle-keymap-select() {
	local _shape=6
	case "${KEYMAP}" in
		vicmd)
			case "${REGION_ACTIVE}" in
				1) _shape=2 ;; # visual mode: block
				2) _shape=2 ;; # V-line mode: block
				*) _shape=2 ;; # normal mode: block
			esac
			;;
		viins|main)
			if [[ "${ZLE_STATE}" == *overwrite* ]]; then
				_shape=4 # replace mode: underline
			else
				_shape=6 # insert mode: beam
			fi
			;;
		viopp) _shape=0 ;; # operator pending mode: blinking block
		visual) _shape=2 ;; # visual mode: block
	esac
	printf $'\e[%d q' ${_shape}
}
zle -N zle-keymap-select

function _set_cursor_beam() {
	echo -ne '\e[6 q'
}
precmd_functions+=(_set_cursor_beam)

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^x^e" edit-command-line


# title
autoload -Uz add-zsh-hook

function _precmd_title() {
  print -Pn "\e]0; %~\a"
}
function _preexec_title() {
  print -Pn "\e]0; $2\a"
}

add-zsh-hook precmd _precmd_title
add-zsh-hook preexec _preexec_title


# setup programs
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
[[ -f "$ZDOTDIR/p10k.zsh" ]] && source "$ZDOTDIR/p10k.zsh"

# config files
source "$ZDOTDIR/keybinds.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/aliases.zsh"
