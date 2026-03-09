local M = {}

---@class OpenOpts
---@field silent? boolean

---@param pdf_path string
---@param opts? OpenOpts
function M.open(pdf_path, opts)
	opts = opts or {}
	if vim.uv.fs_stat(pdf_path) then
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

		vim.g.zathura_window_pid = vim.g.zathuraw_window_pid or find_zathura_on_workspace()

		if is_alive(vim.g.zathura_window_pid) then
			vim.system({
				"busctl", "--user", "call",
				"org.pwmt.zathura.PID-" .. vim.g.zathura_window_pid,
				"/org/pwmt/zathura", "org.pwmt.zathura",
				"OpenDocument", "ssi",
				pdf_path, "", "1",
			})
		else
			local handle = vim.system({ "zathura", pdf_path }, { detach = true }, function(obj)
				if obj.code ~= 0 and obj.stderr then
					vim.notify(obj.stderr, vim.log.levels.ERROR, { title = "Open PDF", icon = "" })
				end
			end)
			vim.g.zathura_window_pid = handle.pid
		end

		if not opts.silent then
			vim.notify("Opening " .. pdf_path, vim.log.levels.INFO, { title = "Open PDF", icon = "", timeout = 0 })
		end
	else
		vim.notify(pdf_path .. " does not exist !", vim.log.levels.ERROR, { title = "Open PDF", icon = "" })
	end
end

return M
