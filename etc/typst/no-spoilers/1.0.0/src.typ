#import "@local/antoine:1.0.0" as environments

#let _ex-count = counter("ex-entries")
#let _ex-data = state("ex-entries", ())

// ex[statement]                    -> statement only
// ex[statement][solution]          -> statement + solution
// ex[statement][solution][hint]    -> statement + solution + hint
#let exercise(name: none, ..args) = {
	let parts = args.pos()
	assert(
		1 <= parts.len() and parts.len() <= 3,
		message: "ex takes between 1 and 3 positional arguments",
	)
	let statement = parts.at(0)
	let sol = parts.at(1, default: none)
	let hint = parts.at(2, default: none)

	_ex-count.step()
	context {
		let n = _ex-count.get().first()
		let id = str(n)
		let lbl = label("ex-entry-" + id)
		_ex-data.update(d => (
			d + ((label: lbl, statement: statement, solution: sol, hint: hint),)
		))
		let target = if sol != none and sol != [] {
			label("ex-entry-" + id + "-sol")
		} else if hint != none and hint != [] {
			label("ex-entry-" + id + "-indic")
		} else {
			none
		}
		let shown = if name == none {
			environments.exercise(ref: target, statement)
		} else {
			environments.exercise(ref: target, name, statement)
		}
		[#shown#lbl]
	}
}

// Les ancres des entrées ne peuvent pas être nommées avec une valeur contenue
// dans _ex-data (elle n'est dispo qu'un passage trop tard pour l'introspection) ;
// on retrouve donc le numéro de l'exercice par arithmétique sur le compteur.
#let _show-entries(field, suffix, render) = context {
	let total = _ex-data.final().len()
	let last-n = _ex-count.final().first()
	for (idx, e) in _ex-data.final().enumerate() {
		let body = e.at(field)
		if body != none and body != [] {
			let n = str(last-n - (total - 1 - idx))
			let anchor = label("ex-entry-" + n + suffix)
			[ #render(e.label, e.statement, body) #anchor ]
		}
	}
}

#let show-hints() = _show-entries("hint", "-indic", (lbl, statement, body) => {
	block(breakable: true)[#strong(ref(lbl, supplement: [:])) #body]
})

// @typstyle off
#let show-solutions() = _show-entries("solution", "-sol", (lbl, statement, body,) => {
	block(breakable: true)[#strong(ref(lbl, supplement: [.],)) #statement #environments.solution(body)]
})
