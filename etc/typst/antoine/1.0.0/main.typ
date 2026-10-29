#import "src/definitions.typ": *
#import "src/environments.typ": *
#import "src/custom.typ": *

// main setup
#let setup(
	title: none,
	subtitle: none,
	name: none,
	author: (),
	date: auto,
	class: "normal",
	maketitle: false,
	body,
) = {
	document-class.update(class)
	let class = classes.at(class)

	if date == auto {
		date = datetime
			.today()
			.display("[day padding:none] [month repr:long] [year]")
	}
	if (date != none) {
		// Translate month in date
		date = context {
			let apply-rules(body, rules) = {
				if rules.len() == 0 {
					body
				} else {
					show rules.first().at(0): rules.first().at(1)
					apply-rules(body, rules.slice(1))
				}
			}
			apply-rules(date, months.at(text.lang, default: (:)).pairs())
		}
	}
	if type(author) == str { author = (author,) }

	set document(title: title, author: author)
	set page(
		paper: "a4",
		margin: (x: 4em, y: 5em),
		header: context {
			if (
				not maketitle
					or here().position().page != 1
					or class.at("first-page-header", default: false)
			) {
				set text(size: 0.8em)
				set align(left)
				text(style: "normal", author.join(", "))
				if (date != none) {
					h(0.2em)
					sym.dash.em
					h(0.2em)
					set text(style: "italic")
					date
				}
				h(1fr)
				text(weight: "bold", if name == none { title } else { name })
				box(width: 100%, align(center, line(length: 100%, stroke: 0.4pt)))
			}
		},
		header-ascent: 15%,
		numbering: "1",
	)
	set par(justify: true)
	set text(font: fonts.text, size: class.at("text-size", default: 11pt))
	show raw: set text(font: fonts.mono)
	set table(stroke: 0.7pt)
	set table.cell(align: center)

	// Section headers
	show: class.at("rules", default: body => {
		set heading(numbering: "I.1")
		show heading: set text(font: fonts.sans, weight: "bold", size: 12pt)
		show heading: it => {
			if it.level == 1 { v(0.2em) } else { v(0em) }
			if (it.numbering != none) {
				text(
					fill: colors.headers,
					counter(heading).display(),
				)
				h(0.3em)
			}
			it.body
			v(if it.level == 1 { -0.4em } else { 0em })
		}
		body
	})
	show heading.where(level: 1): set text(size: 14pt)
	show heading.where(level: 2): set text(size: 13pt)
	show heading.where(level: 3): set text(size: 12pt)

	// Equations
	set math.equation(alt: "equation", supplement: none)
	show math.equation: set text(font: fonts.math)
	show math.equation: set block(breakable: true) // Allow math blocks to break across pages
	show math.attach: it => {
		// display fractions horizontally in subscripts and superscripts
		let f = it.fields()
		let base = f.remove("base")
		let t = f.at("t", default: none)
		if t != none and t.func() == math.frac and not t.has("style") {
			f.insert("t", math.frac(t.num, t.denom, style: "horizontal"))
			math.attach(base, ..f)
		} else {
			it
		}
	}
	show math.gt.eq: math.gt.eq.slant
	show math.lt.eq: math.lt.eq.slant

	// Colorize hyperlinks
	show link: it => {
		set text(fill: if (type(it.dest) == label) {
			colors.label
		} else {
			colors.hyperlink
		})
		it
	}
	show ref: it => {
		if it.element != none and it.element.alt == "equation" {
			link(it.target, "(" + it + ")")
		} else {
			link(it.target, it)
		}
	}

	// Change quote display
	set quote(block: true)
	show quote: set pad(left: 2em, top: -1em, bottom: -0.5em)
	show quote: set text(style: "italic")

	// Make divider not span the whole page width
	show divider: set align(center)
	show divider: set line(length: 85%)

	// Indent lists and use letters instead of numbers for numbering
	set enum(indent: 1em, numbering: "a)")
	set list(indent: 1em)

	// packages
	show: thm.thm-rules.with(qed-symbol: $square$, qed-symbol-nested: $qed$)

	// display exponents
	show regex("[0-9]+(er|ème|eme|st|nd)\b"): it => {
		let m = it.text.match(regex("^([0-9]+)(er|ème|eme)$"))
		[#m.captures.at(0)#super[#m.captures.at(1)]]
	}

	// title
	if (maketitle) {
		show std.title: class.at("title-display", default: it => {
			v(1em)
			align(center, text(
				size: 18pt,
				weight: "bold",
				font: fonts.sans,
				it,
			))
			align(center, text(
				size: 13pt,
				weight: "bold",
				font: fonts.sans,
				subtitle,
			))
			align(center, text(
				size: 15pt,
				weight: "regular",
				smallcaps(author.join(", ")),
			))
			v(-0.2em)
			align(center, text(
				size: 11pt,
				weight: "regular",
				date,
			))
			v(1.5em)
		})
		std.title()
	}

	body
}
