---@alias lang {lang: string, icon: string, ext: string, edit: fun(path: string, exists: boolean)}

---@param name string
---@param lang lang
local function create_or_edit_figure(name, lang)
	local root = vim.fn.fnamemodify(vim.b.typst_root, ":h") or vim.fn.getcwd()
	local figure_dir = root .. "/figures"
	local figure_path = figure_dir .. "/" .. name .. "." .. lang.ext

	local stat = vim.uv.fs_stat(figure_dir)
	if not stat then
		local ok, err = vim.uv.fs_mkdir(figure_dir, 493) -- 493 -> rwxr-xr-x
		if not ok then
			vim.notify("Failed to create directory: " .. err, vim.log.levels.ERROR, { title = lang.lang, icon = lang.icon })
		end
	elseif stat.type ~= "directory" then
		vim.notify(figure_dir .. " is not a directory !", vim.log.levels.ERROR, { title = lang.lang, icon = lang.icon })
	end

	local exists = vim.uv.fs_stat(figure_path) ~= nil
	if not exists then
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.fn.fnamemodify(name, ":p") == figure_path then
				exists = true
			end
		end
	end
	if not exists then
		local indentwidth = vim.api.nvim_eval(vim.opt_local.indentexpr:get()) / vim.bo.shiftwidth
		local figure_line = string.format('%s#figure(image("figures/%s.%s")) <%s>',
			string.rep("\t", indentwidth), name, (lang.ext == "svg" and "svg" or "pdf"), name)
		local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_lines(0, row, row, false, { figure_line })
	end

	lang.edit(figure_path, exists)
end

local langs = {
	{
		lang = "Asymptote",
		icon = "󰒕",
		ext = "asy",
		cmd = "Asy",
		keymap = "<localleader>a",
		edit = function(path, exists)
			vim.cmd.edit(path)
			-- Insert initial content into the new .asy buffer
			if not exists then
				vim.api.nvim_buf_set_lines(0, 0, 0, false,
					vim.split(require("static.lang.asymptote.preamble"), "\n"))
				vim.cmd("LiveRender")
			end
		end,
	},
	{
		lang = "Inkscape",
		icon = "󰜡",
		ext = "svg",
		cmd = "Svg",
		keymap = "<localleader>i",
		edit = function(path, _)
			local template = (vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config") .. "/inkscape/templates/template.svg"
			vim.system({ "cp", template, path }):wait()
			vim.system({ "inkscape", path }, { detach = true })
		end,
	},
} --[[@as table<lang>]]

for _, lang in ipairs(langs) do
	vim.api.nvim_buf_create_user_command(0, lang.cmd, function(arg)
		local name = arg.args
		if name == "" then
			local line = vim.api.nvim_get_current_line()
			local match = line:match('image%("figures/(.*)%.pdf"%)') or line:match('image%("figures/(.*)%.svg"%)')
			if match then
				create_or_edit_figure(match, lang)
			else
				vim.ui.input({ prompt = "New figure name" }, function(input)
					if input then
						create_or_edit_figure(input, lang)
					end
				end)
			end
		else
			create_or_edit_figure(name, lang)
		end
	end, {
		nargs = "?",
		complete = function()
			local results = {}

			local cwd = vim.uv.cwd()
			if not cwd then return results end

			local figures_dir = vim.fs.joinpath(cwd .. "/figures")

			local fd = vim.uv.fs_scandir(figures_dir)
			if not fd then return results end

			while true do
				local name, type = vim.uv.fs_scandir_next(fd)
				if not name then return results end

				local pattern = "%." .. lang.ext .. "$"
				if type == "file" and name:match(pattern) then
					local base_name = name:gsub(pattern, "")
					-- let the completion plugin handle the rest
					table.insert(results, base_name)
				end
			end
		end,
		desc = "Create a new " .. lang.lang .. " figure and insert Typst reference",
	})

	vim.keymap.set("n", lang.keymap, "<Cmd>" .. lang.cmd .. "<CR>",
		{ desc = "Create a new " .. lang.lang .. " figure and insert Typst reference" })
end
