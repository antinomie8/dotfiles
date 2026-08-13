local cats = {
	["Divers"] = 1,
	["Maths"] = 2,
	["Info"] = 3,
	["IA"] = 4,
	["Administratif"] = 5,
}

local function move_window(win)
	if win.class == "firefox" then
		local cat = win.title:match("^%[([^]]*)%]")
		if not cat then return end
		local ws = cat:match("^%d$") and tonumber(cat) or cats[cat]
		if ws then
			hl.dispatch(
				hl.dsp.window.move({
					window = win,
					workspace = ws,
					follow = false,
				})
			)
		end
	end
end

hl.on("window.title", move_window)
hl.on("window.open", move_window)
