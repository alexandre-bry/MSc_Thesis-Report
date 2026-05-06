#import "../other-tools/styled-blocks.typ": block-discussion, block-todo
#import "glossary/glossary-terms.typ": gloss-ref-and-footnote, gloss-url
#import "@local/magic-isprs:0.1.0": isprs-heading

// Comments
#import "@preview/drafting:0.2.2": inline-note, margin-note
#let review(body, color: blue) = {
  set text(size: 8pt, style: "italic")
  inline-note(stroke: color, par-break: false, body)
}
#let review-alexandre(body) = { review(body, color: blue) }
#let review-bruno(body) = { review(body, color: orange) }
#let review-hugo(body) = { review(body, color: green) }
