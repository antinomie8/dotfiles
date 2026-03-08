--- @sync entry

return {
	entry = function(self, job)
		local cwd = cx.active.current.cwd
		local trash_dir = os.getenv("trash")
		if not trash_dir then
			local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
			trash_dir = data_home .. "/Trash"
		end
		if cwd:starts_with(trash_dir .. "/files") then
			ya.emit("remove", { permanently = true, force = job.args.permanently })
		else
			ya.emit("remove", job.args)
		end
	end,
}
