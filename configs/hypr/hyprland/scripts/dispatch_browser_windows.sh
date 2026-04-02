#!/bin/bash

declare -A workspaces=(
	["[Maths]"]=2
	["[Divers]"]=3
	["[Administratif]"]=4
	["[Info]"]=5
)
browser_name="Mozilla Firefox"

############################################

function get_matching_window_addresses_and_move_them_to_workspace() {
	local title_match=$1
	local workspace_name=$2

	# Retrieve the window address using the passed title pattern
	for address in $(hyprctl clients -j | jq -r --arg title "$title_match" --arg browser "$browser_name" \
		'.[] | select(.title | contains($title) and contains($browser)) | .address'); do
		move_window_to_workspace "$address" "$workspace_name"
	done
}

function move_window_to_workspace() {
	local window_address=$1
	local workspace_name=$2

	# Get the current workspace name where the window address is
	local current_workspace=$(hyprctl clients -j | jq -r --arg address "$window_address" '.[] | select(.address == $address) | .workspace.name')

	# Check if window is not at desired workspace
	if [[ "$current_workspace" != "$workspace_name" ]]; then
		# Move window to workspace
		hyprctl dispatch movetoworkspacesilent "$workspace_name",address:"$window_address"
	fi
}

# Start reading events from the Hyprland socket
function handle() {
	if [[ $1 = windowtitle* ]]; then
		for title in "${!workspaces[@]}"; do
			get_matching_window_addresses_and_move_them_to_workspace "$title" "${workspaces[$title]}"
		done
	fi
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
	handle "$line"
done
