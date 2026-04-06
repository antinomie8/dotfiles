runtime! syntax/gdb.vim

syntax match dapLine /^dap>/ contains=dapPrefix,dapArrow
syntax match dapPrefix /^dap/ contained
syntax match dapArrow />/ contained

highlight link dapPrefix Keyword
highlight link dapArrow  Statement
