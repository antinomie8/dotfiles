-- export pdf
local function compile(handler)
	local filepath = vim.b.typst_root and vim.b.typst_root or vim.api.nvim_buf_get_name(0)
	local client = vim.lsp.get_clients({ name = "tinymist" })[1]
	if client then
		client:exec_cmd({
				title = "exportpdf",
				command = "tinymist.exportPdf",
				arguments = { filepath },
			}, nil,
			handler)
	else
		vim.notify("Tinymist is not running !", vim.log.levels.ERROR, { title = "Generate PDF", icon = "" })
	end
end

vim.api.nvim_buf_create_user_command(0, "ExportPdf", function() compile() end, {})
vim.keymap.set("n", "<localleader>c", "<Cmd>ExportPdf<CR>", { desc = "Export pdf", buffer = true })

-- open pdf
local function open(path, opts)
	opts = opts or {}
	local pdf_path
	if path then
		pdf_path = path
	else
		local filepath = vim.b.typst_root and vim.b.typst_root or vim.api.nvim_buf_get_name(0)
		pdf_path = filepath:gsub("%.typ$", ".pdf")
	end

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

vim.api.nvim_buf_create_user_command(0, "OpenPdf", function(arg)
	open(arg.fargs[1], { silent = arg.bang })
end, { nargs = "?", bang = true })
vim.keymap.set("n", "<localleader>o", "<Cmd>OpenPdf<CR>", { desc = "Open pdf", buffer = true })

-- compile and open
vim.keymap.set("n", "<localleader>p", function()
	compile(function(err, result, ctx)
		open(result.path)
	end)
end, { desc = "Export and open pdf", buffer = true })
