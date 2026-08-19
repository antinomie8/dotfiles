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
		date = datetime.today().display("[day] [month repr:long] [year]")
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
		margin: auto,
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

	// Section headers
	show: class.at("rules", default: body => {
		set heading(numbering: "I.1")
		show heading: set text(font: fonts.sans, weight: "bold", size: 12pt)
		show heading: it => {
			if (it.numbering != none) {
				text(
					fill: colors.headers,
					counter(heading).display(),
				)
				h(0.3em)
			}
			it.body
			v(0em)
		}
		body
	})
	show heading.where(level: 1): set text(size: 16pt)
	show heading.where(level: 2): set text(size: 14pt)
	show heading.where(level: 3): set text(size: 13pt)

	// Colorize hyperlinks
	show link: it => {
		set text(fill: if (type(it.dest) == label) { colors.label } else {
			colors.hyperlink
		})
		it
	}
	show ref: it => {
		link(it.target, it)
	}

	// Change quote display
	set quote(block: true)
	show quote: set pad(x: 2em, y: 0em)
	show quote: it => {
		set text(style: "italic")
		v(-1em)
		it
		v(-0.5em)
	}

	// make divider not span the whole page width
	show divider: set align(center)
	show divider: line(length: 85%)

	// Indent lists and use letters instead of numbers for numbering
	set enum(indent: 1em, numbering: "a)")
	set list(indent: 1em)

	show math.equation: set text(font: fonts.math)
	show math.equation: set block(breakable: true) // Allow math blocks to break across pages

	// packages
	show: thmrules

	// title
	if (maketitle) {
		show std.title: class.at("title-display", default: it => {
			v(1em)
			align(center, text(
				size: 1em,
				weight: "bold",
				font: fonts.sans,
				it,
			))
			align(center, text(
				size: 0.6em,
				weight: "bold",
				font: fonts.sans,
				subtitle,
			))
			align(center, text(
				size: 15pt,
				weight: "regular",
				smallcaps(author.join(", ")),
			))
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
