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

#import "settings.typ": *

/* -------------------------------------------------------------------------- */
/*                           Actual document content                          */
/* -------------------------------------------------------------------------- */

#show: init.with(
  title: title,
  subtitle: subtitle,
  authors-names: authors-names,
  authors-data: authors-data,
  base-font-size: 10.5pt,
)

#show: custom-style.custom-style

/* ------------------------------- Cover page ------------------------------- */

#[
  #set par(justify: false)
  
  // First cover page
  #show: cover-container.with(full-page: true)
  #set page(background: scale(270% ,box(
    image("figures/Front_page.png"),
    clip: true,
    inset: (bottom: -2em, left: -1em)
  )), margin: 1em)
  // Title, subtitle and authors
  #let title-content = cover.cover-group(
    contents: (
      cover.cover-text-block(
        cover.cover-group(
          contents: (
            // Title
            box(text(title, size: 44pt, weight: 400, fill: white), width: 100%),
            // Subtitle
            text(longtitle, size: 28pt, weight: 300, style: "italic", fill: white),
            // Authors
            text(
              cover.authors-grid(
                alignment: left,
                authors-data: (:),
                authors-names: authors-names,
                row-gutter: 0.9em,
                header: false,
              ),
              size: 24pt,
              fill: white,
            ),
          ),
          spaces: (0em, 3em, 2em, 0em),
          dir: "v",
          individual-alignments: (left, left, left),
        ),
        alignment: left,
        background-color: luma(20%, 70%),
        background-top-space: 2em,
        background-bottom-space: 2em,
        background-left-space: 100%,
        background-right-space: 2em,
      ),
    ),
    spaces: (3em, 9em),
    dir: "h",
    individual-alignments: (left,),
    general-alignment: left,
  )
  #let logos-content = cover.cover-image-block(
    cover.cover-text-block(
      cover.cover-group(
        contents: (
          image("figures/TU_Delft_logo-cropped.svg", height: 2.3cm),
          image("figures/IGN_logo-cropped.svg", height: 1.4cm),
        ),
        spaces: (3em, 8em, 3em),
        dir: "h",
        individual-alignments: (center, center + bottom),
      ),
      alignment: left,
      background-color: luma(90%, 70%),
      background-top-space: 1em,
      background-bottom-space: 100%,
      background-left-space: 1em,
      background-right-space: 1em,
    ),
  )
  #cover.cover-group(
    contents: (title-content, logos-content),
    spaces: (7em, 1fr, 0.5em),
    dir: "v",
    individual-alignments: (left, center),
  )

  #set page(background: none, margin: (top: 1cm, bottom: 0cm, x: 2cm))

  #set par(justify: false)

  #cover.cover(
    title: [#text(size: 30pt)[#title]#v(1em, weak: true)#text(
        size: 18pt,
        weight: "semibold",
        style: "italic",
        longtitle
      )#v(
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

  = Abstract
  #include "paper/abstract.typ"
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
