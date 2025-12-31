local vim_enter_early_redraw = function()
	-- Skip if we already entered vim
	if vim.v.vim_did_enter == 1 then
		return
	end

	local buf = vim.api.nvim_get_current_buf()

	-- Try to guess the filetype (may change later on during Neovim startup)
	local ft = vim.filetype.match({ buf = buf })

	if ft then
		-- Add treesitter highlights and fallback to syntax
		local lang = vim.treesitter.language.get_lang(ft)

		-- find filetype icon and color
		local icon, color
		if pcall(require("nvim-web-devicons").setup) then
			icon, color = require("nvim-web-devicons").get_icon_color(vim.fn.expand("%"), vim.fn.expand("%:e"))
		end
		vim.api.nvim_set_hl(0, "StatusLineIconColor", { fg = color or "#6d8086" })

		-- setup mock statusline
		vim.opt.statusline =
			"%#StatusLineBlue# NORMAL %#StatusLineSeparatorBlue#%#StatusLineSeparatorGrey#"
			.. "%* %F %#StatusLineIconColor#" .. (icon or " ")
			.. "%=%#StatusLineSeparatorGrey#%#StatusLineGrey# %p%%  %l:%c "
			.. '%#StatusLineSeparatorBlue#%#StatusLineBlue#  %{strftime("%H:%M")} '

		if not (lang and pcall(vim.treesitter.start, buf, lang)) then
			vim.bo[buf].syntax = ft
		end

		-- Trigger early redraw
		vim.cmd([[redraw]])
	end
end

return {
	"rebelot/kanagawa.nvim",
	priority = 1000,
	config = function()
		require("kanagawa").setup({
			compile = true,
			overrides = function(colors)
				local theme = colors.theme
				local palette = colors.palette

				return {
					-- syntax highlighting
					Boolean = { bold = false },
					DiagnosticUnnecessary = { force = true },

					-- user interface
					NormalFloat = { bg = "none" },
					FloatBorder = { bg = "none" },
					FloatTitle = { bg = "none" },

					Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
					PmenuSel = { fg = "none", bg = theme.ui.bg_p2 },
					PmenuSbar = { bg = theme.ui.bg_m1 },
					PmenuThumb = { bg = theme.ui.bg_p2 },

					StatusLine = { fg = palette.springViolet2, bg = palette.sumiInk4 },
					StatusLineBlue = { fg = palette.sumiInk4, bg = palette.crystalBlue },
					StatusLineGrey = { fg = palette.springViolet2, bg = palette.sumiInk6 },
					StatusLineSeparatorBlue = { fg = palette.crystalBlue, bg = palette.sumiInk6 },
					StatusLineSeparatorGrey = { fg = palette.sumiInk6, bg = palette.sumiInk4 },

					Search = { fg = palette.oldWhite, bg = palette.waveBlue2 },
					Folded = { fg = palette.springViolet1, bg = palette.sumiInk3 },
					WinSeparator = { fg = palette.sumiInk6 },
					PanelHeading = { fg = palette.autumnYellow, bg = palette.sumiInk4 },

					NormalDark = { bg = palette.sumiInk1 },
					TerminalBackground = { bg = palette.sumiInk0 },

					Indent = { fg = palette.sumiInk6 },
					IndentScope = { fg = palette.springViolet2 },

					Text = { fg = palette.fujiWhite },

					-- plugins
					markdownH1 = { fg = palette.peachRed },
					markdownH2 = { fg = palette.surimiOrange },
					markdownH3 = { fg = palette.carpYellow },
					markdownH4 = { fg = palette.springGreen },
					markdownH5 = { fg = palette.springBlue },
					markdownH6 = { fg = palette.oniViolet },

					MarkdownInfo = { fg = palette.crystalBlue },
					MarkdownSuccess = { fg = palette.springGreen },
					MarkdownWarn = { fg = palette.roninYellow },
					MarkdownError = { fg = palette.samuraiRed },
					MarkdownHint = { fg = "#6a9589" },
					MarkdownQuote = { fg = palette.oniViolet },
					MarkdownTable = { fg = "#54546d" },

					TypstConcealDelims = { link = "Operator" },
					TypstConcealSymbol = { link = "Operator" },
					TypstConcealScript = { link = "Conceal" },
					TypstConcealSurround = { link = "Delimiter" },
					TypstConcealSet = { link = "Constant" },
					TypstConcealLetters = { link = "Special" },
					["@markup.math.typst"] = { link = "Special" },

					IlluminatedWordText = { bold = true },
					IlluminatedWordRead = { bold = true },
					IlluminatedWordWrite = { bold = true },

					HlSearchLens = { fg = palette.fujiGray, bg = "none" },
					HlSearchLensNear = { fg = palette.oldWhite, bg = palette.waveBlue2 },
					HlSearchLensNearReverted = { fg = palette.waveBlue2, bg = "none" },

					NeoTreePopupWinSeparator = { fg = palette.sumiInk6, bg = palette.sumiInk3 },
					NeoTreeFileIcon = { fg = palette.oldWhite },
					NeoTreeDotfile = { fg = palette.sumiInk6 },
					NeoTreeHiddenByName = { fg = palette.sumiInk6 },

					BlinkCmpKindText = { link = "String" },

					TelescopePromptPrefix = { fg = palette.autumnYellow, bg = palette.sumiInk3 },

					LightBulbSign = { fg = palette.oldWhite },

					LazyNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
				}
			end,
			colors = {
				palette = {}, -- change all usages of these colors
				theme = {
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},
		})
		vim.cmd("colorscheme kanagawa-wave")
		vim_enter_early_redraw()
	end,
}
