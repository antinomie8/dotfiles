pen thickp = linewidth(0.8);
pen thinp = linewidth(0.3);

// geometry
import geometry;
pair foot(pair P, pair A, pair B) {
	return foot(triangle(A, B, P).VC);
}
pair foot(pair P, line l) {
	return intersectionpoint(perpendicular(P, l), l);
}
pair midpoint(pair A, pair B) {
	return (A + B) / 2;
}
pair centroid(pair A, pair B, pair C) {
	return (A + B + C) / 3;
}
line ray(pair A, pair B) {
	return line(A, false, B);
}
point intersect(line l1, line l2) {
	return intersectionpoint(l1, l2);
}
real dist(pair A, pair B) {
	return abs(A - B);
}
transform reflect(point O) {
	return scale(-1, O);
}
point reflect(point A, point O) {
	return scale(-1, 0) * A;
}
circle circletangentat(line l, point T, point X) {
	point center = intersectionpoint(perpendicular(T, l), bisector(segment(T, X)));
	return circle(center, abs(center - T));
}
segment chord(line l, circle C) {
	pair[] inter = intersectionpoints(l, C);
	assert(inter.length == 2);
	pair X = inter[0], Y = inter[1];
	return segment(X, Y);
}
line bisector(pair A, pair B, pair C, int angle = 0) {
	return bisector(line(A, B), line(B, C), angle);
}
line extbisector(pair A, pair B, pair C) {
	return bisector(line(A, B), line(B, C), 90);
}
pair intersect(pair A, pair B, conic C) {
	pair[] inter = intersectionpoints(line(A, B), C);
	assert(inter.length > 0);
	if (inter.length == 1) {
		return inter[0];
	}
	if (abs(inter[0] - A) < 10e-9 || abs(inter[0] - B) < 10e-9) {
		return inter[1];
	} else {
		return inter[0];
	}
}

// recalibrate fill and filldraw for conics
void filldraw(picture pic = currentpicture, conic g, pen fillpen = defaultpen,
              pen drawpen = defaultpen) {
	filldraw(pic, (path)g, fillpen, drawpen);
}
void fill(picture pic = currentpicture, conic g, pen p = defaultpen) {
	filldraw(pic, (path)g, p);
}

// use default size of 5 for markrightangle
void markrightangle(picture pic = currentpicture, point A, point O, point B,
                    real size = 5, pen p = currentpen, margin margin = NoMargin,
                    filltype filltype = NoFill) {
	pair Ap = A, Bp = B, Op = O;
	pair dir = Ap - Op;
	real a1 = degrees(dir);
	pair align = rotate(-a1) * dir(Op--Ap, Op--Bp);
	perpendicularmark(pic = pic, z = O, align = align, dir = dir, size = size, p = p,
	                  margin = margin, filltype = filltype);
}
