#import "@local/magic-isprs:0.1.0": isprs


// Glossary
#import "@preview/glossy:0.9.0": *
#import "../glossary/glossary-terms.typ": glossaryTerms
#show: init-glossary.with(glossaryTerms)

// #import "@preview/wordometer:0.1.5": total-words, word-count
// #show: word-count.with(exclude: (<no-wc>, heading))
// #[The paper contains #total-words words, excluding this sentence and headings!] <no-wc>

// Theme
#show: isprs.with(
  title: [From Points to Prints: Generating Building Roofprints and Footprints from Airborne LiDAR Data and Initial Outlines],
  abstract: include "abstract.typ",
  authors: (
    (
      name: "Alexandre Bry",
      institutions: ("lastig", "tudelft"),
      email: "alexandre.bry@ign.fr",
    ),
    (
      name: "Bruno Vallet",
      institutions: "lastig",
      email: "bruno.vallet@ign.fr",
    ),
    (
      name: "Hugo Ledoux",
      institutions: "tudelft",
      email: "h.ledoux@tudelft.nl",
    ),
  ),
  institutions: (
    lastig: (
      name: "LASTIG, Université Gustave Eiffel, IGN",
      location: [Champs-sur-Marne, France],
      email-suffix: "@ign.fr",
    ),
    tudelft: (
      name: "3D Geoinformation Group, Delft University of Technology (TUD)",
      location: [Delft, Netherlands],
      email-suffix: "@tudelft.nl",
    ),
  ),
  keywords: (
    "Building roofprints",
    "Building footprints",
    "Airborne LiDAR",
    "Roof overhangs",
  ),
  acknowledgements: none,
  bibliography: bibliography("MSc_Thesis-Bibliography.yaml"),
  appendix: none,
  anonymous: false,
)

#include "introduction.typ"

#include "related_work.typ"

#include "methodology.typ"

#include "results.typ"

#include "discussion.typ"

#include "conclusions.typ"

