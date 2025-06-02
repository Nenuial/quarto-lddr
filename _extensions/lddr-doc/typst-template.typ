#import "@preview/chic-hdr:0.5.0": *

#let document(
  title: none,
  subtitle: none,
  sign: none,
  margin: (left: 1.5cm, right: 1.5cm),
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
