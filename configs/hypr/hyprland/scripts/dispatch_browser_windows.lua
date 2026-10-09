local cats = {
	["Divers"] = 1,
	["Maths"] = 2,
	["Info"] = 3,
	["IA"] = 4,
	["Administratif"] = 5,
}

local function is_firefox(win)
	return win.class == "firefox" or win.initial_class == "firefox"
end

local function move_window(win)
	if not is_firefox(win) then return end
	-- title may be empty at window.open, fallback to initial_title
	local title = (win.title ~= "" and win.title) or win.initial_title
	if not title or title == "" then return end
	local cat = title:match("^%[([^]]*)%]")
	if not cat then return end
	local ws = cat:match("^%d$") and tonumber(cat) or cats[cat]
	if not ws then return end
	-- avoid moving if already on target workspace
	if win.workspace and win.workspace.id == ws then return end
	hl.dispatch(
		hl.dsp.window.move({
			window = win,
			workspace = ws,
			follow = false,
		})
	)
end

hl.on("window.title", move_window)
hl.on("window.open", move_window)
hl.on("window.class", move_window)

-- handle windows that already exist when config is (re)loaded
for _, win in ipairs(hl.get_windows()) do
	move_window(win)
end
