local ws_group = require("hyprland.utils").workspace_group
local vars = require("hyprland.variables")

local numberkey = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
local numpadkey = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }

-----------
-- Shell --
-----------
local qsScripts = "$HOME/.config/quickshell/$qsConfig/scripts"
local hyprScripts = "$HOME/.config/hypr/hyprland/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"

hl.bind("SUPER + SUPER_L", hl.dsp.global("quickshell:searchToggleRelease"), { desc = "Shell: Toggle search" })
hl.bind("SUPER + SUPER_R", hl.dsp.global("quickshell:searchToggleRelease"))
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))
hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd(qsIsAlive .. " || pkill fuzzel || fuzzel"))

hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true })
hl.bind("SUPER_L", hl.dsp.global("quickshell:workspaceNumber"),
	{ ignore_mods = true, transparent = true, release = true })
hl.bind("SUPER_R", hl.dsp.global("quickshell:workspaceNumber"),
	{ ignore_mods = true, transparent = true, release = true })
hl.bind("SUPER + Tab", hl.dsp.global("quickshell:overviewWorkspacesToggle"), { desc = "Shell: Toggle overview" })
hl.bind("SUPER + V", hl.dsp.global("quickshell:overviewClipboardToggle"))
-- hl.bind("SUPER + Period", hl.dsp.global("quickshell:overviewEmojiToggle"))
hl.bind("SUPER + A", hl.dsp.global("quickshell:sidebarLeftToggle"), { desc = "Shell: Toggle left sidebar" })
hl.bind("SUPER + ALT + A", hl.dsp.global("quickshell:sidebarLeftToggleDetach"))
hl.bind("SUPER + Z", hl.dsp.global("quickshell:sidebarRightToggle"), { desc = "Shell: Toggle right sidebar" })
hl.bind("SUPER + Comma", hl.dsp.global("quickshell:cheatsheetToggle"), { desc = "Shell: Toggle cheatsheet" })
hl.bind("SUPER + SHIFT + K", hl.dsp.global("quickshell:oskToggle"), { desc = "Shell: Toggle on-screen keyboard" })
hl.bind("SUPER + M", hl.dsp.global("quickshell:mediaControlsToggle"), { desc = "Shell: Toggle media controls" })
hl.bind("SUPER + G", hl.dsp.global("quickshell:overlayToggle"), { desc = "Shell: Toggle widget overlay" })
hl.bind("XF86PowerOff", hl.dsp.global("quickshell:sessionToggle"), { desc = "Shell: Toggle session menu" })
hl.bind("XF86PowerOff", hl.dsp.exec_cmd(qsIsAlive .. " || pkill wlogout || wlogout -p layer-shell"))
hl.bind("SUPER + dead_circumflex", hl.dsp.global("quickshell:barToggle"), { desc = "Shell: Toggle bar" })
hl.bind("SUPER + SHIFT + ALT + Colon", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/$qsConfig/welcome.qml"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(qsIpcCall .. " brightness increment || brightnessctl s 5%+"),
	{ locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(qsIpcCall .. " brightness decrement || brightnessctl s 5%-"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
	{ locked = true, repeating = true })

hl.bind("CTRL + SUPER + T", hl.dsp.global("quickshell:wallpaperSelectorToggle"),
	{ desc = "Shell: Change wallpaper" })
hl.bind("CTRL + SUPER + T", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/colors/switchwall.sh"))
hl.bind("CTRL + SUPER + ALT + T", hl.dsp.global("quickshell:wallpaperSelectorRandom"),
	{ desc = "Shell: Random wallpaper" })
hl.bind("CTRL + SUPER + SHIFT + D", hl.dsp.global("quickshell:toggleLightDark"),
	{ desc = "Shell: Toggle light/dark mode" })
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("killall ydotool qs quickshell; qs -c $qsConfig &"),
	{ desc = "Shell: Restart widgets" })
hl.bind("CTRL + SUPER + P", hl.dsp.global("quickshell:panelFamilyCycle"), { desc = "Shell: Cycle panel family" })

---------------
-- Utilities --
---------------
-- Screenshot, Record, OCR, Color picker, Clipboard history
hl.bind("SUPER + V", hl.dsp.exec_cmd(
		qsIsAlive .. " || pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"),
	{ desc = "Utilities: Clipboard history >> clipboard" })
hl.bind("SUPER + Period", hl.dsp.exec_cmd(
		qsIsAlive .. " || pkill fuzzel || " .. hyprScripts .. "/fuzzel-emoji.sh copy"),
	{ desc = "Utilities: Emoji >> clipboard" })
hl.bind("SUPER + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"), { desc = "Utilities: Screen snip" })
hl.bind("SUPER + SHIFT + S",
	hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent"))
hl.bind("SUPER + SHIFT + A", hl.dsp.global("quickshell:regionSearch"), { desc = "Utilities: Google Lens" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd(qsIsAlive .. " || pidof slurp || " .. hyprScripts .. "/snip_to_search.sh"))
--# OCR
hl.bind("SUPER + SHIFT + X", hl.dsp.global("quickshell:regionOcr"),
	{ desc = "Utilities: Character recognition >> clipboard" })
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:screenTranslate"),
	{ desc = "Utilities: Translate screen content" })
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd(
	qsIsAlive ..
	" || pidof slurp || grim -g \"$(slurp $SLURP_ARGS)\" \"/tmp/ocr_image.png\" && tesseract \"/tmp/ocr_image.png\" stdout -l $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\\\n' '+' | sed 's/\\\\+$/\\\\n/') | wl-copy && rm \"/tmp/ocr_image.png\""
))
-- Color picker
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"),
	{ desc = "Utilities: Pick color #RRGGBB >> clipboard" })
-- Recording stuff
hl.bind("SUPER + SHIFT + R", hl.dsp.global("quickshell:regionRecord"),
	{ locked = true, desc = "Utilities: Record region (no sound)" })
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true })
hl.bind("SUPER + ALT + R", hl.dsp.global("quickshell:regionRecord"), { locked = true })
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(qsIsAlive .. " || " .. qsScripts .. "/videos/record.sh"), { locked = true })
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(qsScripts .. "/videos/record.sh --fullscreen"), { locked = true })
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd(qsScripts .. "/videos/record.sh --fullscreen --sound"),
	{ locked = true, desc = "Utilities: Record screen (with sound)" })
-- Fullscreen screenshot
local grimhyprctl = "grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\""
hl.bind("Print", hl.dsp.exec_cmd(grimhyprctl .. " - | wl-copy"),
	{ locked = true, desc = "Utilities: Screenshot >> clipboard" })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
	'dir="$(xdg-user-dir PICTURES)/Captures d\'écran" && img="$dir/Screenshot "$(date \'+%d-%m-%Y %H:%M:%S\')".png" && ' ..
	'mkdir -p "$dir" && ' .. grimhyprctl .. ' "$img" && wl-copy <"$img"'
), { locked = true, desc = "Utilities: Screenshot >> clipboard & file" })
-- AI
hl.bind("SUPER + SHIFT + ALT + mouse:273", hl.dsp.exec_cmd(hyprScripts .. "/ai/primary-buffer-query.sh"),
	{ desc = "Utilities: Generate AI summary for selected text" }) -- (requires a running ollama model)

------------
-- Screen --
------------
-- Zoom
local function zoomfunction(value)
	local zoomvalue = hl.get_config("cursor:zoom_factor")
	if (zoomvalue + value) > 3.0 then
		hl.config({ cursor = { zoom_factor = 3.0 } })
	elseif (zoomvalue + value) < 1.0 then
		hl.config({ cursor = { zoom_factor = 1.0 } })
	else
		hl.config({ cursor = { zoom_factor = zoomvalue + value } })
	end
end
hl.bind("SUPER + Minus", function() zoomfunction(-0.3) end, { repeating = true, desc = "Screen: Zoom out" })
hl.bind("SUPER + Equal", function() zoomfunction(0.3) end, { repeating = true, desc = "Screen: Zoom in" })
-- Zoom with keypad
hl.bind("SUPER + code:82", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind("SUPER + code:86", function() zoomfunction(0.3) end, { repeating = true })
-- Color temperature
hl.bind("SUPER + F5", hl.dsp.exec_cmd("hyprctl hyprsunset temperature -100"),
	{ desc = "Screen: Color temperature down", locked = true })
hl.bind("SUPER + F6", hl.dsp.exec_cmd("hyprctl hyprsunset temperature +100"),
	{ desc = "Screen: Color temperature up", locked = true })
hl.bind("SUPER + SHIFT + F5", hl.dsp.exec_cmd("hyprctl hyprsunset temperature 2500"),
	{ desc = "Screen: Blue light filter", locked = true })
hl.bind("SUPER + SHIFT + F6", hl.dsp.exec_cmd("hyprctl hyprsunset identity"),
	{ desc = "Screen: Color temperature reset", locked = true })
-- Animations
hl.bind("SUPER + SHIFT + ALT + A", function()
	local is_enabled = hl.get_config("animations.enabled")
	hl.config({ animations = { enabled = not is_enabled } })
end, { desc = "Screen: Toggle animations" })

-----------
-- Media --
-----------
local mediaNextCommand =
'playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`'
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(mediaNextCommand), { locked = true, desc = "Media: Next track" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(mediaNextCommand), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("SUPER + SHIFT + ALT + mouse:275", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("SUPER + SHIFT + ALT + mouse:276", hl.dsp.exec_cmd(mediaNextCommand))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("playerctl previous"),
	{ locked = true, desc = "Media: Previous track" })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("playerctl play-pause"),
	{ locked = true, desc = "Media: Play/pause media" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"),
	{ locked = true, desc = "Media: Toggle mute" })
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"),
	{ locked = true, desc = "Media: Toggle mic" })

------------
-- Window --
------------
-- Mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, desc = "Window: Move" })
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, desc = "Window: Resize" })

-- SUPER + H/J/K/L: Focus in direction
for key, dir in pairs({ ["H"] = "l", ["J"] = "d", ["K"] = "u", ["L"] = "r" }) do
	hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }), { desc = "Window: Move focus" })
end
-- SUPER + ←/↓/↑/→: Move in direction
for _, key in ipairs({ "Left", "Down", "Up", "Right" }) do
	hl.bind("SUPER + " .. key, hl.dsp.window.move({ direction = key:sub(1, 1):lower() }),
		{ desc = "Window: Move " .. key })
end
-- SUPER + SHIFT + ←/↓/↑/→: Resize in steps
for key, dir in pairs({ ["Left"] = { -1, 0 }, ["Down"] = { 0, 1 }, ["Up"] = { 0, -1 }, ["Right"] = { 1, 0 } }) do
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.resize({ x = dir[1] * 20, y = dir[2] * 20, relative = true }),
		{ desc = "Window: Resize " .. key })
end

-- Close
hl.bind("SUPER + Q", hl.dsp.window.close(), { desc = "Window: Close" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill(), { desc = "Window: Kill" })
hl.bind("SUPER + SHIFT + ALT + Q", hl.dsp.exec_cmd("hyprctl kill"), { desc = "Window: Kill a window" })

-- SUPER + ;/,: Adjust split ratio
hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Colon", hl.dsp.layout("splitratio +0.1"), { repeating = true })

-- Positioning mode
hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" }), { desc = "Window: Toggle Floating/Tiling" })
hl.bind("SUPER + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),
	{ desc = "Window: Maximize" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
	{ desc = "Window: Fullscreen" })
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 3, action = "toggle" }),
	{ desc = "Window: Fullscreen state" })
hl.bind("SUPER + SHIFT + F", hl.dsp.global("quickshell:fullspaceToggle"), { desc = "Window: Fullspace" })

hl.bind("SUPER + P", hl.dsp.window.pin(), { desc = "Window: Pin" })
hl.bind("SUPER + Exclam", hl.dsp.layout("togglesplit"), { desc = "Window: Toggle window split" })

-- SUPER + SHIFT + 1/2/3/...: Send and follow to workspace
for i = 1, 10 do
	-- number keys
	hl.bind("SUPER + SHIFT + code:" .. numberkey[i], function()
		hl.dispatch(hl.dsp.window.move({ workspace = ws_group.workspace_in_group(i) }))
	end, { desc = "Window: Send and follow to workspace " .. i })
	-- keypad numbers
	hl.bind("SUPER + SHIFT + code:" .. numpadkey[i], function()
		hl.dispatch(hl.dsp.window.move({ workspace = ws_group.workspace_in_group(i) }))
	end)
end
-- SUPER + ALT + 1/2/3/...: Send to workspace
for i = 1, 10 do
	-- number keys
	hl.bind("SUPER + ALT + code:" .. numberkey[i], function()
		hl.dispatch(hl.dsp.window.move({ workspace = ws_group.workspace_in_group(i), follow = false }))
	end, { desc = "Window: Send to workspace " .. i })
	-- keypad numbers
	hl.bind("SUPER + ALT + code:" .. numpadkey[i], function()
		hl.dispatch(hl.dsp.window.move({ workspace = ws_group.workspace_in_group(i), follow = false }))
	end)
end

-- SUPER + SHIFT + ←/→: Send to workspace left/right
hl.bind("SUPER + ALT + Left", hl.dsp.window.move({ workspace = "r-1" }), { desc = "Send to workspace left" })
hl.bind("SUPER + ALT + Right", hl.dsp.window.move({ workspace = "r+1" }), { desc = "Send to workspace right" })
-- SUPER + SHIFT + Scroll ↑/↓: Send to workspace left/right
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "r+1" }))
-- SUPER + ALT + Scroll ↑/↓: Send to workspace left/right
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "r+1" }))

-- Special workspace
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special", follow = false }),
	{ desc = "Window: Send to scratchpad" })

-- Workspace groups
hl.bind("SUPER + ALT + code:91", ws_group.move(1), { desc = "Move and follow to next window group" })
hl.bind("SUPER + ALT + SHIFT + code:91", ws_group.move(-1), { desc = "Move and follow to previous window group" })
hl.bind("SUPER + ALT + CTRL + code:91", ws_group.move(1, true), { desc = "Move to next window group" })
hl.bind("SUPER + ALT + SHIFT + CTRL + code:91", ws_group.move(-1, true), { desc = "Move to previous window group" })

---------------
-- Workspace --
---------------
-- SUPER + 1/2/3/...: Focus workspace
for i = 1, 10 do
	-- number keys
	hl.bind("SUPER + code:" .. numberkey[i], function()
		hl.dispatch(hl.dsp.focus({ workspace = ws_group.workspace_in_group(i) }))
	end, { desc = "Workspace: Focus " .. i })
	-- keypad numbers
	hl.bind("SUPER + code:" .. numpadkey[i], function()
		hl.dispatch(hl.dsp.focus({ workspace = ws_group.workspace_in_group(i) }))
	end)
end

-- SUPER + CTRL + ←/→: Focus left/right
hl.bind("SUPER + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }), { desc = "Workspace: Focus Left" })
hl.bind("SUPER + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }), { desc = "Workspace: Focus Right" })
-- SUPER + CTRL + ALT, ←/→: Focus busy left/right
hl.bind("SUPER + CTRL + ALT + Left", hl.dsp.focus({ workspace = "m-1" }), { desc = "Workspace: Focus Busy Left" })
hl.bind("SUPER + CTRL + ALT + Right", hl.dsp.focus({ workspace = "m+1" }), { desc = "Workspace: Focus Busy Right" })

-- Special
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("special"), { desc = "Workspace: Toggle scratchpad" })
hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special("special"))

-- Workspace groups
hl.bind("SUPER + code:91", ws_group.focus(1), { desc = "Go to next window group" })
hl.bind("SUPER + SHIFT + code:91", ws_group.focus(-1), { desc = "Go to previous window group" })

-------------
-- Session --
-------------
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("loginctl lock-session"), { desc = "Session: Lock" })
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend || loginctl suspend"),
	{ locked = true, desc = "Session: Sleep" })
hl.bind("CTRL + SHIFT + ALT + SUPER + Delete", hl.dsp.exec_cmd("systemctl poweroff || loginctl poweroff"),
	{ desc = "Session: Shut down" })

----------
-- Apps --
----------
hl.bind("SUPER + Return", hl.dsp.exec_cmd(vars.terminal), { desc = "App: Terminal" })
hl.bind("SUPER + E", hl.dsp.exec_cmd(vars.fileManager), { desc = "App: File manager" })
hl.bind("SUPER + B", hl.dsp.exec_cmd(vars.browser), { desc = "App: Browser" })
hl.bind("SUPER + I", hl.dsp.exec_cmd(vars.settingsApp), { desc = "App: Settings app" })
hl.bind("SUPER + T", hl.dsp.exec_cmd(vars.taskManager), { desc = "App: Task manager" })

-- Passthrough
hl.define_submap("passthrough", function()
	hl.bind("SUPER + ALT + F1", function()
		local currentsubmap = hl.get_current_submap()
		if currentsubmap == "passthrough" then
			hl.dispatch(hl.dsp.exec_cmd(
				"notify-send 'Exited Passthrough submap' 'Keybinds re-enabled' -a 'Hyprland'"))
			hl.dispatch(hl.dsp.submap("reset"))
		elseif currentsubmap == "" then
			hl.dispatch(hl.dsp.exec_cmd(
				"notify-send 'Entered Passthrough submap' 'Keybinds disabled. hit SUPER+ALT+F1 to escape' -a 'Hyprland'"))
			hl.dispatch(hl.dsp.submap("passthrough"))
		end
	end, { submap_universal = true })
end)
