// The book is compiled from the project root
#import "/_extensions/nenuial/lddr-book/lddr-book.typ": *

#let lddr-fr = "$lang$".starts-with("fr")
// banner of the contents, preface and appendices (glossary, references, index)
#let lddr-default-image = $if(chapter-image)$image("$chapter-image$")$else$none$endif$

// Fira Sans Light, bold = Regular: the same choice as the LaTeX version
#set text(font: "Fira Sans", weight: "light")
#show strong: set text(weight: "regular")
#show math.equation: set text(font: "Fira Math", weight: "light")

// Figures and tables float to the top or bottom of the page, as in LaTeX, so that the text
// keeps flowing instead of leaving a blank at the bottom of the page before a large figure
#show figure.where(kind: "quarto-float-fig"): set figure(placement: auto)
#show figure.where(kind: "quarto-float-tbl"): set figure(placement: auto)

// Table cells are not justified (narrow columns would get large gaps between the words)
#show table.cell: set par(justify: false)

// Definition lists (the glossary): the term in the LDDR blue, the definition indented below it
// (replaces Quarto's rule, which pulls the definition up so that it overlaps the term)
#set terms(tight: false, spacing: 1em)
#show terms.item: it => block(breakable: false)[
  #text(weight: "regular", fill: lddr-main)[#it.term]
  #block(above: 0.4em, inset: (left: 1.5em))[#it.description]
]

// The bibliography goes in the References chapter, which has the heading
#set bibliography(title: none)
// French typography in the bibliography, which Typst writes after the filters (french-spaces.lua does
// the text): no line break before ; : ! ? » or after «
#show bibliography: it => if lddr-fr {
  show regex("\\s[;:!?»]"): m => "\u{a0}" + m.text.trim()
  show regex("«\\s"): "«\u{a0}"
  it
} else { it }

// Definitions and examples: redefined with the LDDR look (Quarto's default has an italic body)
#import "@preview/theorion:0.4.1": make-frame
#let (definition-counter, definition-box, definition, show-definition) = make-frame(
  "definition", text(weight: "regular")[#if lddr-fr [Définition] else [Definition]],
  inherited-levels: theorem-inherited-levels, numbering: theorem-numbering, render: lddr-theorem-render)
#show: show-definition
#let (example-counter, example-box, example, show-example) = make-frame(
  "example", text(weight: "regular")[#if lddr-fr [Exemple] else [Example]],
  inherited-levels: theorem-inherited-levels, numbering: theorem-numbering, render: lddr-theorem-render)
#show: show-example

#show: book.with(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  author: "$for(by-author)$$it.name.literal$$sep$, $endfor$",
$endif$
$if(date)$
  date: "$date$",
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
  paper-size: "a4",
  margin: (x: 3cm, top: 3cm, bottom: 3cm),
  main-color: lddr-main,
  title-page: lddr-title-page(
$if(title)$
    title: [$title$],
$endif$
$if(subtitle)$
    subtitle: [$subtitle$],
$endif$
$if(logo)$
    logo: image("$logo$"),
$endif$
$if(cover-background)$
    background: image("$cover-background$"),
$endif$
  ),
  image-index: lddr-default-image,
$if(toc-depth)$
  outline-depth: $toc-depth$,
$else$
  outline-depth: 2,
$endif$
$if(lof)$
  list-of-figure-title: if lddr-fr { "Liste des figures" } else { "List of Figures" },
$endif$
$if(lot)$
  list-of-table-title: if lddr-fr { "Liste des tableaux" } else { "List of Tables" },
$endif$
  supplement-chapter: if lddr-fr { "Chapitre" } else { "Chapter" },
  supplement-part: if lddr-fr { "Partie" } else { "Part" },
  // the back of the title page: the licence (variable set by a filter, e.g. GeoBook's badges)
  copyright: $if(lddr-copyright)$[$lddr-copyright$]$else$none$endif$,
)

$if(margin-geometry)$
// Configure marginalia page geometry for book context
// Geometry computed by Quarto's meta.lua filter (typstGeometryFromPaperWidth)
// IMPORTANT: This must come AFTER book.with() to override the book format's margin settings
#import "@preview/marginalia:0.3.1" as marginalia

#show: marginalia.setup.with(
  inner: (
    far: $margin-geometry.inner.far$,
    width: $margin-geometry.inner.width$,
    sep: $margin-geometry.inner.separation$,
  ),
  outer: (
    far: $margin-geometry.outer.far$,
    width: $margin-geometry.outer.width$,
    sep: $margin-geometry.outer.separation$,
  ),
  top: $if(margin.top)$$margin.top$$else$1.25in$endif$,
  bottom: $if(margin.bottom)$$margin.bottom$$else$1.25in$endif$,
  // CRITICAL: Enable book mode for recto/verso awareness
  book: true,
  clearance: $margin-geometry.clearance$,
)
$endif$
