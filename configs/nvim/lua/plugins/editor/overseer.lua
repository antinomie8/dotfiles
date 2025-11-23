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
		dap = false,
		task_list = {
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
