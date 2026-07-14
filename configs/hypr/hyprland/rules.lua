--------------
-- Floating --
--------------
local center_float = {
	float = true,
	center = true,
	rounding = 0,
	border_color = "#54546d",
	border_size = 2,
}

center_float.size = { "monitor_w * 0.86", "monitor_h * 0.86" }
center_float.match = { title = "File Manager" }
hl.window_rule(center_float)

center_float.size = { "monitor_w * 0.65", "monitor_h * 0.65" }
local patterns = { "Task Manager", "Open files?", "Open director(y|ies)", "Save (as|files?)" }
for _, pattern in ipairs(patterns) do
	center_float.match.title = pattern
	hl.window_rule(center_float)
end

hl.window_rule({ match = { title = "Open File.*" }, center = true, float = true })
hl.window_rule({ match = { title = "Open File.*" }, float = true })
hl.window_rule({ match = { title = "Select a File.*$" }, center = true, float = true })
hl.window_rule({ match = { title = "Choose wallpaper.*" }, center = true, float = true, size = { "(monitor_w*0.60)", "(monitor_h*0.65)" } })
hl.window_rule({ match = { title = "Open Folder.*" }, center = true, float = true })
hl.window_rule({ match = { title = "Save As.*" }, center = true, float = true })
hl.window_rule({ match = { title = "Library.*" }, center = true, float = true })
hl.window_rule({ match = { title = "File Upload.*" }, center = true, float = true })
hl.window_rule({ match = { title = ".*wants to save" }, center = true, float = true })
hl.window_rule({ match = { title = ".*wants to open" }, center = true, float = true })
hl.window_rule({ match = { class = "blueberry\\.py" }, float = true })
hl.window_rule({ match = { class = "guifetch" }, float = true }) -- FlafyDev/guifetch
hl.window_rule({ match = { class = "pavucontrol" }, center = true, float = true, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, center = true, float = true, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
hl.window_rule({ match = { class = "nm-connection-editor" }, center = true, float = true, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = ".*Welcome" }, float = true })
hl.window_rule({ match = { title = "illogical-impulse Settings" }, float = true, scroll_touchpad = 2 })
hl.window_rule({ match = { title = ".*Shell conflicts.*" }, float = true })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true, size = { "(monitor_w*0.60)", "(monitor_h*0.65)" } })
hl.window_rule({ match = { class = "Zotero" }, float = true, size = { "(monitor_w*0.45)", "(monitor_h*0.45)" } })
-- kde-material-you-colors spawns a window when changing dark/light theme. This is to make sure it doesn't interfere at all.
hl.window_rule({ match = { class = "plasma-changeicons" }, float = true, no_initial_focus = true, move = { 999999, 999999 } })
hl.window_rule({ match = { title = "^(Copying — Dolphin)$" }, move = { 40, 80 } }) -- stupid dolphin copy

-- Picture-in-Picture
hl.window_rule({
	match = { title = "[Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture.*" },
	float = true,
	keep_aspect_ratio = true,
	pin = true,
	move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
	size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
})

-- Screen sharing
hl.window_rule({
	match = { title = ".*is sharing (a window|your screen).*" },
	float = true,
	pin = true,
	move = { "(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)" },
})

-- No shadow for tiled windows
hl.window_rule({ match = { float = 0 }, no_shadow = true })

---------------------
-- Workspace rules --
---------------------
hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

-----------------
-- Layer rules --
-----------------
hl.layer_rule({ match = { namespace = ".*" }, xray = true })
hl.layer_rule({ match = { namespace = "walker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "anyrun" }, no_anim = true })
hl.layer_rule({ match = { namespace = "indicator.*" }, no_anim = true })
hl.layer_rule({ match = { namespace = "osk" }, no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

hl.layer_rule({ match = { namespace = "noanim" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true })
hl.layer_rule({ match = { namespace = "launcher" }, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ match = { namespace = "notifications" }, ignore_alpha = 0.69 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true }) -- wlogout

-- Quickshell
-- Quickshell: illogical-impulse
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:.*" }, ignore_alpha = 0.79 })
hl.layer_rule({ match = { namespace = "quickshell:bar" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:actionCenter" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:cheatsheet" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:dock" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "popin 120%" })
hl.layer_rule({ match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:overlay" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:overlay" }, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:osk" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:polkit" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:popup" }, xray = false }) -- No weird color for bar tooltips (this in theory should suffice)
hl.layer_rule({ match = { namespace = "quickshell:popup" }, ignore_alpha = 1 }) -- No weird color for bar tooltips (but somehow this is necessary)
hl.layer_rule({ match = { namespace = "quickshell:mediaControls" }, ignore_alpha = 1 }) -- Same as above
hl.layer_rule({ match = { namespace = "quickshell:reloadPopup" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:regionSelector" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:screenshot" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "quickshell:verticalBar" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:osk" }, order = -1 })
-- Quickshell: waffles
hl.layer_rule({ match = { namespace = "quickshell:wallpaperSelector" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "quickshell:wNotificationCenter" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:wOnScreenDisplay" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:wStartMenu" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:wTaskView" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:wTaskView" }, no_anim = true })

-- Launchers need to be FAST
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })

----------
-- Apps --
----------
hl.window_rule({ match = { class = "org.inkscape.Inkscape", title = ".* - Inkscape$" }, maximize = true })
hl.window_rule({
	match = { class = "org.inkscape.Inkscape", title = "Inkscape \\d*\\.\\d*\\.\\d*.*" },
	size = { 0, 0 },
	no_initial_focus = true,
}) -- hide inkscape loading screen

-- hl.window_rule({ match = { class = "org.pwmt.zathura" }, scroll_touchpad = 0.1 })
