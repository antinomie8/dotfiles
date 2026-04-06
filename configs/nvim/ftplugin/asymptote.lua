-- options
vim.bo.commentstring = "// %s"
vim.bo.makeprg = "asy %"
vim.bo.errorformat = "%f: %l.%c: %m"
vim.wo.winhighlight = "@constant.cpp:@variable.cpp"
vim.bo.includeexpr = "v:lua.require'utils.includeexpr'.asymptote(v:fname)"

vim.b.output_format = "pdf"

-- load custom queries for C++ treesitter highlighting
local asy_queries_path = vim.fn.stdpath("config") .. "/queries/asymptote/"
local highlights = require("utils").loadfile(asy_queries_path .. "highlights.scm")
if highlights then vim.treesitter.query.set("cpp", "highlights", highlights) end

-- compile asy code
local ns = vim.api.nvim_create_namespace("Asymptote")

---@class AsyOpts
---@field bufnr? integer
---@field args? string[]
---@field open? boolean
---@field notify? boolean
---@param opts AsyOpts?
local function asy(opts)
	opts = opts or {}
	local args = vim.iter({ "-f", vim.b.output_format or "pdf", opts.args }):flatten():totable()
	local bufnr = opts.bufnr or 0
	if opts.notify == nil then opts.notify = true end

	local text = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local preamble = require("static.lang.asymptote.preamble")
	local preamble_size = select(2, preamble:gsub("\n", ""))
	local input = preamble .. table.concat(text, "\n")
	local name = vim.fn.expand("%:r")

	vim.system(
		vim.iter({
			"asy",
			args,
			"-o",
			vim.fn.expand("%:r"),
		}):flatten():totable(),
		{ stdin = input },
		function(obj)
			if opts.notify and #obj.stderr ~= 0 then
				---@class vim.Diagnostic.Set[]
				local diagnostics = {}

				-- parse diagnostics
				obj.stderr = obj.stderr:gsub("^%-: (%d+)%.(%d+): (.*)$", function(lnum, col, message)
					local new_num = tonumber(lnum) - preamble_size
					col = tonumber(col)
					table.insert(diagnostics, { lnum = new_num - 1, col = col, message = message, source = "Asymptote compiler" })
					return string.format("-: %d.%d: %s", new_num, col, vim.trim(message))
				end)

				-- set diagnostics
				vim.schedule(function()
					for _, i in ipairs(diagnostics) do
						vim.diagnostic.set(ns, bufnr, diagnostics, { update_in_insert = true })
					end
					vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
						callback = function()
							vim.diagnostic.reset(ns, bufnr)
						end,
						once = true,
					})
				end)

				-- notify errors
				if obj.code ~= 0 then
					vim.notify(obj.stderr, vim.log.levels.ERROR, { title = "Asymptote", icon = "󰒕" })
				else
					vim.notify(obj.stderr, vim.log.levels.WARN, { title = "Asymptote", icon = "󰒕" })
				end
			end
			if opts.open and obj.code == 0 then
				require("utils.pdf").open(name .. ".pdf")
			end
		end
	)
end

vim.keymap.set("n", "<localleader>p", function()
	asy({ open = true })
end, { desc = "compile and open", buffer = true })

vim.keymap.set("n", "<localleader>c", asy, { desc = "compile", buffer = true })

-- live rendering
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
		vim.cmd.LiveRender({ bang = true })
	else
		vim.notify("Live rendering enabled !", vim.log.levels.INFO, { title = "Asymptote", icon = "󰒕", timeout = 0 })
		vim.cmd.LiveRender()
		vim.cmd.OpenPdf({ bang = true })
	end
end, { desc = "Toggle live rendering" })

-- open pdf
vim.api.nvim_buf_create_user_command(0, "OpenPdf", function(arg)
	local path = arg.fargs[1] or vim.api.nvim_buf_get_name(0):gsub("%.asy$", ".pdf")
	require("utils.pdf").open(path, { silent = arg.bang })
end, { nargs = "?", bang = true })

vim.keymap.set("n", "<localleader>o", "<Cmd>OpenPdf<CR>", { desc = "Open pdf", buffer = true })
