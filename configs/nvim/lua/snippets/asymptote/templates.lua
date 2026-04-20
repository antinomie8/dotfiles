local ls = require("utils.snippets.luasnip")
local s, t, i = ls.s, ls.t, ls.i

return {
	s(
		{
			trig = "ABC",
			dscr = "triangle ABC",
		},
		{
			t({
				[[pair A = dir(110);]],
				[[pair B = dir(210);]],
				[[pair C = dir(330);]],
				[[triangle t = triangle(A, B, C);]],
				"",
				"",
			}),
			i(1),
			t({
				"",
				"",
				[[draw(A--B--C--cycle, largep);]],
				"",
				[[dot("$A$", A, dir(A));]],
				[[dot("$B$", B, dir(B));]],
				[[dot("$C$", C, dir(C));]],
			}),
		}
	),
	s(
		{
			trig = "orthABC",
			dscr = "H orthocenter of ABC",
		},
		{
			t({
				[[pair HA = foot(A, B, C);]],
				[[pair HB = foot(B, C, A);]],
				[[pair HC = foot(C, A, B);]],
				[[pair H = orthocenter(A, B, C);]],
				"",
				[[draw(A--HA);]],
				[[draw(B--HB);]],
				[[draw(C--HC);]],
				"",
				[[markrightangle(A, HA, C);]],
				[[markrightangle(B, HB, A);]],
				[[markrightangle(C, HC, B);]],
				"",
				[[dot("$H$", H, dir(H));]],
				"",
			}),
		}
	),
	s(
		{
			trig = "circumABC",
			dscr = "Omega circumcircle of ABC",
		},
		{
			t({
				[[circle Omega = circumcircle(A, B, C);]],
				[[draw(Omega);]],
				"",
			}),
		}
	),
	s(
		{
			trig = "incircleABC",
			dscr = "omega incircle of ABC",
		},
		{
			t({
				[[circle omega = incircle(A, B, C);]],
				[[draw(omega);]],
				"",
			}),
		}
	),
	s(
		{
			trig = "ABCD",
			dscr = "quadrilateral ABCD",
		},
		{
			t({
				[[pair A = (-0.61, 1.11);]],
				[[pair B = (-1.41, -0.3);]],
				[[pair C = (-0.17, -0.8);]],
				[[pair C = (-0.17, -0.8);]],
				[[pair D = (0.79, -0.01)]],
				"",
				"",
			}),
			i(1),
			t({
				"",
				"",
				[[draw(A--B--C--D--cycle, largep);]],
				"",
				[[dot("$A$", A, dir(A));]],
				[[dot("$B$", B, dir(B));]],
				[[dot("$C$", C, dir(C));]],
				[[dot("$D$", D, dir(D));]],
			}),
		}
	),
}
