###################################################################################################
############################################# Aliases #############################################
###################################################################################################

# global aliases
alias -g C='| wc -l'
alias -g NUL=">/dev/null 2>&1"

# shortcuts
alias     q="exit"
alias     c="clear"
alias -- +x="chmod u+x"
dots="..";
back="../"
for i in {1..7}; do
	alias $dots="cd $back"
	dots="$dots."
	back="$back../"
done
alias 'gitcd'='cd "$(git rev-parse --show-toplevel)"'

# miscellaneous
function cfd() {
	cd "$(fd . -td | fzf --no-multi --query="$1")"
}
function mkcd() {
	[[ $# ==  0 ]] && echo "mkcd: missing operand"
	[[ $# -ge 2 ]] && echo "mkcd: too many operands"
	[[ $# -ne 1 ]] && return 1
	mkdir -p "$1"  && cd "$1"
}
function run() {
	[[ $# == 0 ]] && { echo "run: missing operand"; return 1 }
	command="$1"
	shift
	nohup "$command" $@ >/dev/null 2>&1 &
}
function compile() {
	local file_extension="$1:e"
	local ouput_filename="$1:r"
	case "$file_extension" in
		cpp)
			local compiler="g++"
			;;
		c)
			local compiler="gcc"
			;;
		asm)
			local compiler="assemble"
			;;
		*)
			echo "file extension not recognized"
			;;
	esac
	[[ -n "$compiler" ]] && command "$compiler" "$1" -o "$ouput_filename"
}
alias path='echo -e ${PATH//:/\\n}' # human-readable path

# rm that only asks for confirmation for nonempty files
alias rm=rm_confirm_nonempty
function rm_confirm_nonempty() {
	local args=()
	local items=()
	while (($#)); do
		if [[ "$1" =~ ^- ]]; then
			args+=("$1")
		else
			items+=("$1")
		fi
		shift
	done
	for element ("$items[@]"); do
	if [[ (-e "$element" && ! -s "$element") || ${#items[@]} == 1 ]]; then
			command rm -f "${args[@]}" "$element"
		else
			command rm -i "${args[@]}" "$element"
		fi
	done
}

# help command using bat
function help() {
	$@ --help 2>/dev/null | bat --plain --language=help --paging=always
}

# find and replace
function far() {
	[[ ! -d "$1" ]] && echo "Usage: far /path/to/directory/ regexp replacement"
	sed -i -e "s@$2@$3@g" "$(rg "$2" "$1" -l --fixed-strings)"
}

# CLI tools default options
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias fzf="fzf --preview='~/.local/bin/fzf_preview_wrapper {}'"

# programs
alias top="btop"
alias fetch="fastfetch"
alias lg="lazygit"
alias py="python3"
alias mutt="neomutt"
alias m="neomutt"

# eza
alias eza="LS_COLORS= eza" # prevent eza from reading LS_COLORS instead of ~/.config/eza/theme.yml
alias ls="eza --icons=always --group-directories-first --no-quotes"
alias l="eza --icons=always --group-directories-first --no-quotes -a"
alias ll="eza --icons=always --group-directories-first --no-quotes -alh"
alias llg="eza --icons=always --group-directories-first --no-quotes -alh --git"
alias llag="eza --icons=always --group-directories-first --no-quotes -alh --git"
alias tree="eza --icons=always --group-directories-first --no-quotes --tree"

# git
function clone() {
	[[ $# == 0 ]] && { echo "clone: missing operand"; return 1 }
	[[ ! "$1" =~ ^https?:// ]] && 1="https://github.com/$1" # default domain
	dir="${2:-$HOME/Téléchargements/git/${1:t}}"
	[[ "$2" == . || -d "$dir" ]] && dir+="/${1:t}"
	[[ -z "$2" && "$dir" =~ ^(.*)/([^/]+)\.git$ ]] && dir="${match[1]}/${match[2]}" # strip trailing .git, if any
	git clone "$1" "$dir" && cd "$dir"
}
alias gc="git commit"
alias amend="git commit --amend"
alias ga="git add"
alias gb="git branch"
alias gco="git checkout"
alias push="git push"
gacp() {
	git add .
	git commit -m $@
	git push
}
gitdot() {
	if [[ $# == 0 ]]; then
		git_dotfiles
		if cd ~/.config/dotfiles; then
			lazygit
			cd - >/dev/null
		fi
	else
		git_dotfiles $@
	fi
}

# neovim
function nfd() {
	local lines=()
	if [[ $# == 0 ]]; then
	   lines+=( ${(f)"$(fd . --print0 --type f | fzf --read0 --multi --select-1 )"} )
	fi
	for arg in $@ ; do
	  lines+=(
			${(f)"$(
				fd . --print0 --strip-cwd-prefix=always --type=f |
				fzf --read0 --multi --select-1 --query=$arg
			)"}
		)
	done
	if [[ ${#lines} != 0 ]]; then
		nvim $lines
	fi
}
alias vim="nvim"
alias nv="nvim"
alias v="nvim"

# pacman
alias rmpkg="sudo pacman -Rns"
alias sypkg="sudo pacman -S"
alias pacmanclean='sudo pacman -Rns $(pacman -Qtdq)'

# tmux
alias tls="tmux list-session"
alias trs="tmux rename-session"
alias trw="tmux rename-window"
function tns() {
	if [[ $# == 0 ]]; then
		tmux new-session
	else
		tmux new-session -s"$1"
	fi
}
function tas() {
	if [[ -n "$TMUX" ]]; then
		command="switch-client"
	elif ! /bin/tmux run 2>/dev/null; then
		tns $@
		exit
	else
		command="attach-session"
	fi
	tmux $command -t"$(/bin/tmux list-session | fzf --preview='' --select-1 --query="$1" | sed 's/:.*//')"
}
function tmux_choose_pane() {
	local panes current_window current_pane target target_window target_pane
	panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
	current_pane=$(tmux display-message -p '#I:#P')
	current_window=$(tmux display-message -p '#I')

	target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse --preview='') || return

	target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
	target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

	if [[ $current_window -eq $target_window ]]; then
		tmux select-pane -t ${target_window}.${target_pane}
	else
		tmux select-pane -t ${target_window}.${target_pane} &&
			tmux select-window -t $target_window
	fi
}

# yazi
function x() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi $@ --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	/bin/rm -f -- "$tmp"
}

# zathura
alias zathura="run zathura"
