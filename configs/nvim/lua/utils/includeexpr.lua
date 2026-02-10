local M = {}

function M.systemd(module)
	-- trim whitespace
	module = module:gsub("^%s+", ""):gsub("%s+$", "")

	-- drop everything before the first '='
	module = module:gsub("^.-=", "")

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
		module = module:gsub("%%" .. k, v)
	end

	return module
end

function M.typst(_)
	local line = vim.api.nvim_get_current_line()

	-- package import: #import "@repo/name:version"
	local repo, name, version = line:match('#import%s+"@([^/]+)/([^:]+):([^"]+)"')

	if repo and name and version then
		local data_home = vim.env.XDG_DATA_HOME
		                  or (vim.env.HOME and vim.fs.joinpath(vim.env.HOME, ".local", "share"))
		                  or ""

		return vim.fs.joinpath(
			data_home,
			"typst",
			"packages",
			repo,
			name,
			version,
			"typst.toml"
		)
	end
end

return M
