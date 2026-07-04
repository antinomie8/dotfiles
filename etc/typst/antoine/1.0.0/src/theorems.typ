// Store theorem environment numbering

#let thmcounters = state("thm", (
	"counters": ("heading": ()),
	"latest": (),
))


#let thmenv(identifier, base, base_level, fmt) = {
	let global_numbering = numbering

	return (
		..args,
		body,
		number: auto,
		numbering: "1.1",
		refnumbering: auto,
		supplement: identifier,
		base: base,
		base_level: base_level,
	) => {
		let name = none
		if args != none and args.pos().len() > 0 {
			name = args.pos().first()
			supplement = name
		}
		if refnumbering == auto {
			refnumbering = numbering
		}
		let result = none
		if number == auto and numbering == none {
			number = none
		}
		if number == auto and numbering != none {
			result = context {
				let heading-counter = counter(heading).get()
				return thmcounters.update(thmpair => {
					let counters = thmpair.at("counters")
					// Manually update heading counter
					counters.at("heading") = heading-counter
					if not identifier in counters.keys() {
						counters.insert(identifier, (0,))
					}

					let tc = counters.at(identifier)
					if base != none {
						let bc = counters.at(base)

						// Pad or chop the base count
						if base_level != none {
							if bc.len() < base_level {
								bc = bc + (0,) * (base_level - bc.len())
							} else if bc.len() > base_level {
								bc = bc.slice(0, base_level)
							}
						}

						// Reset counter if the base counter has updated
						if tc.slice(0, -1) == bc {
							counters.at(identifier) = (..bc, tc.last() + 1)
						} else {
							counters.at(identifier) = (..bc, 1)
						}
					} else {
						// If we have no base counter, just count one level
						counters.at(identifier) = (tc.last() + 1,)
						let latest = counters.at(identifier)
					}

					let latest = counters.at(identifier)
					return (
						"counters": counters,
						"latest": latest,
					)
				})
			}

			number = context {
				global_numbering(numbering, ..thmcounters.get().at("latest"))
			}
		}

		return figure(
			result
				+ // hacky!
				fmt(name, number, body, ..args.named())
				+ [#metadata(identifier) <meta:thmenvcounter>],
			kind: "thmenv",
			outlined: false,
			caption: name,
			supplement: supplement,
			numbering: refnumbering,
		)
	}
}


#let thmbox(
	identifier,
	head,
	..blockargs,
	supplement: auto,
	padding: (top: 0.5em, bottom: 0.5em),
	namefmt: x => [(#x)],
	titlefmt: strong,
	bodyfmt: x => x,
	separator: [#h(0.1em):#h(0.2em)],
	base: "heading",
	base_level: none,
) = {
	if supplement == auto {
		supplement = head
	}
	let boxfmt(name, number, body, title: auto, ..blockargs_individual) = {
		if not name == none {
			name = [ #namefmt(name)]
		} else {
			name = []
		}
		if title == auto {
			title = head
		}
		if not number == none {
			title += " " + number
		}
		title = titlefmt(title)
		body = bodyfmt(body)
		pad(
			..padding,
			block(
				width: 100%,
				inset: 1.2em,
				radius: 0.3em,
				breakable: false,
				..blockargs.named(),
				..blockargs_individual.named(),
				[#title#name#separator#body],
			),
		)
	}
	return thmenv(
		identifier,
		base,
		base_level,
		boxfmt,
	).with(
		supplement: supplement,
	)
}


#let thmplain = thmbox.with(
	padding: (top: 0em, bottom: 0em),
	breakable: true,
	inset: (top: 0em, left: 0em, right: 0em),
	namefmt: name => emph([(#name)]),
	titlefmt: emph,
)


// Track whether the qed symbol has already been placed, for each
// currently open proof. This is a stack: one boolean per open proof
// environment, with the last entry corresponding to the innermost
// (currently active) proof. A stack is needed rather than a single
// shared flag, since otherwise a nested proof finishing (and setting
// the flag to true) would incorrectly mark the enclosing proof(s) as
// already having shown their qed symbol too.
#let thm-qed-stack = state("thm-qed-stack", ())

// The configured QED symbol for a top-level (outermost) proof
#let thm-qed-symbol = state("thm-qed-symbol", $square$)

// The configured QED symbol for a nested proof, i.e. one that appears
// inside the body of another, still-open proof
#let thm-qed-symbol-nested = state("thm-qed-symbol-nested", $square.filled$)

// Show the qed symbol for the innermost currently-open proof, and mark
// it as done. Uses the nested symbol iff more than one proof is
// currently open (i.e. this qed belongs to a nested proof).
#let thm-qed-show = {
	thm-qed-stack.update(stack => {
		if stack.len() == 0 {
			stack
		} else {
			stack.slice(0, -1) + (true,)
		}
	})
	context {
		let stack = thm-qed-stack.get()
		if stack.len() > 1 {
			thm-qed-symbol-nested.get()
		} else {
			thm-qed-symbol.get()
		}
	}
}

// If placed in a block equation/enum/list, place a qed symbol to its right
#let qedhere = metadata("thm-qedhere")

// Checks if content x contains the qedhere tag
#let thm-has-qedhere(x) = {
	if x == "thm-qedhere" {
		return true
	}

	if type(x) == content {
		for (f, c) in x.fields() {
			if thm-has-qedhere(c) {
				return true
			}
		}
	}

	if type(x) == array {
		for c in x {
			if thm-has-qedhere(c) {
				return true
			}
		}
	}

	return false
}


// bodyfmt for proofs
#let proof-bodyfmt(body) = {
	thm-qed-stack.update(stack => stack + (false,))
	body
	context {
		let stack = thm-qed-stack.get()
		if stack.len() > 0 and stack.last() == false {
			h(1fr)
			thm-qed-show
		}
	}
	thm-qed-stack.update(stack => {
		if stack.len() == 0 {
			stack
		} else {
			stack.slice(0, -1)
		}
	})
}

#let thmproof(..args) = thmplain(
	..args,
	namefmt: emph,
	bodyfmt: proof-bodyfmt,
	..args.named(),
).with(numbering: none)


#let thmrules(
	qed-symbol: $square$,
	nested-qed-symbol: $square.filled$,
	doc,
) = {
	show figure.where(kind: "thmenv"): set block(breakable: true)
	show figure.where(kind: "thmenv"): set align(start)
	show figure.where(kind: "thmenv"): it => it.body

	show ref: it => {
		if it.element == none {
			return it
		}
		if it.element.func() != figure {
			return it
		}
		if it.element.kind != "thmenv" {
			return it
		}

		if it.element.caption != none {
			return link(
				it.target,
				it.element.supplement,
			)
		}

		let supplement = it.element.supplement
		if it.citation.supplement != none {
			supplement = it.citation.supplement
		}

		let loc = it.element.location()
		let thms = query(selector(<meta:thmenvcounter>).after(loc))
		let number = thmcounters.at(thms.first().location()).at("latest")
		return link(
			it.target,
			[#supplement~#numbering(it.element.numbering, ..number)],
		)
	}

	show math.equation.where(block: true): eq => {
		let stack = thm-qed-stack.at(eq.location())
		if thm-has-qedhere(eq) and stack.len() > 0 and stack.last() == false {
			grid(
				columns: (1fr, auto, 1fr),
				[], eq, align(right + horizon)[#thm-qed-show],
			)
		} else {
			eq
		}
	}

	show enum.item: it => {
		show metadata.where(value: "thm-qedhere"): {
			h(1fr)
			thm-qed-show
		}
		it
	}

	show list.item: it => {
		show metadata.where(value: "thm-qedhere"): {
			h(1fr)
			thm-qed-show
		}
		it
	}

	thm-qed-symbol.update(qed-symbol)
	thm-qed-symbol-nested.update(nested-qed-symbol)

	doc
}
