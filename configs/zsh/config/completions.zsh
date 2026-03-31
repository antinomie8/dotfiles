# colors
eval "$(dircolors "$ZDOTDIR/misc/dircolors")" # colorize completion menu entries
LS_COLORS="=*/.[^/]#=38;2;114;113;105:=.[^/]#=38;2;114;113;105:$LS_COLORS" # colorize dotfiles in gray

# completions
zstyle ':completion:*'                 use-cache on
zstyle ':completion:*'                 cache-path ~/.cache/zsh/completion-cache
zstyle ':completion:*'                 matcher-list "m:{a-z}={A-Za-z}"
zstyle ':completion:*'                 complete-options true
zstyle ':completion:*'                 menu no
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:descriptions'    format '[%d]'
zstyle ':completion:*'                 list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:-command-:*:*'   file-patterns \
	'*(-*x):executables' '*:all-files' # suggest executables rather than files when completing a command

# commands
zstyle ':completion:*:git-checkout:*'  sort false
zstyle ':completion:*:git-rebase:*'    sort false
zstyle ':completion:*:*:just:*:arguments'     ignored-patterns '-*'

# preview
zstyle ':fzf-tab:*:*'                         fzf-flags   '--style=default' '--no-scrollbar' '--info=right'
zstyle ':fzf-tab:complete:*'                  fzf-preview '~/.local/bin/fzf_preview_wrapper ${realpath:-$word}'
zstyle ':fzf-tab:complete:*:options'          fzf-preview 'echo' # disable preview for options

# commands preview
zstyle ':fzf-tab:complete:(\\|*/|)man:*'      fzf-preview 'man $word'
zstyle ':fzf-tab:complete:help:*'             fzf-preview '$word --help 2>/dev/null | bat --plain --language=help'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w'
zstyle ':fzf-tab:complete:oly:*'              fzf-preview \
	'case "$group" in
	"[problem]") oly show $word --color=always ;;
	"[subcommand]") oly $word --help ;;
esac'

# git preview
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*'                fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*'               fzf-preview 'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
esac'

# load completions
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump"
autoload -Uz compinit
compinit -d $ZSH_COMPDUMP
