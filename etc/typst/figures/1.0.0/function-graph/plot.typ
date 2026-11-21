#import "@preview/cetz-plot:0.1.4"
#import cetz-plot.plot: *

#import "drawing.typ": label as plot-label

/// Add data to a plot environment.
///
/// Note: You can use this for scatter plots by setting
///       the stroke style to `none`: `add(..., style: (stroke: none))`.
///
/// Must be called from the body of a `plot(..)` command.
///
/// - domain (domain): Domain of `data`, if `data` is a function. Has no effect
///                    if `data` is not a function.
/// - hypograph (bool): Fill hypograph; uses the `hypograph` style key for
///                     drawing
/// - epigraph (bool): Fill epigraph; uses the `epigraph` style key for
///                    drawing
/// - fill (bool): Fill the shape of the plot
/// - fill-type (string): Fill type:
///   / `"axis"`: Fill the shape to y = 0
///   / `"shape"`: Fill the complete shape
/// - samples (int): Number of times the `data` function gets called for
///   sampling y-values. Only used if `data` is of type function. This parameter gets
///   passed onto `sample-fn`.
/// - sample-at (array): Array of x-values the function gets sampled at in addition
///   to the default sampling. This parameter gets passed to `sample-fn`.
/// - line (string, dictionary): Line type to use. The following types are
///   supported:
///   / `"raw"`: Plot raw data
///   / `"linear"`: Linearize data
///   / `"spline"`: Calculate a Catmull-Rom curve through all points
///   / `"vh"`: Move vertical and then horizontal
///   / `"hv"`: Move horizontal and then vertical
///   / `"hvh"`: Add a vertical step in the middle
///
///   If the value is a dictionary, the type must be
///   supplied via the `type` key. The following extra
///   attributes are supported:
///   / `"samples" <int>`: Samples of splines
///   / `"tension" <float>`: Tension of splines
///   / `"mid" <float>`: Mid-Point of hvh lines (0 to 1)
///   / `"epsilon" <float>`: Linearization slope epsilon for
///      use with `"linear"`, defaults to 0.
///
///   ```cexample-vertical
///   let points(offset: 0) = ((0,0), (1,1), (2,0), (3,1), (4,0)).map(((x,y)) => {
///     (x,y + offset * 1.5)
///   })
///   plot.plot(size: (12, 3), axis-style: none, {
///     plot.add(points(offset: 5), line: (type: "hvh", mid: .1))
///     plot.add(points(offset: 4), line: "hvh")
///     plot.add(points(offset: 3), line: "hv")
///     plot.add(points(offset: 2), line: "vh")
///     plot.add(points(offset: 1), line: "spline")
///     plot.add(points(offset: 0), line: "linear")
///   })
///   ```
///
/// - style (style): Style to use, can be used with a `palette` function
/// - axes (axes): Name of the axes to use for plotting. Reversing the axes
///   means rotating the plot by 90 degrees.
/// - mark (string): Mark symbol to place at each distinct value of the
///   graph. Uses the `mark` style key of `style` for drawing:
///
///   ```cexample-vertical
///   let points(offset) = ((offset, 0), (offset, 1))
///
///   plot.plot(size: (12, 2), axis-style: none, {
///     plot.add(points(0), mark: "*")  // same as "x"
///     plot.add(points(1), mark: "square")
///     plot.add(points(2), mark: "triangle")
///     plot.add(points(3), mark: "o")
///     plot.add(points(4), mark: "+")
///     plot.add(points(5), mark: "-")
///     plot.add(points(6), mark: "|")
///     plot.add(points(7), mark: "<>")
///     plot.add(points(8), mark: 5)  // specify an integer to use a regular polygon.
///
///     // Alternatively, specify custom function:
///     plot.add(points(9), mark: (pt, size, style) => {
///       let top = (to: pt, rel: (0, size))
///       let bot = (to: pt, rel: (0, -size))
///       let left = (to: pt, rel: (-size/2, 0))
///       let right = (to: pt, rel: (size/2, 0))
///       cetz.draw.line(top, left, bot, right, close: true, ..style)
///     })
///    })
///   ```
///
///
/// - mark-size (float): Mark size in canvas units
/// - data (array,function): Array of 2D data points (numeric) or a function
///   of the form `x => y`, where `x` is a value in `domain`
///   and `y` must be numeric or a 2D vector (for parametric functions).
///   ```cexample
///   plot.plot(size: (2, 2), axis-style: none, {
///     // Using an array of points:
///     plot.add(((0,0), (calc.pi/2,1),
///                    (1.5*calc.pi,-1), (2*calc.pi,0)))
///     // Sampling a function:
///     plot.add(domain: (0, 2*calc.pi), calc.sin)
///   })
///   ```
/// - label (none,content): Legend label to show for this plot.
#let add(..args, label: none) = (
	(kind: "plot", args: args, label: label),
)

/// Fill the area between two graphs. This behaves same as `add` but takes
/// a pair of data instead of a single data array/function.
/// The area between both function plots gets filled. For a more detailed
/// explanation of the arguments, see add().
///
/// This can be used to display an error-band of a function.
///
/// ```cexample
/// plot.plot(size: (2,2), x-tick-step: none, y-tick-step: none, {
///   plot.add-fill-between(domain: (0, 2*calc.pi),
///     calc.sin, // First function/data
///     calc.cos) // Second function/data
/// })
/// ```
///
/// - domain (domain): Domain of both `data-a` and `data-b`. The domain is used for
///   sampling functions only and has no effect on data arrays.
/// - samples (int): Number of times the `data-a` and `data-b` function gets called for
///   sampling y-values. Only used if `data-a` or `data-b` is of
///   type function.
/// - sample-at (array): Array of x-values the function(s) get sampled at in addition
///   to the default sampling.
/// - line (string, dictionary): Line type to use, see add().
/// - style (style): Style to use, can be used with a palette function.
/// - label (none,content): Legend label to show for this plot.
/// - axes (array): Name of the axes to use for plotting.
/// - data-a (array,function): Data of the first plot, see add().
/// - data-b (array,function): Data of the second plot, see add().
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

/// Create a plot environment. Data to be plotted is given by passing it to the
/// `plot.add` or other plotting functions. The plot environment supports different
/// axis styles to draw, see its parameter `axis-style:`.
///
/// ```cexample
/// plot.plot(size: (2,2), x-tick-step: none, y-tick-step: none, {
///   plot.add(((0,0), (1,1), (2,.5), (4,3)))
/// })
/// ```
///
/// To draw elements insides a plot, using the plots coordinate system, use
/// the `plot.annotate(..)` function.
///
/// === Options
///
/// You can use the following options to customize each axis of the plot. You must pass them as named arguments prefixed by the axis name followed by a dash (`-`) they should target. Example: `x-min: 0`, `y-ticks: (..)` or `x2-label: [..]`.
///
/// #show-parameter-block("label", ("none", "content"), default: "none", [
///   The axis' label. If and where the label is drawn depends on the `axis-style`.])
/// #show-parameter-block("min", ("auto", "float"), default: "auto", [
///   Axis lower domain value. If this is set greater than than `max`, the axis' direction is swapped])
/// #show-parameter-block("max", ("auto", "float"), default: "auto", [
///   Axis upper domain value. If this is set to a lower value than `min`, the axis' direction is swapped])
/// #show-parameter-block("equal", ("string"), default: "none", [
///   Set the axis domain to keep a fixed aspect ratio by multiplying the other axis domain by the plots aspect ratio,
///   depending on the other axis orientation (see `horizontal`).
///   This can be useful to force one axis to grow or shrink with another one.
///   You can only "lock" two axes of different orientations.
///   ```cexample
///   plot.plot(size: (2,1), x-tick-step: 1, y-tick-step: 1,
///             x-equal: "y",
///   {
///     plot.add(domain: (0, 2 * calc.pi),
///       t => (calc.cos(t), calc.sin(t)))
///   })
///   ```
/// ])
/// #show-parameter-block("horizontal", ("bool"), default: "axis name dependant", [
///   If true, the axis is considered an axis that gets drawn horizontally, vertically otherwise.
///   The default value depends on the axis name on axis creation. Axes which name start with `x` have this
///   set to `true`, all others have it set to `false`. Each plot has to use one horizontal and one
///   vertical axis for plotting, a combination of two y-axes will panic: ("y", "y2").
/// ])
/// #show-parameter-block("tick-step", ("none", "auto", "float"), default: "auto", [
///   The increment between tick marks on the axis. If set to `auto`, an
///   increment is determined. When set to `none`, incrementing tick marks are disabled.])
/// #show-parameter-block("minor-tick-step", ("none", "float"), default: "none", [
///   Like `tick-step`, but for minor tick marks. In contrast to ticks, minor ticks do not have labels.])
/// #show-parameter-block("ticks", ("none", "array"), default: "none", [
///   A List of custom tick marks to additionally draw along the axis. They can be passed as
///   an array of `<float>` values or an array of `(<float>, <content>)` tuples for
///   setting custom tick mark labels per mark.
///
///   ```cexample
///   plot.plot(x-tick-step: none, y-tick-step: none,
///             x-min: 0, x-max: 4,
///             x-ticks: (1, 2, 3),
///             y-min: 1, y-max: 2,
///             y-ticks: ((1, [One]), (2, [Two])),
///   {
///     plot.add(((0,0),))
///   })
///   ```
///
///   Examples: `(1, 2, 3)` or `((1, [One]), (2, [Two]), (3, [Three]))`])
/// #show-parameter-block("format", ("none", "string", "function"), default: "float", [
///   How to format the tick label: You can give a function that takes a `<float>` and return
///   `<content>` to use as the tick label. You can also give one of the predefined options:
///   / float: Floating point formatting rounded to two digits after the point (see `decimals`)
///   / sci: Scientific formatting with $times 10^n$ used as exponet syntax
///
///   ```cexample
///   let formatter(v) = if v != 0 {$ #{v/calc.pi} pi $} else {$ 0 $}
///   plot.plot(x-tick-step: calc.pi, y-tick-step: none,
///             x-min: 0, x-max: 2 * calc.pi,
///             x-format: formatter,
///   {
///     plot.add(((0,0),))
///   })
///   ```
/// ])
/// #show-parameter-block("decimals", ("int"), default: "2", [
///   Number of decimals digits to display for tick labels, if the format is set
///   to `"float"`.
/// ])
/// #show-parameter-block("mode", ("none", "string"), default: "none", [
///   The scaling function of the axis. Takes `lin` (default) for linear scaling,
///   and `log` for logarithmic scaling.])
/// #show-parameter-block("base", ("none", "number"), default: "none", [
///   The base to be used when labeling axis ticks in logarithmic scaling])
/// #show-parameter-block("grid", ("bool", "string"), default: "false", [
///   If `true` or `"major"`, show grid lines for all major ticks. If set
///   to `"minor"`, show grid lines for minor ticks only.
///   The value `"both"` enables grid lines for both, major- and minor ticks.
///
///   ```cexample
///   plot.plot(x-tick-step: 1, y-tick-step: 1,
///             y-minor-tick-step: .2,
///             x-min: 0, x-max: 2, x-grid: true,
///             y-min: 0, y-max: 2, y-grid: "both", {
///     plot.add(((0,0),))
///   })
///   ```
/// ])
/// #show-parameter-block("break", ("bool"), default: "false", [
///   If true, add a "sawtooth" at the start or end of the axis line, depending
///   on the axis bounds. If the axis min. value is > 0, a sawtooth is added
///   to the start of the axes, if the axis max. value is < 0, a sawtooth is added
///   to its end.])
///
/// - body (body): Calls of `plot.add` or `plot.add-*` commands. Note that normal drawing
///   commands like `line` or `rect` are not allowed inside the plots body, instead wrap
///   them in `plot.annotate`, which lets you select the axes used for drawing.
/// - size (array): Plot size tuple of `(<width>, <height>)` in canvas units.
///   This is the plots inner plotting size without axes and labels.
/// - axis-style (none, string): How the axes should be styled:
///   / scientific: Frames plot area using a rectangle and draw axes `x` (bottom), `y` (left), `x2` (top), and `y2` (right) around it.
///     If `x2` or `y2` are unset, they mirror their opposing axis.
///   / scientific-auto: Draw set (used) axes `x` (bottom), `y` (left), `x2` (top) and `y2` (right) around
///     the plotting area, forming a rect if all axes are in use or a L-shape if only `x` and `y` are in use.
///   / school-book: Draw axes `x` (horizontal) and `y` (vertical) as arrows pointing to the right/top with both crossing at $(0, 0)$
///   / left: Draw axes `x` and `y` as arrows, while the y axis stays on the left (at `x.min`)
///               and the x axis at the bottom (at `y.min`)
///   / `none`: Draw no axes (and no ticks).
///
///   ```cexample-vertical
///   let opts = (x-tick-step: none, y-tick-step: none, size: (2,1))
///   let data = plot.add(((-1,-1), (1,1),), mark: "o")
///
///   for name in (none, "school-book", "left", "scientific") {
///     plot.plot(axis-style: name, ..opts, data, name: "plot")
///     content(((0,-1), "-|", "plot.south"), repr(name))
///     set-origin((3.5,0))
///   }
///   ```
/// - plot-style (style,function): Styling to use for drawing plot graphs.
///   This style gets inherited by all plots and supports `palette` functions.
///   The following style keys are supported:
///   #show-parameter-block("stroke", ("none", "stroke"), default: 1pt, [
///     Stroke style to use for stroking the graph.
///   ])
///   #show-parameter-block("fill", ("none", "paint"), default: none, [
///     Paint to use for filled graphs. Note that not all graphs may support filling and
///     that you may have to enable filling per graph, see `plot.add(fill: ..)`.
///   ])
/// - mark-style (style,function): Styling to use for drawing plot marks.
///   This style gets inherited by all plots and supports `palette` functions.
///   The following style keys are supported:
///   #show-parameter-block("stroke", ("none", "stroke"), default: 1pt, [
///     Stroke style to use for stroking the mark.
///   ])
///   #show-parameter-block("fill", ("none", "paint"), default: none, [
///     Paint to use for filling marks.
///   ])
/// - fill-below (bool): If true, the filled shape of plots is drawn _below_ axes.
/// - name (string): The plots element name to be used when referring to anchors
/// - legend (none, auto, coordinate): The position the legend will be drawn at. See plot-legends for information about legends. If set to `<auto>`, the legend's "default-placement" styling will be used. If set to a `<coordinate>`, it will be taken as relative to the plot's origin.
/// - legend-anchor (auto, string): Anchor of the legend group to use as its origin.
///   If set to `auto` and `lengend` is one of the predefined legend anchors, the
///   opposite anchor to `legend` gets used.
/// - legend-style (style): Style key-value overwrites for the legend style with style root `legend`.
/// - ..options (any): Axis options, see _options_ below.
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
						padding: spec.label.at("padding", default: 0.13),
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
