local M = {}

local config = {
	open_cmd = function(url)
		require("utils.hypr").set_layout("master")
		local id = vim.api.nvim_create_autocmd("VimLeave", {
			callback = function() require("utils.hypr").set_layout() end,
		})

		vim.fn.jobstart({ "firefox", "--new-window", url, "-P", "typst-preview" }, {
			on_exit = function()
				vim.schedule(function()
					require("utils.hypr").set_layout()
					vim.api.nvim_del_autocmd(id)
				end)
			end,
		})

		-- doesn't kill firefox on exit for some reason
		-- vim.system(
		-- 	{ "firefox", "--new-window", url, "-P", "typst-preview" },
		-- 	{}, function()
		-- 		vim.schedule_wrap(require("utils.hypr").set_layout)
		-- 	end)
	end,
	follow_cursor = true,
	debounce_ms = 80, -- Debounce window for cursor movements to prevent LSP spam
}

local debounce_timer = nil
local last_line

local function error(msg, level)
	vim.notify(msg, level or vim.log.levels.ERROR, { title = "Tinymist", icon = "" })
end

---Synchronizes preview scroll position with Neovim cursor
---@param bufnr integer
---@param client vim.lsp.Client
function M.scroll_preview(bufnr, client)
	if not vim.api.nvim_buf_is_valid(bufnr) then return end
	if not config.follow_cursor then return end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = cursor[1] - 1
	if line == last_line then
		return
	else
		last_line = line
	end
	local character = cursor[2]

	client:exec_cmd({
		title = "scrollPreview",
		command = "tinymist.scrollPreview",
		arguments = {
			"default-preview",
			{
				event = "panelScrollTo",
				filepath = vim.api.nvim_buf_get_name(bufnr),
				line = line,
				character = character,
			},
		},
	}, { bufnr = bufnr }, function(err, result)
		if err then
			error("Preview error: " .. tostring(err.message))
		end
	end)
end

---Initialize cursor tracking autocommands
---@param bufnr integer
---@param client vim.lsp.Client
local function setup_follow_cursor(bufnr, client)
	local group = vim.api.nvim_create_augroup("TypstPreviewFollowCursor_" .. bufnr, { clear = true })

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = group,
		buffer = bufnr,
		callback = function()
			if debounce_timer then
				debounce_timer:stop()
			else
				debounce_timer = vim.uv.new_timer()
				if not debounce_timer then return end
			end

			debounce_timer:start(config.debounce_ms, 0, vim.schedule_wrap(function()
				M.scroll_preview(bufnr, client)
			end))
		end,
	})

	-- Clean up resources when buffer is unloaded
	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		buffer = bufnr,
		callback = function()
			if debounce_timer then
				debounce_timer:stop()
				debounce_timer:close()
				debounce_timer = nil
			end
			vim.api.nvim_del_augroup_by_id(group)
		end,
	})
end

---@param client vim.lsp.Client
function M.start_preview(client)
	local bufnr = vim.api.nvim_get_current_buf()

	if not client then
		error("Tinymist LSP client is not active on this buffer.")
		return
	end

	if vim.b[bufnr].typst_preview_url then
		config.open_cmd(vim.b[bufnr].typst_preview_url)
		return
	end

	vim.notify("Starting web preview server...", vim.log.levels.INFO)

	client:exec_cmd({
		title = "start browsing preview server",
		command = "tinymist.startDefaultPreview",
		arguments = { vim.v.null },
	}, { bufnr = bufnr }, function(err, result)
		if err then
			error("Failed to start preview: " .. tostring(err.message))
			return
		end

		if not result or not result.staticServerAddr then
			error("Tinymist did not return a valid server URL.", vim.log.levels.WARN)
			return
		end

		local url = "http://" .. result.staticServerAddr
		vim.b[bufnr].typst_preview_url = url

		config.open_cmd(url)

		setup_follow_cursor(bufnr, client)
	end)
end

return M
