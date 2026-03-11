#import "@preview/calmly-touying:0.2.0": *
#import "@preview/lilaq:0.5.0" as lq
#import "@preview/subpar:0.2.2"

#import "illustrations.typ": *

#show: calmly.with(
  config-info(
    title: [From Points to Prints],
    subtitle: [Monthly Presentation (2)],
    author: [Alexandre Bry],
    date: datetime(day: 16, month: 3, year: 2026),
    institution: [IGN],
    logo: image("../../images/IGN_logo.svg"),
  ),
  variant: "light",
  colortheme: "warm-amber",
  progressbar: "foot",
  header-style: "moloch",
)

#set text(font: "Overpass")
#set par(justify: true)

#let SHOW-FIGURES = false

#title-slide(layout: "centered")

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: none, indent: 1em, depth: 1))

= Context

== Goal

#image("../../diagrams/Overview_of_pipeline.drawio.png")

= Work done until now

== Point cloud topology

#v(1fr)

- Define the different elements of the point cloud:
  - Flight axes
  - Scan lines
- Explain how these elements are extracted
- Explain how to

#v(1fr)

== Flight axes trajectories

#v(1fr)

- Code from Wu Teng that computes the trajectory of the scanning vehicle
- Useful to compute the adjusted position of roof points for single-echo rays

#v(1fr)

== Identification of potential edge points

#only("1-")[Points are identified by iterating over a flight axis in *acquisition order*.
  They are compared to the *lowest point in the neighbourhood*:
  - The lowest point in the same ray in case of a multi-echo ray
  - The lowest point in the previous and next rays in case of a single-echo ray
]

#only(
  "2-",
)[To account for the variation of angular difference between rays in ellipsoidal LiDAR scanners, the *height difference* ($Delta h$) between the points is divided by the *temporal difference* ($Delta t$) between the rays: $ v = (Delta h) / (Delta t) $

  The temporal difference $Delta t$ is assumed to be a *good approximation of the angular difference*, as the scanning speed is constant.
]

#only("3-")[
  Finally, this value is compared to a threshold $v_(min)$, which is set to $v_(min) = 2.10^6$ with $(Delta h)_(min) = 2$ in metres and $(Delta t)_(min) = 10^(-6)$ in seconds.
  For multi-echo rays, since $Delta t = 0$, the height difference is directly compared to the threshold: $Delta h > (Delta h)_(min)$.
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

== Weighing of potential edge points

Potential edge points are weighted using:

#only("1-")[- Their *height* (normalized over the area of the building) to a factor $w_h in [1.0, 3.0]$]
#only("2-")[
  - Their *origin* to a factor $w_o in {0.1, 0.5, 1.0}$:
    - Multi-echo: 1.0
    - Single echo with good estimation of position: 0.5
    - Single echo with less precise estimation of position: 0.1
]
#only("3-")[
  - Their *classification* to a factor $w_c in {1.0, 2.0}$:
    - Building: 2.0
    - Other: 1.0
]

#only("4-")[These values were picked arbitrarily and would need to be optimized.
  The final weight $w$ is given by: $ w = w_h times w_o times w_c $
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

= Next objectives



#ending-slide(
  title: [Thank You],
  subtitle: [Any questions?],
  contact: ("alexandre.bry@ign.fr",),
)
