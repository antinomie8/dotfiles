return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
				only_first_definition = true,
				all_references = false,
				clear_on_continue = false,
				virt_text_pos = "eol", -- "inline" or "eol"
			},
		},
	},
	cmd = { "DapContinue", "DapToggleBreakpoint", "RunWithArgs" },
	keys = {
		{ "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
		{ "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
		{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
		{
			"<leader>dB",
			function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
			desc = "Breakpoint Condition",
		},
		{ "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
		{ "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
		{ "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
		{ "<leader>dg", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
		{ "<leader>dG", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
		{ "<leader>dj", function() require("dap").down() end, desc = "Down" },
		{ "<leader>dk", function() require("dap").up() end, desc = "Up" },
		{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle repl" },
		{ "<leader>ds", function() require("dap").session() end, desc = "Debugging session" },
		{ "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
		{ "<leader>dW", function() require("dap.ui.widgets").preview() end, desc = "Preview widgets" },
		{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle ui", silent = false },
		{ "<leader>df", function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames) end },
		{ "<leader>ds", function() require("dap.ui.widgets").centered_float(require("dap.ui.widgets").scopes) end },
		{ "<leader>dR", function() require("dap").restart() end, desc = "Restart", silent = false },
		{ "<leader>de", function() require("dapui").eval() end, desc = "Eval line", silent = false },
		{ "<leader>dT", function() require("dap").terminate() end, desc = "Terminate" },

		{ "<leader>dd", ":RunWithArgs ", desc = "Run an executable in the debugger " },
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local path = vim.fn.expand("%:p:r")

		local function close_dap_float()
			for _, win in pairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].filetype == "dap-float" then
					vim.api.nvim_win_close(win, true)
				end
			end
		end

		-- setup dapui
		dap.listeners.before.attach.dapui_config = function() dapui.open() end
		dap.listeners.before.launch.dapui_config = function() dapui.open() end
		dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		dapui.setup()

		-- keymaps
		local keymaps_debug = {
			["b"] = { function() dap.toggle_breakpoint() end, "Debug mode: toggle breakpoint" },
			["i"] = {
				function()
					require("dap.ui.widgets").hover()
					vim.cmd("hi Cursor blend=100")
				end,
				"Debug mode: inspect variable under cursor",
			},
			["c"] = { function() require("dap").continue() end, "Debug mode: continue" },
			["H"] = { function() require("dap").step_out() end, "Debug mode: step out" },
			["J"] = { function() require("dap").step_over() end, "Debug mode: step over" },
			["K"] = { function() require("dap").step_back() end, "Debug mode: step back" },
			["L"] = { function() require("dap").step_into() end, "Debug mode: step into" },
			["G"] = { function() require("dap").run_to_cursor() end, "Debug mode: run to cursor" },
			["q"] = { function() require("dap").terminate() end, "Debug mode: terminate" },
			["C"] = { close_dap_float, "Debug mode: Remove debugger floating windows" },
		}
		local keymap_restore = {}
		dap.listeners.after.event_initialized.keymaps = function()
			local keymaps = vim.api.nvim_get_keymap("n")
			for _, keymap in ipairs(keymaps) do
				if keymaps_debug[keymap.lhs] then
					table.insert(keymap_restore, keymap)
				end
			end
			for key, callback in pairs(keymaps_debug) do
				vim.keymap.set("n", key, callback[1], { desc = callback[2] })
			end
		end
		dap.listeners.after.event_terminated.keymaps = function()
			for key, _ in pairs(keymaps_debug) do
				vim.keymap.del("n", key)
			end
			for _, keymap in pairs(keymap_restore) do
				vim.keymap.set(
					keymap.mode,
					keymap.lhs,
					keymap.rhs or keymap.callback,
					{
						silent = keymap.silent == 1,
						desc = keymap.desc,
					}
				)
			end
			keymap_restore = {}
			close_dap_float()
		end

		local select_executable = function()
			return coroutine.create(function(coro)
				local exclude = {
					".git/*",
					"build/_deps",
					"CMakeFiles",
				}
				local cmd = { "fd", "--no-ignore", "--type", "x" }
				for _, pattern in pairs(exclude) do
					table.insert(cmd, "--exclude")
					table.insert(cmd, pattern)
				end
				local obj = vim.system(cmd):wait()
				if obj.code == 0 then
					vim.ui.select(
						vim.split(obj.stdout, "\n", { trimempty = true }),
						{ prompt_title = "Path to executable" },
						function(choice) coroutine.resume(coro, choice) end
					)
				else
					vim.notify(obj.stderr, vim.log.levels.ERROR, { "Debugger", "" })
					coroutine.resume(coro, nil)
				end
			end)
		end

		-- run with args
		vim.api.nvim_create_user_command("RunWithArgs", function(obj)
			local args = require("utils.argparse").shell_split(vim.fn.expand(obj.args))
			local dap_config = dap.configurations[vim.bo.filetype]
			if dap_config then
				dap.run({
					type = dap_config[1].type,
					request = "launch",
					name = "Launch file with custom arguments (adhoc)",
					program = select_executable(),
					args = args,
				})
			else
				vim.notify("Configuration for language '" .. vim.bo.filetype .. "' not found",
					vim.log.levels.ERROR, { title = "Debugger", icon = "" })
			end
		end, {
			complete = "file",
			nargs = "*",
		})

		dap.adapters.codelldb = {
			type = "executable",
			command = "codelldb",
		}

		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					if vim.b.use_default_executable_path then
						return vim.fn.expand("%:r")
					end
					return select_executable()
					-- return vim.fn.input("Path to executable: ", vim.fn.expand("%:r"), "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				stdio = function()
					if vim.b.codelldb_stdio_redirection then
						return { path .. ".in", path .. ".out", path .. ".err" }
					else
						return nil
					end
				end,
			},
		}

		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp

		-- automatically add a breakpoint at the beginning of main function
		dap.listeners.before.event_initialized.auto_breakpoint = function()
			local pattern
			if vim.tbl_contains({ "c", "cpp" }, vim.bo.filetype) then
				if vim.api.nvim_buf_get_name(0):match("Codeforces") then
					pattern = "^[%w_]*%s+solve%s*%("
				else
					pattern = "^[%w_]*%s+main%s*%("
				end
			end
			if pattern then
				for lnum = 1, vim.fn.line("$") do
					if vim.fn.getline(lnum):match(pattern) then
						vim.api.nvim_win_set_cursor(0, { lnum, 0 })
						require("dap").set_breakpoint()
						return
					end
				end
			end
		end
	end,
}
