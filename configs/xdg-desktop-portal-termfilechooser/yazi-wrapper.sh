#!/usr/bin/env bash
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`

set -e

if [[ "$6" -ge 4 ]]; then
	set -x
fi

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

if [[ "$save" = "1" ]]; then
	if [[ "$directory" = "1" ]]; then
		title="Save as"
	else
		title="Save "
		if [[ "$multiple" = "1" ]]; then
			title+="files"
		else
			title+="file"
		fi
	fi
else
	title="Open "
	if [[ "$directory" = "1" ]]; then
		if [[ "$multiple" = "1" ]]; then
			title+="directories"
		else
			title+="directory"
		fi
	else
		if [[ "$multiple" = "1" ]]; then
			title+="files"
		else
			title+="file"
		fi
	fi
fi

cmd="yazi"
termcmd="${TERMCMD:-kitty --class yazi --title \"$title\"}"

if [[ "$save" = "1" ]]; then
	# save a file
	set -- --chooser-file="$out" "$path"
elif [[ "$directory" = "1" ]]; then
	# upload files from a directory
	set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
elif [[ "$multiple" = "1" ]]; then
	# upload multiple files
	set -- --chooser-file="$out" "$path"
else
	# upload only 1 file
	set -- --chooser-file="$out" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
	# escape double quotes
	escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
	# escape special
	command="$command \"$escaped\""
done

sh -c "$command"

if [[ "$directory" = "1" ]]; then
	if [[ ! -s "$out" ]] && [[ -s "$out"".1" ]]; then
		cat "$out"".1" >"$out"
		rm "$out"".1"
	else
		rm "$out"".1"
	fi
fi
