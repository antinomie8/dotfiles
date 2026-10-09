-- per-directory overrides set via key-sort, persist for whole session
local overrides = {}

local function setup()
	-- remember manual sort per directory (Source::Key -> key-sort)
	ps.sub("key-sort", function(opt)
		local cwd = cx.active.current.cwd
		local key = tostring(cwd)
		overrides[key] = {
			by = opt.by,
			reverse = opt.reverse,
			dir_first = opt.dir_first,
			sensitive = opt.sensitive,
			translit = opt.translit,
			fallback = opt.fallback,
		}
		return opt
	end)

	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd
		local key = tostring(cwd)

		-- if user manually changed sort for this directory, honor it for the whole session
		local o = overrides[key]
		if o then
			if o.by ~= nil then opt.by = o.by end
			if o.reverse ~= nil then opt.reverse = o.reverse end
			if o.dir_first ~= nil then opt.dir_first = o.dir_first end
			if o.sensitive ~= nil then opt.sensitive = o.sensitive end
			if o.translit ~= nil then opt.translit = o.translit end
			if o.fallback ~= nil then opt.fallback = o.fallback end
			return opt
		end

		local home = os.getenv("HOME") .. "/"
		local data_home = (os.getenv("XDG_DATA_HOME") .. "/") or (home .. ".local/share/")
		local state_home = (os.getenv("XDG_STATE_HOME") .. "/") or (home .. ".local/state/")
		local dirs = {
			home .. "Downloads",
			home .. "Téléchargements",
			data_home .. "Trash/files",
			state_home .. "nvim/swap",
			home .. "Médias",
		}
		local disable = {
			[home .. "Téléchargements"] = { "git" },
		}

		for _, name in ipairs(dirs) do
			if cwd:starts_with(name) then
				if disable[name] then
					for _, disabled in ipairs(disable[name]) do
						if cwd.parent:starts_with(name .. "/" .. disabled) then
							goto default
						end
					end
				end

				opt.by, opt.reverse, opt.dir_first = "mtime", true, false
				return opt
			end
		end

		::default::

		opt.by, opt.reverse, opt.dir_first = "natural", false, true
		return opt
	end)
end

local function entry(_, job)
	local arg = job.args[1]
	if arg == "clear" or arg == "reset" then
		local target = job.args[2]
		if target then
			overrides[target] = nil
		else
			for k in pairs(overrides) do
				overrides[k] = nil
			end
		end
	end
end

return { setup = setup, entry = entry }
