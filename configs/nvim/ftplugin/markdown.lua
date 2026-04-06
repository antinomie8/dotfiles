vim.schedule(
	function()
		vim.cmd([[
			if exists('b:current_syntax')
				unlet b:current_syntax
			endif

			" %% comment
			syn region markdownComment start='\\\@<!%%' end='%%' skip='\\%' contains=@Comment,@Spell keepend
			highlight link markdownComment Comment

			let b:current_syntax = 'markdown'
		]])
	end
)
