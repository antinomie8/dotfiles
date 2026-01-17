return {
	{
		"kevinhwang91/nvim-hlslens",
		lazy = true,
		keys = {
			{
				"n",
				"<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
				desc = "Previous",
			},
			{ "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>", desc = "Next" },
		},
		init = function()
			local group = vim.api.nvim_create_augroup("hlslens lazy loading", { clear = true })
			vim.api.nvim_create_autocmd("CmdlineEnter", {
				group = group,
				callback = function()
					local cmd_type = vim.fn.getcmdtype()
					if cmd_type == "/" or cmd_type == "?" then
						require("hlslens")
						vim.api.nvim_del_augroup_by_name("hlslens lazy loading")
					end
				end,
			})
			vim.api.nvim_create_autocmd("CmdlineChanged", {
				group = group,
				callback = function()
					local cmd_text = vim.fn.getcmdline()
					if cmd_text:match("^[<>,%d%s%%']*s") then
						require("hlslens")
						vim.api.nvim_del_augroup_by_name("hlslens lazy loading")
					end
				end,
			})
		end,
		opts = {
			nearest_float_when = "never",
			override_lens = function(render, posList, nearest, idx, relIdx)
				local sfw = vim.v.searchforward == 1
				local indicator, text, chunks
				local absRelIdx = math.abs(relIdx)
				if absRelIdx > 1 then
					indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and " " or " ")
				elseif absRelIdx == 1 then
					indicator = sfw ~= (relIdx == 1) and "" or ""
				else
					indicator = ""
				end

				local lnum, col = unpack(posList[idx])
				if nearest then
					local cnt = #posList
					if indicator ~= "" then
						text = ("%s %d/%d"):format(indicator, idx, cnt)
					else
						text = ("%d/%d"):format(idx, cnt)
					end
					chunks = {
						{ "  ◖", "HlSearchLensNearReverted" },
						{ text, "HlSearchLensNear" },
						{ "◗", "HlSearchLensNearReverted" },
					}
				else
					text = ("%s"):format(indicator, idx)
					chunks = { { "  " }, { text, "HlSearchLens" } }
				end
				render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
			end,
		},
	},
	{
		"haya14busa/vim-asterisk",
		keys = {
			{ "*", "<Plug>(asterisk-z*)zz<Cmd>lua require('hlslens').start()<CR>" },
			{ "#", "<Plug>(asterisk-z#)zz<Cmd>lua require('hlslens').start()<CR>" },
			{ "g*", "<Plug>(asterisk-gz*)zz<Cmd>lua require('hlslens').start()<CR>" },
			{ "g#", "<Plug>(asterisk-gz#)zz<Cmd>lua require('hlslens').start()<CR>" },

			{ "*", "<Plug>(asterisk-z*)zz<Cmd>lua require('hlslens').start()<CR>" },
			{ "#", "<Plug>(asterisk-z#)zz<Cmd>lua require('hlslens').start()<CR>" },
			{ "g*", "<Plug>(asterisk-gz*)zz<Cmd>lua require('hlslens').start()<CR>" },
			{ "g#", "<Plug>(asterisk-gz#)zz<Cmd>lua require('hlslens').start()<CR>" },
		},
		config = function() vim.cmd("let g:asterisk#keeppos = 1") end,
	},
}
