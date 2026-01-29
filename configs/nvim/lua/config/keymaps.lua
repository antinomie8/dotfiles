local keymap = vim.keymap

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- buffers
keymap.set("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Previous Buffer" })
keymap.set("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
keymap.set("n", "[b", "<Cmd>bprevious<CR>", { desc = "Previous Buffer" })
keymap.set("n", "]b", "<Cmd>bnext<CR>", { desc = "Next Buffer" })
keymap.set("n", "<leader>bb", "<Cmd>e #<CR>", { desc = "Switch to Other Buffer" })
keymap.set("n", "<leader>bd", "<Cmd>bd<CR>", { desc = "Delete Buffer and Window" })

-- tabs
keymap.set("n", "<leader>tt", "<Cmd>tabnew<CR>", { desc = "New Tab" })
keymap.set("n", "<leader>td", "<Cmd>tabclose<CR>", { desc = "Close Tab" })
keymap.set("n", "<leader>tx", "<Cmd>tabonly<CR>", { desc = "Close Other Tabs" })
keymap.set("n", "<leader>tn", "<Cmd>tabnext<CR>", { desc = "Next Tab" })
keymap.set("n", "<leader>tp", "<Cmd>tabprevious<CR>", { desc = "Previous Tab" })
keymap.set("n", "<leader>tf", "<Cmd>tabfirst<CR>", { desc = "First Tab" })
keymap.set("n", "<leader>tl", "<Cmd>tablast<CR>", { desc = "Last Tab" })

-- Move Lines
keymap.set("n", "<C-M-j>", "<Cmd>m .+1<CR>==", { desc = "Move Down" })
keymap.set("n", "<C-M-k>", "<Cmd>m .-2<CR>==", { desc = "Move Up" })
keymap.set("i", "<C-M-j>", "<esc><Cmd>m .+1<CR>==gi", { desc = "Move Down" })
keymap.set("i", "<C-M-k>", "<esc><Cmd>m .-2<CR>==gi", { desc = "Move Up" })
keymap.set("v", "<C-M-j>", "<Cmd>m '+1<CR>gv=gv", { desc = "Move Down" })
keymap.set("v", "<C-M-k>", "<Cmd>m '<-2<CR>gv=gv", { desc = "Move Up" })

-- diagnostics
local diagnostic_jump = function(count, severity)
	local severity = severity and vim.diagnostic.severity[severity] or nil
	return function() vim.diagnostic.jump({ count = count, severity = severity }) end
end
keymap.set("n", "<leader>sd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
keymap.set("n", "]d", diagnostic_jump(1), { desc = "Next Diagnostic" })
keymap.set("n", "[d", diagnostic_jump(-1), { desc = "Previous Diagnostic" })
keymap.set("n", "]e", diagnostic_jump(1, "ERROR"), { desc = "Next Error" })
keymap.set("n", "[e", diagnostic_jump(-1, "ERROR"), { desc = "Previous Error" })
keymap.set("n", "]w", diagnostic_jump(1, "WARN"), { desc = "Next Warning" })
keymap.set("n", "[w", diagnostic_jump(-1, "WARN"), { desc = "Previous Warning" })

-- better up and down motions
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- yanking and pasting
keymap.set("n", "<leader>P", "i<C-R><C-P>+<ESC>", { desc = 'Paste "+ content before cursor' })
keymap.set({ "n", "v" }, "<C-M-y>", "<Cmd>%y+<CR>", { desc = "Yank buffer content to the system clipboard" })
keymap.set("v", "<C-z>", '"+y', { desc = "Yank selected text into the system cliboard" })
keymap.set("n", "<leader>cwd", '<Cmd>let @+=expand("%")<CR>', { desc = "Copy absolute path to the system clipboard" })

-- indenting
keymap.set({ "n", "v" }, "<leader>i", "=G", { desc = "Indent file" })
keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")

-- command line keymaps
keymap.set("c", "<M-i>", "<C-b>", { desc = "Go to beginning" })
keymap.set("c", "<M-a>", "<C-e>", { desc = "Go to end" })
keymap.set("c", "<M-f>", "<S-Right>", { desc = "Forward word" })
keymap.set("c", "<M-b>", "<S-Left>", { desc = "Backward word" })
keymap.set("c", "<M-v>", function()
	local str = vim.api.nvim_replace_termcodes("vim.notify(vim.inspect())<Left><Left>", true, false, true)
	if vim.fn.getcmdline():match("^lua") then
		vim.api.nvim_feedkeys(str, "c", false)
	else
		vim.api.nvim_feedkeys("lua " .. str, "c", false)
	end
end, { desc = "Inspect" })

-- indert mode keymaps
keymap.set("i", "<M-i>", "<C-o>^", { desc = "Got to beginning" })
keymap.set("i", "<M-a>", "<C-o>$", { desc = "Go to end" })
keymap.set("i", "<M-f>", "<C-o>E", { desc = "Forward word" })
keymap.set("i", "<M-b>", "<C-o>B", { desc = "Backward word" })

-- toggle options
keymap.set("n", "<leader>os", "<Cmd>set spell!<CR>", { desc = "Toggle spell checking" })
keymap.set("n", "<leader>ow", "<Cmd>set wrap!<CR>", { desc = "Toggle line wrapping" })
keymap.set("n", "<leader>or", "<Cmd>set relativenumber!<CR>", { desc = "Toggle relative numbers" })
keymap.set("n", "<leader>oa", "<Cmd>set autochdir!<CR>", { desc = "Sync cwd with buffer's" })
keymap.set(
	"n",
	"<leader>od",
	function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
	{ desc = "Toggle diagnostics" }
)

-- search
keymap.set("n", "n", "nzz")
keymap.set("n", "N", "Nzz")
keymap.set("n", "<leader>nh", "<Cmd>nohl<CR>", { desc = "Clear search highlights" })

-- new file
keymap.set("n", "<leader>fn", "<Cmd>enew<CR>", { desc = "New File" })

-- plugin manager
keymap.set("n", "<leader>L", "<Cmd>Lazy<CR>", { desc = "Open Lazy.nvim ui" })
