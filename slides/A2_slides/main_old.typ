#import "@preview/touying:0.6.3": *
#import themes.university: *
// #import themes.dewdrop: *
#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.4.1": *
#import cosmos.clouds: *
#show: show-theorion

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: university-theme.with(
  aspect-ratio: "16-9",
  align: horizon,
  // config-common(handout: true),
  config-common(frozen-counters: (theorem-counter,)),
  config-info(
    title: [From Points to Prints],
    subtitle: [Monthly Presentation (2)],
    author: [Alexandre Bry],
    date: datetime(day: 16, month: 3, year: 2026),
    institution: [IGN],
    logo: image("../../images/IGN_logo.svg"),
  ),
)

#set heading(numbering: numbly("{1}.", default: "1.1"))

#set text(font: "Overpass")

#title-slide()

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em, depth: 1))

= Context

== Goal

#image("../../diagrams/Overview_of_pipeline.drawio.png")

= Work done until now

== Point cloud topology

- Define the different elements of the point cloud:
  - Flight axes
  - Scan lines
- Explain how these elements are identified
- Explain how to

==

= Next objectives
