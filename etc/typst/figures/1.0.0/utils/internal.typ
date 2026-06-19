#let argparse(signatures, args) = {
	let ret = (:)
	for (cat, _) in signatures {
		ret.insert(cat, (:))
	}
	ret.insert("default", (:))

	for (key, value) in args.named() {
		let found = false
		for (cat, arg-strings) in signatures {
			if arg-strings.contains(key) {
				ret.at(cat).insert(key, value)
				found = true
				break
			}
		}
		if not found {
			ret.default.insert(key, value)
		}
	}

	return ret
}
