-- tab title
ps.sub("ind-app-title", function(args)
	args.value = "󰇥 " .. tostring(cx.active.current.cwd.name)
	return args
end)

-- plugins
require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("smart-enter"):setup({ open_multi = true })

require("folder-rules"):setup()

th.git = th.git or {}
th.git.added_sign = " "
th.git.modified_sign = " "
th.git.deleted_sign = "󱟃 "
th.git.updated_sign = " "
th.git.untracked_sign = " "
th.git.ignored_sign = " "
th.git.added = ui.Style():fg("#76946a")
th.git.modified = ui.Style():fg("#dca561")
th.git.deleted = ui.Style():fg("#c34043")
th.git.updated = ui.Style():fg("#5fd700")
th.git.untracked = ui.Style():fg("#957fb8")
th.git.ignored = ui.Style():fg("#727169")
require("git"):setup({ order = 1500 })

-- statusline components
function Status:mode()
	local mode = tostring(self._tab.mode):upper()

	local style = self:style()
	return ui.Line({
		ui.Span(th.status.sep_left.open):fg(style.main:bg()):bg("reset"),
		ui.Span(" " .. mode .. " "):style(style.main),
		ui.Span(th.status.sep_left.close):fg(style.main:bg()):bg(style.alt:bg()),
	})
end

function Status:size()
	-- local h = self._current.hovered
	-- local size = h and (h:size() or h.cha.len) or 0

	local style = self:style()
	return ui.Line({
		-- ui.Span(" " .. ya.readable_size(size) .. " "):style(style.alt),
		ui.Span(th.status.sep_left.close):fg(style.alt:bg()),
	})
end

function Status:name()
	local h = self._current.hovered
	if not h then return ui.Line({}) end

	local icon = h:icon()
	local url = tostring(h.url)
	local home = os.getenv("HOME")
	if home and url:sub(1, #home) == home then
		url = "~" .. url:sub(#home + 1)
	end
	local spans = {
		ui.Span(" " .. tostring(url)),
		ui.Span(" " .. icon.text):style(icon.style),
	}

	if h.link_to then
		local color = h:style()
		table.insert(spans, 2, ui.Span(" -> "):fg(h:style():fg()))
		table.insert(spans, 3, ui.Span(tostring(h.link_to)))
	end

	return ui.Line(spans)
end

function Status:perm()
	local h = self._current.hovered
	if not h then
		return ""
	end

	local perm = h.cha:perm()
	if not perm then
		return ""
	end

	local spans = {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
	for i = 1, #perm do
		local c = perm:sub(i, i)
		local style = th.status.perm_type
		if c == "-" or c == "?" then
			style = th.status.perm_sep
		elseif c == "r" then
			style = th.status.perm_read
		elseif c == "w" then
			style = th.status.perm_write
		elseif c == "x" or c == "s" or c == "S" or c == "t" or c == "T" then
			style = th.status.perm_exec
		end
		spans[#spans + 1] = ui.Span(c):style(style)
	end
	return ui.Line(spans)
end

function Status:percent()
	local percent = 0
	local cursor = self._current.cursor
	local length = #self._current.files
	if cursor ~= 0 and length ~= 0 then
		percent = math.floor((cursor + 1) * 100 / length)
	end

	if percent == 0 then
		percent = " Top "
	elseif percent == 100 then
		percent = " Bot "
	else
		percent = string.format(" %2d%% ", percent)
	end

	local style = self:style()
	return ui.Line({
		ui.Span(" " .. th.status.sep_right.open):fg(style.alt:bg()),
		ui.Span(percent):style(style.alt),
		ui.Span(string.format("%2d/%-2d ", math.min(cursor + 1, length), length)):style(style.alt),
	})
end

function Status:position()
	local style = self:style()
	return ui.Line({
		ui.Span(th.status.sep_right.open):fg(style.main:bg()):bg(style.alt:bg()),
		ui.Span("  " .. tostring(os.date("%R")) .. " "):style(style.main),
		ui.Span(th.status.sep_right.close):fg(style.main:bg()):bg("reset"),
	})
end

-- merge tabs into header
Header:children_add(function()
	if #cx.tabs == 1 then return "" end
	local lines = {}
	if cx.tabs.idx ~= 1 then
		lines[1] = ui.Line(th.tabs.sep_outer.open):fg(th.tabs.inactive:bg())
	end

	local max = 20
	for i = 1, #cx.tabs do
		if i == cx.tabs.idx then
			local name = ui.truncate(string.format(
				"%d %s",
				i,
				cx.tabs[i].name
			), { max = max })
			local left_sep = ui.Span(th.tabs.sep_inner.open):style(th.tabs.inactive)
			local right_sep = ui.Span(th.tabs.sep_inner.close):style(th.tabs.inactive)
			if i == 1 then
				left_sep = left_sep:bg("reset")
			end
			if i == #cx.tabs then
				right_sep = right_sep:bg("reset")
			end
			lines[#lines + 1] = ui.Line({
				left_sep,
				ui.Span(name):style(th.tabs.active),
				right_sep,
			})
		else
			local name = ui.truncate(string.format(
				(i ~= 1 and " " or "") .. "%d %s" .. (i ~= #cx.tabs and " " or ""),
				i,
				cx.tabs[i].name
			), { max = max })
			lines[#lines + 1] = ui.Line(name):style(th.tabs.inactive)
		end
	end

	if cx.tabs.idx ~= #cx.tabs then
		lines[#lines + 1] = ui.Line(th.tabs.sep_outer.close):fg(th.tabs.inactive:bg())
	end

	return ui.Line(lines)
end, 9000, Header.RIGHT)

function Tabs.height() return 0 end -- hide tab bar

-- change linemode style
th.linemode = ui.Style():fg("#54546d")

function Linemode:mime()
	return ui.Span(self._file:mime() or ""):style(th.linemode)
end

function Linemode:size()
	local size = self._file:size()
	if size then
		return ui.Span(ya.readable_size(size)):style(th.linemode)
	else
		local folder = cx.active:history(self._file.url)
		return folder and ui.Span(tostring(#folder.files)):style(th.linemode) or ""
	end
end

function Linemode:btime()
	local time = math.floor(self._file.cha.btime or 0)
	if time == 0 then
		return ""
	elseif os.date("%Y", time) == os.date("%Y") then
		return ui.Span(os.date("%m/%d %H:%M", time)):style(th.linemode)
	else
		return ui.Span(os.date("%m/%d  %Y", time)):style(th.linemode)
	end
end

function Linemode:mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		return ""
	elseif os.date("%Y", time) == os.date("%Y") then
		return ui.Span(os.date("%m/%d %H:%M", time)):style(th.linemode)
	else
		return ui.Span(os.date("%m/%d  %Y", time)):style(th.linemode)
	end
end

function Linemode:permissions()
	return ui.Span(self._file.cha:perm() or ""):style(th.linemode)
end

function Linemode:owner()
	local user = ya.user_name and ya.user_name(self._file.cha.uid) or self._file.cha.uid
	local group = ya.group_name and ya.group_name(self._file.cha.gid) or self._file.cha.gid
	return ui.Span(string.format("%s:%s", user, group)):style(th.linemode)
end

function Entity:found()
	if not self._file.is_hovered then
		return ""
	end

	local found = self._file:found()
	if not found then
		return ""
	elseif found[1] >= 99 then
		return ""
	end

	local s = string.format("[%d/%s]", found[1] + 1, found[2] >= 100 and "99+" or found[2])
	return ui.Line({ "  ", ui.Span(s):style(th.mgr.find_position) }):style(th.linemode)
end

-- don't color the icon the same color as the current line
function Entity:icon()
	local icon = self._file:icon()
	if not icon then
		return ""
	else
		return ui.Line(icon.text .. " "):style(icon.style)
	end
end
