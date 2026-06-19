#let derivative(f, n: 1) = {
	if n == 1 {
		x => {
			let epsilon = 0.001
			(f(x + epsilon) - f(x - epsilon)) / (2 * epsilon)
		}
	} else {
		derivative(derivative(f), n: n - 1)
	}
}

#let local_extremum(f, ..args) = {
	import "@preview/epsilon:0.1.0": bisection
	bisection(derivative(f), ..args)
}

#let inflexion_point(f, ..args) = {
	import "@preview/epsilon:0.1.0": bisection
	bisection(derivative(f, n: 2), ..args)
}

#let tangent(f, a) = { x => derivative(f)(a) * (x - a) + f(a) }
