local M = {}

local function error(msg)
	if msg then
		vim.notify(
			msg,
			vim.log.levels.ERROR,
			{
				title = "Open PDF",
				icon = "",
			}
		)
	end
end

local function find_zathura_on_workspace()
	local ws = vim.system({ "hyprctl", "activeworkspace", "-j" }, { text = true }):wait()
	local ws_id = vim.json.decode(ws.stdout).id

	local clients = vim.system({ "hyprctl", "clients", "-j" }, { text = true }):wait()
	local data = vim.json.decode(clients.stdout)

	for _, c in ipairs(data) do
		if c.class == "org.pwmt.zathura" and c.workspace.id == ws_id then
			return c.pid
		end
	end
end

local function is_alive(pid)
	if not pid then
		return false
	end
	local ok, err = vim.uv.kill(pid, 0)
	return ok
end

---@private
---@param pdf_path string
---@param opts OpenOpts
---@return vim.SystemObj handle
local function hyprland_set_layout(pdf_path, opts)
	local ws
	local old_layout

	vim.system({ "hyprctl", "getoption", "general:layout", "-j" }, function(obj)
		if obj.code ~= 0 then
			error(obj.stderr)
			return
		end
		old_layout = vim.json.decode(obj.stdout).str
	end)

	vim.system({ "hyprctl", "-j", "activewindow" }, function(hyprctl)
		if hyprctl.code ~= 0 then
			error(hyprctl.stderr)
			return
		end

		local win = vim.json.decode(hyprctl.stdout)
		ws = win.workspace.id

		vim.system({ "hyprctl", "keyword", "workspace", ws .. ",", "layout:master" }, function(hyprctl)
			if hyprctl.code ~= 0 then
				error(hyprctl.stderr)
				return
			end
		end)
	end)

	local function hyprland_reset_layout()
		vim.system({ "hyprctl", "keyword", "workspace", ws .. ",", "layout:" .. old_layout }, function(hyprctl)
			if hyprctl.code ~= 0 then
				error(hyprctl.stderr)
				return
			end
		end)
	end

	local group = vim.api.nvim_create_augroup("pdf_zathura_hyprland_layout", {})
	vim.api.nvim_create_autocmd("VimLeave", {
		group = group,
		callback = hyprland_reset_layout,
	})

	local handle = vim.system({ "zathura", pdf_path }, { detach = true }, function(obj)
		if obj.code ~= 0 then
			error(obj.stderr)
		end
		if opts.layout and old_layout and ws then
			hyprland_reset_layout()
			vim.schedule(function()
				vim.api.nvim_del_augroup_by_id(group)
			end)
		end
	end)

	return handle
end

---@class OpenOpts
---@field silent? boolean
---@field layout? boolean

local defaults = {
	silent = false,
	layout = true,
}

---@param pdf_path string
---@param opts? OpenOpts
function M.open(pdf_path, opts)
	opts = opts or {}
	opts = vim.tbl_extend("force", defaults, opts)
	if vim.uv.fs_stat(pdf_path) then
		vim.g.zathura_window_pid = vim.g.zathura_window_pid or find_zathura_on_workspace()

		if is_alive(vim.g.zathura_window_pid) then
			vim.system({
				"busctl", "--user", "call",
				"org.pwmt.zathura.PID-" .. vim.g.zathura_window_pid,
				"/org/pwmt/zathura", "org.pwmt.zathura",
				"OpenDocument", "ssi",
				pdf_path, "", "1",
			})
		else
			local handle

			if opts.layout then
				handle = hyprland_set_layout(pdf_path, opts)
			else
				handle = vim.system({ "zathura", pdf_path }, { detach = true }, function(obj)
					if obj.code ~= 0 then
						error(obj.stderr)
					end
				end)
			end
			vim.g.zathura_window_pid = handle.pid
		end

		if not opts.silent then
			vim.notify("Opening " .. pdf_path, vim.log.levels.INFO, { title = "Open PDF", icon = "", timeout = 0 })
		end
	else
		error(pdf_path .. " does not exist !")
	end
end

return M
