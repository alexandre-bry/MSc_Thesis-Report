#import "../template/template-long.typ": (
  appendix-container, cover-container, init, main-content-container, post-content-container, pre-content-container,
)
#import "../template/cover.typ"

#import "../other-tools/custom-style.typ"

#import "@preview/numbly:0.1.0": *

// Glossary
#import "@preview/glossy:0.9.0": *
#import "glossary/glossary-terms.typ": glossaryTerms
#show: init-glossary.with(glossaryTerms)


/* -------------------------------------------------------------------------- */
/*                 Define some parameters used multiple times                 */
/* -------------------------------------------------------------------------- */

/* ---------------------------- Document settings --------------------------- */
#let title = "From Points to Prints"
#let subtitle = "Final MSc Thesis Report"
#let authors-names = "Alexandre Bry"
#let authors-data = ("Student number": "6277535", "Student email": "abry@tudelft.nl")

/* -------------------------------------------------------------------------- */
/*                           Actual document content                          */
/* -------------------------------------------------------------------------- */

#show: init.with(
  title: title,
  subtitle: subtitle,
  authors-names: authors-names,
  authors-data: authors-data,
)

#show: custom-style.custom-style

/* ------------------------------- Cover page ------------------------------- */

#[
  #show: cover-container.with(full-page: true)

  #set page(background: none, margin: (top: 1cm, bottom: 0cm, x: 2cm))

  #set par(justify: false)

  #cover.cover(
    title: [#text(size: 30pt)[#title]#v(1em, weak: true)#text(
        size: 18pt,
        weight: "semibold",
        style: "italic",
      )[Generation of building @roofprint:pl:noindex and @footprint:pl:noindex from @als:short:noindex point clouds]#v(
        1em,
      )],
    subtitle: text(size: 22pt)[#subtitle],
    authors-names: authors-names,
    authors-data: authors-data,
    full-page: true,
    date: datetime(day: 5, month: 6, year: 2026),
    other-content: text(size: 14pt)[
      #grid(
        columns: 2,
        align: (right, left),
        row-gutter: 1em,
        column-gutter: 0.5em,
        stroke: none,
        [1#super[st] @tudelft:short:noindex supervisor:], [Hugo Ledoux],
        [2#super[nd] @tudelft:short:noindex supervisor:], [Ravi Peters],
        [@ign:short:noindex supervisor:], [Bruno Vallet],
      )

      #v(5em)

      #text(
        style: "italic",
      )[
        This work is licensed under the Creative Commons Attribution 4.0 International License (CC BY 4.0).
        To view a copy of the license, visit #link("https://creativecommons.org/licenses/by/4.0/").
      ]
    ],
  )
]

#[
  #show: pre-content-container.with()

  #include "content/acknowledgements.typ"
  #include "content/outline.typ"
]

/* ------------------------------ Main content ------------------------------ */

#[
  #show: main-content-container.with()
  #include "content/introduction.typ"
  #include "content/preliminary_materials.typ"
  #include "content/paper.typ"
  #include "content/conclusion.typ"
]

/* ---------------------- Parts after the main content ---------------------- */

#[
  #show: post-content-container.with()

  #include "bibliography.typ"
]

#[
  #show: appendix-container.with(
    heading-numbering: numbly(..(
      "{1:A}.",
      "{1:A}.{2:1}.",
      "{1:A}.{2:1}.{3:a}.",
      none,
      none,
      none,
    )),
    heading-supplement: (
      none,
      none,
      none,
      none,
      none,
      none,
    ),
    special-h1-heading: false,
  )
  #include "content/use_of_ai.typ"
  #include "content/reproducibility.typ"
  #include "glossary/glossary-style.typ"
]
