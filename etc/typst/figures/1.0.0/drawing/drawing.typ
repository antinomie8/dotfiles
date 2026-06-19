#import "@preview/cetz:0.5.2"

#import "/utils/internal.typ": argparse
#import "/utils/complex.typ": *

#let label(point, content, ..args, dir: none) = {
	let args = argparse((content: ("anchor", "angle", "name", "padding")), args)

	if args.content.at("anchor", default: auto) == auto {
		args.content.anchor = 180deg + calc.atan2(..point)
	}
	if dir != none {
		let angle = if type(dir) == int or type(dir) == float {
			calc.atan(dir * calc.pi / 180)
		} else { calc.atan2(dir) }
		args.content.anchor = 180deg + angle
	}

	cetz.draw.content(point, text(..args.default, content), ..args.content)
}

#let dot(..args) = {
	let points = args.pos()
	let args = argparse((label: ("padding", "fill", "anchor", "dir"), dot: ("label",)), args)

	args.default.insert("fill", args.label.at("fill", default: black))

	let draw-label = args.dot.at("label", default: none)
	for point in points {
		cetz.draw.circle(point, radius: 0.15em, ..args.default)
		if draw-label != none {
			label(point, args.dot.label, ..args.label)
		}
	}
}

#let blob(name: none, ..args) = {
	// @typstyle off
	hobby(
		(-4, 3), (-5, 1), (-4.7, 0), (-4.1, -2), (-4, -3),
		(-1, -3.3), (1, -3.2), (4, -3), (4.3, -1),
		(4.1, 0.5), (4, 3), (2, 3.3), (0, 3.1), (-3, 2.9),
		close: true,
		fill: rgb("#e5e5ff"),
		stroke: black,
		..args,
	)
	// @typstyle on
	if name != none {
		label((4, 3), name, dir: 5, padding: 0.7em)
	}
}

#let O = (0, 0)

#let unitcircle(..args) = cetz.draw.circle((0, 0), radius: 1, ..args)

#let circle(..args, rotate: 0deg) = {
	cetz.draw.rotate(rotate)
	cetz.draw.circle(..args)
	cetz.draw.rotate(-rotate)
}

#let ellipse(foci1, foci2, focal-sum: none, ..args) = {
	let mid = div(add(foci1, foci2), 2)
	let dist = norm(sub(foci1, foci2))
	if focal-sum == none { focal-sum = dist } // circle with diameter
	let major = focal-sum - dist
	let minor = calc.sqrt(calc.pow(focal-sum / 2, 2) + calc.pow(dist / 2, 2))
	cetz.draw.circle(mid, radius: (major, minor), ..args)
}

#let right-angle(..args) = cetz.angle.right-angle(label: none, radius: 1cm / 3, ..args)

#let brace(..args) = {
	cetz.decorations.brace(flip: true, amplitude: 0.1, name: "brace", content-offset: 0.05, ..args)
	if args.named().keys().contains("label") {
		cetz.draw.content("brace.content", args.at("label"))
	}
}

#let dir(angle) = (calc.cos(angle * calc.pi / 180), calc.sin(angle * calc.pi / 180))
