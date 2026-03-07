#!/usr/bin/env bash

WS=$(hyprctl activeworkspace -j | jq '.id')
STATE_FILE="${TMPDIR:-/tmp}/hyprland.toggle_fullspace"

if [[ -f "$STATE_FILE" ]]; then
	gapsin=$(hyprctl getoption general:gaps_in -j | jq '.custom')
	gapsout=$(hyprctl getoption general:gaps_out -j | jq '.custom')
	hyprctl dispatch global quickshell:barOpenForWorkspace
	hyprctl -r keyword workspace "$WS", gapsin:"${gapsin:1:-1}", gapsout:"${gapsout:1:-1}", rounding:true, decorate:true, border:true
	rm "$STATE_FILE"
else
	hyprctl dispatch global quickshell:barCloseForWorkspace
	hyprctl -r keyword workspace "$WS", gapsin:0, gapsout:0, rounding:false, decorate:false, border:false
	touch "$STATE_FILE"
fi
