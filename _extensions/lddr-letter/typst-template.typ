#let letter(
  authors: none,
  position: none,
  date: none,
  logo: none,
  nref: none,
  subject: none,
  subsubject: none,
  title: none,
  first: none,
  last: none,
  class: none,
  address: none,
  location: none,
  cc: none,
  margin: (top: 2cm, bottom: 3.5cm),
  paper: "a4",
  lang: "fr",
  region: "CH",
  font: (),
  fontsize: 10pt,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    footer: [
      #v(1cm)
      #line(length: 100%, stroke: .5pt)
      #align(center)[
        #set text(size: 7pt)
        #v(-.2cm)
        #upper[
          #grid(columns: 5, column-gutter: 1cm,
          [CH-2002 Neuchâtel],
          [Rue Breguet 3],
          [Case Postale 1],
          [Tél. 032 717 50 00],
          [Site internet : #lower[#link("https://www.lddr.ch")[www.lddr.ch]]]
          )
        ]
      ]
    ],
  )
  set par(justify: true)
  show par: set block(spacing: 1.5em)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)

  place(
    top + left,
    block(
      image(logo, width: 5cm),
    )
  )
  
  place(
    top + left,
    dy: 2.5cm,
    grid(columns: 2, column-gutter: .5cm,
    [
      #box(width: 9cm)[
      #set text(size: 8pt)
      #upper[*Département de la formation,\
            des finances et de la digitalisation*\
            LYCÉE DENIS-DE-ROUGEMONT]
      #v(1cm)
      #set text(size: 7pt)
      N/REF. : #nref  
    ]],
    [
      #v(1cm)
      #if(title != none) [#title\ ]
      #first #last\
      #address\
      #location
    ]
    )
  )
  
  place(
    bottom + left,
    dy: 1cm,
    [#cc]
  )
  
  v(7cm)
  h(9.5cm)
  [Neuchâtel, le #date]
  
  v(1cm)
  [*#subject
   #if(subsubject != none) [\ #subsubject]*
   #v(-.2cm)
   #line(length: 100%)]
  
  doc
  
  v(2cm)
  grid(columns: 2, column-gutter: .5cm,
  [#h(9cm)],
  [
    #align(center)[
      #for author in authors [
        #author.name
        #if("affiliation" in author.keys()) [
        \ #author.affiliation
        ]
      ]
    ]
  ])
}
