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

local function is_alive(pid)
	if not pid then
		return false
	end
	local ok = vim.uv.kill(pid, 0)
	return ok
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
		if not vim.g.zathura_window_pid then
			vim.g.zathura_window_pid = require("utils.hypr").find_win_on_ws("org.pwmt.zathura")
			if opts.layout and vim.g.zathura_window_pid then
				require("utils.hypr").set_layout("master")
				vim.api.nvim_create_autocmd("VimLeave", {
					callback = function() require("utils.hypr").set_layout() end,
				})
			end
		end

		if is_alive(vim.g.zathura_window_pid) then
			vim.system({
				"busctl", "--user", "call",
				"org.pwmt.zathura.PID-" .. vim.g.zathura_window_pid,
				"/org/pwmt/zathura", "org.pwmt.zathura",
				"OpenDocument", "ssi",
				pdf_path, "", "1",
			})
		else
			local id
			if opts.layout then
				require("utils.hypr").set_layout("master")
				id = vim.api.nvim_create_autocmd("VimLeave", {
					callback = function() require("utils.hypr").set_layout() end,
				})
			end

			-- open zathura
			local handle = vim.system({ "zathura", pdf_path }, { detach = true }, function(obj)
				if obj.code ~= 0 then
					error(obj.stderr)
				end
				if opts.layout then
					vim.schedule(function()
						require("utils.hypr").set_layout()
						vim.api.nvim_del_autocmd(id)
					end)
				end
			end)
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
