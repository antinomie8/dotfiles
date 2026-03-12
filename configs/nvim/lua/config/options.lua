local opt = vim.opt

opt.fillchars = {
	foldopen  = "",
	foldclose = "",
	fold      = "·",
	foldsep   = " ",
	diff      = "╱",
	eob       = " ",
	lastline  = " ",
}

-- folding
opt.foldlevel      = 99
opt.foldlevelstart = 99
opt.foldmethod     = "manual"
opt.foldcolumn     = "0"
opt.foldlevelstart = 99
opt.conceallevel   = 2
opt.concealcursor  = ""

-- lines & statuscolumn
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.scrolloff      = 999
opt.sidescrolloff  = 10
opt.smoothscroll   = true
opt.cursorline     = true

-- line wrapping and auto-commenting
opt.wrap           = false
opt.breakindent    = true
opt.breakindentopt = { "min:30", "shift:-1" }
opt.linebreak      = true
opt.breakat        = " "
opt.formatoptions  = "c,q,n,2,j"
opt.formatlistpat  = [[^\s*\%(\d\+[\]\-:.)}\t ]\|[-+]\s\)\s*]]

-- writing, undo & backup
opt.autowrite      = false
opt.swapfile       = true
opt.undofile       = true
opt.undolevels     = 1024
opt.confirm        = false
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- tabs & indentation
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.expandtab      = false
opt.autoindent     = true
opt.shiftround     = true
opt.smarttab       = true
opt.smartindent    = true

-- split windows
opt.splitkeep      = "screen"
opt.splitright     = true
opt.splitbelow     = true
opt.winminwidth    = 5
opt.winwidth       = 10
opt.equalalways    = false

-- popup windows
opt.timeout        = true
opt.timeoutlen     = 500
opt.pumblend       = 20
opt.pumheight      = 10
opt.updatetime     = 250
opt.completeopt    = "menu,menuone,noselect"

-- statusline
opt.laststatus     = 3
opt.showmode       = false
opt.ruler          = false

-- search settings
opt.gdefault       = true
opt.ignorecase     = true
opt.smartcase      = true

-- colors
opt.termguicolors  = true
opt.cmdheight      = 0
opt.background     = "dark"

-- title
opt.title          = true
opt.titlestring    = " %t"

-- cursor
opt.guicursor:append("a:Cursor/lCursor")
opt.guicursor:append("t:ver25")

-- diffs
opt.diffopt:append("iwhiteall")

-- mouse
opt.mouse          = "nvi"

-- miscellaneous
opt.backspace      = "indent,eol,start"
opt.wildmode       = "longest:full,full"
opt.shortmess      = "tToOcCFI"
opt.belloff        = "all"
opt.exrc           = false  -- patched by ~/.config/nvim/after/plugin/exrc.lua
opt.fileformat     = "unix" -- convert line endings to unix
