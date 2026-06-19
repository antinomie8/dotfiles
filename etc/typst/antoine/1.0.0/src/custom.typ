#import "definitions.typ": *

// symbols
#let prod = sym.product
#let setminus = sym.without
#let cap = sym.inter
#let cup = sym.union
#let iff = sym.arrow.l.r.double.long
#let pm = sym.plus.minus
#let mp = sym.minus.plus
#let tensor = sym.times.o
#let int = sym.integral
#let oint = sym.integral.cont
#let iint = sym.integral.double
#let oiint = sym.integral.surf
#let iiint = sym.integral.triple
#let oiiint = sym.integral.vol

#let ord = math.op("ord")
#let pgcd = math.op("pgcd")
#let ppcm = math.op("ppcm")

#let sumcyc = $sum_("cyc")$
#let sumsym = $sum_("sym")$
#let NNN = $NN^*$

#let pmod(x) = $space (mod #x)$
#let dbbracket(lhs, rhs) = {
	if type(lhs) == array { lhs = lhs.join() }
	if type(rhs) == array { rhs = rhs.join() }
	math.lr[$⟦ lhs ; rhs ⟧$]
}
#let card = math.abs
#let proj(point) = {
	math.attach([$=$], t: [$#point$])
}

// commands
#let vocab = text.with(weight: "bold", ..colors.env.vocab)
#let bf(x) = $bold(upright(#x))$
#let cal(it) = math.class("normal", context {
	show math.equation: set text(
		font: ("Garamond-Math", "New Computer Modern Math"),
		stylistic-set: 3,
	)
	let scaling = 100% * (1em.to-absolute() / text.size)
	let wrapper = if scaling < 60% {
		math.sscript
	} else if scaling < 100% {
		math.script
	} else {
		it => it
	}
	box(text(top-edge: "bounds", $wrapper(math.cal(it))$))
})

#let boxed(x, ..args) = box(stroke: .05em, outset: (x: 2pt, y: 4pt), x, ..args)
#let bigbox(x, color: auto, ..args) = {
	align(center, box(stroke: (thickness: .07em, paint: auto), inset: .8em, x, ..args))
}

#let toc = {
	show outline.entry: it => {
		set text(fill: colors.toc.entries)
		link(
			it.element.location(),
			{
				let weight = "regular"
				if it.level == 1 {
					v(1.2em, weak: true)
					weight = "bold"
				}
				it.indented(
					text(font: fonts.sans, weight: "semibold", it.prefix()),
					text(weight: weight, it.inner()),
				)
			},
		)
	}
	outline(
		title: text(
			weight: "semibold",
			fill: colors.toc.title,
			size: 1.4em,
			font: fonts.sans,
			get_env_name("toc"),
		),
		indent: 2em,
	)
}

#let oly(name, ..arg) = {
	let text = arg.at(0, default: name)
	link("oly://gen?name=" + name, text)
}

#let parachuted = {
	import "@preview/marginalia:0.3.1": notefigure
	notefigure(image("/icons/parachute.svg"), dy: 1.5em)
}
