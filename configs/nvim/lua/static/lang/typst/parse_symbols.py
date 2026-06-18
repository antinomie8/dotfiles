#!/usr/bin/env python3

import urllib.request
import re


def fetch_and_parse():
	# Raw URLs for the codex definition files
	urls = {
		"sym": "https://raw.githubusercontent.com/typst/codex/main/src/modules/sym.txt",
		"emoji": "https://raw.githubusercontent.com/typst/codex/main/src/modules/emoji.txt",
	}

	symbol_entries = {}
	emoji_entries = {}

	# Known groups that should be styled as 'TypstConcealSet'
	set_keys = {"AA", "CC", "EE", "FF", "HH", "KK", "NN", "PP", "QQ", "RR", "ZZ"}

	def parse_content(content, target_dict, default_hl=None):
		prefix_stack = []
		last_base = ""

		for line in content.splitlines():
			# Strip trailing inline comments and whitespace
			line = line.split("//")[0].rstrip()
			if not line:
				continue

			# Track block contexts (e.g., "gender {", "control {")
			if line.endswith("{"):
				name = line[:-1].strip()
				prefix_stack.append(name)
				continue

			if line.strip() == "}":
				if prefix_stack:
					prefix_stack.pop()
				continue

			# Check if line is indented (indicates a modifier or sub-property)
			is_indented = line.startswith(" ") or line.startswith("\t")

			stripped_line = line.strip()
			parts = stripped_line.split(maxsplit=1)

			# If there's no character value, it's establishing a new base name
			if len(parts) == 1:
				last_base = parts[0]
				continue

			name_part, char_part = parts

			# Resolve the hierarchical name
			if is_indented and name_part.startswith("."):
				current_name = last_base + name_part
			else:
				last_base = name_part
				current_name = name_part

			# Prepend block scope if we are inside curly braces
			if prefix_stack:
				current_name = ".".join(prefix_stack) + "." + current_name

			# Clean up the output character
			# 1. Remove variation selectors like \vs{emoji} or \vs{text}
			char_part = re.sub(r"\\vs\{[^}]*\}", "", char_part)
			# 2. Convert explicit unicode blocks like \u{200D} to actual characters
			char_part = re.sub(
				r"\\u\{([0-9A-Fa-f]+)\}", lambda m: chr(int(m.group(1), 16)), char_part
			)

			# Store based on whether it's a symbol (needs dict) or emoji (needs string)
			if default_hl:
				hl = default_hl
				if current_name in set_keys:
					hl = "TypstConcealSet"
				target_dict[current_name] = {"cchar": char_part, "hl": hl}
			else:
				target_dict[current_name] = char_part

	# 1. Fetch and parse symbols
	print("Fetching sym.txt...")
	sym_req = urllib.request.urlopen(urls["sym"])
	parse_content(sym_req.read().decode("utf-8"), symbol_entries, "TypstConcealSymbol")

	# 2. Fetch and parse emojis
	print("Fetching emoji.txt...")
	emoji_req = urllib.request.urlopen(urls["emoji"])
	parse_content(emoji_req.read().decode("utf-8"), emoji_entries)

	# 3. Generate symbols.lua
	print("Generating typst_symbols.lua...")
	max_sym_len = max(len(k) for k in symbol_entries.keys())
	with open("typst_symbols.lua", "w", encoding="utf-8") as f:
		f.write("return {\n")
		for k in sorted(symbol_entries.keys()):
			v = symbol_entries[k]
			cchar = v["cchar"].replace("\\", "\\\\").replace('"', '\\"')
			padding = " " * (max_sym_len - len(k))
			f.write(
				f'\t["{k}"]{padding} = {{ cchar = "{cchar}", hl = "{v["hl"]}" }},\n'
			)
		f.write("}\n")

	# 4. Generate emojis.lua
	print("Generating emojis.lua...")
	max_emo_len = max(len(k) for k in emoji_entries.keys())
	with open("emojis.lua", "w", encoding="utf-8") as f:
		f.write("return {\n")
		for k in sorted(emoji_entries.keys()):
			char_val = emoji_entries[k].replace("\\", "\\\\").replace('"', '\\"')
			padding = " " * (max_emo_len - len(k))
			f.write(f'\t["{k}"]{padding} = "{char_val}",\n')
		f.write("}\n")

	print("Done! Both files have been generated.")


if __name__ == "__main__":
	fetch_and_parse()
