-- $VIMRUNTIME/pack/dist/opt/nvim.difftool/plugin/difftool.lua
vim.api.nvim_create_user_command("DiffTool", function(opts)
	if #opts.fargs == 2 then
		require("difftool").open(opts.fargs[1], opts.fargs[2])
	else
		vim.notify("Usage: DiffTool <left> <right>", vim.log.levels.ERROR)
	end
end, { nargs = "*", complete = "file", force = false })
