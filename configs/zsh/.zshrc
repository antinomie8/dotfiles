# terminal emulator specific settings
[[ $TERM == "xterm-kitty" ]] && source $ZDOTDIR/config/kitty.zsh

# source Powerlevel10k's instant prompt
if [[ -r ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh ]]; then
	source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh
fi

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
		viins | main)
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

# completions
source $ZDOTDIR/config/completions.zsh

# config files
source $ZDOTDIR/config/keybinds.zsh
source $ZDOTDIR/config/functions.zsh
source $ZDOTDIR/config/aliases.zsh
autoload -Uz $ZDOTDIR/functions/*(:t)

# setup plugins and tools
eval "$(zsh-patina activate)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"
source $ZDOTDIR/plugins/p10k.zsh
source $ZDOTDIR/plugins/atuin.zsh
source $ZDOTDIR/plugins/rationalize-dot.zsh

# options and modules
opts=(
	"dot_glob"           # let globs match dotfiles
	"globdots"           # show dotfiles on tab completion
	"autocd"             # cd in a directory by typing its name
	"auto_pushd"         # automatically push the last directory on the directory stack
	"cdable_vars"        # cd to a directory by typing its path relative to $HOME
	"pushd_silent"       # do not print the directory stack after pushd or popd
	"correct"            # correction for invalid command names
	"rcquotes"           # escape single quotes with '' instead of '\'' in singly quoted strings
	"c_bases"            # use 0x for displaying hexadecimal numbers
	"octal_zeroes"       # use 0 for displaying octal numbers
	"extended_history"   # save timestamp and command execution duration to history
	"complete_in_word"   # complete missing letters before cursor with <tab>

	"share_history"      # share history between sessions
	"hist_ignore_space"  # don't save commands starting with a space
	"inc_append_history" # write directly to the history file
	"hist_expand"        # expand !n
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
PROMPT_EOL_MARK="$fg[yellow] "

# history
HISTFILE=$XDG_STATE_HOME/zsh/zsh_history
[[ -f $HISTFILE ]] || mkdir -p $(dirname $HISTFILE)
HISTSIZE=1000000
SAVEHIST=$HISTSIZE
HISTDUP=erase
HIST_STAMPS="dd/mm/yyyy"
