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

require("directory-rules"):setup()

th.git = th.git or {}
th.git.added_sign = " "
th.git.modified_sign = " "
th.git.deleted_sign = "󱟃 "
th.git.updated_sign = " "
th.git.untracked_sign = " "
th.git.ignored_sign = " "
th.git.added = ui.Style():fg("#76946a")
th.git.modified = ui.Style():fg("#dca561")
th.git.deleted = ui.Style():fg("#c34043")
th.git.updated = ui.Style():fg("#e82424")
th.git.untracked = ui.Style():fg("#957fb8")
th.git.ignored = ui.Style():fg("#727169")
require("git"):setup({ order = 500 })

require("restore"):setup({
	position = { "center", h = 20, w = 70 },
	show_confirm = false, -- Show confirm prompt before restore.
	suppress_success_notification = true, -- Suppress success notification when all files or folder are restored.
})

-- statusline components {{{
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
	local percent = 0 ---@type integer|string
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

Status.clocks = { "󱑖 ", "󱑋 ", "󱑌 ", "󱑍 ", "󱑎 ", "󱑏 ", "󱑐 ", "󱑑 ", "󱑒 ", "󱑓 ", "󱑔 ", "󱑕 " }
function Status:position()
	local style = self:style()
	local date = os.date("%R")
	local hour = tonumber(tostring(date):sub(1, 2))
	local icon = self.clocks[hour % 12 + 1]

	return ui.Line({
		ui.Span(th.status.sep_right.open):fg(style.main:bg()):bg(style.alt:bg()),
		ui.Span(" " .. icon .. date .. " "):style(style.main),
		ui.Span(th.status.sep_right.close):fg(style.main:bg()):bg("reset"),
	})
end

-- }}}

-- merge tabs into header {{{
Header = {
	-- TODO: remove these two constants
	LEFT = 0,
	RIGHT = 1,

	_id = "header",
	_inc = 1000,
	_left = {
		{ "cwd", id = 1, order = 1000 },
		{ "flags", id = 2, order = 2000 },
	},
	_right = {
		{ "count", id = 1, order = 1000 },
	},
	_offsets = {},
}

function Header:new(area, tab)
	return setmetatable({
		_area = area,
		_tab = tab,
		_current = tab.current,
	}, { __index = self })
end

function Header:cwd()
	local max = self._area.w - self._right_width
	if max <= 0 then
		return ""
	end

	local s = ya.readable_path(tostring(self._current.cwd))
	return ui.Span(ui.truncate(s, { max = max, rtl = true })):style(th.mgr.cwd)
end

function Header:flags()
	local cwd = self._current.cwd
	local filter = self._current.files.filter
	local finder = self._tab.finder

	local t = {}
	if cwd.is_search then
		t[#t + 1] = string.format("search: %s", cwd.domain)
	end
	if filter then
		t[#t + 1] = string.format("filter: %s", filter)
	end
	if finder then
		t[#t + 1] = string.format("find: %s", finder)
	end
	-- return #t == 0 and "" or " (" .. table.concat(t, ", ") .. ")"
	local text = #t == 0 and "" or " (" .. table.concat(t, ", ") .. ")"
	return ui.Span(text):style(th.status.perm_sep)
end

function Header:count()
	local selected = #self._tab.selected
	local yanked = selected > 0 and 0 or #cx.yanked

	local span
	if selected > 0 then
		span = ui.Span(" " .. selected .. " "):style(th.mgr.count_selected)
	elseif yanked <= 0 then
		return ""
	elseif cx.yanked.is_cut then
		span = ui.Span(" " .. yanked .. " "):style(th.mgr.count_cut)
	else
		span = ui.Span(" " .. yanked .. " "):style(th.mgr.count_copied)
	end

	return ui.Line({ span, " " })
end

function Header:reflow() return { self } end

function Header:redraw()
	local right = self:children_redraw(self.RIGHT)
	self._right_width = right:width()

	local left = self:children_redraw(self.LEFT)

	return {
		ui.Line(left):area(self._area),
		ui.Line(right):area(self._area)--[[@as ui.Line]]:align(ui.Align.RIGHT),
	}
end

-- Children
function Header:children_add(fn, order, side)
	self._inc = self._inc + 1
	local children = side == self.RIGHT and self._right or self._left

	children[#children + 1] = { fn, id = self._inc, order = order }
	table.sort(children, function(a, b) return a.order < b.order end)

	return self._inc
end

function Header:children_remove(id, side)
	local children = side == self.RIGHT and self._right or self._left
	for i, child in ipairs(children) do
		if child.id == id then
			table.remove(children, i)
			break
		end
	end
end

function Header:children_redraw(side)
	local lines = {}
	for _, c in ipairs(side == self.RIGHT and self._right or self._left) do
		lines[#lines + 1] = (type(c[1]) == "string" and self[c[1]] or c[1])(self)
	end
	return ui.Line(lines)
end

Header:children_add(function(self)
	if #cx.tabs == 1 then
		return ""
	end

	local lines = {}
	if cx.tabs.idx ~= 1 then
		lines[1] = ui.Line(th.tabs.sep_outer.open):fg(th.tabs.inactive:bg())
	end

	local max = math.floor(self:inner_width() / #cx.tabs)
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
		self._offsets[i] = lines[#lines]:width()
	end

	if cx.tabs.idx ~= #cx.tabs then
		lines[#lines + 1] = ui.Line(th.tabs.sep_outer.close):fg(th.tabs.inactive:bg())
	end

	return ui.Line(lines):area(self._area)
end, 9000, Header.RIGHT)

function Header:inner_width()
	local si, so = th.tabs.sep_inner, th.tabs.sep_outer
	return 0.75 * math.max(0, self._area.w - ui.Line({ si.open, si.close, so.open, so.close }):width())
end

function Header:click(event, up)
	if up or event.is_middle then
		return
	end
	local col = self._area.w
	for i = #cx.tabs, 1, -1 do
		col = col - self._offsets[i]
		if event.x >= col then
			ya.emit("tab_switch", { i - 1 })
			break
		end
	end
end

function Tabs.height() return 0 end -- hide tab bar

-- }}}

-- change linemode style {{{
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
		return ui.Span(os.date("%d/%m %H:%M", time)--[[@as string]]):style(th.linemode)
	else
		return ui.Span(os.date("%d/%m  %Y", time)--[[@as string]]):style(th.linemode)
	end
end

function Linemode:mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		return ""
	elseif os.date("%Y", time) == os.date("%Y") then
		return ui.Span(os.date("%d/%m %H:%M", time)--[[@as string]]):style(th.linemode)
	else
		return ui.Span(os.date("%d/%m  %Y", time)--[[@as string]]):style(th.linemode)
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

-- }}}

-- don't color the icon the same color as the current line
function Entity:icon()
	local icon = self._file:icon()
	if not icon then
		return ""
	else
		return ui.Line(icon.text .. " "):style(icon.style)
	end
end
