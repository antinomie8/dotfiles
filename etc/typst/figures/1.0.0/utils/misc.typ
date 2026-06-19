#let board-examples(
	n, // content
	f, // color function: (x, y) => boolean
	..args,
	cell-size: 2em,
	spacing: 2em,
	position: top,
) = {
	let board(k) = {
		return figure(
			table(
				columns: k * (cell-size,),
				rows: k * (cell-size,),
				align: center,
				stroke: 1pt,
				fill: (x, y) => if f(x, y) { gray } else { white },
			),
			numbering: none,
			caption: figure.caption(
				position: position,
			)[$#n = #k$],
		)
	}
	let arr = ()
	for i in args.pos() {
		arr.push(board(i))
	}
	figure(
		grid(
			columns: args.pos().len(),
			gutter: spacing,
			..arr,
		),
	)
}
