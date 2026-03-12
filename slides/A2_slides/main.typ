#import "@preview/calmly-touying:0.2.0": *
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/subpar:0.2.2"

#import "illustrations.typ": *

#let colortheme = "paper"
#let variant = "light"

#show: calmly.with(
  config-info(
    title: [From Points to Prints],
    subtitle: [Monthly Presentation (2)],
    author: [Alexandre Bry],
    date: datetime(day: 16, month: 3, year: 2026),
    institution: [IGN],
    logo: image("../../images/IGN_logo.svg"),
  ),
  config-common(show-notes-on-second-screen: right),
  variant: variant,
  colortheme: colortheme,
  progressbar: "foot",
  header-style: "moloch",
)

#set text(font: "Overpass")
#set par(justify: true)

#let colors = get-theme-colors(theme: colortheme, variant: variant)
#let list-marker-shift = 0.25em
#set list(
  marker: (
    box(bullet-circle(color: colors.accent-secondary), inset: (y: list-marker-shift)),
    box(bullet-square(color: colors.accent-secondary), inset: (y: list-marker-shift)),
    box(bullet-dash(color: colors.accent-secondary), inset: (y: 1.2 * list-marker-shift)),
  ),
  indent: spacing-md,
  body-indent: spacing-sm,
)
#set enum(
  numbering: n => text(fill: colors.accent-secondary)[#n.],
  indent: spacing-md,
  body-indent: spacing-sm,
)

#let SHOW-FIGURES = false

#title-slide(layout: "centered")

== Outline <touying:hidden>

#v(1fr)

#components.adaptive-columns(outline(title: none, indent: 1em, depth: 1))

#v(1fr)

= Context

== Goal

#image("../../diagrams/Overview_of_pipeline.drawio.png")

= Work done until now

== Point cloud topology

#example-box(title: "Pulse")[
  A single emission of the LiDAR sensor, which may result in one or more echoes (points) depending on the number of surfaces the pulse hits.
]

#example-box(title: "Scan line")[
  A set of points collected during one rotation of the LiDAR scanner, i.e., one “scan” of the platform.
]

#example-box(title: "Flight strip")[
  A continuous swath of LiDAR data collected along one pass of the aircraft over the ground, i.e., one “track” of the platform.
]

---

LiDAR HD is distributed as a set of *cloud-optimized tiles* (1000m x 1000m) in the COPC format.
This means that *flight strips are mixed together* in the same tile, and points are *spatially ordered* instead of being ordered by acquisition time.

#only("2-")[Therefore, to extract the topology, we use:
  - For flight strips: the *Point Source ID* field, which identifies the flight strip the point belongs to
  - For scan lines:
    - The *GPS Time* field, which is a timestamp of the acquisition of the point, and can be used to sort points in acquisition order
    - The *Scan Direction Flag* field, which indicates the direction of the scan and alternates between 0 and 1 for consecutive scan lines
  - For pulses: the *GPS Time* field, which is the same for all points of a pulse
]

#only("3-")[
  #alert-box()[
    The *Number of Returns* field is not reliable for pulses in the LiDAR HD dataset, as it is not updated when points are filtered out during the processing of the raw data.
  ]
]

== Flight strips trajectories

I use code from #link("https://whuwuteng.github.io/")[Wu Teng] to *retrieve the trajectory* of the scanning vehicle, using multi-echo pulses
The precision of the method increases with the number of multi-echo pulses, meaning that it is necessary to *rebuild the flight strips* (scattered between tiles) in order to get a good estimation of the trajectory.

#only("2-")[
  #highlight-box()[
    This method allows to use the trajectory *without relying on its availability*, and therefore without adding new requirements on the input data.
  ]
]

== Identification of potential edge points

#only("1-")[Points are identified by iterating over a flight strip in *acquisition order*.
  They are compared to the *lowest point in the neighbourhood*:
  - The lowest point in the same pulse in case of a multi-echo pulse
  - The lowest point in the previous and next pulses in case of a single-echo pulse
]

#only("2-")[
  To account for the variation of angular difference between pulses in ellipsoidal LiDAR scanners, the *height difference* ($Delta h$) between the points is divided by the *temporal difference* ($Delta t$) between the pulses: $ v = (Delta h) / (Delta t) $

  The temporal difference $Delta t$ is assumed to be a *good approximation of the angular difference*, as the scanning speed is constant.
]

#only("3-")[
  Finally, this value is compared to a threshold $v_(min)$, which is set to $v_(min) = 2.10^6$ with $(Delta h)_(min) = 2$ in metres and $(Delta t)_(min) = 10^(-6)$ in seconds.
  For multi-echo pulses, since $Delta t = 0$, the height difference is directly compared to the threshold: $Delta h > (Delta h)_(min)$.
]

---

#{
  let fig-height = 40%
  let line-width = 0.1em
  let images = (
    image("images/Scan_line-Vertical_gain-1.png"),
    image("images/Scan_line-Vertical_gain-3.png"),
  )
  figure(
    grid(
      rows: fig-height,
      inset: (x, y) => {
        let res = (top: 0em, bottom: 0em)
        if (y > 0) { res.top = line-width / 2 }
        if (y < images.len() - 1) { res.bottom = line-width / 2 }
        res
      },
      stroke: (x, y) => { if (y > 0) { (top: black + line-width) } },
      ..images
    ),
    caption: [Two examples of the height differences obtained on a scan line. Black points are vegetation points, and for the other points the color represents the value of $Delta h$, with blue-green-yellow-red from low to high values.],
  )
}

#speaker-note[
  - Points at the edges of what looks like building roofs have *high values of $Delta h$*
  - Other points get *low values* of $Delta h$
  - Points classified as *vegetation* would have gotten high values if not excluded
  - These scan lines are actually *curved* when looked at from above, but this is not a problem as the *angle is very small* between consecutive pulses
]

== Weighing of potential edge points

Potential edge points are weighted using:

#only("1-")[
  + Their *height* (normalized over the area of the building) to a factor $w_h in [1.0, 3.0]$
]
#only("2-")[
  + Their *origin* to a factor $w_o in {0.1, 0.5, 1.0}$:
    - Multi-echo: 1.0
    - Single echo with good estimation of position: 0.5
    - Single echo with less precise estimation of position: 0.1
]
#only("3-")[
  + Their *classification* to a factor $w_c in {1.0, 2.0}$:
    - Building: 2.0
    - Other: 1.0
]

#only("4-")[These values were picked arbitrarily and would need to be optimized.
  The final weight $w$ is given by: $ w = w_h times w_o times w_c $
]

#speaker-note[
  + The *height* is a *simple but effective* metric to give more weight to points a roof edge than to the points on the façade below it.
  + The *origin* gives more weight to real points that are *less likely to be imprecisely positioned*.
  + The *classification* gives more weight to points classified as building, which are *less likely to actually be something else such as vegetation*.
    This is important because many points are unclassified.
]

== Displacement of BD TOPO edges

#slide[
  The value of a point is not only determined by its weight, but also by its *distance to the edge*.
  Distances are computed *in 2D* after getting rid of the vertical component of the position.

  #align(center + horizon)[#figure(lq.diagram(
    width: 100%,
    height: 5cm,
    title: [Criterion for edge matching],
    xlabel: [Distance to the edge (m)],
    ylabel: [Weight],

    lq.plot((0, 0.3, 1), (1, 0, 0), mark: none),
  ))]][
  #only(
    "2-",
  )[This distance is evaluated by projecting the point onto the edge, keeping only the points that project on the segment.


    #if SHOW-FIGURES {
      align(center)[#scale(
        fig-edge-matching-criterion(
          num-points-uniform: 20,
          num-points-around: 20,
          edge-start: (0, 0),
          edge-end: (3, 4),
          rand-seed: 1,
        ),
        180%,
        reflow: true,
      )]
    }
  ]

  #speaker-note[
    - The decreasing weight based on distance to the edge allows to find the *best position* for the edge.
    - The current threshold of *30 cm* was *picked arbitrarily* and would need to be optimized.
    - Discarding points that *do not project on the segment* prevents matching to a longer edge that would be close but not actually the right one.
  ]
]

#slide[
  The BD TOPO edges are translated perpendicularly to themselves, and the criterion is evaluated for each translation.

  #if SHOW-FIGURES {
    let figures = ()
    for fig-step in range(fig-edge-matching-translation-steps) {
      figures.push(
        figure(
          scale(
            fig-edge-matching-translation(
              fig-step,
              num-points-uniform: 20,
              num-points-around: 40,
              edge-start: (0, 0),
              edge-end: (3, 4),
              rand-seed: 2,
            ),
            180%,
            reflow: true,
          ),
          caption: [Step #fig-step],
        ),
      )
    }
    align(center + horizon)[#subpar.grid(
      columns: fig-edge-matching-translation-steps,
      column-gutter: 1em,
      caption: [Process of finding a better edge position.],
      ..figures
    )]
  }
]

= Preliminary results

== Identification of potential edge points

#figure(
  image("../../images/results_A2/Potential_edges-Simple_with_lidarhd_intensity.png", height: 90%),
  caption: [Edge points in blue and LiDAR HD data in gray scale from low (black) to high (white) intensity.],
)

---

#figure(
  image("../../images/results_A2/Potential_edges-Simple_with_lidarhd_classification.png", height: 90%),
  caption: [Edge points in blue and LiDAR HD data coloured by classification.],
)

---

#figure(
  image("../../images/results_A2/Potential_edges-Simple.png", height: 90%),
  caption: [Edge points in blue without LiDAR HD data.],
)

---

#figure(
  image("../../images/results_A2/Potential_edges-IsGenerated.png", height: 90%),
  caption: [Edge points coloured per type (blue: real point, green: generated by translation, red: generated with trajectory) without LiDAR HD data.],
)

= Next objectives



#ending-slide(
  title: [Thank You],
  subtitle: [Any questions?],
  contact: ("alexandre.bry@ign.fr",),
)
