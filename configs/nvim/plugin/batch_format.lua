vim.api.nvim_create_user_command("BatchFormat", function(arg)
	local dir, ft, lsp

	if #arg.fargs == 3 then
		dir = arg.fargs[1]
		ft = arg.fargs[2]
		lsp = arg.fargs[3]
	elseif #arg.fargs == 2 then
		dir = "."
		ft = arg.fargs[1]
		lsp = arg.fargs[2]
	else
		vim.notify(
			"Usage: BatchFormat [dir] <fileext> <lsp>",
			vim.log.levels.ERROR
		)
		return
	end

	local files = vim.fn.systemlist(
		string.format("fd -e %s . %s", ft, vim.fn.shellescape(dir))
	)

	for _, file in ipairs(files) do
		vim.cmd.edit(file)

		-- wait until LSP attaches
		local ok = vim.wait(2000, function()
			return next(vim.lsp.get_clients({
				bufnr = 0,
				name = lsp,
			})) ~= nil
		end)

		if ok then
			pcall(vim.lsp.buf.format, {
				filter = function(client)
					return client.name == lsp
				end,
				timeout_ms = 2000,
			})

			vim.cmd.write()
		end

		vim.cmd.bdelete({ bang = true })
	end
end, {
	nargs = "+",
	desc = "Batch format files using an LSP",
})
