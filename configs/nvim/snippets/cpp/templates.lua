local ls = require("snippets.luasnip")
local s, i, fmt = ls.s, ls.i, ls.fmt
local helpers = require("snippets.helpers")
local line_begin, first_line = helpers.line_begin, helpers.first_line
local not_in_string_comment = helpers.not_in_string_comment

return {
	s(
		{
			trig = "tmp",
			dscr = "CP template",
			snippetType = "autosnippet",
			condition = first_line * not_in_string_comment,
			hidden = true,
		},
		fmt(
			[[
				#include <<bits/stdc++.h>>
				using namespace std;

				#ifdef LOCAL
				#include "dbg.hpp"
				#else
				#define n(...) 42
				#define id(...) 42
				#define dbg(...) 42
				#define line(...) 42
				#define dbgarr(...) 42
				#define dbg_var(...) 42
				#endif
				
				///////////////////////////////////
				
				
				
				///////////////////////////////////
				
				int main() {
					ios::sync_with_stdio(false);
					cin.tie(nullptr);
					<>
				}
			]],
			{
				i(0),
			}
		)
	),
	s(
		{
			trig = "cf",
			dscr = "Codeforces template",
			snippetType = "autosnippet",
			condition = first_line * not_in_string_comment,
			hidden = true,
		},
		fmt(
			[[
				#include <<bits/stdc++.h>>
				using namespace std;
				
				#ifdef LOCAL
				#include "dbg.hpp"
				#else
				#define n(...) 42
				#define id(...) 42
				#define dbg(...) 42
				#define line(...) 42
				#define dbgarr(...) 42
				#define dbg_var(...) 42
				#endif
				
				///////////////////////////////////
				
				void solve() {
					<>
				}
				
				///////////////////////////////////
				
				int main() {
					ios::sync_with_stdio(false);
					cin.tie(nullptr);
					int nbTests;
					cin >>>> nbTests;
					while (nbTests--){
						solve();
					}
				}
			]],
			{
				i(0),
			}
		)
	),
	s(
		{
			trig = "io ",
			dscr = "input/output from file",
			snippetType = "autosnippet",
			condition = line_begin * not_in_string_comment,
			hidden = true,
		},
		fmt(
			[[
				void setIO(std::string name = "<>") {
					if ( name != "" ) {
						std::freopen((name + ".in").c_str(), "r", stdin);
						std::freopen((name + ".out").c_str(), "w", stdout);
					}
				}
			]],
			{
				i(1),
			}
		)
	),
}
