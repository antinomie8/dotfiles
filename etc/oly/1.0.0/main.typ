#import "definitions.typ": *
#import "environments.typ": *

#let toc = {
  show outline.entry.where(level: 1): it => {
    v(1.2em, weak: true)
    strong(it)
  }
  text(weight: "bold", fill: colors.title, size: 1.4em, font: fonts.sans, get_env_name("toc"))
  v(0.6em)
  outline(
    title: none,
    indent: 2em,
  )
}

// symbols
#let iff = sym.arrow.l.r.double.long
#let pm = sym.plus.minus
#let mp = sym.minus.plus
#let int = sym.integral
#let oint = sym.integral.cont
#let iint = sym.integral.double
#let oiint = sym.integral.surf
#let iiint = sym.integral.triple
#let oiiint = sym.integral.vol

#let pgcd = math.op("pgcd")
#let ppcm = math.op("ppcm")
#let ord = math.op("ord")

#let pmod(x) = $space (mod #x)$
#let dbbracket(lhs, rhs) = {
  if type(lhs) == array {
    lhs = lhs.join()
  }
  if type(rhs) == array {
    rhs = rhs.join()
  }
  math.lr[$⟦ lhs ; rhs ⟧$]
}
#let proj(point) = {
  math.attach([$=$], t: [$#point$])
}

// commands
#let boxed(x) = rect(
  stroke: 0.5pt,
  inset: 6pt,
  text(x),
)
#let vocab(x) = text(weight: "bold", fill: rgb("#0000ff"), x)
#let bf(x) = $bold(upright(#x))$
#let scr(it) = text(
  features: ("ss01",),
  $cal(it)$,
)
#let hrule = box(width: 100%, align(center)[#line(length: 100%, stroke: 0.6pt)])
#let Box = {
  h(1fr)
  text(size: 1.4em, $square$)
}

// main setup
#let setup(
  document_title: none,
  author: none,
  date: none,
  maketitle: true,
  body,
) = {
  set document(title: {
    align(center, text(
      size: 1em,
      weight: "bold",
      font: fonts.sans,
      document_title,
    ))
  })
  set document(author: author)
  set page(
    paper: "a4",
    margin: auto,
    header: context {
      set text(size: 0.8em)
      set align(left)
      text(style: "normal", author)
      h(0.2em)
      sym.dash.em
      h(0.2em)
      text(style: "italic", date)
      h(1fr)
      text(weight: "bold", document_title)
      box(width: 100%, align(center)[#line(length: 100%, stroke: 0.7pt)])
    },
    numbering: "1",
  )
  set par(
    justify: true,
  )
  set text(
    font: "New Computer Modern",
    size: 11pt,
    fallback: false,
  )

  // Section headers
  let heading_numbering(..nums) = {
    let (section, ..subsections) = nums.pos()
    if subsections.len() == 0 {
      numbering("I", section)
    } else {
      numbering("1", subsections.at(subsections.len() - 1))
    }
  }
  set heading(numbering: heading_numbering)
  show heading: it => {
    block([
      #if (it.numbering != none) [
        #text(
          fill: colors.headers,
          counter(heading).display(),
        )
        #h(0.1em)
      ]
      #it.body
      #v(0.4em)
    ])
  }
  show heading: set text(font: fonts.sans, size: 11pt)
  show heading.where(level: 1): set text(size: 14pt)
  show heading.where(level: 2): set text(size: 12pt)

  // Colorize hyperlinks
  show link: it => {
    set text(fill: if (type(it.dest) == label) { colors.label } else {
      colors.hyperlink
    })
    it
  }
  show ref: it => {
    link(it.target, it)
  }

  // Change quote display
  set quote(block: true)
  show quote: set pad(x: 2em, y: 0em)
  show quote: it => {
    set text(style: "italic")
    v(-1em)
    it
    v(-0.5em)
  }

  // Indent lists
  set enum(indent: 1em)
  set list(indent: 1em)

  // Allow math blocks to break across pages
  show math.equation: set block(breakable: true)

  // package settings
  show: thmrules.with(qed-symbol: $square$)

  show title: it => {
    set align(center)
    it
  }
  if (maketitle and type(document_title) == str) {
    title()
  }

  body
}
