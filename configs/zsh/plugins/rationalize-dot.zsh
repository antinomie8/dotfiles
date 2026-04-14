function expand-dots() {
	local MATCH
	if [[ $LBUFFER =~ '(^| )\.\.\.+' ]]; then
		LBUFFER=$LBUFFER:fs%\.\.\.%../../%
	fi
}

function expand-dots-then-expand-or-complete() {
	zle expand-dots
	zle fzf-tab-complete
}

function expand-dots-then-accept-line() {
	zle expand-dots
	zle .zsh-no-ps2
}

zle -N expand-dots
zle -N expand-dots-then-expand-or-complete
zle -N expand-dots-then-accept-line
bindkey '^I' expand-dots-then-expand-or-complete
bindkey '^M' expand-dots-then-accept-line
