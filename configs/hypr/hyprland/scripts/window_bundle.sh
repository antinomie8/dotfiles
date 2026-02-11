#!/usr/bin/env bash
curr_workspace="$(hyprctl activeworkspace -j | jq -r ".id")"

size=${1:1}
target_workspace=$((((curr_workspace + 1) / size + 1) * size + 1))

[[ ${1:0:1} == "-" ]] && ((target_workspace -= size))
if [[ ${1:0:1} == "-" && $target_workspace -gt $size ]]; then
	((target_workspace -= size))
fi

hyprctl dispatch workspace $target_workspace
