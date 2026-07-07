local ls = require("utils.snippets.luasnip")
local i, s, t, c = ls.i, ls.s, ls.t, ls.c

local abbrs = {
	["SPA"] = {
		desc = "reductio ad absurdum",
		text = {
			"Supposons par l'absurde",
			"Assume for the sake of contradiction",
		},
	},
	["FTSOC"] = {
		desc = "reductio ad absurdum",
		text = "for the sake of contradiction",
	},
	["wlog"] = {
		text = {
			"without loss of generality",
			"sans perte de généralité",
		},
		uppercase = true,
	},
	["spdg"] = {
		text = {
			"sans perte de généralité",
			"without loss of generality",
		},
		uppercase = true,
	},
	["wrt"] = {
		desc = "with respect to",
		text = {
			"par rapport à",
			"with respect to",
		},
	},
	["apcr"] = {
		text = "à partir d'un certain rang",
		uppercase = true,
	},
	["mq"] = {
		text = "montrer que",
		uppercase = true,
	},
	-- ["iff"] = "if and only if",
	-- ["SSI"] = "si et seulement si"
}

local accents = {
	["à"] = "À", ["á"] = "Á", ["â"] = "Â", ["ã"] = "Ã", ["ä"] = "Ä",
	["è"] = "È", ["é"] = "É", ["ê"] = "Ê", ["ë"] = "Ë",
	["ì"] = "Ì", ["í"] = "Í", ["î"] = "Î", ["ï"] = "Ï",
	["ò"] = "Ò", ["ó"] = "Ó", ["ô"] = "Ô", ["õ"] = "Õ", ["ö"] = "Ö",
	["ù"] = "Ù", ["ú"] = "Ú", ["û"] = "Û", ["ü"] = "Ü",
	["ç"] = "Ç", ["ñ"] = "Ñ", ["ý"] = "Ý",
}

local function capitalize(str)
	if not str or str == "" then
		return str
	end

	-- Determine the byte-length of the first UTF-8 character.
	local byte1 = str:byte(1)
	local len
	if byte1 < 0x80 then
		len = 1
	elseif byte1 < 0xE0 then
		len = 2
	elseif byte1 < 0xF0 then
		len = 3
	else
		len = 4
	end

	local first = str:sub(1, len)
	local rest = str:sub(len + 1)

	return (accents[first] or first:upper()) .. rest
end

-- Build uppercase-triggered variants first, then merge them in
local uppercase_variants = {}
for trig, snip in pairs(abbrs) do
	if type(snip) == "table" and snip.uppercase then
		local new_text
		if type(snip.text) == "string" then
			new_text = capitalize(snip.text)
		elseif type(snip.text) == "table" then
			new_text = {}
			for idx, txt in ipairs(snip.text) do
				new_text[idx] = capitalize(txt)
			end
		end

		uppercase_variants[capitalize(trig)] = {
			desc = snip.desc,
			text = new_text,
		}
	end
end

for trig, snip in pairs(uppercase_variants) do
	abbrs[trig] = snip
end

return {
	setup = function(condition)
		local snippets = {}

		for trig, snip in pairs(abbrs) do
			if type(snip) == "string" then
				snip = { text = snip }
			end

			if type(snip.text) == "string" then
				table.insert(snippets,
					s(
						{
							trig = trig .. " ",
							dscr = snip.desc or snip.text,
							snippetType = "autosnippet",
							condition = condition,
						},
						t(snip.text .. " ")
					)
				)
			elseif type(snip.text) == "table" then
				local choices = {}
				for _, text in ipairs(snip.text) do
					table.insert(choices, { t(text .. " "), i(1) })
				end
				table.insert(snippets,
					s(
						{
							trig = trig .. " ",
							dscr = snip.desc or snip.text[1],
							snippetType = "autosnippet",
							condition = condition,
						},
						c(1, choices)
					)
				)
			end
		end

		return snippets
	end,
}
