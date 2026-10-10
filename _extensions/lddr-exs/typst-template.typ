#import "@preview/chic-hdr:0.5.0": *

#let document(
  title: none,
  subtitle: none,
  sign: none,
  margin: (left: 1.5cm, right: 1.5cm, top: 2.5cm, bottom: 2cm),
  paper: "a4",
  lang: "fr",
  region: "CH",
  font: "Fira Sans",
  mathfont: "Fira Math",
  codefont: "Fira Code",
  fontsize: 10pt,
  logo: none,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1/1"
  )
  set par(justify: true, spacing: 1.5em)
  show table: set par(justify: false)
  show math.equation: set text(weight: 100, font: mathfont)
  show raw: set text(font: codefont)
  show strong: set text(weight: 100)
  show heading: set text(weight: 400)
  set text(lang: lang,
           weight: "light",
           region: region,
           font: font,
           size: fontsize)
  
  show: chic.with(
    chic-footer(
      left-side: [#sign/#datetime.today().display("[year]")],
      right-side: [#chic-page-number()/#context(counter(page).final().last())]
    ),
    chic-header(
      left-side: image(logo, width: 2cm),
    ),
    chic-separator(.5pt),
    chic-offset(7pt),
    chic-height(on: "header", 2.5cm),
    chic-height(on: "footer", 1.5cm)
  )
  
  if(title != none) {
    set text(24pt)
    align(center, {
      strong(smallcaps(title))
      if(subtitle != none) {
        set text(fontsize + 2pt)
        linebreak()
        v(-1cm)
        strong(smallcaps(subtitle))
      }
    })
  }
  
  doc
}

// Exercise layout, used by the Typst filter of lddr-solution
// (exercises-typst.lua): numbered questions and parts, answer space.
#let lddr-indent-width = 1.8em
#let lddr-question-counter = counter("lddr-question")
#let lddr-part-counter = counter("lddr-part")
#let lddr-saved-number = state("lddr-saved-number", 0)

#let lddr-questions-start() = lddr-question-counter.update(0)
#let lddr-parts-start() = lddr-part-counter.update(0)
#let lddr-save-number() = context lddr-saved-number.update(lddr-question-counter.get().first())
#let lddr-restore-number() = context lddr-question-counter.update(lddr-saved-number.get())

#let lddr-item(number, body) = grid(
  columns: (lddr-indent-width, 1fr),
  number,
  body,
)

#let lddr-question(body) = {
  lddr-question-counter.step()
  lddr-item(context lddr-question-counter.display("1."), body)
}

#let lddr-part(body) = {
  lddr-part-counter.step()
  lddr-item(context lddr-part-counter.display("(a)"), body)
}

#let lddr-indent(body) = pad(left: lddr-indent-width, body)

// Ruled lines filling the given height (exam's \fillwithlines)
#let lddr-answer-lines(height, spacing: 0.8cm) = block(
  width: 100%,
  height: height,
  breakable: false,
  for i in range(1, calc.floor(height / spacing) + 1) {
    place(top, dy: i * spacing, line(length: 100%, stroke: 0.5pt))
  },
)

// Empty framed box of the given height (exam's solutionorbox)
#let lddr-answer-box(height) = block(
  width: 100%,
  height: height,
  breakable: false,
  stroke: 0.5pt,
)
