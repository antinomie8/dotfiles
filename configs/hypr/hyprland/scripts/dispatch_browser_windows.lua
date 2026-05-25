hl.on("window.title", function(win)
	if win.class == "firefox" then
		local cats = {
			["Maths"] = 2,
			["Divers"] = 3,
			["Administratif"] = 4,
			["Info"] = 5,
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
end)
