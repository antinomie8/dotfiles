#import "@preview/cetz:0.5.2"

#import "/drawing/canvas.typ": canvas as cetz-canvas

/// Draws a plane with a Cartesian coordinate system
/// - n (int): the size of the grid
/// - lattice (boolean): whether to draw the integer lattice
/// - style (style): additional style arguments for cetz.set-style
/// - drawing: the canvas content
#let plane(
	n: 4.65,
	lattice: false,
	ticks: true,
	style: (:),
	length: 1cm,
	canvas: true,
	x-label: $x$,
	y-label: $y$,
	drawing,
) = {
	let canvas-content = {
		import cetz.draw: *

		// Style overrides
		set-style(..style)

		// Draw the integer lattice
		if lattice {
			grid(
				(-n, -n),
				(n, n),
				shift: calc.fract(n),
				step: 1,
				stroke: gray + 0.2pt,
			)
		}

		// Draw the axis lines and axis labels
		line((-n, 0), (n, 0), mark: (start: "triangle", end: "triangle"))
		content((), x-label, anchor: "north", padding: .5em)
		line((0, -n), (0, n), mark: (start: "triangle", end: "triangle"))
		content((), y-label, anchor: "east", padding: .5em)

		// Draw the number steps on the axes
		if ticks {
			let max = calc.floor(if calc.fract(n) == 0 { n - 1 } else { n })
			for c in range(-max, max + 1) {
				line((c, 3pt), (c, -3pt))
				line((3pt, c), (-3pt, c))
			}
		}

		// Draw origin
		content((0, 0), anchor: "north-east", $0$)

		drawing
	}

	if canvas {
		cetz-canvas(length: length, canvas-content)
	} else {
		canvas-content
	}
}

/// Draws a complex plane
/// - n (int): the size of the grid
/// - lattice (boolean): whether to draw the Gaussian integers lattice
/// - style (style): additional style arguments for cetz.set-style
/// - drawing: the canvas content
#let complex-plane = plane.with(x-label: math.op("Re"), y-label: math.op("Im"))
