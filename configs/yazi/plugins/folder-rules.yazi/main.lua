local function setup()
	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd
		local dirs = { "Downloads", "Téléchargements", "Trash/files" }
		for _, name in ipairs(dirs) do
			if cwd:ends_with(name) then
				opt.by, opt.reverse, opt.dir_first = "mtime", true, false
				return opt
			end
		end
		opt.by, opt.reverse, opt.dir_first = "natural", false, true
		return opt
	end)
end

return { setup = setup }
