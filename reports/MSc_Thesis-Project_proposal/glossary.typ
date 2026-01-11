#import "@preview/glossy:0.8.0": *

#let my-theme = (
  section: (title, body) => {
    heading(level: 1, title)
    v(4em, weak: true)
    body
  },
  group: (name, index, total, body) => {
    if name != "" and total > 1 {
      v(3em, weak: true)
      align(left, text(weight: "bold", size: 1.2em, name))
      v(1em, weak: true)
      line(length: 100%, stroke: 0.5pt)
      v(1em, weak: true)
    }
    body
  },
  entry: (entry, index, total) => {
    let short-display = text(weight: "bold", entry.short)
    let long-display = if entry.long == none {
      []
    } else {
      [ (#entry.long)]
    }

    let description = if entry.description == none {
      []
    } else {
      [ — #entry.description]
    }

    set par(justify: false)
    block(
      below: 1em,
      text(
        size: 0.95em,
        {
          grid(
            columns: (6fr, 1fr),
            align: (left, right),
            gutter: 1em,
            [#short-display#long-display#description#entry.label], text(fill: rgb("#666666"), entry.pages),
          )
        },
      ),
    )
  },
)

#glossary(
  title: "Glossary",
  theme: my-theme,
  sort: false, // Optional: whether or not to sort the glossary
  ignore-case: true, // Optional: ignore case when sorting terms
  show-all: false, // Optional; Show all terms even if unreferenced
)
