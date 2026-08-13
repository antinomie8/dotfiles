#import "@preview/cetz-plot:0.1.4"
#import cetz-plot.plot: *

#import "drawing.typ": label as plot-label

#let add(..args, label: none) = (
	(kind: "plot", args: args, label: label),
)

#let add-fill-between(..args, label: none) = (
	(kind: "fill-between", args: args, label: label),
)

#let line-palette = (rgb("#0000FF"), rgb("#9500ff"))
#let fill-palette = (blue.lighten(40%), red.lighten(25%))

#let stroke-color(style) = {
	let s = style.at("stroke", default: none)
	if type(s) == color { s } else if type(s) == stroke { s.paint } else {
		luma(0%)
	}
}

#let plot(..plot-args, specs) = {
	let line-cnt = 0
	let fill-cnt = 0

	cetz-plot.plot.plot(..plot-args, {
		for spec in specs {
			let kind = spec.at("kind", default: none)

			if kind == "plot" {
				let named = spec.args.named()
				let explicit-style = named.at("style", default: none)

				let (style, color) = if explicit-style != none {
					(explicit-style, stroke-color(explicit-style))
				} else {
					let c = line-palette.at(calc.rem(line-cnt, line-palette.len()))
					((stroke: 0.05em + c), c)
				}
				line-cnt += 1

				cetz-plot.plot.add(..spec.args.pos(), ..named + (style: style))

				if spec.label != none {
					let fn = spec.args.pos().last()
					plot-label(
						(spec.label.x, fn(spec.label.x)),
						text(
							fill: color,
							spec.label.content,
						),
						anchor: spec.label.at("anchor", default: none),
						padding: spec.label.at("padding", default: none),
						angle: spec.label.at("angle", default: 0deg),
					)
				}
			} else if kind == "fill-between" {
				let named = spec.args.named()
				let explicit-style = named.at("style", default: none)

				let style = if explicit-style != none {
					explicit-style
				} else {
					(
						fill: fill-palette.at(calc.rem(fill-cnt, fill-palette.len())),
						stroke: none,
					)
				}
				fill-cnt += 1

				cetz-plot.plot.add-fill-between(
					..spec.args.pos(),
					..named + (style: style),
				)
			} else {
				// passthrough
				(spec,)
			}
		}
	})
}
