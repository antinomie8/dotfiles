function kitty_set_spacing() {
	if [[ -z $NVIM && -z $TMUX && -n $KITTY_LISTEN_ON ]]; then
		kitty @ --to $KITTY_LISTEN_ON set-spacing padding=20
	fi
}
function kitty_remove_spacing() {
	if [[ -z $NVIM && -z $TMUX && -n $KITTY_LISTEN_ON ]]; then
		kitty @ --to $KITTY_LISTEN_ON set-spacing padding=0
	fi
}

kitty_set_spacing

function zshexit() {
	if [[ -n "$YAZI_ID" ]]; then
		kitty_remove_spacing
	fi
}

function _tui_handle_spacing() {
	local cmd=$1
	shift 1
	kitty_remove_spacing
	SPACING=ok command $cmd $@
	kitty_set_spacing
}

function nvim() {
	for arg in $@; do
		if [[ $arg == "--headless" ]]; then
			command nvim $@
			return
		fi
	done
	_tui_handle_spacing nvim $@
}
function lazygit() {
	local repo
	if repo=$(git rev-parse --show-toplevel 2>/dev/null); then
		print -Pn "\e]0; $(basename $repo)\a"
		export LAZYGIT=$repo
		kitty_remove_spacing
		_tui_handle_spacing lazygit $@
		kitty_set_spacing
		unset LAZYGIT
	else
		echo "Error: must be run inside a git repository"
	fi
}
function btop() {
	print -Pn "\e]0; top\a"
	_tui_handle_spacing btop $@
}
function neomutt() {
	kitty_remove_spacing
	TERM=xterm-direct command neomutt $@
	kitty_set_spacing
}
alias yazi="_tui_handle_spacing yazi"
alias ncdu="_tui_handle_spacing ncdu"
alias aerc="_tui_handle_spacing aerc"
alias cxxmatrix="_tui_handle_spacing cxxmatrix"
alias tmux="_tui_handle_spacing tmux"
