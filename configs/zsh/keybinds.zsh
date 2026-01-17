bindkey "^p" history-search-backward
bindkey "^n" history-search-forward
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

bindkey "\cb" beginning-of-line
bindkey "\ce" end-of-line
bindkey "\ei" beginning-of-line
bindkey "\ea" end-of-line
bindkey "\ef" forward-word
bindkey "\eb" backward-word
bindkey '^Z' undo

bindkey " " magic-space
bindkey -a -r ':'                 # disable vicmd mode
bindkey "^?" backward-delete-char # fix backspace in insert mode

# Alt-Enter: Execute what's been typed even if it's malformed.
bindkey '^[^J' accept-line
bindkey '^[^M' accept-line

# plugins
bindkey "\ee" autosuggest-accept

[[ -v terminfo ]] || zmodload zsh/terminfo
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down
if [[ -n "$terminfo[kcuu1]" ]]; then
	bindkey -M viins "$terminfo[kcuu1]" history-substring-search-up
fi
if [[ -n "$terminfo[kcud1]" ]]; then
	bindkey -M viins "$terminfo[kcud1]" history-substring-search-down
fi
