local setup_mock_statusline = function()
	-- Skip if we already entered vim
	if vim.v.vim_did_enter == 1 then return end

	local buf = vim.api.nvim_get_current_buf()

	-- Try to guess the filetype (may change later during Neovim startup)
	local ft = vim.filetype.match({ buf = buf })

	if ft then
		-- find filetype icon and color
		local icon, color
		local ok, devicons = pcall(require, "nvim-web-devicons")
		if ok then
			icon, color = devicons.get_icon_color(vim.fn.expand("%"), vim.fn.expand("%:e"))
		end
		vim.api.nvim_set_hl(0, "StatusLineIconColor", { fg = color or "#6d8086" })

		-- setup mock statusline
		vim.opt.statusline = "%#StatusLineBlue# NORMAL %#StatusLineSeparatorBlue#%#StatusLineSeparatorGrey#"
		                     .. "%* %F %#StatusLineIconColor#" .. (icon or " ")
		                     .. "%=%#StatusLineSeparatorGrey#%#StatusLineGrey# %p%%  %l:%c "
		                     .. '%#StatusLineSeparatorBlue#%#StatusLineBlue#  %{strftime("%H:%M")} '
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

					["@markup.math.typst"] = { link = "Special" },
					["@variable.cmake"] = { link = "Identifier" },
					["MailURL"] = { link = "@string.special.url" },

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
					Folded = { fg = palette.springViolet1 },
					WinSeparator = { fg = palette.sumiInk6 },
					PanelHeading = { fg = palette.autumnYellow, bg = palette.sumiInk4 },

					LspReferenceText = { link = "bold" },
					LspReferenceWrite = { link = "LspReferenceText" },

					NormalDark = { bg = palette.sumiInk1 },
					TerminalBackground = { bg = palette.sumiInk0 },
					Indent = { fg = palette.sumiInk6 },
					IndentScope = { fg = palette.springViolet2 },
					Text = { fg = palette.fujiWhite },
					Transparent = { blend = 100 },
					None = { fg = "none", bg = "none" },
					diffDelete = { link = "Comment" },

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
					MarkdownHint = { fg = palette.waveAqua1 },
					MarkdownQuote = { fg = palette.oniViolet },
					MarkdownTable = { fg = palette.sumiInk6 },

					RenderMarkdownBullet = { link = "function" },

					TypstConcealDelims = { link = "Operator" },
					TypstConcealSymbol = { link = "Operator" },
					TypstConcealScript = { link = "Conceal" },
					TypstConcealSurround = { link = "Delimiter" },
					TypstConcealSet = { link = "Constant" },
					TypstConcealLetters = { link = "Special" },

					GitGraphHash = { link = "diffAdded" },
					GitGraphTimestamp = { link = "Comment" },
					GitGraphAuthor = { link = "Title" },
					GitGraphBranchName = { link = "diffChanged" },
					GitGraphBranchTag = { link = "DiagnosticHint" },
					GitGraphBranchMsg = { link = "Normal" },

					GitGraphBranch1 = { fg = palette.oniViolet },
					GitGraphBranch2 = { fg = palette.crystalBlue },
					GitGraphBranch3 = { fg = palette.springBlue },
					GitGraphBranch4 = { fg = palette.lightBlue },
					GitGraphBranch5 = { fg = palette.waveAqua2 },

					DiffViewFolderSign = { link = "Directory" },

					HlSearchLens = { fg = palette.fujiGray, bg = "none" },
					HlSearchLensNear = { fg = palette.oldWhite, bg = palette.waveBlue2 },
					HlSearchLensNearReverted = { fg = palette.waveBlue2, bg = "none" },

					NeoTreePopupWinSeparator = { fg = palette.sumiInk6, bg = palette.sumiInk3 },
					NeoTreeFileIcon = { fg = palette.oldWhite },
					NeoTreeDotfile = { fg = palette.sumiInk6 },
					NeoTreeHiddenByName = { fg = palette.sumiInk6 },

					SnacksPickerPrompt = { fg = palette.autumnYellow, bg = palette.sumiInk3 },
					SnacksDashboardKey = { link = "Keyword" },
					SnacksDashboardIcon = { link = "Type" },

					BlinkCmpKindText = { link = "String" },
					BlinkCmpLabelDescription = { link = "Conceal" },
					BlinkCmpLabelDetail = { link = "Conceal" },

					WhichKeyIconGrey = { fg = palette.sumiInk6 },
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

		vim.cmd.colorscheme("kanagawa-wave")
		setup_mock_statusline()
	end,
}
