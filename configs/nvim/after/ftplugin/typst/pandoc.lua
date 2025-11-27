local function format(lines)
	local replace = {
		["bb%((%a)%)"] = "%1%1",
		[" %("] = "(",

		["dot%.op"] = "dot",
		["integral_"] = "int_",
		["integral%.cont"] = "oint",
		["integral%.double"] = "iint",
		["integral%.triple"] = "iiint",
		["thin dif"] = "dif",
		["thin bf"] = "bf",
		["quad arrow.r.double quad"] = "==>",
		["\\%-"] = "-",
		["%-\n"] = "- ",
		["%*%*"] = "*",
		["\\%*"] = "*",
		["\\#"] = "=",
		[" gt%.eq "] = " >= ",
		[" lt%.eq "] = " <= ",
		[" eq%.not "] = " != ",
		[" plus%.minus "] = " pm ",
		['delim: "%(", '] = "",

		["⌊"] = "floor(",
		["⌋"] = ")",
		["⌈"] = "ceil(",
		["⌉"] = ")",
		["⟨ "] = "angle.l ",
		["⟨"] = "angle.l ",
		[" ⟩"] = " angle.r",
		["⟩"] = "angle.r",

		[" thin "] = " ",
		["\\,"] = ",",
	}

	for tex, typst in pairs(replace) do
		if type(typst) == "table" then
			if typst.cond() then
				lines = lines:gsub(tex, typst[1])
			end
		else
			lines = lines:gsub(tex, typst)
		end
	end

	return lines
end

vim.api.nvim_buf_create_user_command(0, "LatexToTypst", function(opts)
	local start_line, end_line
	if opts.range == 0 then
		start_line, end_line = 1, -1
	else
		start_line, end_line = opts.line1, opts.line2
	end

	local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local input = table.concat(text, "\n")

	vim.system({
		"pandoc",
		"-f", "latex",
		"-t", "typst",
	}, { text = true, stdin = input }, function(obj)
		if #obj.stderr ~= 0 then
			if obj.code ~= 0 then
				vim.notify(obj.stderr, vim.log.levels.ERROR, { title = "Pandoc", icon = "󰈙" })
			else
				vim.notify(obj.stderr, vim.log.levels.WARN, { title = "Pandoc", icon = "󰈙" })
			end
		end
		if obj.code ~= 0 then return end
		local formatted_lines = format(obj.stdout)
		local converted_lines = vim.split(formatted_lines, "\n", { plain = true })
		vim.schedule(function()
			vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, converted_lines)
		end)
	end)
end, {
	range = true,
	desc = "Convert LaTeX to Typst",
})
