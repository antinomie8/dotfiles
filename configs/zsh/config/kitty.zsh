local spacing=20
function _kitty_spacing() {
	if [[ -z $NVIM && -z $TMUX && -n $KITTY_LISTEN_ON ]]; then
		kitty @ --to $KITTY_LISTEN_ON set-spacing --match "id:$KITTY_WINDOW_ID" padding=$1
	fi
}

_kitty_spacing $spacing

function zshexit() {
	if [[ -n $YAZI_ID && $(ps -p $PPID -o comm=) == "yazi" ]]; then
		# parent process is yazi
		_kitty_spacing 0
	fi
}

function _tui_handle_spacing() {
	local cmd=$1
	shift
	_kitty_spacing 0
	SPACING=ok command $cmd $@
	_kitty_spacing $spacing
}

#########################################

function nvim() {
	if (( ${@[(Ie)--headless]} )); then
		command nvim $@
	else
		_tui_handle_spacing nvim $@
	fi
}
function lazygit() {
	local repo
	if repo=$(git rev-parse --show-toplevel 2>/dev/null); then
		print -Pn "\e]0; $(basename $repo)\a"
		export LAZYGIT=$repo
		_tui_handle_spacing lazygit $@
		unset LAZYGIT
	else
		echo "Error: must be run inside a git repository"
	fi
}
function btop() {
	print -Pn "\e]0; top\a"
	_tui_handle_spacing btop $@
}
alias neomutt="TERM=xterm-direct _tui_handle_spacing neomutt"
local tuis=(yazi ncdu aerc tmux)
for tui in $tuis; do
	alias $tui="_tui_handle_spacing $tui"
done
