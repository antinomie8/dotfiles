local hypr = {}

local function error(msg)
	if msg then
		vim.notify(
			msg,
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

local default_layout --[[@as HyprlandLayout]]
local workspace      --[[@as integer]]

---@return HyprlandLayout
local function get_default_layout()
	if not default_layout then
		vim.system({ "hyprctl", "getoption", "general:layout", "-j" }, function(obj)
			if obj.code ~= 0 then
				error(obj.stderr)
				return
			end
			default_layout = vim.json.decode(obj.stdout).str
		end):wait()
	end
	return default_layout
end

---@return integer
local function get_current_workspace()
	if not workspace then
		vim.system({ "hyprctl", "activeworkspace", "-j" }, function(hyprctl)
			if hyprctl.code ~= 0 then
				error(hyprctl.stderr)
				return
			end
			workspace = vim.json.decode(hyprctl.stdout).id
		end):wait()
	end
	return workspace
end

---@param layout HyprlandLayout?
function hypr.set_layout(layout)
	if not layout then
		layout = get_default_layout()
	end
	if not workspace then
		workspace = get_current_workspace()
	end

	vim.system(
		{ "hyprctl", "keyword", "workspace", workspace .. ",", "layout:" .. layout },
		function(hyprctl)
			if hyprctl.code ~= 0 then
				error(hyprctl.stderr)
				return
			end
		end
	)
end

---@param class string
---@param workspace integer?
---@return integer? pid
function hypr.find_win_on_ws(class, workspace)
	if not workspace then
		workspace = get_current_workspace()
	end

	local clients = vim.system({ "hyprctl", "clients", "-j" }):wait()
	local data = vim.json.decode(clients.stdout)

	for _, c in ipairs(data) do
		if c.class == class and c.workspace.id == workspace then
			return c.pid
		end
	end
end

return hypr
