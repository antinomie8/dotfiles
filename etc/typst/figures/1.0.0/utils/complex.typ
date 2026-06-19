/// Returns the real part of a complex number.
/// - Z (complex): A complex number.
/// -> float
#let re(Z) = if type(Z) == float or type(Z) == int { Z } else { Z.at(0) }
// #let re(Z) = Z.at(0)

/// Returns the real part of a complex number as a complex number.
/// - Z (complex): A complex number.
/// -> complex
#let Re(Z) = (Z.at(0), 0)

/// Returns the imaginary part of a complex number.
/// - Z (complex): A complex number.
/// -> float
#let im(Z) = if type(Z) == float or type(Z) == int { 0 } else { Z.at(1) }
// #let im(Z) = Z.at(1)

/// Returns the imaginary part of a complex number as a complex number.
/// - Z (complex): A complex number.
/// -> complex
#let Im(Z) = (0, Z.at(1))

/// Multiplies two complex numbers together and returns the result $Z W$.
/// - Z (complex): The complex number on the left hand side.
/// - W (complex): The complex number on the right hand side.
#let mul(Z, W) = (re(Z) * re(W) - im(Z) * im(W), im(Z) * re(W) + re(Z) * im(W))

/// Calculates the conjugate of a complex number.
/// - Z (complex): A complex number.
/// -> complex
#let conj(Z) = (re(Z), -im(Z))

/// Calculates the dot product of two complex numbers $Z \cdot W$.
/// - Z (complex): The complex number on the left hand side.
/// - W (complex): The complex number on the right hand side.
/// -> float
#let dot(Z, W) = re(mul(Z, conj(W)))

/// Calculates the squared norm of a complex number.
/// - Z (complex): The complex number.
/// -> float
#let normsq(Z) = dot(Z, Z)

/// Calculates the norm of a complex number
/// - Z (complex): The complex number.
/// -> float
#let norm(Z) = calc.sqrt(normsq(Z))

// /// Multiplies a complex number by a scale factor.
// /// - Z (complex): The complex number to scale.
// /// - t (float): The scale factor.
// /// -> complex
// #let scale(Z, t) = mul(Z, (t, 0))

/// Returns a unit vector in the direction of a complex number.
/// - Z (complex): The complex number.
/// -> vector
#let unit(Z) = mul(Z, 1 / norm(Z))

/// Inverts a complex number.
/// - Z (complex): The complex number
/// -> complex
#let inv(Z) = mul(conj(Z), 1 / normsq(Z))

/// Divides two complex numbers.
/// - Z (complex): The complex number of the numerator.
/// - W (complex): The complex number of the denominator.
/// -> complex
#let div(Z, W) = mul(Z, inv(W))

/// Adds two complex numbers together.
/// - Z (complex): The complex number on the left hand side.
/// - W (complex): The complex number on the right hand side.
/// -> complex
#let add(Z, W) = (re(Z) + re(W), im(Z) + im(W))

/// Subtracts two complex numbers together.
/// - Z (complex): The complex number on the left hand side.
/// - W (complex): The complex number on the right hand side.
/// -> complex
#let sub(Z, W) = (re(Z) - re(W), im(Z) - im(W))

/// Calculates the argument of a complex number.
/// - Z (complex): The complex number.
#let arg(Z) = calc.atan2(..Z) / 1rad

/// Get the signed angle of two complex numbers from Z to W.
/// - Z (complex): A complex number.
/// - W (complex): A complex number.
#let ang(Z, W) = arg(div(W, Z))

/// Returns e^(i theta)
/// - theta (float): the argument of the desired complex number
#let expi(theta) = (calc.cos(theta), calc.sin(theta))

// Rotate by angle theta
#let rot(v, theta) = mul(v, expi(theta))
