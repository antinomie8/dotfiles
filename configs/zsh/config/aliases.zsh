# global aliases
alias -g C='| wc -l'
alias -g NUL='>/dev/null 2>&1'
alias -g gr="| rg"

# suffix aliases
alias -s {c,cpp,asm,typ,tex}='nvim'
alias -s {jpeg,jpg,JPEG,JPG,png,gif,xpm}='imv'
alias -s {avi,AVI,Avi,divx,DivX,mkv,mpg,mpeg,wmv,WMV,mov,rm,flv,ogm,ogv,mp4}='mpv'
alias -s {json,jsonc}='view_json'
alias -s pdf='zathura'

# zmv
autoload -Uz zmv
alias zmv='zmv -w'
alias zcp='zmv -C' # Copy with patterns
alias zln='zmv -L' # Link with patterns

# shortcuts
alias _='sudo'
alias __='sudoedit'
alias q='exit'
alias -- +x='chmod u+x'
alias -- -x='chmod u+x'
alias path='echo -e ${PATH//:/\\n}' # human-readable path
alias uncompress='tar -xvzf'
alias soft-reboot='systemctl soft-reboot'
function {
	local dots='..'
	local back='../'
	local i
	for i in {1..7}; do
		alias $dots="cd $back"
		dots="$dots."
		back="$back../"
	done
}

# CLI tools default options
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias run='runapp --dir "$(pwd)" --'
alias mime='file --mime-type --brief'

# programs
alias top='btop'
alias fetch='fastfetch'
alias lg='lazygit'
alias py='python3'
alias m='nvim -c Inbox'
alias copy='wl-copy'
alias paste='wl-paste'

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
