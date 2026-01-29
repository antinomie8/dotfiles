-- diagnostics
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ", -- 
			[vim.diagnostic.severity.WARN]  = "󰀪 ", -- 
			[vim.diagnostic.severity.HINT]  = " ", -- 
			[vim.diagnostic.severity.INFO]  = " ", -- 
		},
		texthl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
			[vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
			[vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
			[vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
			[vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
		},
	},
	virtual_text = false,
	severity_sort = true,
})

-- debugging
local signs = {
	Stopped = { "", "DiagnosticWarn", "DapStoppedLine" },
	Breakpoint = { "" },
	BreakpointCondition = { "" },
	BreakpointRejected = { "", "DiagnosticError" },
	LogPoint = { ".>" },
}
for name, sign in pairs(signs) do
	vim.fn.sign_define("Dap" .. name, {
		text = sign[1],
		texthl = sign[2] or "DiagnosticInfo",
		linehl = sign[3],
		numhl = sign[3],
	})
end
