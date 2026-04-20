bindkey '^p'  history-search-backward                     \
        '^n'  history-search-forward                      \
        '\cb' beginning-of-line                           \
        '\ce' end-of-line                                 \
        '\ei' beginning-of-line                           \
        '\ea' end-of-line                                 \
        '\ef' forward-word                                \
        '\eb' backward-word                               \
        '^Z'  undo                                        \
        '^?'  backward-delete-char # fix backspace at the beginning of a new line

bindkey -M vicmd '^[[A' history-beginning-search-backward \
                 '^[[B' history-beginning-search-forward

bindkey -a -r ':' # disable vicmd mode

# open cmd in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey          '^x' edit-command-line
bindkey -M vicmd '^x' edit-command-line

# plugins
bindkey '\ee'  autosuggest-accept                        \
        '^[^M' autosuggest-execute                       \
        '^[[A' history-substring-search-up               \
        '^[[B' history-substring-search-down             \

# \c   -> Ctrl
# \e   -> Meta
# ^[^M -> Meta+<CR>
