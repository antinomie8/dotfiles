#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"

#import "/utils/internal.typ": argparse

#let content(..args) = cetz-plot.plot.annotate(cetz.draw.content(..args))
#let line(..args) = cetz-plot.plot.annotate(cetz.draw.line(..args))
#let circle(..args) = cetz-plot.plot.annotate(cetz.draw.circle(..args))
#let rect(..args) = cetz-plot.plot.annotate(cetz.draw.rect(..args))
#let angle(..args) = cetz-plot.plot.annotate(cetz.angle.angle(..args))

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

	cetz-plot.plot.annotate(cetz.draw.content(point, text(..args.default, content), ..args.content))
}

#let dot(..args) = {
	let points = args.pos()
	let args = argparse((label: ("padding", "fill", "anchor", "dir"), dot: ("label",)), args)

	args.default.insert("fill", args.label.at("fill", default: black))

	let draw-label = args.dot.at("label", default: none)
	for point in points {
		circle(point, radius: 0.15em, stroke: none, ..args.default)
		if draw-label != none {
			label(point, args.dot.label, ..args.label)
		}
	}
}

#let O = (0, 0)

#let unitcircle(..args) = circle((0, 0), radius: 1, ..args)

#let right-angle(..args) = cetz-plot.plot.annotate(
	cetz.angle.right-angle(label: none, radius: 1cm / 3, ..args),
)

#let brace(..args) = {
	cetz-plot.plot.annotate(
		cetz.decorations.brace(
			flip: true,
			amplitude: 0.1,
			name: "brace",
			content-offset: 0.05,
			..args,
		),
	)
	if args.named().keys().contains("label") {
		content("brace.content", args.at("label"))
	}
}

#let dir(angle) = (calc.cos(angle * calc.pi / 180), calc.sin(angle * calc.pi / 180))
