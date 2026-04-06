return {
	{
		"xeluxee/competitest.nvim",
		-- dependencies:
		--  MunifTanjim/nui.nvim
		cmd = { "CompetiTest" },
		keys = {
			{
				"<localleader>add",
				"<Cmd>CompetiTest add_testcase<CR>",
				ft = { "c", "cpp", "asm", "rust" },
				desc = "Add testcase",
			},
			{
				"<localleader>dlt",
				function()
					vim.cmd("hi Cursor blend=100")
					vim.cmd("CompetiTest delete_testcase")
				end,
				ft = { "c", "cpp", "asm", "rust" },
				desc = "Delete testcase",
			},
			{
				"<localleader>run",
				"<Cmd>CompetiTest run<CR>",
				ft = { "c", "cpp", "asm", "rust" },
				desc = "Run the code on tests",
			},
			{ "<localleader>shw", "<Cmd>CompetiTest show_ui<CR>", ft = { "c", "cpp", "asm" }, desc = "Show ui" },
			{
				"<localleader>tst",
				"<Cmd>CompetiTest run_no_compile<CR>",
				ft = { "c", "cpp", "asm", "rust" },
				desc = "Test without recompiling",
			},
			{
				"<localleader>edt",
				function()
					vim.cmd("hi Cursor blend=100")
					vim.cmd("CompetiTest edit_testcase")
				end,
				ft = { "c", "cpp", "asm", "rust" },
				desc = "Edit testcase",
			},
		},
		opts = {
			local_config_file_name = "competitest.lua",

			floating_border = "rounded",
			floating_border_highlight = "FloatBorder",
			run_empty_testcase = true,
			picker_ui = {
				width = 0.2,
				height = 0.3,
				mappings = {
					focus_next = { "j", "<down>", "<Tab>" },
					focus_prev = { "k", "<up>", "<S-Tab>" },
					close = { "<esc>", "<C-c>", "q", "Q" },
					submit = { "<CR>" },
				},
			},
			editor_ui = {
				popup_width = 0.4,
				popup_height = 0.6,
				show_nu = true,
				show_rnu = false,
				normal_mode_mappings = {
					switch_window = { "<C-h>", "<C-l>", "<C-i>" },
					save_and_close = "<C-s>",
					cancel = { "q", "Q" },
				},
				insert_mode_mappings = {
					switch_window = { "<C-h>", "<C-l>", "<C-i>" },
					save_and_close = "<C-s>",
					cancel = "<C-q>",
				},
			},
			runner_ui = {
				interface = "split",
				selector_show_nu = false,
				selector_show_rnu = false,
				show_nu = true,
				show_rnu = false,
				mappings = {
					run_again = "R",
					run_all_again = "<C-r>",
					kill = "K",
					kill_all = "<C-k>",
					view_input = { "i", "I" },
					view_output = { "a", "A" },
					view_stdout = { "o", "O" },
					view_stderr = { "e", "E" },
					toggle_diff = { "d", "D" },
					close = { "q", "Q" },
				},
				viewer = {
					width = 0.5,
					height = 0.5,
					show_nu = true,
					show_rnu = false,
					open_when_compilation_fails = false,
				},
			},
			popup_ui = {
				total_width = 0.8,
				total_height = 0.8,
				layout = {
					{ 4, "tc" },
					{ 5, { { 1, "so" }, { 1, "si" } } },
					{ 5, { { 1, "eo" }, { 1, "se" } } },
				},
			},
			split_ui = {
				position = "left",
				relative_to_editor = true,
				total_width = 0.3,
				vertical_layout = {
					{ 1, "tc" },
					{ 1, { { 1, "so" }, { 1, "eo" } } },
					{ 1, { { 1, "si" }, { 1, "se" } } },
				},
				total_height = 0.2,
				horizontal_layout = {
					{ 2, "tc" },
					{ 3, { { 1, "so" }, { 1, "si" } } },
					{ 3, { { 1, "eo" }, { 1, "se" } } },
				},
			},

			save_current_file = true,
			save_all_files = false,
			compile_directory = ".",
			compile_command = {
				c = { exec = "gcc", args = { "-g", "-Wall", "$(FNAME)", "-o", "$(FNOEXT)" } },
				cpp = {
					exec = "g++",
					args = {
						"-g",
						"-O0",
						"-std=c++23",
						"-Wall",
						"-Wextra",
						"-Wshadow",
						"-Wformat=2",
						"-Wfloat-equal",
						"-Wlogical-op",
						"-Wshift-overflow=2",
						"-Wduplicated-cond",
						"-Wcast-qual",
						"-Wcast-align",
						"-Wno-sign-compare",
						"-pedantic",
						"-D_GLIBCXX_DEBUG",
						"-D_GLIBCXX_DEBUG_PEDANTIC",
						"-DLOCAL",
						"-fsanitize=address", -- comment this line out to disable the LeakSanitizer and the AddressSanitizer
						"-fno-sanitize-recover",
						"-fstack-protector",
						"$(FNAME)",
						"-o",
						"$(FNOEXT)",
					},
				},
				asm = { exec = "assemble", args = { "$(FNAME)" } },
				rust = { exec = "rustc", args = { "$(FNAME)" } },
				java = { exec = "javac", args = { "$(FNAME)" } },
			},
			running_directory = ".",
			run_command = {
				c = { exec = "./$(FNOEXT)" },
				cpp = { exec = "./$(FNOEXT)" },
				asm = { exec = "./$(FNOEXT).out" },
				rust = { exec = "./$(FNOEXT)" },
				python = { exec = "python", args = { "$(FNAME)" } },
				java = { exec = "java", args = { "$(FNOEXT)" } },
			},
			multiple_testing = -1,
			maximum_time = 5000,
			output_compare_method = "squish",
			view_output_diff = false,

			testcases_directory = ".",
			testcases_use_single_file = true,
			testcases_auto_detect_storage = true,
			testcases_single_file_format = "$(FNOEXT).testcases",
			testcases_input_file_format = "$(FNOEXT)_input$(TCNUM).txt",
			testcases_output_file_format = "$(FNOEXT)_output$(TCNUM).txt",

			companion_port = 27121,
			receive_print_message = true,
			template_file = "$(HOME)/Informatique/Competitive Programming/Codeforces/template.cpp",
			evaluate_template_modifiers = false,
			date_format = "%c",
			received_files_extension = "cpp",
			received_problems_path = "$(HOME)/Informatique/Competitive Programming/Codeforces/$(CONTEST)/$(PROBLEM).$(FEXT)",
			received_problems_prompt_path = true,
			received_contests_directory = "$(HOME)/Informatique/Competitive Programming/Codeforces/$(CONTEST)",
			received_contests_problems_path = "$(PROBLEM).$(FEXT)",
			received_contests_prompt_directory = true,
			received_contests_prompt_extension = false,
			open_received_problems = true,
			open_received_contests = true,
			replace_received_testcases = false,
		},
		init = function()
			vim.api.nvim_create_user_command("CodeForces", "CompetiTest receive contest", {})
		end,
	},
	{
		"p00f/clangd_extensions.nvim",
		keys = {
			{
				"<localleader>f",
				"<Cmd>ClangdSwitchSourceHeader<CR>",
				ft = { "c", "cpp" },
				desc = "Switch between source and header files",
			},
		},
		cmd = {
			"ClangdSwitchSourceHeader",
			"ClangdAST",
			"ClangdSymbolInfo",
			"ClangdTypeHierarchy",
			"ClangdMemoryUsage",
		},
		opts = {
			ast = {
				role_icons = {
					type = " ",
					declaration = "󰙠 ",
					expression = " ",
					specifier = " ",
					statement = " ",
					["template argument"] = " ",
				},
				kind_icons = {
					Compound = "󰅩 ",
					Recovery = " ",
					TranslationUnit = " ", -- 
					PackExpansion = "󰪴 ", -- 
					TemplateTypeParm = "󰆩 ",
					TemplateTemplateParm = "󰆩 ",
					TemplateParamObject = "󰆩 ",
				},

				highlights = {
					detail = "Comment",
				},
			},
			memory_usage = {
				border = "rounded",
			},
			symbol_info = {
				border = "rounded",
			},
		},
	},
}
