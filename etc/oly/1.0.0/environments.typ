#import "@preview/shadowed:0.2.0": shadowed

#import "definitions.typ": *
#import "theorems.typ": *

// environments
#let callout(
  breakable: true,
  headless: false,
  header-inset: 0.5em,
  width: auto,
  stroke-width: 3pt,
  border-radius: 0pt,
  border-width: 0pt,
  content-inset: 1em,
  header-color: rgb("#000000"),
  header-text-color: rgb("#ffffff"),
  accent-color: rgb("#000000"),
  body-color: rgb("#f6f8f9"),
  clip-content: false,
  shadow: false,
  shadow-offset: 0.4em,
  title: none,
  icon: none,
  content,
) = context {
  let stroke-color = accent-color
  let border-color = accent-color

  let header_block = block(
    sticky: true,
    below: 0pt,
    fill: header-color,
    width: 100%,
    radius: (
      top-right: border-radius,
      top-left: if (stroke-width == 0pt) { border-radius } else { 0pt },
    ),
    inset: header-inset,
  )[
    #if icon == none {
      text(fill: header-text-color, weight: "bold", title)
    } else {
      grid(
        columns: (auto, auto),
        align: (horizon, left + horizon),
        gutter: 1em,
        box(height: 1em)[ #icon ], text(fill: header-text-color, weight: "bold", title),
      )
    }
  ]

  let content_block(content) = block(
    breakable: breakable,
    width: 100%,
    fill: body-color,
    inset: content-inset,
    radius: (
      top-right: if (title != none) { 0pt } else { border-radius },
      top-left: if (title != none or stroke-width != 0pt) { 0pt } else {
        border-radius
      },
      bottom-left: if (stroke-width == 0pt) { border-radius } else { 0pt },
      bottom-right: border-radius,
    ),
    above: 0pt,
  )[#content]

  let callout = block(
    breakable: breakable,
    width: width,
    radius: (
      right: border-radius,
      left: if (stroke-width == 0pt) {
        border-radius
      } else { 0pt },
    ),
    stroke: (
      left: if (stroke-width == 0pt) {
        border-width + border-color
      } else { (thickness: stroke-width, paint: stroke-color, cap: "butt") },
      top: if (title != none) { border-width + header-color } else {
        border-width + border-color
      },
      rest: border-width + border-color,
    ),
    clip: clip-content,
  )[
    #set align(start)
    #if (not headless and title != none) { header_block }
    #content_block(content)
  ]

  if shadow {
    return shadowed(
      radius: border-radius,
      shadow: 0pt,
      dx: shadow-offset,
      dy: shadow-offset,
      callout,
    )
  } else {
    return callout
  }
}

#let thm_plain(
  env_name,
  linebreak: false,
  style: "normal",
  box: false,
  display-title: false,
  ..calloutargs,
) = thmenv(
  "environment",
  "heading",
  none,
  (
    name,
    number,
    body,
    color: black,
    linebreak: linebreak,
    style: style,
    box: box,
    display-title: display-title,
    ..additional_calloutargs,
  ) => [
    #if display-title {
      callout(
        ..calloutargs,
        ..additional_calloutargs,
        title: get_env_name(env_name)
          + if number != none {
            " " + number
          }
          + if type(name) == str or type(name) == content {
            " (" + name + ")"
          },
        body,
      )
    } else {
      let header = [
        #{
          text(
            weight: "bold",
            style: style,
            fill: color,
            get_env_name(env_name),
          )
          if number != none {
            text(weight: "bold", style: style, fill: color, " " + number)
          }
          if type(name) == str or type(name) == content {
            text(style: style, fill: color, " (" + name + ")")
          }
          if linebreak {
            [\ ]
          } else {
            text(weight: "bold", style: style, fill: color, ": ")
          }
        }
      ]
      if box {
        callout(
          ..calloutargs,
          ..additional_calloutargs,
          header + body,
        )
      } else {
        header + body
      }
    }
  ],
)
#let thm_box(
  env_name,
  ..thmboxargs,
  accent: color.black,
  linebreak: false,
) = thmbox(
  "environment",
  get_env_name(env_name),
  // base = if (counter(heading).get().at(1)) { "heading" } else { none },
  titlefmt: (content, delta: none) => context {
    text(weight: "bold", fill: accent, content)
  },
  namefmt: content => text(
    fill: accent,
    "(" + content + ")",
  ),
  separator: text(
    weight: "bold",
    fill: accent,
    if (linebreak) { [\ ] } else { [:] },
  ),
  breakable: true,
  ..thmboxargs,
)

#let thm_numbering(..args) = {
  if (args.at(2, default: none) == none and args.at(0) == 0) {
    return args.at(1)
  } else {
    return numbering("1.1", ..args)
  }
}

#let proof = thmproof("proof", get_env_name("proof"))
#let solution = thmproof("solution", get_env_name("solution"))

#let definition = thm_plain("definition").with(numbering: thm_numbering)
#let notation = thm_plain("notation").with(numbering: thm_numbering)
#let lemma = thm_plain("lemma", style: "italic").with(numbering: thm_numbering)
#let conjecture = thm_plain("conjecture", style: "italic").with(numbering: thm_numbering)
#let remark = thm_plain("remark", box: true, body-color: rgb("#f6f8f9")).with(
  numbering: thm_numbering,
)
#let exercise = thm_plain("exercise", box: true, body-color: rgb("#f6f8f9")).with(
  numbering: thm_numbering,
)
#let question = thm_plain("question", box: true, body-color: rgb("#f6f8f9")).with(
  numbering: thm_numbering,
)
#let problem = thm_plain(
  "problem",
  display-title: true,
  box: true,
  border-radius: 6pt,
  stroke-width: 0pt,
  border-width: 0.7pt,
  body-color: rgb("#f2ecf5"),
  header-color: rgb("#5c5477"),
  shadow: true,
).with(numbering: thm_numbering)
#let theorem = thm_box("theorem", linebreak: true, ..colors.env.theorems).with(
  numbering: thm_numbering,
)
#let corollary = thm_box("corollary", fill: rgb("#e8e8f8")).with(numbering: thm_numbering)
#let proposition = thm_box("proposition", fill: rgb("#e8e8f8")).with(numbering: thm_numbering)
#let example = thm_box("example", ..colors.env.examples).with(numbering: thm_numbering)

#let _definition = thm_plain("definition").with(numbering: none)
#let _notation = thm_plain("notation").with(numbering: none)
#let _lemma = thm_plain("lemma", style: "italic").with(numbering: none)
#let _conjecture = thm_plain("conjecture", style: "italic").with(numbering: none)
#let _remark = thm_plain("remark", box: true, body-color: rgb("#f6f8f9")).with(numbering: none)
#let _exercise = thm_plain("exercise", box: true, body-color: rgb("#f6f8f9")).with(numbering: none)
#let _question = thm_plain("question", box: true, body-color: rgb("#f6f8f9")).with(numbering: none)
#let _problem = thm_plain(
  "problem",
  box: true,
  display-title: true,
  border-radius: 6pt,
  stroke-width: 0pt,
  border-width: 0.7pt,
  body-color: rgb("#f2ecf5"),
  header-color: rgb("#5c5477"),
  shadow: true,
).with(number: none)
#let _theorem = thm_box("theorem", linebreak: true, ..colors.env.theorems).with(numbering: none)
#let _corollary = thm_box("corollary", fill: rgb("#e8e8f8")).with(numbering: none)
#let _proposition = thm_box("proposition", fill: rgb("#e8e8f8")).with(numbering: none)
#let _example = thm_box("example", ..colors.env.examples).with(numbering: none)

#let eqn(it) = {
  set math.equation(numbering: "(1)")
  it
}
