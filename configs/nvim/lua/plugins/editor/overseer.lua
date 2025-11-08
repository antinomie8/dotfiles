return {
	"stevearc/overseer.nvim",
	cmd = {
		"OverseerOpen",
		"OverseerClose",
		"OverseerToggle",
		"OverseerSaveBundle",
		"OverseerLoadBundle",
		"OverseerDeleteBundle",
		"OverseerRunCmd",
		"OverseerRun",
		"OverseerInfo",
		"OverseerBuild",
		"OverseerQuickAction",
		"OverseerTaskAction",
		"OverseerClearCache",
		"Grep",
		"Make",
		"CMake",
	},
	opts = {
		templates = { "builtin" },
		template_dirs = { "overseer.template" },
		dap = false,
		task_list = {
			default_detail = 1, -- Default detail level for tasks. Can be 1-3.
			-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
			-- min_width and max_width can be a single value or a list of mixed integer/float types.
			-- max_width = {100, 0.2} means "the lesser of 100 columns or 20% of total"
			max_width = { 100, 0.2 },
			-- min_width = {40, 0.1} means "the greater of 40 columns or 10% of total"
			min_width = { 40, 0.1 },
			-- optionally define an integer/float for the exact width of the task list
			width = nil,
			max_height = { 20, 0.1 },
			min_height = 8,
			height = nil,
			separator = "────────────────────────────────────────", -- String that separates tasks
			direction = "bottom", -- Default direction. Can be "left", "right", or "bottom"
			-- Set keymap to false to remove default behavior
			-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
			bindings = {
				["?"] = "ShowHelp",
				["g?"] = "ShowHelp",
				["<CR>"] = "RunAction",
				["<C-e>"] = "Edit",
				["o"] = "Open",
				["<C-v>"] = "OpenVsplit",
				["<C-s>"] = "OpenSplit",
				["<C-f>"] = "OpenFloat",
				["<C-q>"] = "OpenQuickFix",
				["p"] = "TogglePreview",
				["<M-l>"] = "IncreaseDetail",
				["<M-h>"] = "DecreaseDetail",
				["L"] = "IncreaseAllDetail",
				["H"] = "DecreaseAllDetail",
				["["] = "DecreaseWidth",
				["]"] = "IncreaseWidth",
				["{"] = "PrevTask",
				["}"] = "NextTask",
				["<M-k>"] = "ScrollOutputUp",
				["<M-j>"] = "ScrollOutputDown",
				["q"] = "Close",
			},
		},
		-- See :help overseer-actions
		actions = {},
		-- Configure the floating window used for task templates that require input
		-- and the floating window used for editing tasks
		form = {
			border = "rounded",
			zindex = 40,
			-- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
			-- min_X and max_X can be a single value or a list of mixed integer/float types.
			min_width = 80,
			max_width = 0.9,
			width = nil,
			min_height = 10,
			max_height = 0.9,
			height = nil,
			-- Set any window options here (e.g. winhighlight)
			win_opts = {
				winblend = vim.opt.pumblend,
			},
		},
		task_launcher = {
			-- Set keymap to false to remove default behavior
			-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
			bindings = {
				i = {
					["<C-s>"] = "Submit",
					["<C-c>"] = "Cancel",
				},
				n = {
					["<CR>"] = "Submit",
					["<C-s>"] = "Submit",
					["q"] = "Cancel",
					["?"] = "ShowHelp",
				},
			},
		},
		task_editor = {
			-- Set keymap to false to remove default behavior
			-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
			bindings = {
				i = {
					["<CR>"] = "NextOrSubmit",
					["<C-s>"] = "Submit",
					["<Tab>"] = "Next",
					["<S-Tab>"] = "Prev",
					["<C-c>"] = "Cancel",
				},
				n = {
					["<CR>"] = "NextOrSubmit",
					["<C-s>"] = "Submit",
					["<Tab>"] = "Next",
					["<S-Tab>"] = "Prev",
					["q"] = "Cancel",
					["?"] = "ShowHelp",
				},
			},
		},
		-- Configure the floating window used for confirmation prompts
		confirm = {
			border = "rounded",
			zindex = 40,
			-- Dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
			-- min_X and max_X can be a single value or a list of mixed integer/float types.
			min_width = 20,
			max_width = 0.5,
			width = nil,
			min_height = 6,
			max_height = 0.9,
			height = nil,
			-- Set any window options here (e.g. winhighlight)
			win_opts = {
				winblend = 0,
			},
		},
		-- Configuration for task floating windows
		task_win = {
			-- How much space to leave around the floating window
			padding = 2,
			border = "rounded",
			-- Set any window options here (e.g. winhighlight)
			win_opts = {
				winblend = 0,
			},
		},
		-- Configuration for mapping help floating windows
		help_win = {
			border = "rounded",
			win_opts = {},
		},
		-- Aliases for bundles of components. Redefine the builtins, or create your own.
		component_aliases = {
			-- Most tasks are initialized with the default components
			default = {
				{ "display_duration", detail_level = 2 },
				"on_output_summarize",
				"on_exit_set_status",
				"on_complete_notify",
				{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
			},
			-- Tasks from tasks.json use these components
			default_vscode = {
				"default",
				"on_result_diagnostics",
			},
		},
		bundles = {
			-- When saving a bundle with OverseerSaveBundle or save_task_bundle(), filter the tasks with
			-- these options (passed to list_tasks())
			save_task_opts = {
				bundleable = true,
			},
			-- Autostart tasks when they are loaded from a bundle
			autostart_on_load = true,
		},
		-- A list of components to preload on setup.
		-- Only matters if you want them to show up in the task editor.
		preload_components = {},
		-- Controls when the parameter prompt is shown when running a template
		--   always    Show when template has any params
		--   missing   Show when template has any params not explicitly passed in
		--   allow     Only show when a required param is missing
		--   avoid     Only show when a required param with no default value is missing
		--   never     Never show prompt (error if required param missing)
		default_template_prompt = "allow",
		-- For template providers, how long to wait (in ms) before timing out.
		-- Set to 0 to disable timeouts.
		template_timeout = 3000,
		-- Cache template provider results if the provider takes longer than this to run.
		-- Time is in ms. Set to 0 to disable caching.
		template_cache_threshold = 100,
		-- Configure where the logs go and what level to use
		-- Types are "echo", "notify", and "file"
		log = {
			{
				type = "notify",
				level = vim.log.levels.WARN,
			},
			{
				type = "file",
				filename = "overseer.log",
				level = vim.log.levels.WARN,
			},
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")

		overseer.setup(opts)

		vim.api.nvim_create_user_command("Grep", function(params)
			local args = vim.fn.expandcmd(params.args)
			-- Insert args at the '$*' in the grepprg
			local cmd, num_subs = vim.o.grepprg:gsub("%$%*", args)
			if num_subs == 0 then
				cmd = cmd .. " " .. args
			end
			local cwd
			local has_oil, oil = pcall(require, "oil")
			if has_oil then
				cwd = oil.get_current_dir()
			end

			local task = overseer.new_task({
				cmd = cmd,
				cwd = cwd,
				name = "grep " .. args,
				components = {
					{
						"on_output_quickfix",
						errorformat = vim.o.grepformat,
						open = not params.bang,
						open_height = 8,
						items_only = true,
					},
					-- We don't care to keep this around as long as most tasks
					{ "on_complete_dispose", timeout = 30, require_view = {} },
					"default",
				},
			})
			task:start()
		end, { nargs = "*", bang = true, bar = true, complete = "file" })

		vim.api.nvim_create_user_command("Make", function(params)
			-- set the makeprg to CMake if CMakeLists.txt is found
			if vim.uv.fs_access("CMakeLists.txt", "R") then
				vim.o.makeprg = "cmake --build build"
			end
			-- Insert args at the '$*' in the makeprg
			local cmd, num_subs = vim.o.makeprg:gsub("%$%*", params.args)
			if num_subs == 0 then
				cmd = cmd .. " " .. params.args
			end
			local task = require("overseer").new_task({
				cmd = vim.fn.expandcmd(cmd),
				components = {
					{ "on_output_quickfix", open = not params.bang, open_height = 8 },
					"unique",
					"default",
				},
			})
			task:start()
		end, {
			desc = "Run your makeprg as an Overseer task",
			nargs = "*",
			bang = true,
		})

		vim.api.nvim_create_user_command("CMake", function(params)
			if params.args:lower():match("debug") then
				params.args = "Debug"
			elseif params.args:lower():match("release") then
				params.args = "Release"
			elseif params.args:lower():match("relwithdebinfo") then
				params.args = "RelWithDebInfo"
			end

			local cmd = "cmake -DCMAKE_BUILD_TYPE=" .. params.args .. " build"
			local task = require("overseer").new_task({
				cmd = vim.fn.expandcmd(cmd),
				components = {
					"unique",
					"default",
				},
			})
			task:start()
		end, {
			desc = "Change the CMake build type",
			nargs = "*",
		})
	end,
}
