#import "src/definitions.typ": *
#import "src/environments.typ": *
#import "src/custom.typ": *

// main setup
#let setup(
	title: none,
	subtitle: none,
	author: (),
	date: none,
	maketitle: true,
	title-function: title,
	body,
) = {
	if type(author) == str { author = (author,) }
	set document(title: title, author: author)
	set page(
		paper: "a4",
		margin: auto,
		header: context {
			if not maketitle or here().position().page != 1 {
				set text(size: 0.8em)
				set align(left)
				text(style: "normal", author.join(", "))
				if (date != none) {
					h(0.2em)
					sym.dash.em
					h(0.2em)
					// date
					context {
						let found = false
						for (en, tr) in months.at(text.lang, default: months.at("en")) {
							if (date.find(en) != none) {
								found = true
								show en: tr
								text(style: "italic", date)
								break
							}
						}
						if not found {
							text(style: "italic", date)
						}
					}
				}
				h(1fr)
				text(weight: "bold", title)
				box(width: 100%, align(center, line(length: 100%, stroke: 0.4pt)))
			}
		},
		header-ascent: 15%,
		numbering: "1",
	)
	set par(
		justify: true,
	)
	set text(
		font: fonts.text,
		size: 11pt,
		fallback: false,
	)
	show raw: set text(font: fonts.mono)

	// Section headers
	set heading(numbering: "I.1")
	show heading: it => {
		block({
			if (it.numbering != none) {
				text(
					fill: colors.headers,
					counter(heading).display(),
				)
				h(0.3em)
			}
			it.body
			v(0.4em)
		})
	}
	show heading: set text(font: fonts.sans, weight: "bold", size: 12pt)
	show heading.where(level: 1): set text(size: 14pt)
	show heading.where(level: 2): set text(size: 13pt)

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

	// Indent lists
	set enum(indent: 1em)
	set list(indent: 1em)

	// Allow math blocks to break across pages
	show math.equation: set block(breakable: true)

	// package settings
	show: thmrules.with(qed-symbol: $square$)

	// title
	show title-function: it => {
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
	}
	if (maketitle) {
		title-function()
	}

	body
}
