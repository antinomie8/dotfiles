local function setup()
	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd
		local home = os.getenv("HOME") .. "/"
		local data_home = (os.getenv("XDG_DATA_HOME") .. "/") or (home .. ".local/share/")
		local dirs = {
			home .. "Downloads",
			home .. "Téléchargements",
			data_home .. "Trash/files",
		}

		for _, name in ipairs(dirs) do
			if cwd:starts_with(name) then
				opt.by, opt.reverse, opt.dir_first = "mtime", true, false
				return opt
			end
		end
		opt.by, opt.reverse, opt.dir_first = "natural", false, true
		return opt
	end)
end

return { setup = setup }
