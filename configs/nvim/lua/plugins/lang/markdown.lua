local obsidian_vaults = {
	["Mathématiques"] = { vim.env.HOME .. "/Mathématiques/Mathématiques", "Solutions et Notes/Compétitions" },
}
local workspaces = {}
for vault, path in pairs(obsidian_vaults) do
	table.insert(workspaces, {
		name = vault,
		path = path[1],
		overrides = {
			notes_subdir = path[2],
		},
	})
end
local vault_enter = {}
for _, path in pairs(obsidian_vaults) do
	table.insert(vault_enter, "BufReadPre " .. path[1] .. "/*.md")
	table.insert(vault_enter, "BufNewFile " .. path[1] .. "/*.md")
end

return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "mail" },
		cmd = "RenderMarkdown",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			-- nvim-tree/nvim-web-devicons
		},
		opts = {
			file_types = { "markdown", "mail" },
			render_modes = { "n", "c", "t" },
			completions = { blink = { enabled = true } },
			anti_conceal = { enabled = false },
			win_options = {
				conceallevel = {
					default = vim.o.conceallevel,
					rendered = 2,
				},
				concealcursor = {
					default = vim.o.concealcursor,
					rendered = "nc",
				},
			},

			heading = {
				position = "inline",
				icons = { "󰼏 ", "󰼐 ", "󰼑 ", "󰼒 ", "󰼓 ", "󰼔 " },
				sign = false,
				backgrounds = {
					"markdownH1",
					"markdownH2",
					"markdownH3",
					"markdownH4",
					"markdownH5",
					"markdownH6",
				},
				foregrounds = {
					"markdownH1",
					"markdownH2",
					"markdownH3",
					"markdownH4",
					"markdownH5",
					"markdownH6",
				},
			},
			callout = {
				note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "MarkdownInfo", category = "github" },
				tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "MarkdownSuccess", category = "github" },
				important = {
					raw = "[!IMPORTANT]",
					rendered = "󰅾 Important",
					highlight = "MarkdownHint",
					category = "github",
				},
				warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "MarkdownWarn", category = "github" },
				caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "MarkdownError", category = "github" },
				abstract = {
					raw = "[!ABSTRACT]",
					rendered = "󰨸 Abstract",
					highlight = "MarkdownInfo",
					category = "obsidian",
				},
				summary = { raw = "[!SUMMARY]", rendered = "󰨸 Summary", highlight = "MarkdownInfo", category = "obsidian" },
				tldr = { raw = "[!TLDR]", rendered = "󰨸 Tldr", highlight = "MarkdownInfo", category = "obsidian" },
				info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "MarkdownInfo", category = "obsidian" },
				todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "MarkdownInfo", category = "obsidian" },
				hint = { raw = "[!HINT]", rendered = "󰌶 Hint", highlight = "MarkdownSuccess", category = "obsidian" },
				success = {
					raw = "[!SUCCESS]",
					rendered = "󰄬 Success",
					highlight = "MarkdownSuccess",
					category = "obsidian",
				},
				check = { raw = "[!CHECK]", rendered = "󰄬 Check", highlight = "MarkdownSuccess", category = "obsidian" },
				done = { raw = "[!DONE]", rendered = "󰄬 Done", highlight = "MarkdownSuccess", category = "obsidian" },
				question = {
					raw = "[!QUESTION]",
					rendered = "󰘥 Question",
					highlight = "MarkdownWarn",
					category = "obsidian",
				},
				help = { raw = "[!HELP]", rendered = "󰘥 Help", highlight = "MarkdownWarn", category = "obsidian" },
				faq = { raw = "[!FAQ]", rendered = "󰘥 Faq", highlight = "MarkdownWarn", category = "obsidian" },
				attention = {
					raw = "[!ATTENTION]",
					rendered = "󰀪 Attention",
					highlight = "MarkdownWarn",
					category = "obsidian",
				},
				failure = { raw = "[!FAILURE]", rendered = "󰅖 Failure", highlight = "MarkdownError", category = "obsidian" },
				fail = { raw = "[!FAIL]", rendered = "󰅖 Fail", highlight = "MarkdownError", category = "obsidian" },
				missing = { raw = "[!MISSING]", rendered = "󰅖 Missing", highlight = "MarkdownError", category = "obsidian" },
				danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "MarkdownError", category = "obsidian" },
				error = { raw = "[!ERROR]", rendered = "󱐌 Error", highlight = "MarkdownError", category = "obsidian" },
				bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "MarkdownError", category = "obsidian" },
				example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "MarkdownHint", category = "obsidian" },
				quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "MarkdownQuote", category = "obsidian" },
				cite = { raw = "[!CITE]", rendered = "󱆨 Cite", highlight = "MarkdownQuote", category = "obsidian" },
			},
			code = {
				sign = false,
				border = "thin",
				position = "right",
				width = "block",
				left_pad = 1,
				right_pad = 1,
				highlight = "TerminalBackground",
				highlight_border = "TerminalBackground",
				highlight_fallback = "TerminalBackground",
				highlight_inline = "TerminalBackground",
			},
			pipe_table = {
				alignment_indicator = "─",
				head = "MarkdownTable",
				row = "MarkdownTable",
				filler = "MarkdownTable",
			},
			latex = { enabled = false },
		},
	},
	{
		"bullets-vim/bullets.vim",
		keys = {
			{
				"<CR>",
				"<Cmd>InsertNewBullet<CR>",
				mode = "i",
				ft = { "markdown", "text", "gitcommit" },
				desc = "Insert new bullet",
			},
			{
				"<localleader>x",
				"<Cmd>ToggleCheckbox<CR>",
				ft = { "markdown", "text", "gitcommit" },
				desc = "Toggle Bullet",
			},
		},
		config = function()
			vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
			vim.g.bullets_set_mapping = 0
		end,
	},
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		event = vault_enter,
		-- dependencies:
		--  nvim-lua/plenary.nvim
		opts = {
			workspaces = workspaces,
			log_level = vim.log.levels.INFO,
			completion = {
				blink = true,
				nvim_cmp = false,
				min_chars = 2,
			},
			wiki_link_func = "use_alias_only",
			disable_frontmatter = true,
			picker = {
				name = "telescope.nvim",
				note_mappings = {
					-- Create a new note from your query.
					new = "<C-x>",
					-- Insert a link to the selected note.
					insert_link = "<C-l>",
				},
				tag_mappings = {
					-- Add tag(s) to current note.
					tag_note = "<C-x>",
					-- Insert a tag at the current location.
					insert_tag = "<C-l>",
				},
			},
			backlinks = {
				parse_headers = true,
			},
			open_notes_in = "current", -- current, vsplit or hsplit
			ui = {
				enable = false, -- set to false to disable all additional syntax features
			},
			attachments = {
				img_folder = "assets/imgs",
				---@return string
				img_name_func = function()
					-- Prefix image names with timestamp.
					return string.format("Pasted image %s", os.date("%Y%m%d%H%M%S"))
				end,
				img_text_func = function(client, path)
					path = client:vault_relative_path(path) or path
					return string.format("![%s](%s)", path.name, path)
				end,
			},
			statusline = {
				enabled = false,
				format = "{{properties}} properties {{backlinks}} backlinks {{words}} words {{chars}} chars",
			},
		},
	},
}
