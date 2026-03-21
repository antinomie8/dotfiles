# terminal emulator specific settings
[[ "$TERM" == "xterm-kitty" && -f "$ZDOTDIR/misc/kitty.zsh" ]] && source "$ZDOTDIR/misc/kitty.zsh"

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
antidote load $ZDOTDIR/plugins/plugins


eval "$(dircolors "$ZDOTDIR/misc/dircolors")" # colorize completion menu entries
LS_COLORS="=*/.[^/]#=38;2;114;113;105:=.[^/]#=38;2;114;113;105:$LS_COLORS" # colorize dotfiles in gray

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
zstyle ':completion:*'                 list-colors ${(s.:.)LS_COLORS}

# preview
zstyle ':fzf-tab:*:*'                         fzf-flags   '--style=default' '--no-scrollbar' '--info=right'
zstyle ':fzf-tab:complete:*'                  fzf-preview '~/.local/bin/fzf_preview_wrapper ${realpath:-$word}'
zstyle ':fzf-tab:complete:(\\|*/|)man:*'      fzf-preview 'man $word'
zstyle ':fzf-tab:complete:help:*'             fzf-preview 'help $word'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w'
zstyle ':fzf-tab:complete:oly:*'              fzf-preview 'oly show $word'
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
setopt EXTENDEDGLOB         # extend glob patterns
setopt DOT_GLOB             # let globs match dotfiles
setopt GLOBDOTS             # show dotfiles on tab completion
setopt AUTOCD               # cd in a directory by typing its name
setopt AUTO_PUSHD           # automatically push the last directory on the directory stack
setopt CDABLE_VARS          # cd to a directory by typing its path relative to $HOME
setopt PUSHD_SILENT         # do not print the directory stack after pushd or popd
setopt CORRECT              # correction for invalid command names
setopt RCQUOTES             # escape single quotes with '' instead of '\'' in singly quoted strings
setopt C_BASES              # use 0x for displaying hexadecimal numbers
setopt OCTAL_ZEROES         # use 0 for displaying octal numbers
setopt EXTENDED_HISTORY     # save timestamp and command execution duration to history
setopt INC_APPEND_HISTORY   # write directly to the history file
setopt COMPLETE_IN_WORD     # complete missing letters before cursor with <tab>
setopt HIST_EXPAND          # expand !n

autoload -Uz zargs          # zargs [options] -- PATTERN -- COMMAND --
autoload -Uz regexp-replace # regexp-replace VARNAME REGEXP REPLACE
autoload -Uz zcalc          # Zsh calculator
zmodload zsh/mapfile        # $mapfile[path/to/file] contains path/to/file's contents

# autocorrect
autoload -U colors && colors
SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [Yes, No, Abort, Edit]: "

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


# Vi mode and cursor style
bindkey -v # enable vi keybindings
KEYTIMEOUT=1 # time in ms to wait for key sequences
zle_highlight=(region:bg="#223249" fg=15) # visual mode highlight color

function zle-keymap-select() {
	local shape=6
	case "${KEYMAP}" in
		vicmd)
			case "${REGION_ACTIVE}" in
				1) shape=2 ;; # visual mode: block
				2) shape=2 ;; # V-line mode: block
				*) shape=2 ;; # normal mode: block
			esac
			;;
		viins|main)
			if [[ "${ZLE_STATE}" == *overwrite* ]]; then
				shape=4 # replace mode: underline
			else
				shape=6 # insert mode: beam
			fi
			;;
		viopp) shape=0 ;; # operator pending mode: blinking block
		visual) shape=2 ;; # visual mode: block
	esac
	printf $'\e[%d q' ${shape}
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
source "$ZDOTDIR/plugins/p10k.zsh"
source "$ZDOTDIR/plugins/atuin.zsh"

# config files
source "$ZDOTDIR/config/keybinds.zsh"
source "$ZDOTDIR/config/functions.zsh"
source "$ZDOTDIR/config/aliases.zsh"
autoload -Uz $ZDOTDIR/functions/*(:t)
