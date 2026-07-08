return {
	settings = {
		exportPdf = "onType",
		lint = {
			enabled = true,
		},
		preview = {
			browsing = {
				args = {
					"--data-plane-host=127.0.0.1:0",
					"--control-plane-host=127.0.0.1:0",
					"--no-open",
				},
			},
		},
	},
	on_attach = function(client, bufnr)
		vim.keymap.set("n", "<localleader>O", function()
			require("utils.typst_preview").start_preview(client)
		end, { desc = "Typst Web Preview" })

		local function notify(message, level)
			vim.notify(message, level or vim.log.levels.ERROR, { title = "Tinymist", icon = "" })
		end
		---@type lsp.Handler
		local function handler(err, res)
			if err then
				return notify(err.code .. ": " .. err.message)
			end
		end

		-- tinymist commands
		local cmds = {
			["export"] = { "svg", "png", "pdf", "html", "markdown", "text", "query", "ansi" },
			["get"] = { "server_info", "document_trace", "workspace_labels", "document_metrics" },
			["pin"] = {},
		}
		vim.api.nvim_buf_create_user_command(bufnr, "Typst", function(arg)
			local args = arg.fargs
			if #args == 0 then
				notify("Expected subcommand")
			end
			local cmd = args[1]
			if not cmds[cmd] then
				notify("Unrecognized subcommand: " .. args[1])
			end

			local function run_tinymist_command(command_name, title_str, null)
				local arguments = { null and vim.v.null or vim.api.nvim_buf_get_name(bufnr) }
				return client:exec_cmd({
					title = title_str,
					command = command_name,
					arguments = arguments,
				}, { bufnr = bufnr }, handler)
			end

			local arg = args[2]
			if cmd == "export" then
				if not vim.tbl_contains(cmds[cmd], arg) then
					notify("Unsupported export format: " .. arg)
					return
				end
				local capitalize = function(name)
					if name == "ansi" then
						return "AnsiHighlight"
					else
						return name:sub(1, 1):upper() .. name:sub(2)
					end
				end
				run_tinymist_command("tinymist.export" .. capitalize(arg), "Export " .. arg)
			elseif cmd == "get" then
				if not vim.tbl_contains(cmds[cmd], arg) then
					notify("Unrecognized query: " .. arg)
					return
				end
				local function snake_to_pascal(str)
					return (str:gsub("_(%w)", function(c)
						return c:upper()
					end):gsub("^%l", string.upper))
				end
				run_tinymist_command("tinymist.get" .. snake_to_pascal(arg), "Get " .. arg:gsub("_", " "))
			elseif cmd == "pin" then
				run_tinymist_command("tinymist.pinMain", "Pin as main file", arg.bang)
			else
				vim.notify("Typst: unrecognized subcommand: " .. args[1], vim.log.levels.ERROR)
			end
		end, {
			nargs = "+",
			bang = true,
			complete = function(arglead, cmdline, cursorpos)
				cmdline = cmdline:sub(1, cursorpos)
				local words = vim.split(cmdline, "%s+", { trimempty = false })
				if #words <= 2 then
					return { "export", "get", "pin" }
				else
					return cmds[words[2]]
				end
			end,
		})

		-- main file detection
		local root_path = vim.b[bufnr].typst_root
		if not root_path then
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 3, false)

			for _, line in ipairs(lines) do
				local typst_root = line:match("^//%s*typst%s+root:%s*(.*)%s*$")
				if typst_root then
					vim.b[bufnr].typst_root = typst_root
					root_path = typst_root
				end
			end
		end
		if not root_path or not vim.uv.fs_stat(root_path) then
			return
		end

		local root_buf = vim.fn.bufadd(root_path)
		vim.bo[root_buf].buflisted = false

		client:exec_cmd({
			title = "pin",
			command = "tinymist.pinMain",
			arguments = { vim.api.nvim_buf_get_name(root_buf) },
		}, { bufnr = bufnr }, handler)
		client:exec_cmd({
			title = "exportpdf",
			command = "tinymist.exportPdf",
			arguments = { vim.api.nvim_buf_get_name(root_buf) },
		}, { bufnr = bufnr }, handler)

		vim.keymap.set(
			"n",
			"<localleader>tp",
			function()
				client:exec_cmd({
					title = "pin",
					command = "tinymist.pinMain",
					arguments = { vim.api.nvim_buf_get_name(0) },
				}, { bufnr = bufnr }, handler)
			end,
			{ desc = "tinymist pin main" }
		)
		vim.keymap.set(
			"n",
			"<localleader>tu",
			function()
				client:exec_cmd({
					title = "unpin",
					command = "tinymist.pinMain",
					arguments = { vim.v.null },
				}, { bufnr = bufnr }, handler)
			end,
			{ desc = "tinymist unpin main" }
		)
	end,
}
