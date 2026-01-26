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

-- windows
keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other Window", remap = true })
keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split Window Below", remap = true })
keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split Window Right", remap = true })
keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- Terminal Mappings
keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Go to Left Window" })
keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Go to Lower Window" })
keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Go to Upper Window" })
keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Go to Right Window" })
keymap.set("t", "<C-/>", "<Cmd>close<CR>", { desc = "Hide Terminal" })
keymap.set("t", "<c-_>", "<Cmd>close<CR>", { desc = "which_key_ignore" })

-- Move to window using the <ctrl> hjkl keys
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase Window Height" })
keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease Window Height" })
keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

-- Move Lines
keymap.set("n", "<M-j>", "<Cmd>m .+1<CR>==", { desc = "Move Down" })
keymap.set("n", "<M-k>", "<Cmd>m .-2<CR>==", { desc = "Move Up" })
keymap.set("i", "<M-j>", "<esc><Cmd>m .+1<CR>==gi", { desc = "Move Down" })
keymap.set("i", "<M-k>", "<esc><Cmd>m .-2<CR>==gi", { desc = "Move Up" })
keymap.set("v", "<M-j>", "<Cmd>m '+1<CR>gv=gv", { desc = "Move Down" })
keymap.set("v", "<M-k>", "<Cmd>m '<-2<CR>gv=gv", { desc = "Move Up" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<Cmd>close<CR>", { desc = "Close current split" })

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
keymap.set("n", "<localleader>p", '"_diwP', { desc = "replace word under cursor" })
keymap.set("x", "<leader>r", '"_dP')
keymap.set("n", "<leader>P", "i<C-R><C-P>+<ESC>", { desc = 'Paste "+ content before cursor' })
keymap.set({ "n", "v" }, "<C-M-y>", "<Cmd>%y+<CR>", { desc = "Yank buffer content into the + register" })
keymap.set("v", "<C-z>", '"+y', { desc = 'Yank selected text into "+' })
keymap.set("n", "<leader>cwd", '<Cmd>let @+=expand("%")<CR>', { desc = 'Copy absolute path to the "+' })

-- indenting
keymap.set({ "n", "v" }, "<leader>i", "=G", { desc = "Indent file" })
keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")

-- command line keymaps
keymap.set("c", "<M-a>", "<C-e>", { desc = "Go to end" })
keymap.set("c", "<M-i>", "<C-b>", { desc = "Go to beginning" })
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
