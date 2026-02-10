local M = {}

function M.systemd(expr)
	-- trim whitespace
	expr = expr:gsub("^%s+", ""):gsub("%s+$", "")

	-- drop everything before the first '='
	expr = expr:gsub("^.-=", "")

	local spec = {
		["%%"] = "%",
		["h"] = vim.env.HOME or "",
		["u"] = vim.env.USER or "",
		["U"] = vim.loop.getuid and tostring(vim.loop.getuid()) or "",
		["t"] = vim.env.XDG_RUNTIME_DIR or "",
		["S"] = "/var/lib",
		["T"] = "/run",
		["L"] = "/var/log",
		["C"] = "/var/cache",
		["E"] = "/etc",
	}

	for k, v in pairs(spec) do
		expr = expr:gsub("%%" .. k, v)
	end

	return expr
end

return M
