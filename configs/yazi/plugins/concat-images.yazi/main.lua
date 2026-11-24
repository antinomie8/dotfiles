local selected_or_hovered = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, file in pairs(tab.selected) do
		paths[#paths + 1] = tostring(file.path)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.path)
	end
	return paths, tostring(tab.current.cwd)
end)

local function notify(content, level)
	ya.notify { title = "Concatenate images", content = content, level = level, timeout = 5 }
end

return {
	entry = function()
		local paths, cwd = selected_or_hovered()
		if #paths == 0 then
			return notify("No images selected", "warn")
		end

		local name, event = ya.input {
			title = "Output filename (including extension):",
			pos = { "top-center", y = 3, w = 60 },
		}
		if event ~= 1 or name == "" then
			return
		end
		if name:find("/") or name == "." or name == ".." then
			return notify("Enter a filename without directories", "error")
		end

		local output = tostring(Url(cwd):join(Url(name)))
		local result, err = Command("sh")
			:arg({ "-c", [[
				output=$1
				shift
				if [ -e "$output" ] || [ -L "$output" ]; then
					printf 'Output already exists: %s\n' "$output" >&2
					exit 1
				fi
				exec magick -- "$@" -auto-orient -append "$output"
			]], "sh", output })
			:arg(paths)
			:output()
		if not result then
			return notify("Failed to run ImageMagick: " .. tostring(err), "error")
		end
		if not result.status.success then
			return notify("Concatenation failed: " .. result.stderr, "error")
		end
		notify("Created " .. name, "info")
	end,
}
