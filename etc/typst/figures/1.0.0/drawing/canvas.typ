#import "@preview/cetz:0.5.2"
#import cetz.draw: *
#import cetz.angle: *
#import cetz.decorations: *

#import "/utils/complex.typ": *
#import "drawing.typ": *

#let canvas(drawing, ..args) = cetz.canvas(..args, {
	let scaling-factor = 1cm / args.at("length", default: 1cm)

	// Change the design for all elements after it
	cetz.draw.set-style(
		// Design of arrow tips at the end of lines
		mark: (fill: black),
		// Design of lines
		stroke: (thickness: 0.4pt, cap: "round"),
		// // Design of angles
		// angle: (
		// 	radius: 0.6 * scaling-factor,
		// 	label-radius: .39 * scaling-factor,
		// 	label: none,
		// ),
		// Design of all text elements with an anchor
		content: (padding: 0.1 * scaling-factor),
	)
	drawing
})
