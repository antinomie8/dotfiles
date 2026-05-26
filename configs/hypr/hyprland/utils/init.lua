local vars = require("hyprland.variables")

local function get_ws_in_dir(dir)
	local cur = hl.get_active_workspace().id
	local target = math.floor((cur - 1) / vars.workspaceGroupSize + dir) * vars.workspaceGroupSize + 1
	return math.max(target, 1)
end

local workspace_group = {}
function workspace_group.move(dir, silent)
	return function()
		hl.dispatch(hl.dsp.window.move({ workspace = get_ws_in_dir(dir), silent = silent }))
	end
end

function workspace_group.focus(dir)
	return function()
		hl.dispatch(hl.dsp.focus({ workspace = get_ws_in_dir(dir) }))
	end
end

function workspace_group.workspace_in_group(i)
	local curr = hl.get_active_workspace().id
	local newVal = math.floor((curr - 1) / vars.workspaceGroupSize) * vars.workspaceGroupSize + i
	return newVal
end

return {
	file_exists = function(name)
		local f = io.open(name, "r")
		if f ~= nil then
			io.close(f)
			return true
		else
			return false
		end
	end,

	workspace_group = workspace_group,
}
