#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"

#import "/utils/internal.typ": argparse
#import "/utils/complex.typ": *

#let annotate = cetz-plot.plot.annotate
#let content(..args) = annotate(cetz.draw.content(..args))
#let line(..args)    = annotate(cetz.draw.line(..args))
#let circle(..args)  = annotate(cetz.draw.circle(..args))
#let rect(..args)    = annotate(cetz.draw.rect(..args))
#let angle(..args)   = annotate(cetz.angle.angle(..args))

#let label(point, label, ..args, dir: none) = {
	let args = argparse((content: ("anchor", "angle", "name", "padding")), args)

	if args.content.at("anchor", default: auto) == auto {
		args.content.anchor = 180deg + calc.atan2(..point)
	}
	if dir != none {
		let angle = if type(dir) == int or type(dir) == float {
			calc.atan(dir * calc.pi / 180)
		} else { calc.atan2(..dir) }
		args.content.anchor = 180deg + angle
	}

	content(point, text(..args.default, label), ..args.content)
}

#let dot(..args) = {
	let points = args.pos()
	let args = argparse(
		(label: ("padding", "fill", "anchor", "dir"), dot: ("label",)),
		args,
	)

	args.default.insert("fill", args.label.at("fill", default: black))

	let draw-label = args.dot.at("label", default: none)
	for point in points {
		circle(point, radius: 0.15em, ..args.default)
		if draw-label != none {
			label(point, args.dot.label, ..args.label)
		}
	}
}

#let O = (0, 0)

#let right-angle(..args) = annotate(
	cetz.angle.right-angle(label: none, radius: 1cm / 3, ..args),
)

#let dir(angle) = (
	calc.cos(angle * calc.pi / 180),
	calc.sin(angle * calc.pi / 180),
)

#let unitcircle = circle.with((0, 0), radius: 1)

#let brace(start, end, ..args) = {
	let brace = cetz.decorations.brace(
		start,
		end,
		amplitude: 0.1,
		name: "brace",
		content-offset: -0.02,
		..args,
	)
	if args.named().keys().contains("content") {
		let flip = args.at("flip", default: false)
		let pt = sub(end, start)
		let angle = 0
		let anchor = if calc.abs(im(pt)) < 10e-9 {
			// horizontal
			if flip != (re(pt) > 0) { "south" } else { "north" }
		} else if calc.abs(re(pt)) < 10e-9 {
			// vertical
			if flip != (im(pt) > 0) { "east" } else { "west" }
		} else {
			let arg = arg(pt)
			angle = if (calc.abs(arg) < calc.pi / 2) { arg } else { calc.pi + arg }
			if flip != (calc.abs(arg) < calc.pi / 2) { "south" } else { "north" }
		}
		annotate({
			brace
			cetz.draw.content(
				"brace.content",
				args.at("content"),
				angle: args.at("angle", default: angle * 1rad),
				anchor: args.at("anchor", default: anchor),
			)
		})
	} else {
		annotate(brace)
	}
}
