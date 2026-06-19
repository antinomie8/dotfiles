#let interpolate(..points) = {
	let n = points.pos().len()

	x => {
		let sum = 0
		for i in range(0, n) {
			let (xi, yi) = points.at(i)
			let term = yi
			for j in range(0, n) {
				if i != j {
					let (xj, _) = points.at(j)
					term *= (x - xj) / (xi - xj)
				}
			}
			sum += term
		}
		sum
	}
}

#let preset = (
	linear: x => 0.5 * x,
	affine: x => 0.7 * x - 1,
	quadratic: x => 0.4 * calc.pow(x - 3.2, 2) - 1.2,
	cubic: x => 0.2 * calc.pow(x - 2, 3) - 0.6 * calc.pow(x - 1.3, 2) + 1.1,
)
