ZSH_CACHE_HOME="$XDG_CACHE_HOME/zsh"

# colors
eval "$(dircolors "$ZDOTDIR/config/colors/dircolors")" # colorize completion menu entries
LS_COLORS="*/.[^/]#=38;2;114;113;105:=.[^/]#=38;2;114;113;105:$LS_COLORS" # colorize dotfiles in gray

# completions
zstyle ':completion:*'                    use-cache on
zstyle ':completion:*'                    cache-path $ZSH_CACHE_HOME/zcompcache
zstyle ':completion:*'                    matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*'                    complete-options true
zstyle ':completion:*'                    menu no
zstyle ':completion:*:*:*:*:processes'    command 'ps -u $USER -o pid,user,comm -w -w'
zstyle ':completion:*:descriptions'       format '[%d]'
zstyle ':completion:*'                    list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*'                    sort false
zstyle ':completion:*:ls:*'               list-dirs-first true
zstyle ':completion:*:-command-:*:*'      file-patterns \
	'*(-*x):executables' '*:all-files'      # suggest executables rather than files when completing a command

# commands
zstyle ':completion:*:*:just:*:arguments' ignored-patterns '-*'

# preview
zstyle ':fzf-tab:*:*'                     fzf-flags   '--style=default' '--no-scrollbar' '--info=right'
zstyle ':fzf-tab:complete:*:*'            fzf-preview '
	# colors (use \033 instead of \e for awk)
	BLUE="\033[34m"
	OCHRE="\033[33m"
	ITALIC="\033[3m"
	RESET="\033[0m"

	# if $realpath is set, complete a path
	[[ -n $realpath ]] && group="[file]"

	case $group in
		"[file]")
			~/.local/bin/fzf_preview $realpath
			;;
		"[parameter]")
			case $word in
				path|PATH)
					echo -e ${PATH//:/\\n}
					;;
				fpath|FPATH)
					echo ${(F)fpath}
					;;
				*)
					printenv $word
					;;
			esac
			;;
		"command]" | "[executable file]")
				(# search for --help flag in the file
					strings $(whence -p $word) | rg --quiet --fixed-strings -- "--help" && \
					# sandbox
					bwrap \
						--unshare-all \
						--ro-bind / / \
						--chdir $PWD \
						--tmpfs /tmp \
						--dev /dev \
						--proc /proc \
						--unshare-net \
						$word --help | bat --plain --language=help) || \
					(MANWIDTH=$FZF_PREVIEW_COLUMNS man $word 2>/dev/null | bat -plman --color=always) || \
					(out=which $word && echo $out) || \
					echo ${(P)word}
			;;
		"[shell function]")
			autoload +X $word
			which $word | bat --plain --language=zsh 
			;;
		"[alias]" | "[regular alias]")
			source $ZDOTDIR/config/aliases.zsh
			if [[ $aliases[$word] ]]; then
				out="$aliases[$word]"
			else
				ABBR_USER_ABBREVIATIONS_FILE="$ZDOTDIR/config/abbreviations.zsh"
				fpath+=("$HOME/.local/share/zsh/antidote//github.com/olets/zsh-abbr")
				source "$HOME/.local/share/zsh/antidote/github.com/olets/zsh-abbr/zsh-abbr.plugin.zsh"
				out=$(abbr expand $word)
			fi
			if [[ -n $out ]]; then
				echo -en "$BLUE$word $OCHRE$ITALIC-> $RESET"
				echo $out | bat --plain --language=zsh
			fi
			;;
		"[process ID]")
				ps --pid=$word \
					-o pid= -o ppid= -o user= -o %cpu= -o %mem= -o etime= -o stat= -o cmd= -ww |
				awk -v OCHRE="$OCHRE" -v BLUE="$BLUE" -v RESET="$RESET" "{
					pid=\$1; ppid=\$2; user=\$3; cpu=\$4; mem=\$5; time=\$6; state=\$7
					\$1=\$2=\$3=\$4=\$5=\$6=\$7=\"\"
					sub(/^ +/, \"\")
					cmd=\$0

					printf \"%sCmd%s:   %s%s%s\n\",   OCHRE, RESET, BLUE, cmd, RESET
					printf \"%sCPU%s:   %s%s%s\n\",   OCHRE, RESET, BLUE, cpu, RESET
					printf \"%sMEM%s:   %s%s%s\n\",   OCHRE, RESET, BLUE, mem, RESET
					printf \"%sTime%s:  %s%s%s\n\",   OCHRE, RESET, BLUE, time, RESET
					printf \"%sState%s: %s%s%s\n\",   OCHRE, RESET, BLUE, state, RESET
					printf \"%sPID%s:   %s%s%s\n\",   OCHRE, RESET, BLUE, pid, RESET
					printf \"%sPPID%s:  %s%s%s\n\",   OCHRE, RESET, BLUE, ppid, RESET
					printf \"%sUser%s:  %s%s%s\n\",   OCHRE, RESET, BLUE, user, RESET
				}"
			;;
		"[unit]" | *" unit]")
			SYSTEMD_COLORS=1 systemctl status $word
			;;
		*)
			echo ${group:1:-1}
			;;
	esac'
zstyle ':fzf-tab:complete:*:options'    fzf-preview 
# zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
# zstyle ':fzf-tab:complete:-command-:*'  fzf-preview

# commands preview
zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'MANWIDTH=$FZF_PREVIEW_COLUMNS man $word'
zstyle ':fzf-tab:complete:help:*'        fzf-preview '$word --help 2>/dev/null | bat --plain --language=help'
zstyle ':fzf-tab:complete:oly:*'         fzf-preview '
	case $group in
		"[problem]") oly show $word --color=always ;;
		"[subcommand]") oly $word --help ;;
	esac'
# git
zstyle ':fzf-tab:complete:git:argument-1'           fzf-preview 'git $word --help | bat -plman'
zstyle ':fzf-tab:complete:git-help:*'               fzf-preview 'git help $word | bat -plman'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $realpath 2>/dev/null | delta'
zstyle ':fzf-tab:complete:git-log:*'                fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-show:*'               fzf-preview '
	case $group in
		"commit tag") git show --color=always $word ;;
		*) git show --color=always $word | delta ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*'           fzf-preview '
	case $group in
		"modified file") git diff $word | delta ;;
		"recent commit object name") git show --color=always $word | delta ;;
		*) git log --color=always $word ;;
	esac'

# load completions
[[ -d $ZSH_CACHE_HOME ]] || mkdir -p $ZSH_CACHE_HOME
autoload -Uz compinit
compinit -d $ZSH_CACHE_HOME/zcompdump
