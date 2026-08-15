#import "src/definitions.typ": *
#import "src/environments.typ": *
#import "src/custom.typ": *

// main setup
#let setup(
	title: none,
	subtitle: none,
	name: none,
	author: (),
	date: none,
	class: "normal",
	maketitle: false,
	body,
) = {
	document-class.update(class)

	// Translate month in date
	if (date != none) {
		date = context {
			let found = false
			for (en, tr) in months.at(text.lang, default: months.at("en")) {
				if (date.find(en) != none) {
					found = true
					show en: tr
					date
					break
				}
			}
			if not found { date }
		}
	}

	if type(author) == str { author = (author,) }

	set document(title: title, author: author)
	set page(
		paper: "a4",
		margin: auto,
		header: context {
			if not maketitle or here().position().page != 1 or class == "pofm" {
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
	set par(
		justify: true,
	)
	set text(
		font: fonts.text,
		size: if class == "normal" { 11pt } else if class == "pofm" { 12pt },
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

	// make divider not span the whole page width
	show divider: set align(center)
	show divider: line(length: 85%)

	// Indent lists
	set enum(indent: 1em)
	set list(indent: 1em)

	show math.equation: set text(font: fonts.math)
	show math.equation: set block(breakable: true) // Allow math blocks to break across pages

	// packages
	show: thmrules

	// title
	if (maketitle) {
		show std.title: it => if class == "normal" {
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
		} else if class == "pofm" {
			v(0.9em)
			align(center, smallcaps(text(
				font: "New Computer Modern 08",
				weight: "bold",
				size: 22pt,
				title,
			)))
		}
		std.title()
	}

	body
}
