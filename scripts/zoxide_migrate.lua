#!/usr/bin/env lua

-- zoxide_migrate.lua
-- Usage: lua zoxide_migrate.lua <file> <old> <new>

local filename = arg[1]
local old = arg[2]
local new = arg[3]

if not filename or not old or not new then
	io.stderr:write("Usage: lua zoxide_migrate.lua <file> <old> <new>\n")
	os.exit(1)
end

local file, err = io.open(filename, "r")
if not file then
	io.stderr:write("Error opening file: " .. err .. "\n")
	os.exit(1)
end

local function shell_escape(s)
	-- minimal POSIX-safe shell escaping
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function escape_lua_pattern(s)
	return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

for line in file:lines() do
	-- skip empty or whitespace-only lines
	if not line:match("^%s*$") then
		local score, path = line:match("^%s*(%S+)%s+(.+)$")

		if not score or not path then
			io.stderr:write("Skipping malformed line: " .. line .. "\n")
		else
			local escaped_old = escape_lua_pattern(old)
			local new_path = path:gsub(escaped_old, new, 1)

			if new_path ~= path then
				-- remove old path
				os.execute(
					"zoxide remove " .. shell_escape(path) .. " >/dev/null 2>&1"
				)
				-- reset score and add new path with score
				os.execute(
					"zoxide remove " .. shell_escape(new_path) .. " >/dev/null 2>&1"
				)
				os.execute(
					"zoxide add " .. shell_escape(new_path) ..
					" --score " .. tonumber(score) / 4 -- need divide by 4
				)

				print(string.format(
					"✔ %s → %s (score=%s)",
					path, new_path, score
				))
			else
				io.stderr:write(
					"No substitution made, skipping: " .. path .. "\n"
				)
			end
		end
	end
end

file:close()
