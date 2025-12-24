#!/usr/bin/env lua

local plugins = {
	"https://github.com/yurikhan/kitty_grab",
}

local config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
if not os.execute("cd " .. config .. "/kitty") then
	os.exit(1)
end

for _, plugin in pairs(plugins) do
	os.execute("git clone " .. plugin)
end
