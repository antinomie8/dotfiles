; extends

(declaration
	type: (qualified_identifier
		name: (type_identifier) @injection.language)
	declarator: (init_declarator
		value: (argument_list
			(raw_string_literal
				(raw_string_content) @injection.content)))
	(#eq? @injection.language "regex"))

(call_expression
	function: (qualified_identifier
		name: (identifier) @injection.language)
	arguments: (argument_list
		(raw_string_literal
			(raw_string_content) @injection.content))
	(#eq? @injection.language "regex"))
