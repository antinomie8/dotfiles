// plotting
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"

#import "/drawing/canvas.typ": canvas as cetz-canvas

#let graph(
	preset: "default",
	length: 1cm,
	scale: 1,
	axes: (:),
	style: (:),
	canvas: true,
	..args,
) = {
	let canvas-content = {
		let presets = (
			"default": (
				axis: (mark: (end: "curved-stealth", fill: black, scale: 0.8)),
				axis-style: "school-book",
				x-tick-step: none,
				y-tick-step: none,
				x-max: 7.4,
				x-min: -2,
				y-max: 3.4,
				y-min: -2.3,
			),
			"complex-plane": (
				axis: (
					mark: (start: "triangle", end: "triangle", fill: black),
					overshoot: 0,
					padding: 1 / 2,
					tick: (label: ("show": false)),
				),
				axis-style: "school-book",
				x-tick-step: 1,
				y-tick-step: 1,
				x-max: 5,
				x-min: -5,
				y-max: 5,
				y-min: -5,
				x-label: $"Re"$,
				y-label: $"Im"$,
				y-format: x => if (x == 1) { $i$ } else if (x == -1) { $-i$ } else { $#x i$ },
			),
		)
		let preset = presets.at(preset)
		let get = key => args.at(key, default: preset.at(key))

		let axis = preset.at("axis")
		let mark = axis.at("mark")
		let shared-zero = get("x-tick-step") != none and get("y-tick-step") != none
		cetz.draw.set-style(
			axes: (
				x: (mark: mark),
				y: (mark: mark),
				shared-zero: shared-zero,
				stroke: .05em,
				..axis,
			),
			..style,
		)
		cetz.draw.set-style(axes: axes)

		let size = (scale * (get("x-max") - get("x-min")), scale * (get("y-max") - get("y-min")))
		cetz-plot.plot.plot(
			size: size,
			..preset,
			..args,
		)
	}

	if canvas {
		cetz-canvas(length: length, canvas-content)
	} else {
		canvas-content
	}
}
