#import "../template/template-long.typ": (
  appendix-container, cover-container, init, main-content-container, post-content-container, pre-content-container,
)
#import "../template/cover.typ"

#import "../other-tools/custom-style.typ"


// Glossary
#import "@preview/glossy:0.8.0": *
#import "glossary-definition.typ": glossaryTerms
#show: init-glossary.with(glossaryTerms)



/* -------------------------------------------------------------------------- */
/*                 Define some parameters used multiple times                 */
/* -------------------------------------------------------------------------- */

/* ---------------------------- Document settings --------------------------- */
#let title = "From Points to Prints"
#let subtitle = "Project Proposal"
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
    title: text(size: 30pt)[#title],
    subtitle: text(size: 20pt)[#subtitle],
    authors-names: authors-names,
    authors-data: authors-data,
    full-page: true,
    date: datetime.today(),
    other-content: text(size: 14pt)[
      #grid(
        columns: 2,
        align: (right, left),
        row-gutter: 1em,
        column-gutter: 0.5em,
        stroke: none,
        [@ign:short supervisor:], [Bruno Vallet],
        [1st @tudelft:short supervisor:], [Hugo Ledoux],
        [2nd @tudelft:short supervisor:], [Ravi Peters],
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

/* ------------------------------ Main content ------------------------------ */

#[
  #show: main-content-container.with(h1-new-page: false)
  #include "content.typ"
]

/* ---------------------- Parts after the main content ---------------------- */

#[
  #show: post-content-container.with()
  #include "bibliography.typ"
  #include "glossary.typ"
]
