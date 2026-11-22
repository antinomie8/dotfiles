#import "definitions.typ": *
#import "@preview/ctheorems:2.0.0" as thm

#let thm-fmt(
  /// Theorem data.
  /// See @thm.fmt for details.
  /// -> dictionary
  thm,
  /// Named arguments for the block.
  /// -> dictionary
  block-args: (:),
  /// Formatting for the environment name.
  /// -> function
  name-fmt: x => [(#x)],
  /// Formatting for the environment title (head and number).
  /// -> function
  title-fmt: strong,
  /// Formatting for the environment body.
  /// -> function
  body-fmt: x => x,
  /// Separator between title and body.
  /// -> content
  separator: [*.* ],
	/// Function that returns the actual content
	/// -> function
	render: (title, name, separator, body, block-args, style) => {
		block(
			width: 100%,
			..block-args,
			[#box[#title]#name#separator#body]
		)	
	},
) = {
  // Swallow formatting arguments passed directly to the `thm`
  block-args = thm.args.remove("block-args", default: block-args)
  name-fmt   = thm.args.remove("name-fmt",   default: name-fmt)
  title-fmt  = thm.args.remove("title-fmt",  default: title-fmt)
  body-fmt   = thm.args.remove("body-fmt",   default: body-fmt)
  separator  = thm.args.remove("separator",  default: separator)

	let style = thm.args.remove("style", default: none)
	if style == "plain" { title-fmt = text.with(style: "italic") }

  let name = []
  if thm.name != none {
    name = [ #name-fmt(thm.name)]
  }

  let title = thm.supplement
  if not thm.number == none {
    title += [ #thm.number]
  }
  title = title-fmt(title)
  let body = body-fmt(thm.body)

	render(title, name, separator, body, block-args + thm.args, style)
}

#let thm-proof = thm.proof.with(
	block-args: (
		stroke: ( left: .5pt + colors.env.proof),
		inset: ( left: 1em),
		outset: ( left: -.5em, y: .15em),
	),
	body-fmt: thm.proof-body-fmt,
	separator: none,
	title-fmt: text.with(fill: colors.env.proof, weight: "bold"),
	fmt: thm-fmt.with(render: (title, name, separator, body, block-args, style) => {
		if style == "plain" {
			[#box[#title]#name.#body]
		} else if style == "oneline" {
			[#box[#title]#name#separator#body]
		} else {
			[#box[#title]#name#separator]
			block(
				width: 100%,
				above: .5em,
				..block-args,
				body
			)
		}
	}),
)

#let thm-env = thm.thm.with(
	ref-fmt: thm => {
		if thm.ref-supplement == [:] or thm.ref-supplement == [.] {
			link(thm.loc, text(fill: colors.label)[#thm.supplement #thm.number#thm.ref-supplement])
		} else if thm.ref-supplement != none and thm.ref-supplement != [!] {
			link(thm.loc, text(fill: colors.label)[#thm.ref-supplement #thm.number])
		} else if thm.name == none or thm.ref-supplement == [!] {
			link(thm.loc, text(fill: colors.label)[#thm.supplement #thm.number])
		} else {
			link(thm.loc, text(fill: colors.label, thm.name))
		}
	},
)

#let qedhere = thm.qedhere
#let tag = thm.tag

// environments
#let callout(
	breakable: true,
	header-inset: 0.5em,
	width: auto,
	stroke-width: 1.5pt,
	border-radius: 0pt,
	left-border-rounding: true,
	border-width: 0pt,
	content-inset: 1em,
	header-color: black,
	header-text-color: white,
	accent-color: black,
	body-color: none,
	clip-content: false,
	shadow: false,
	shadow-offset: 0.4em,
	title: none,
	icon: none,
	content,
) = {
	let body-color = if body-color != none {
		body-color
	} else if accent-color == black {
		rgb("#f6f8f9")
	} else {
		color.mix((accent-color, 10%), white)
	}
	let stroke-color = accent-color
	let border-color = accent-color

	let content_block = block(
		breakable: breakable,
		width: 100%,
		fill: body-color,
		inset: (left: content-inset + stroke-width, rest: content-inset),
		outset: (left: -stroke-width),
		radius: (
			top-right: if (title != none) { 0pt } else { border-radius },
			top-left: if (title != none or stroke-width != 0pt) { 0pt } else { border-radius },
			bottom-left: if (stroke-width == 0pt) { border-radius } else { 0pt },
			bottom-right: border-radius,
		),
		stroke: (
			left: if (stroke-width == 0pt) {
				border-width + border-color
			} else { (thickness: stroke-width, paint: stroke-color, cap: "butt") },
			top: if (title != none) { border-width + header-color } else {
				border-width + border-color
			},
			rest: border-width + border-color,
		),
		content,
	)

	let callout = if title == none {
		content_block
	} else {
		let header_block = block(
			sticky: true,
			below: 0pt,
			fill: header-color,
			width: 100%,
			radius: (
				top-right: border-radius,
				top-left: if (stroke-width == 0pt) { border-radius } else { 0pt },
			),
			outset: (left: -stroke-width),
			inset: (left: header-inset + stroke-width, rest: header-inset),
			stroke: (
				left: if (stroke-width == 0pt) {
					border-width + border-color
				} else { (thickness: stroke-width, paint: stroke-color, cap: "butt") },
				rest: border-width + border-color,
			),
			{
				let args = arguments(fill: header-text-color, weight: "bold", title)
				if icon == none {
					text(..args)
				} else {
					grid(
						columns: (auto, auto),
						align: (horizon, left + horizon),
						gutter: 1em,
						box(height: 1em)[ #icon ], text(..args),
					)
				}
			},
		)

		block(
			breakable: breakable,
			width: width,
			radius: (
				right: border-radius,
				left: if (stroke-width == 0pt) {
					border-radius
				} else { 0pt },
			),
			clip: clip-content,
			{
				set align(start)
				header_block
				content_block
			},
		)
	}

	if shadow {
		import "@preview/shadowed:0.3.0": shadow
		return shadow(
			radius: border-radius,
			fill: rgb("#d9d9d9"),
			dx: shadow-offset,
			dy: shadow-offset,
			callout,
		)
	} else {
		return callout
	}
}

#let thm-plain(
	env_name,
	linebreak: false,
	separator: ". ",
	style: "normal",
	boxed: false,
	display-title: false,
	..callout-args,
) = thm-env.with(
	counter: env_name,
	supplement: get_env_name(env_name),
	fmt: (
		color: callout-args.at("accent-color", default: black),
		linebreak: linebreak,
		style: style,
		boxed: boxed,
		display-title: display-title,
		thm,
	) => context {
		let class = classes.at(document-class.get())
		let body = {
			// colorize boxed stroke
			show box: it => {
				if type(it.stroke) == stroke and it.stroke.paint == auto {
					set box(stroke: color)
					it
				} else {
					it
				}
			}
			thm.body
		}
		if display-title {
			callout(
				..callout-args,
				title: {
					get_env_name(env_name)
					if thm.number != none { [ #thm.number] }
					if type(thm.name) == str or type(thm.name) == content {
						if type(thm.name) == str and thm.name.starts-with(regex("https?://")) {
							thm.name = link(thm.name, text(fill: white, thm.name))
						}
						" (" + thm.name + ")"
					}
					if thm.args.at("link", default: none) != none {
						" " + link(thm.args.at("link"), "🔗")
					}
				},
				body,
			)
		} else {
			let header = {
				let args = class.at("env-header-args", default: arguments(
					weight: "bold",
					style: style,
				))
				args = arguments(fill: color, ..args)

				let first-letter-size = class.at("env-first-letter-size", default: (:)).at(env_name, default: none)
				if first-letter-size != none {
					let (first-letter, rest) = get_env_name(env_name, split-first-letter: true)
					text(first-letter, ..args, size: first-letter-size)
					text(rest, ..args)
				} else {
					text(get_env_name(env_name), ..args)
				}
				if thm.number != none {
					text(..args, [ #thm.number])
				}
				if thm.args.at("link", default: none) != none {
					" " + link(thm.args.at("link"), "🔗")
				}
				if type(thm.name) == str or type(thm.name) == content {
					text(size: 11pt, style: style, fill: color, " (" + thm.name + ")")
				}
				if linebreak { [\ ] } else {
					text(..args, separator)
				}
			}
			if thm.args.at("ref", default: none) != none {
				header = link(thm.args.at("ref"), header)
			}
			if boxed and class.at("boxed-envs", default: true) {
				callout(
					..callout-args,
					header + body,
				)
			} else {
				header + body
			}
		}
	},
)

#let thm-box(
	env_name,
	accent: color.black,
	/// Thickness of the top/bottom border where the box is split across pages
	/// -> length
	break-thickness: .3pt,
	..thm-args,
) = thm-env.with(
	counter: env_name,
	base: "heading",
	inset: 1.2em,
	radius: 0.3em,
	supplement: get_env_name(env_name),
	title-fmt: text.with(weight: "bold", fill: accent),
	name-fmt: content => text(fill: accent, "(" + content + ")"),
	fmt: thm-fmt.with(render: (title, name, separator, body, block-args, style) => {
		let full = 1pt
		show: pad.with(top: 0.8em, bottom: 0em)
		context {
			// This box's location identifies it: every fragment's footer leaves a
			// marker holding it, so a header/footer can tell whether another
			// fragment of the *same* box (even with nested boxes) lies before/after.
			// Markers never change between layout passes, so this can't cause
			// convergence problems (unlike counters keyed on a counter value).
			let box-id = here()
			// The side borders stick out by half their width past the edge of the
			// row, so the rule is shifted outwards (dir: -1 up, 1 down) to make its
			// outer edge flush with the end of the sides. Zero shift when full-width.
			let rule(thickness, dir) = move(
				dy: dir * (full - thickness) / 2,
				line(length: 100%, stroke: (thickness: thickness, paint: accent)),
			)
			let mine(markers) = markers.any(m => m.value == box-id)
			block(
				breakable: true,
				width: 100%,
				// ..block-args,
				grid(
					columns: 1fr,
					inset: 0pt,
					stroke: (x: (thickness: full, paint: accent)),
					// Repeated on every page: thin unless this is the first fragment
					// (= no footer of this box before it).
					grid.header(repeat: true, context {
						let before = query(selector(<thm-box-fragment>).after(box-id).before(here()))
						rule(if mine(before) { break-thickness } else { full }, -1)
					}),
					grid.cell(inset: 1em, {
						place(top, dx: .1em, dy: -1.8em, block(fill: white, inset: 5pt, title + name))
						body
					}),
					// Repeated on every page: thin unless this is the last fragment
					// (= no footer of this box after it).
					grid.footer(repeat: true, {
						[#metadata(box-id) <thm-box-fragment>]
						context {
							let after = query(selector(<thm-box-fragment>).after(here()))
							rule(if mine(after) { break-thickness } else { full }, 1)
						}
					}),
				),
			)
		}
	}),
	..thm-args,
)

// predefined environments
#let thm_numbering(..args) = {
	if (args.at(2, default: none) == none and args.at(0) == 0) {
		return args.at(1)
	} else {
		return numbering("1.1", ..args)
	}
}

#let un-numbered(base) = (
	base.with(numbering: thm_numbering),
	base.with(numbering: none),
)

#let (theorem, _theorem) = un-numbered(thm-box("theorem", ..colors.env.theorem))
#let (corollary, _corollary) = un-numbered(thm-box("corollary", ..colors.env.theorem))
#let (proposition, _proposition) = un-numbered(thm-box("proposition", ..colors.env.theorem))
#let (example, _example) = un-numbered(thm-box("example", radius: 0em, ..colors.env.example))

#let (definition, _definition) = un-numbered(thm-box("definition", ..colors.env.definition))
#let (notation, _notation) = un-numbered(thm-plain("notation", ..colors.env.plain))
#let (conjecture, _conjecture) = un-numbered(thm-plain("conjecture", style: "italic"))
#let (remark, _remark) = un-numbered(thm-plain("remark", boxed: true))
#let (exercise, _exercise) = un-numbered(thm-plain("exercise", boxed: true, ..colors.env.exercise))
#let (question, _question) = un-numbered(thm-plain("question", boxed: true))
#let (lemma, _lemma) = un-numbered(thm-plain("lemma", boxed: true, ..colors.env.lemma))
#let (problem, _problem) = un-numbered(thm-plain(
	"problem",
	display-title: true,
	boxed: true,
	border-radius: 6pt,
	stroke-width: 0pt,
	border-width: 0.5pt,
	shadow: true,
	..colors.env.problem,
))

#let reformulation = thm-plain("reformulation", boxed: true, ..colors.env.reformulation).with(numbering: none)
#let algorithm = thm-plain("algorithm", boxed: true, ..colors.env.algorithm).with(numbering: none)
#let properties = thm-plain("properties", ..colors.env.plain).with(numbering: none)

#let proof = thm-proof.with(supplement: get_env_name("proof"))
#let solution = thm-proof.with(supplement: get_env_name("solution"))

#let eqn(it) = {
	set math.equation(numbering: "(1)")
	it
}
