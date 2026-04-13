local hypr = {}

---@param hyprctl vim.SystemCompleted
local function notify_errors(hyprctl)
	if hyprctl.code ~= 0 then
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

local default_layout --[[@as HyprlandLayout]]
local workspace      --[[@as HyprlandWorkspace]]

---@return HyprlandLayout
local function get_default_layout()
	if not default_layout then
		local handle = vim.system({ "hyprctl", "getoption", "general:layout", "-j" }, notify_errors):wait()
		default_layout = vim.json.decode(handle.stdout).str
	end
	return default_layout
end

---@return HyprlandWorkspace
local function get_current_workspace()
	if not workspace then
		local handle = vim.system({ "hyprctl", "activeworkspace", "-j" }, notify_errors):wait()
		workspace = vim.json.decode(handle.stdout).id
	end
	return workspace
end

---@param layout HyprlandLayout?
function hypr.set_layout(layout)
	layout = layout or get_default_layout()
	workspace = workspace or get_current_workspace()

	vim.system(
		{ "hyprctl", "keyword", "workspace", workspace .. ",", "layout:" .. layout },
		notify_errors
	)
end

---@param class string
---@param ws HyprlandWorkspace?
---@return integer? pid
function hypr.find_win_on_ws(class, ws)
	ws = ws or get_current_workspace()

	local clients = vim.system({ "hyprctl", "clients", "-j" }):wait()
	local data = vim.json.decode(clients.stdout)

	for _, c in ipairs(data) do
		if c.class == class and c.workspace.id == ws then
			return c.pid
		end
	end
end

return hypr
