local function move_window(win)
	if win.class == "firefox" then
		local cats = {
			["Divers"] = 1,
			["Maths"] = 2,
			["Info"] = 3,
			["Administratif"] = 4,
		}
		local cat = win.title:match("^%[(%a*)%]")
		local ws = cat and cats[cat] or nil
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
