local M = {}

---@param opts snacks.picker.notifications.Config
function M.notifier(opts)
	local notifs = require("notify").history()
	local items = {} ---@type snacks.picker.finder.Item[]

	local i = #notifs
	while i >= 1 do
		local notif = notifs[i]
		notif.msg = table.concat(notif.message, " ")
		notif.title = notif.title[1]
		items[#items + 1] = {
			text = notif.level:lower() .. " " .. notif.title .. " " .. notif.msg,
			item = notif,
			severity = notif.level,
			preview = {
				text = notif.msg,
				ft = "markdown",
			},
		}

		i = i - 1
	end

	return items
end

return M
