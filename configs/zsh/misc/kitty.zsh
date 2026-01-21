function kitty_set_spacing() {
	if [[ -z "$NVIM" && -z "$TMUX" && -n "$KITTY_LISTEN_ON" ]]; then
		kitty @ --to $KITTY_LISTEN_ON set-spacing padding=20
	fi
}
function kitty_remove_spacing() {
	if [[ -z "$NVIM" && -z "$TMUX" && -n "$KITTY_LISTEN_ON" ]]; then
		kitty @ --to $KITTY_LISTEN_ON set-spacing padding=0
	fi
}

kitty_set_spacing

function nvim() {
	kitty_remove_spacing
	command nvim "$@"
	kitty_set_spacing
}
# function sudoedit() {
# 	kitty_remove_spacing
# 	command sudoedit "$@"
# 	kitty_set_spacing
# }
function yazi() {
	kitty_remove_spacing
	command yazi "$@"
	kitty_set_spacing
}
function lazygit() {
	kitty_remove_spacing
	command lazygit "$@"
	kitty_set_spacing
}
function btop() {
	kitty_remove_spacing
	command btop "$@"
	kitty_set_spacing
}
function man() {
	kitty_remove_spacing
	command man "$@"
	kitty_set_spacing
}
function ncdu() {
	kitty_remove_spacing
	command ncdu "$@"
	kitty_set_spacing
}
function neomutt() {
	kitty_remove_spacing
	TERM=xterm-direct command neomutt "$@"
	kitty_set_spacing
}
function aerc() {
	kitty_remove_spacing
	command aerc "$@"
	kitty_set_spacing
}
function cxxmatrix() {
	kitty_remove_spacing
	command cxxmatrix "$@"
	kitty_set_spacing
}
function tmux() {
	kitty_remove_spacing
	command tmux "$@"
	kitty_set_spacing
}
