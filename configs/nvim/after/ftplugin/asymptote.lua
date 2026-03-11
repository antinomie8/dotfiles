-- options
vim.bo.commentstring = "// %s"
vim.bo.makeprg = "asy %"
vim.bo.errorformat = "%f: %l.%c: %m"
vim.wo.winhighlight = "@constant.cpp:@variable.cpp"

vim.b.output_format = "pdf"

-- use C++ treesitter highlighting with custom queries
local query_path = vim.fn.stdpath("config") .. "/queries/asymptote/highlights.scm"
if vim.fn.filereadable(query_path) ~= 1 then return end
local query_text = table.concat(vim.fn.readfile(query_path), "\n")
vim.treesitter.query.set("cpp", "highlights", query_text)

-- compile asy code
local function asy(opts)
	opts = opts or {}
	local args = vim.iter({ "-f", vim.b.output_format or "pdf", opts.args }):flatten():totable()
	local bufnr = opts.bufnr or 0
	if opts.notify == nil then opts.notify = true end

	local text = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local preamble = require("static.lang.asymptote.preamble")
	local preamble_size = select(2, preamble:gsub("\n", ""))
	local input = preamble .. table.concat(text, "\n")

	vim.system(
		vim.iter({
			"asy",
			args,
			"-o",
			vim.fn.expand("%:r"),
		}):flatten():totable(),
		{ text = true, stdin = input },
		function(obj)
			if opts.notify and #obj.stderr ~= 0 then
				obj.stderr = obj.stderr:gsub("%-: (%d+)%.", function(num)
					local new_num = tonumber(num) - preamble_size
					return string.format("-: %d.1:", new_num)
				end)
				if obj.code ~= 0 then
					vim.notify(obj.stderr, vim.log.levels.ERROR, { title = "Asymptote", icon = "󰒕" })
				else
					vim.notify(obj.stderr, vim.log.levels.WARN, { title = "Asymptote", icon = "󰒕" })
				end
			end
			if opts.open and obj.code == 0 then
				require("utils.pdf").open(vim.fn.expand("%:r") .. ".pdf")
			end
		end
	)
end

vim.keymap.set("n", "<localleader>p", function()
	asy({ open = true })
end, { desc = "compile and open", buffer = true })

vim.keymap.set("n", "<localleader>c", asy, { desc = "compile", buffer = true })

-- live rendering
vim.b.asy_live_rendering = nil
vim.api.nvim_buf_create_user_command(0, "LiveRender", function(args)
	local id = vim.b.asy_live_render_autocmd_id
	if args.bang and id then
		vim.api.nvim_del_autocmd(id)
		vim.b.asy_live_render_autocmd_id = nil
		vim.b.asy_live_rendering = false
	elseif not id then
		vim.b.asy_live_render_autocmd_id =
			vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
				callback = function(event)
					asy({ bufnr = event.buf, notify = false })
				end,
				buffer = 0,
			})
		vim.b.asy_live_rendering = true
		asy()
	end
end, {
	bang = true,
	desc = "Live render asymptote",
})

vim.keymap.set("n", "<localleader>ll", function()
	if vim.b.asy_live_rendering then
		vim.notify("Live rendering disabled !", vim.log.levels.INFO, { title = "Asymptote", icon = "󰒕", timeout = 0 })
		vim.cmd("LiveRender!")
	else
		vim.notify("Live rendering enabled !", vim.log.levels.INFO, { title = "Asymptote", icon = "󰒕", timeout = 0 })
		vim.cmd("LiveRender")
	end
end, { desc = "Toggle live rendering" })

-- open pdf
vim.api.nvim_buf_create_user_command(0, "OpenPdf", function()
	local pdf_path = vim.api.nvim_buf_get_name(0):gsub("%.asy$", ".pdf")
	require("utils.pdf").open(pdf_path)
end, {})

vim.keymap.set("n", "<localleader>o", "<Cmd>OpenPdf<CR>", { desc = "Open pdf", buffer = true })
