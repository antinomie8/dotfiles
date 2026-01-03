# suffix aliases
alias -s c='nvim'
alias -s cpp='nvim'
alias -s tex='nvim'
alias -s asm='nvim'
alias -s typ='nvim'
alias -s pdf='zathura'
alias -s json='view_json'
alias -s jsonc='view_json'

# global aliases
alias -g C='| wc -l'
alias -g NUL='>/dev/null 2>&1'

# zmv
autoload -Uz zmv
alias zcp='zmv -C' # Copy with patterns
alias zln='zmv -L' # Link with patterns

# shortcuts
alias _='sudo'
alias q='exit'
alias -- +x='chmod u+x'
alias -- -x='chmod u+x'
dots='..'
back='../'
for i in {1..7}; do
	alias $dots="cd $back"
	dots="$dots."
	back="$back../"
done

alias path='echo -e ${PATH//:/\\n}' # human-readable path
alias uncompress='tar -xvzf'

# CLI tools default options
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias fzf='fzf --preview="~/.local/bin/fzf_preview_wrapper {}"'
alias run='runapp --dir "$(pwd)"'

# programs
alias top='btop'
alias fetch='fastfetch'
alias lg='lazygit'
alias py='python3'
alias m='nvim -c Inbox'

# eza
alias ls='eza --icons=always --group-directories-first --no-quotes'
alias l='eza --icons=always --group-directories-first --no-quotes -a'
alias ll='eza --icons=always --group-directories-first --no-quotes -alh'
alias llg='eza --icons=always --group-directories-first --no-quotes -alh --git'
alias llag='eza --icons=always --group-directories-first --no-quotes -alh --git'
alias tree='eza --icons=always --group-directories-first --no-quotes --tree'

# git
alias g='git'
alias gc='git commit'
alias amend='git commit --amend'
alias ga='git add'
alias gb='git branch'
alias gco='git checkout'
alias push="git push"
alias gcd='cd "$(git rev-parse --show-toplevel)"'

# neovim
alias vim='nvim'
alias nv='nvim'
alias v='nvim'

# pacman
alias rmpkg='sudo pacman -Rns'
alias sypkg='sudo pacman -S'
alias pacmanclean='sudo pacman -Rns $(pacman -Qtdq)'

# zathura
alias zathura='run zathura'
