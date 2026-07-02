#let fonts = (
	text: ("New Computer Modern", "Noto Color Emoji"),
	sans: ("Noto Sans", "Noto Color Emoji"),
	mono: ("JetBrainsMono NF", "DejaVu Sans Mono"),
	math: ("New Computer Modern Math", "Noto Color Emoji"),
)

#let colors = (
	headers: rgb("#bf0040"),
	label: rgb("#7f0000"),
	hyperlink: blue,
	strong: rgb("#000055"),
	toc: (
		title: rgb("#008a55"),
		entries: rgb("#00007f"),
	),
	env: (
		theorem: (
			accent: rgb("#5787a0"),
			stroke: rgb("#0000ff"),
			fill: rgb("#f1f9fa"),
		),
		example: (
			accent: rgb("#964108"),
			stroke: rgb("#964108") + 0.5pt,
			fill: rgb("#fcf8f8"),
		),
		problem: (
			body-color: rgb("#f2ecf5"),
			header-color: rgb("#5c5477"),
		),
		reformulation: (accent-color: rgb("#8839ee")),
		lemma: (accent-color: rgb("#008a55")),
		exercise: (accent-color: rgb("#00007f")),
		algorithm: (accent-color: rgb("#00bfa5")),
		vocab: (fill: rgb("#0000ff")),
		plain: (accent-color: rgb("#000066")),
	),
)

// language
#let env_names = (
	"fr": (
		"theorem": "Théorème",
		"corollary": "Corollaire",
		"lemma": "Lemme",
		"proof": "Preuve",
		"proposition": "Proposition",
		"definition": "Définition",
		"notation": "Notation",
		"exercise": "Exercice",
		"example": "Exemple",
		"remark": "Remarque",
		"solution": "Solution",
		"conjecture": "Conjecture",
		"problem": "Problème",
		"algorithm": "Algorithme",
		"reformulation": "Reformulation",
		"properties": "Propriétés",
		"toc": "Table des matières",
	),
	"en": (
		"theorem": "Theorem",
		"corollary": "Corollary",
		"lemma": "Lemma",
		"proof": "Proof",
		"proposition": "Proposition",
		"definition": "Definition",
		"notation": "Notation",
		"exercise": "Exercise",
		"example": "Example",
		"remark": "Remark",
		"solution": "Solution",
		"conjecture": "Conjecture",
		"problem": "Problem",
		"algorithm": "Algorithm",
		"reformulation": "Reformulation",
		"properties": "Properties",
		"toc": "Table of contents",
	),
)
#let get_env_name(env) = {
	return context env_names
		.at(text.lang, default: env_names.at("en"))
		.at(env, default: upper(env.at(0)) + env.slice(1)) // capitalize first letter
}

#let months = (
	"en": (
		"January": "January",
		"February": "February",
		"March": "March",
		"April": "April",
		"May": "May",
		"June": "June",
		"July": "July",
		"August": "August",
		"September": "September",
		"October": "October",
		"November": "November",
		"December": "December",
	),
	"fr": (
		"January": "Janvier",
		"February": "Février",
		"March": "Mars",
		"April": "Avril",
		"May": "Mai",
		"June": "Juin",
		"July": "Juillet",
		"August": "Août",
		"September": "Septembre",
		"October": "Octobre",
		"November": "Novembre",
		"December": "Décembre",
	),
)
