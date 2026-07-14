local utils = {}

function utils.file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function utils.notify(summary, body)
	local cmd = string.format("notify-send -a Hyprland -i hyprland '%s' '%s'", summary, body)
	hl.dispatch(hl.dsp.exec_cmd(cmd))
end

utils.workspace_group = require("hyprland.utils.workspace_group")

return utils
