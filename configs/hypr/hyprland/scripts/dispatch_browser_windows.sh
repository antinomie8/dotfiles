#!/bin/bash

declare -A workspaces=(
	["[Maths]"]=2
	["[Divers]"]=3
	["[Linux]"]=4
)
browser_name="Mozilla Firefox"

############################################

get_window_address_and_move_to_workspace() {
	local title_match=$1
	local workspace_name=$2

	# Retrieve the window address using the passed title pattern
	for address in $(hyprctl clients -j | jq -r --arg title "$title_match" --arg browser "$browser_name" \
		'.[] | select(.title | contains($title) and contains($browser)) | .address'); do
		move_window_to_workspace "$workspace_name" "$address"
	done
}

move_window_to_workspace() {
	local workspace_name=$1
	local window_address=$2

	# Get the current workspace name where the window address is
	current_workspace=$(hyprctl clients -j | jq -r --arg address "$window_address" '.[] | select(.address == $address) | .workspace.name')

	# Check if window is not at desired workspace
	if [[ "$current_workspace" != "$workspace_name" ]]; then
		# Move window to workspace
		hyprctl dispatch movetoworkspacesilent "$workspace_name",address:"$window_address"
	fi
}

# Start reading events from the Hyprland socket
handle() {
	case $1 in
	windowtitle*)
		echo "Detected A Window Title Change"
		for title in "${!workspaces[@]}"; do
			get_window_address_and_move_to_workspace "$title" "${workspaces[$title]}"
		done
		;;
	esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
	handle "$line"
done
