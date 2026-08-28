#import "@preview/cetz:0.5.2"

#import "/drawing/canvas.typ": canvas as cetz-canvas

/// Draws a plane with a Cartesian coordinate system
/// - n (int): the size of the grid
/// - lattice (boolean): whether to draw the integer lattice
/// - style (style): additional style arguments for cetz.set-style
/// - drawing: the canvas content
#let plane(
	x-min: none,
	x-max: none,
	y-min: none,
	y-max: none,
	n: 4.65,
	lattice: false,
	ticks: true,
	style: (:),
	length: 1cm,
	canvas: true,
	x-label: $x$,
	y-label: $y$,
	marks: (start: "triangle", end: "triangle"),
	drawing,
) = {
	if x-min == none { x-min = -n }
	if x-max == none { x-max = n }
	if y-min == none { y-min = -n }
	if y-max == none { y-max = n }

	let canvas-content = {
		// Style overrides
		import cetz.draw: *
		set-style(..style)

		// Draw the integer lattice
		if lattice {
			grid(
				(x-min, y-min),
				(x-max, y-max),
				shift: (shift-x: calc.fract(-x-min), shift-y: calc.fract(-y-min) + 1),
				step: 1,
				stroke: gray + 0.2pt,
			)
		}

		// Draw the axis lines and axis labels
		line((x-min, 0), (x-max, 0), mark: (marks))
		content((), x-label, anchor: "north", padding: .5em)
		line((0, y-min), (0, y-max), mark: (marks))
		content((), y-label, anchor: "east", padding: .5em)

		// Draw the number steps on the axes
		if ticks {
			for c in range(calc.ceil(x-min + 0.01), calc.floor(x-max - 0.01) + 1) {
				line((c, 3pt), (c, -3pt))
			}
			for c in range(calc.ceil(y-min + 0.01), calc.floor(y-max - 0.01) + 1) {
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

#let complex-plane = plane.with(x-label: math.op("Re"), y-label: math.op("Im"))

#let trig-circle(drawing, ..overrides) = plane(
	x-label: none,
	y-label: none,
	n: 1.4,
	length: 2cm,
	ticks: false,
	marks: none,
	..overrides,
	{
		cetz.draw.circle((0, 0), radius: 1)
		drawing
	},
)
