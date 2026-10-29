#import "definitions.typ": *
#import "@preview/ctheorems:2.0.0" as thm

#let qedhere = thm.qedhere

#let thm-env = thm.thm.with(
	ref-fmt: thm => {
		if thm.ref-supplement != none and thm.ref-supplement != [!] {
			link(thm.loc, text(fill: colors.label)[#thm.ref-supplement #thm.number])
		} else if thm.name == none or thm.ref-supplement == [!] {
			link(thm.loc, text(fill: colors.label)[#thm.supplement #thm.number])
		} else {
			link(thm.loc, text(fill: colors.label, thm.name))
		}
	},
)

// environments
#let callout(
	breakable: true,
	headless: false,
	header-inset: 0.5em,
	width: auto,
	stroke-width: 3pt,
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

	let header_block = block(
		sticky: true,
		below: 0pt,
		fill: header-color,
		width: 100%,
		radius: (
			top-right: border-radius,
			top-left: if (stroke-width == 0pt) { border-radius } else { 0pt },
		),
		inset: header-inset,
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

	let content_block(content) = block(
		breakable: breakable,
		width: 100%,
		fill: body-color,
		inset: content-inset,
		radius: (
			top-right: if (title != none) { 0pt } else { border-radius },
			top-left: if (title != none or stroke-width != 0pt) { 0pt } else {
				border-radius
			},
			bottom-left: if (stroke-width == 0pt) { border-radius } else { 0pt },
			bottom-right: border-radius,
		),
		above: 0pt,
		content,
	)

	let callout = block(
		breakable: breakable,
		width: width,
		radius: (
			right: border-radius,
			left: if (stroke-width == 0pt) {
				border-radius
			} else { 0pt },
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
		clip: clip-content,
		{
			set align(start)
			if (not headless and title != none) { header_block }
			content_block(content)
		},
	)

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
	..calloutargs,
) = thm-env.with(
	counter: env_name,
	supplement: get_env_name(env_name),
	fmt: (
		color: calloutargs.at("accent-color", default: black),
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
				..calloutargs,
				// ..additional_calloutargs,
				title: {
					get_env_name(env_name)
					if thm.number != none { [ #thm.number] }
					if type(thm.name) == str or type(thm.name) == content {
						if type(thm.name) == str and thm.name.starts-with(regex("https?://")) {
							thm.name = std.link(thm.name, text(fill: white, thm.name))
						}
						" (" + thm.name + ")"
					}
					if thm.args.at("link", default: none) != none {
						" " + std.link(thm.args.at("link"), "🔗")
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
				if type(thm.name) == str or type(thm.name) == content {
					text(size: 11pt, style: style, fill: color, " (" + thm.name + ")")
				}
				if linebreak { [\ ] } else {
					text(..args, separator)
				}
			}
			if boxed and class.at("boxed-envs", default: true) {
				callout(
					..calloutargs,
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
	linebreak: false,
	..thmargs,
) = thm-env.with(
	counter: env_name,
	base: "heading",
	inset: 1.2em,
	radius: 0.3em,
	supplement: get_env_name(env_name),
	title-fmt: (content, delta: none) => context {
		text(weight: "bold", fill: accent, content)
	},
	name-fmt: content => text(
		fill: accent,
		"(" + content + ")",
	),
	body-fmt: x => x,
	separator: if linebreak { [\ ] } else {
		text(weight: "bold", fill: accent, ":")
	},
	block-args: (breakable: true),
	..thmargs,
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

#let (theorem, _theorem) = un-numbered(thm-box("theorem", linebreak: true, ..colors.env.theorem))
#let (corollary, _corollary) = un-numbered(thm-box("corollary", ..colors.env.theorem))
#let (proposition, _proposition) = un-numbered(thm-box("proposition", linebreak: true, ..colors.env.theorem))
#let (example, _example) = un-numbered(thm-box("example", radius: 0em, ..colors.env.example))

#let (definition, _definition) = un-numbered(thm-plain("definition", ..colors.env.plain))
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
	border-width: 0.7pt,
	shadow: true,
	..colors.env.problem,
))

#let reformulation = thm-plain("reformulation", boxed: true, ..colors.env.reformulation).with(numbering: none)
#let algorithm = thm-plain("algorithm", boxed: true, ..colors.env.algorithm).with(numbering: none)
#let properties = thm-plain("properties", ..colors.env.plain).with(numbering: none)

#let proof = thm.proof.with(supplement: get_env_name("proof"), separator: ":")
#let solution = thm.proof.with(supplement: get_env_name("solution"), separator: ":")

#let eqn(it) = {
	set math.equation(numbering: "(1)")
	it
}
