-- The folder within ~/.config/quickshell containing the config
hl.env("qsConfig", "ii")

-- Apps
return {
	terminal = "kitty -1",
	fileManager = "kitty -1 --title 'File Manager' yazi ~/Téléchargements/",
	browser = "firefox",
	codeEditor = "kitty -1 nvim",
	officeSoftware = "libreoffice",
	textEditor = "kitty -1 nvim",
	volumeMixer = "~/.config/hypr/hyprland/scripts/launch_first_available.sh 'pavucontrol-qt' 'pavucontrol'",
	settingsApp =
	"XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh 'qs -p ~/.config/quickshell/$qsConfig/settings.qml' 'systemsettings' 'gnome-control-center' 'better-control'",
	taskManager = "kitty -1 btop",

	workspaceGroupSize = 10,
}
