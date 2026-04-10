; extends

(command
	name: (command_name
		(word) @_zstyle)
	argument: (_)
	argument: (word) @_fzf_preview
	argument: (raw_string) @injection.content
	(#eq? @_zstyle "zstyle")
	(#eq? @_fzf_preview "fzf-preview")
	(#offset! @injection.content 0 1 0 -1)
	(#set! injection.language "zsh"))
