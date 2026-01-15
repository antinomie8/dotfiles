#let fonts = (
  text: ("Libertinus Serif", "Noto Serif CJK TC", "Noto Color Emoji"),
  sans: ("Noto Sans", "Noto Sans CJK TC", "Noto Color Emoji"),
  mono: "Inconsolata",
)

#let colors = (
  title: eastern,
  headers: rgb("#bf0040"),
  partfill: rgb("#002299"),
  label: red,
  hyperlink: blue,
  strong: rgb("#000055"),
  env: (
    theorems: (
      accent: rgb("#5787a0"),
      stroke: rgb("#0000ff"),
      fill: rgb("#f1f9fa"),
    ),
    examples: (
      accent: rgb("#964108"),
      stroke: rgb("#964108") + 0.5pt,
      fill: rgb("#fcf8f8"),
    ),
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
    "toc": "Table des matières",
  ),
  "en": (
    "theorem": "Theorem",
    "corollary": "Corollary",
    "lemma": "Lemma",
    "proof": "Proof",
    "proposition": "Proposition",
    "notation": "Notation",
    "exercise": "Exercise",
    "example": "Example",
    "remark": "Remark",
    "solution": "Solution",
    "conjecture": "Conjecture",
    "problem": "Problem",
    "toc": "Table of contents",
  ),
)
#let get_env_name(env) = {
  return context env_names.at(text.lang).at(env)
}
