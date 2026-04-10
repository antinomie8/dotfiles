# misc
function compile() {
	local file_extension=${1:e}
	local ouput_filename=${1:r}
	case $file_extension in
		cpp)
			local compiler="g++"
			;;
		c)
			local compiler="gcc"
			;;
		asm)
			local compiler="assemble"
			;;
		*)
			echo "file extension not recognized"
			;;
	esac
	[[ -n $compiler ]] && command $compiler $1 -o $ouput_filename
}
function view_json() {
	jq . $1 -C | less -R
}
function bak() {
	mv $1{,.bak}
}
function weather {
  curl --silent "http://wttr.in/$1" | head -n -2
}

# cd
function c() {
	if [[ $# == 0 ]]; then
		clear
	else
		cd $@
	fi
}
function cfd() {
	cd "$(fd . -td | fzf --no-multi --query=$1)"
}
function mkcd() {
	[[ $# ==  0 ]] && echo "mkcd: missing operand"
	[[ $# -ge 2 ]] && echo "mkcd: too many operands"
	[[ $# -ne 1 ]] && return 1
	mkdir -p $1  && cd $1
}

# rm that only asks for confirmation for nonempty files
alias rm=rm_confirm_nonempty
function rm_confirm_nonempty() {
	local args=()
	local items=()
	while (($#)); do
		if [[ $1 =~ ^- ]]; then
			args+=($1)
		else
			items+=($1)
		fi
		shift
	done
	for element ($items[@]); do
	if [[ (-e "$element" && ! -s "$element") || ${#items[@]} == 1 ]]; then
			command rm -f ${args[@]} $element
		else
			command rm -i ${args[@]} $element
		fi
	done
}

# help command using bat
function help() {
	$@ --help 2>/dev/null | bat --plain --language=help --paging=always
}

# find and replace
function far() {
	[[ ! -d "$1" ]] && echo "Usage: far /path/to/directory/ regexp replacement"
	sed -i -e "s@$2@$3@g" "$(rg "$2" "$1" -l --fixed-strings)"
}

# git
function gacp() {
	git add .
	git commit -m $@
	git push
}
function clone() {
	[[ $# == 0 ]] && { echo "clone: missing operand"; return 1 }
	[[ $# > 2 ]]  && { echo "clone: too many operands"; return 1 }

	local repo_name
	if [[ $1 =~ ^[A-Za-z0-9._-]+:([^/][/A-Za-z0-9._-]*)$ ]]; then
		# git url insteadOf
		repo_name=$match[1]
	else
		repo_name=${1:t}
		if [[ $1 =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]]; then
			# repo/owner format
			1="gh:$1"
		fi
	fi

	local dir=${2:-$HOME/Téléchargements/git/$repo_name}
	if [[ $dir == '.' ]]; then
		dir=$repo_name # clone in cwd
	fi
	if [[ (-z $2 || $2 == '.') && $dir =~ ^(.*)\.git$ ]]; then
		dir=$match[1] # strip trailing .git
	fi

	git clone $1 $dir && cd $dir
}
function gitdot() {
	if [[ $# == 0 ]]; then
		git_dotfiles
		if cd ~/.config/dotfiles; then
			lazygit
			cd - >/dev/null
		fi
	else
		git_dotfiles $@
	fi
}
function ghfork() {
	local url="$(git config --get remote.origin.url)"
	if [[ $url =~ (github\.com|^gh).*/([^/]*)$ ]]; then
		echo "n" | gh repo fork $url
		git remote remove origin
		git remote add origin me:"$match[2]"
		local cur_branch="$(git branch --show-current)"
		case $cur_branch in
			main|master)
				local new_branch
				echo -en "Enter new branch name: "
				read -r new_branch
				git switch -c $new_branch
				git push -u origin $new_branch
				;;
			*)
				echo $cur
				git push -u origin $cur_branch
				;;
		esac
	else
		return 1
	fi
}

# Neovim
function nfd() {
	local lines=()
	if [[ $# == 0 ]]; then
	   lines+=( ${(f)"$(fd . --print0 --type f | fzf --read0 --multi --select-1 )"} )
	fi
	for arg in $@ ; do
	  lines+=(
			${(f)"$(
				fd . --hidden --print0 --strip-cwd-prefix=always --type=f |
				fzf --read0 --multi --select-1 --query=$arg
			)"}
		)
	done
	if [[ ${#lines} != 0 ]]; then
		nvim $lines
	fi
}
function viml() {
	file_and_line=$1
	file="$(echo $file_and_line | cut -d: -f1)"
	line="$(echo $file_and_line | cut -d: -f2)"

	nvim $file +$line
}

# yazi
function x() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi $@ --cwd-file=$tmp
	if cwd="$(command cat -- $tmp)" && [ -n $cwd ] && [ $cwd != $PWD ]; then
		builtin cd -- $cwd
	fi
	command rm -f -- $tmp
}

# pandoc
function pdfconvert() {
	[[ $# ==  0 ]] && echo "pdfconvert: expected filename"
	[[ $# -ne 1 ]] && return 1
	while (($#)); do
		local input=$1
		local ext=${1:e}
		pandoc --from $ext --to pdf $1 --output ${1:r}.pdf
		shift
	done
}
