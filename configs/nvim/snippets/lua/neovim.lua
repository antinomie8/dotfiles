local ls = require("utils.snippets.luasnip")
local s, t, i, c, d, sn, fmt =
      ls.s, ls.t, ls.i, ls.c, ls.d, ls.sn, ls.fmt
local helpers = require("utils.snippets.helpers")
local line_begin = helpers.line_begin
local get_visual = helpers.get_visual
local not_in_string_comment = helpers.not_in_string_comment

return {
	s(
		{
			trig = "autocmd ",
			dscr = "Neovim autocmd",
			condition = not_in_string_comment * line_begin,
		},
		fmt(
			[[
				vim.api.nvim_create_autocmd(<>, {<>
					callback = function()
						<>
					end,
				})
			]],
			{
				c(1, {
					{ t('{ "'), i(1), t('" }') },
					{ t('"'), i(1), t('"') },
				}),
				c(2, {
					{ t({ "", '\tpattern = { "' }), i(1), t('" },') },
					{ t({ "", '\tpattern = "' }), i(1), t('",') },
					{ t("") },
				}),
				d(3, get_visual),
			}
		)
	),
	s(
		{
			trig = "usercmd ",
			dscr = "Neovim user command",
			condition = not_in_string_comment * line_begin,
		},
		fmt(
			[[
				vim.api.nvim_create_user_command("<>", function(arg)
					<>
				end, {})
			]],
			{
				i(1),
				d(2, get_visual),
			}
		)
	),
	s(
		{
			trig = "snp",
			dscr = "LuaSnip lua snippet template",
			snippetType = "autosnippet",
			condition = not_in_string_comment * line_begin,
		},
		fmt(
			[=[
				s({ trig = "<>", dscr = "<>"<><><> },
					<>
				),
			]=],
			{
				i(1),
				i(2),
				c(3, { t(", regTrig = true"), t("") }),
				c(4, { t(", wordTrig = false"), t("") }),
				c(5, { t(', snippetType = "autosnippet"'), t("") }),
				c(6, {
					sn(
						nil,
						fmt(
							[=[
							fmt(
									[[
										<>
									]],
									{
										<>
									}
								)
						]=],
							{
								i(1),
								i(2),
							}
						)
					),
					sn(nil, { t({ "{", '\t\tt("' }), i(1), t({ '")', "\t}" }) }),
				}),
			}
		)
	),
	s(
		{
			trig = "<c[mM][dD]>",
			dscr = "Neovim keymap command",
			wordTrig = false,
			regTrig = true,
			snippetType = "autosnippet",
		},
		{
			t("<Cmd>"),
			d(1, get_visual),
			t("<CR>"),
		}
	),
	s(
		{
			trig = "vks",
			dscr = "Create a keymap",
			snippetType = "autosnippet",
			condition = not_in_string_comment * line_begin,
		},
		{
			t('vim.keymap.set("'),
			i(1, "n"),
			t('", "'),
			i(2, "LHS"),
			t('", '),
			i(3, '"RHS"'),
			t(', { desc = "'),
			i(4),
			t('" })'),
		}
	),
	s(
		{
			trig = "vni",
			dscr = "Inspect",
			snippetType = "autosnippet",
			condition = not_in_string_comment,
		},
		{
			t("vim.notify(vim.inspect("),
			d(1, get_visual),
			t("))"),
		}
	),
	s(
		{
			trig = "vsf",
			dscr = "Schedule",
			snippetType = "autosnippet",
			condition = not_in_string_comment * line_begin,
		},
		{
			t("vim.schedule(function() "),
			d(1, get_visual),
			t(" end)"),
		}
	),
}
