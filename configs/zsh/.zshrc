# terminal emulator specific settings
[[ $TERM == "xterm-kitty" ]] && source $ZDOTDIR/config/kitty.zsh

# source Powerlevel10k's instant prompt
if [[ -r ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh ]]; then
	source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh
fi

# completions
source $ZDOTDIR/config/completions.zsh

# setup plugins and tools
eval "$(zsh-patina activate)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"
source $ZDOTDIR/plugins/p10k.zsh
source $ZDOTDIR/plugins/atuin.zsh
source $ZDOTDIR/plugins/rationalize-dot.zsh

# config files
source $ZDOTDIR/config/keybinds.zsh
source $ZDOTDIR/config/functions.zsh
source $ZDOTDIR/config/aliases.zsh
autoload -Uz $ZDOTDIR/functions/*(:t)

# vi mode and cursor style
bindkey -v   # enable vi keybindings
KEYTIMEOUT=1 # time to wait for key sequences
autoload -Uz add-zsh-hook

function zle-keymap-select {
	local shape=6
	case ${KEYMAP} in
		vicmd)
			case ${REGION_ACTIVE} in
				1) shape=2 ;; # visual mode: block
				2) shape=2 ;; # V-line mode: block
				*) shape=2 ;; # normal mode: block
			esac
			;;
		viins|main)
			if [[ ${ZLE_STATE} == *overwrite* ]]; then
				shape=4 # replace mode: underline
			else
				shape=6 # insert mode: beam
			fi
			;;
		viopp)
			shape=0 ;; # operator pending mode: blinking block
		visual)
			shape=2 ;; # visual mode: block
	esac
	printf $'\e[%d q' ${shape}
}
zle -N zle-keymap-select

function _set_cursor_beam() {
	echo -ne '\e[6 q'
}
add-zsh-hook precmd _set_cursor_beam

# title
function _precmd_title() {
	if [[ $PWD == $HOME ]]; then
		local basename="~/"
	else
		local basename=${PWD:h:t}/${PWD:t}
	fi
	print -Pn "\e]0; $basename\a"
}
function _preexec_title() {
  print -Pn '\e]0; $1\a'
}
add-zsh-hook precmd _precmd_title
add-zsh-hook preexec _preexec_title

# plugins
ABBR_USER_ABBREVIATIONS_FILE="$ZDOTDIR/config/abbreviations.zsh"
ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES=(' ' $'\t') # space and tab
ABBR_SET_EXPANSION_CURSOR=1
ZSH_AUTOSUGGEST_COMPLETION_IGNORE=('*[^_-/[:alpha:]]')

# setup the plugin manager
ANTIDOTE_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/antidote/"
if [[ ! -d $ANTIDOTE_HOME ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote $ANTIDOTE_HOME
fi
source $ANTIDOTE_HOME/antidote.zsh
antidote load $ZDOTDIR/plugins/plugins.zsh $ZDOTDIR/plugins/static.zsh

# options and modules
opts=(
	"EXTENDEDGLOB"       # extend glob patterns
	"DOT_GLOB"           # let globs match dotfiles
	"GLOBDOTS"           # show dotfiles on tab completion
	"AUTOCD"             # cd in a directory by typing its name
	"AUTO_PUSHD"         # automatically push the last directory on the directory stack
	"CDABLE_VARS"        # cd to a directory by typing its path relative to $HOME
	"PUSHD_SILENT"       # do not print the directory stack after pushd or popd
	"CORRECT"            # correction for invalid command names
	"RCQUOTES"           # escape single quotes with '' instead of '\'' in singly quoted strings
	"C_BASES"            # use 0x for displaying hexadecimal numbers
	"OCTAL_ZEROES"       # use 0 for displaying octal numbers
	"EXTENDED_HISTORY"   # save timestamp and command execution duration to history
	"COMPLETE_IN_WORD"   # complete missing letters before cursor with <tab>

	"SHARE_HISTORY"      # share history between sessions
	"HIST_IGNORE_SPACE"  # don't save commands starting with a space
	"INC_APPEND_HISTORY" # write directly to the history file
	"HIST_EXPAND"        # expand !n
)
setopt $opts[@]

mods=( # see man zshcontrib
	"zargs"              # zargs [options] -- PATTERN -- COMMAND --
	"regexp-replace"     # regexp-replace VARNAME REGEXP REPLACE
	"zcalc"              # Zsh calculator
	"colors"             # define color maps
)
autoload -Uz $mods[@]

zmodload zsh/mapfile   # $mapfile[path/to/file] contains path/to/file's contents

# autocorrect
SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [Yes, No, Abort, Edit]: "

# history
HISTFILE=$XDG_STATE_HOME/zsh/zsh_history
[[ -f $HISTFILE ]] || mkdir -p $(dirname $HISTFILE)
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
HISTDUP=erase
HIST_STAMPS="dd/mm/yyyy"
