; extends

(math) @nospell

(code) @nospell

((linebreak) @conceal
	(#set! conceal "⏎")) ; \

([ "$" "_" "*" "^" (align) ] @conceal @operator
	(#set! conceal ""))

(shorthand) @operator  ; <= >= <=> !=

(symbol) @operator     ; + - * < >

((ident) @diff.delta
	(#has-ancestor? @diff.delta math)
	(#any-of? @diff.delta
		"arccos" "arcsin" "arctan" "arg" "cos" "cosh" "cot" "coth" "csc" "csch" "ctg"
		"deg" "det" "dim" "exp" "gcd" "lcm" "hom" "id" "im" "inf" "ker" "lg"
		"lim" "liminf" "limsup" "ln" "log" "max" "min" "mod" "Pr"
		"sec" "sech" "sin" "sinc" "sinh" "sup" "tan" "tanh" "tg" "tr"

		"pgcd" "ppcm"))
