local hypr = {}

---@param hyprctl vim.SystemCompleted
local function notify_errors(hyprctl)
	-- for some reason hyprctl:
	--   returns 0 even when it fails
	--   uses stdout instead of stderr
	if hyprctl.stderr and vim.startswith(hyprctl.stdout, "error") then
		vim.notify(
			hyprctl.stderr,
			vim.log.levels.ERROR,
			{
				title = "Hyprland",
				icon = "",
			}
		)
	end
end

---@alias HyprlandLayout
---| "dwindle"
---| "master"
---| "scrolling"
---| "monocle"
---@alias HyprlandWorkspace integer

local workspace      --[[@as HyprlandWorkspace]]

---@param ws HyprlandWorkspace
function hypr.switch_workspace(ws)
	vim.system({ "hyprctl", "dispatch", "hl.dps.focus({ workspace = " .. ws .. " })" }, notify_errors):wait()
end

---@return HyprlandWorkspace
function hypr.get_current_workspace()
	if not workspace then
		local handle = vim.system({ "hyprctl", "activeworkspace", "-j" }, notify_errors):wait()
		workspace = vim.json.decode(handle.stdout).id
	end
	return workspace
end

---@param layout HyprlandLayout?
function hypr.set_layout(layout)
	layout = layout or "dwindle"
	workspace = workspace or hypr.get_current_workspace()

	vim.system({ "hyprctl", "eval",
		string.format("hl.workspace_rule({ workspace = %d, layout = '%s' })", workspace, layout),
	}, notify_errors)
end

---@param class string
---@param ws HyprlandWorkspace?
---@return integer? pid
function hypr.find_win_on_ws(class, ws)
	ws = ws or hypr.get_current_workspace()

	local clients = vim.system({ "hyprctl", "clients", "-j" }):wait()
	local data = vim.json.decode(clients.stdout)

	for _, c in ipairs(data) do
		if c.class == class and c.workspace.id == ws then
			return c.pid
		end
	end
end

return hypr
