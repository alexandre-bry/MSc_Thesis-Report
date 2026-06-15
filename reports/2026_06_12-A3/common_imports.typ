#import "../other-tools/styled-blocks.typ": block-discussion, block-todo
#import "glossary/glossary-terms.typ": gloss-ref-and-footnote, gloss-url
#import "@preview/magic-isprs:0.1.0": isprs-heading
#import "@preview/drafting:0.2.2": inline-note, margin-note, set-margin-note-defaults
#import "@preview/lovelace:0.3.1": pseudocode-list
#import "@preview/algorithmic:1.0.7"
#import "@preview/lilaq:0.6.0" as lq
#import "@preview/cetz:0.5.1"
#import "@preview/subpar:0.2.2"

#let HIDE-ALL = sys.inputs.at("hide-comments", default: "false") == "true"

#let block-todo = block-todo.with(render: not HIDE-ALL)
#let block-discussion = block-discussion.with(render: not HIDE-ALL)

#let review(body, color: blue) = {
  set text(style: "italic")
  inline-note(stroke: color + 2pt, par-break: false, hidden: HIDE-ALL, body)
}
#let review-alexandre(body) = { review(body, color: blue) }
#let review-bruno(body) = { review(body, color: orange) }
#let review-hugo(body) = { review(body, color: green) }
#let review-florent(body) = { review(body, color: red) }
#let review-elodie(body) = { review(body, color: purple) }
#let review-ravi(body) = { review(body, color: yellow) }

#let citen = cite.with(form: "normal")
#let citep = cite.with(form: "prose")

#let lod-version(v) = { [@lod#h(0em)#v] }
