// LDDR book: orange-book (vendored in orange-book/) with the LDDR cover, fonts and index.
// Used by typst-show.typ; the Lua filter lddr-book.lua turns \index{} and \chapterimage{}
// of the sources into lddr-index-mark() and update-heading-image().
#import "orange-book/lib.typ": book, part, chapter, appendices, update-heading-image

#let lddr-blue = rgb(36, 32, 75)
#let lddr-main = rgb("#0F2D61")

/* ---------------- Cover ---------------- */

// Same layout as the LaTeX cover (lddr-book/before-body.tex): picture at the bottom right,
// a dark band rising to the top right corner with the title along it, logo at the top left.
// logo and background are image() calls made by the document, so that paths are its own.
#let lddr-title-page(title: none, subtitle: none, logo: none, background: none) = {
  set text(fill: black)
  if background != none {
    place(bottom + right, box(height: 20cm, {
      set image(height: 20cm)
      background
    }))
  }
  // the band: corners as in the TikZ original (page centre ± 6 cm / 4 cm on the left)
  place(top + left, polygon(
    fill: lddr-blue,
    (0cm, 18.85cm), (0cm, 8.85cm), (21cm, 0cm), (21cm, 10cm),
  ))
  if logo != none {
    place(top + left, dx: 1.5cm, dy: 1.5cm, box(width: 5cm, {
      set image(width: 5cm)
      logo
    }))
  }
  // title and subtitle centred on the band, 5 cm below the middle of its upper edge
  place(top + left, dy: 7.4cm, box(width: 21cm, height: 4cm,
    align(center + horizon, rotate(-22.85deg, reflow: true, block(width: 18cm, {
      set align(center)
      set par(justify: false, leading: 0.6em)
      text(fill: white, size: 26pt, weight: "regular", upper(title))
      if subtitle != none {
        v(14pt)
        text(fill: white, size: 21pt, weight: "regular", subtitle)
      }
    })))))
}

/* ---------------- Definitions and examples ---------------- */

// "Definition 4.1 (Title). Body", body upright and left-aligned (orange-book centres figures)
#let lddr-theorem-render(prefix: none, title: "", full-title: auto, body) = block(width: 100%, {
  set align(left)
  if full-title != "" and full-title != auto and full-title != none {
    text(weight: "regular", fill: lddr-main)[#full-title.]
    h(0.5em)
  }
  body
})

/* ---------------- Index ---------------- */

// One index entry, from \index{sort@Display!sub|see{other}}:
//   entry: array of (sort, display) pairs, one per level; see: none or a string
#let lddr-index-mark(entry, see: none) = [#metadata((entry: entry, see: see)) <lddr-index>]

#let lddr-make-index(title: "Index", see-text: "see", color: lddr-main) = {
  heading(level: 1, numbering: none, title)
  context {
    // key of a path: sort strings, lowercase, joined with a separator that sorts first
    let key-of = path => path.map(p => lower(p.at(0))).join("\u{1}")
    let items = (:)
    for m in query(<lddr-index>) {
      let path = m.value.entry
      // the parents of a sub-entry are entries too, even without their own pages
      for n in range(1, path.len() + 1) {
        let k = key-of(path.slice(0, n))
        if k not in items {
          items.insert(k, (level: n - 1, display: path.at(n - 1).at(1), pages: (), see: none))
        }
      }
      let k = key-of(path)
      let item = items.at(k)
      if m.value.see != none {
        item.see = m.value.see
      } else {
        let loc = m.location()
        let num = counter(page).at(loc).first()
        if item.pages.all(p => p.num != num) {
          item.pages.push((num: num, loc: loc))
        }
      }
      items.insert(k, item)
    }

    set par(first-line-indent: 0em, justify: false, spacing: 0.45em)
    set text(size: 0.9em)
    columns(2, gutter: 1cm, {
      let letter = none
      for k in items.keys().sorted() {
        let item = items.at(k)
        let first = upper(k.clusters().first())
        if item.level == 0 and first != letter {
          letter = first
          v(1em, weak: true)
          block(width: 100%, fill: color.lighten(80%), inset: 4pt,
            align(center, text(size: 1.1em, weight: "regular", fill: color, letter)))
          v(0.6em, weak: true)
        }
        let pages = item.pages.map(p => link(p.loc, str(p.num))).join(", ")
        block(inset: (left: item.level * 1.2em), {
          item.display
          if pages != none { [, #pages] }
          if item.see != none { [, #emph(see-text) #item.see] }
        })
      }
    })
  }
}
