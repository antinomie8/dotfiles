# Custom widget to skip duplicates when going up
up-line-skip-dups() {
	local prev_buffer=$BUFFER
	local prev_histno=$HISTNO
	zle up-line-or-search
	while [[ "$BUFFER" == "$prev_buffer" ]] && [[ $HISTNO -ne $prev_histno ]]; do
		prev_histno=$HISTNO
		zle up-line-or-search
	done
}
zle -N up-line-skip-dups
bindkey '^[[A' up-line-skip-dups # Bind to Up Arrow

# Custom widget to skip duplicates when going down
down-line-skip-dups() {
	local prev_buffer=$BUFFER
	local prev_histno=$HISTNO
	zle down-line-or-search
	while [[ "$BUFFER" == "$prev_buffer" ]] && [[ $HISTNO -ne $prev_histno ]]; do
		prev_histno=$HISTNO
		zle down-line-or-search
	done
}
zle -N down-line-skip-dups
bindkey '^[[B' down-line-skip-dups # Bind to Down Arrow
