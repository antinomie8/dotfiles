---@diagnostic disable: undefined-global

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

th.git = th.git or {}
th.git.added_sign = " "
th.git.modified_sign = " "
th.git.deleted_sign = "󱟃 "
th.git.updated_sign = " "
th.git.untracked_sign = " "
th.git.ignored_sign = ""
require("git"):setup()

-- status
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
	if not h then
		return ui.Line({})
	end
	local icon = h:icon()

	return ui.Line({
		ui.Span(" " .. tostring(h.url) .. " "),
		ui.Span(icon.text):style(icon.style),
	})
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

	local spans = {}
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
		spans[i] = ui.Span(c):style(style)
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

-- header
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

function Tabs.height() return 0 end
