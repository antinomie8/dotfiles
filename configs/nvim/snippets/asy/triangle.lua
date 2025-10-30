local ls = require("snippets.luasnip")
local s, t, i  = ls.s, ls.t, ls.i
local helpers = require("snippets.helpers")

return {
	s(
		{
			trig = "triangle",
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
				[[draw(A--B--C--cycle);]],
				"",
				[[dot("$A$", A, dir(A));]],
				[[dot("$B$", B, dir(B));]],
				[[dot("$C$", C, dir(C));]],
			})
		}
	),
	s(
		{
			trig = "orthocenter",
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
			})
		}
	),
	s(
		{
			trig = "circumcircle",
			dscr = "Omega circumcircle of ABC",
		},
		{
			t({
				[[circle Omega = circumcircle(A, B, C);]],
				[[draw(Omega);]],
				"",
			})
		}
	),
	s(
		{
			trig = "incircle",
			dscr = "omega incircle of ABC",
		},
		{
			t({
				[[circle omega = incircle(A, B, C);]],
				[[draw(omega);]],
				"",
			})
		}
	),
}
