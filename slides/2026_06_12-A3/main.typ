#import "../slides_theme/theme.typ": *

#import "@preview/lilaq:0.5.0" as lq
#import "@preview/subpar:0.2.2"

#import "illustrations.typ": *

#let handout = sys.inputs.at("handout", default: "false") == "true"
#let notes = sys.inputs.at("notes", default: "false") == "true"
#let theme = sys.inputs.at("theme", default: "tu-delft")

#let variant = "light"

#show: slides-theme.with(
  config-info(
    title: [From Points to Prints],
    subtitle: [A3 Presentation],
    author: [Alexandre Bry],
    date: datetime(day: 18, month: 5, year: 2026),
    institution: [TU Delft, IGN],
  ),
  config-common(
    show-notes-on-second-screen: if notes { right } else { none },
    handout: handout,
    notes: notes,
  ),
  variant: variant,
  colortheme: theme,
  progressbar: "foot",
  header-style: "moloch",
)

#let theme-colors = get-theme-colors(theme: theme, variant: variant)


/* ------------------------------ Some styling ------------------------------ */

#set par(justify: true)

#set table(
  stroke: (x, y) => (
    top: if y <= 1 { 1pt } else { 0.4pt },
    bottom: 1pt,
  ),
  inset: 6pt,
  align: center + horizon,
)
#show table.cell.where(y: 0): set text(weight: "bold")

#show link: it => {
  if type(it.dest) == str { text(fill: rgb("#3087b3"), it) } else { it }
}

#let SHOW-FIGURES = true

= Title <touying:hidden>

#title-slide(layout: "centered", logos: (
  place(
    bottom + left,
    image("../../images/TU_Delft_logo-cropped.svg", width: 9em),
    dx: -2em,
    dy: 2em,
  ),
  place(
    bottom + right,
    image("../../images/IGN_logo-cropped.svg", width: 5em),
    dx: 2em,
    dy: 2em,
  ),
))

= Context

== Roofprint vs. footprint

#slide(
  composer: (50%, 50%),
)[
  #set par(justify: false)
  #v(1fr)
  #figure(
    table(
      columns: 3,
      align: (left, center, center).map(t => t + horizon),
      table.header([], [*Roofprint*], [*Footprint*]),
      [Defined by], [Roof], [Façades],
      [Comes from], [Aerial data (images, ALS)], [Terrain measurements (TLS, MLS)],
      [Used for], [3D modelling, solar potential], [Tax estimation, energy consumption],
    ),
    caption: [Comparison between roofprints and footprints],
  )
  #v(1fr)
][
  #v(1fr)
  #figure(
    image("../../images/LoDs_illustration-Filip_Biljecki-cropped_2_2_and_2_3.jpg", width: 100%),
    caption: [Part of the visual definition of buildings Level of Detail (LoD) containg LoD 2.2 and 2.3 #cite(<Biljecki2016>, form: "normal").],
  )
  #v(1fr)

  #speaker-note[
    - Roofprints and footprints can serve different purposes, and knowing the difference between them is important when the roof overhangs are significant.
    - Since this difference is usually not available, it is unclear what the use cases could be, but we can think about:
      - More accurate visualisation and texturing of 3D models
      - More accurate simulations (wind, luminosity)
  ]
]

== Strengths and weaknesses of BD TOPO

#figure(
  image("../../images/2026_05_07/BD_TOPO_is_shifted.png", width: 85%),
  caption: [BD TOPO buildings are most of the time footprints, and often shifted.],
)

#speaker-note[
  - Strengths:
    - The BD TOPO contains most of the buildings in France
    - Buildings were manually delineated by humans, so their shape is generally of good quality
  - Weaknesses:
    - It is a mix of footprints and roofprints, coming from different sources
    - Georeferencing is not perfect because it was not crucial for the cadastre initially
]

== Research questions

#v(1fr)
#highlight-box()[
  #set text(style: "italic", size: 24pt)
  How to generate coherent building *roofprints* and *footprints* from high-density *ALS* point clouds and existing *imprecise outlines*?

  #set text(style: "normal", size: 20pt)
  - How to identify and use the *points on roof edges* in ALS point clouds?
  - How to identify and use the points in an ALS point cloud that contain *information about the façades* despite their sparsity?
  - How to *deform an imprecise outline* with global and local transformations while preserving the angles of the edges?

]
#v(1fr)

== Overview of the methodology

#figure(
  image("../../diagrams/Overview_of_pipeline-updated-v2.drawio.png", width: 70%),
  caption: [Overview of the pipeline.],
)

#speaker-note[
  - We start with the roofprint because aerial LiDAR data gives a much higher density of points on the roof than on the façades, making the roof much easier to identify.
  - Then, once the roofprint is accurately registered on the point cloud, we can use it to generate an accurate 3D roof model that allows to select all the points below the roof (hopefully façade and ground points), which are all the points that provide information about the façades and the roof overhangs.
]

= Polygon deformation

== Constraints over the movements

#speaker-note[
  - The constraints ensure that we *preserve some topology* while keeping a *lot of freedom* for the edges to move.
  - They could be *further improved* to preserve *shared vertices*, which would be possible but a bit more complex to implement and at the cost of some freedom of motion.
]

We modify the polygons by applying the following rules:
- *never rotate an edge*,
- *never flip an edge*,
- *move shared edges together*.

#pause

#v(0.5em)
#{
  let fig-height = 50%
  grid(
    columns: (10em, 1fr),
    align: (left + horizon, center + horizon),
    [
      #set par(justify: false)
      However it is not perfect as it can *separate two points* that were initially at the same position.
    ],
    [
      #import cetz.draw: *

      #let shift(p, dp: (0, 0)) = {
        return (p.at(0) + dp.at(0), p.at(1) + dp.at(1))
      }
      #let moving-edge = ((0.3, -1.5), (0, 0))
      #let segments-black = (
        ((-2, 1), (0, 0)),
        ((2, 1), (0, 0)),
        moving-edge,
      )
      #let shift-red = (-0.75, -0.15)
      #let line-red = ((0.35, -1.75), (-0.25, 1.25)).map(shift.with(dp: shift-red))
      #let segments-blue = (
        ((-2, 1), (-0.864, 0.432)),
        ((2, 1), (-0.71, -0.355)),
        ((-0.45, -1.65), (-0.864, 0.432)),
      )

      #let rect-size = rect((-2, -1.95), (2, 1.1), stroke: none, fill: none)

      #let scale = 2.0

      #let figures = (
        figure(
          [
            #cetz.canvas(
              x: scale,
              y: scale,
              {
                rect-size
                // Black initial situation
                for points in segments-black {
                  line(
                    ..points,
                    stroke: black,
                  )
                  for point in points.slice(1) {
                    circle(point, radius: 0.1, fill: black, stroke: none)
                  }
                }

                // Red line and arrow
                line(
                  ..line-red,
                  stroke: (paint: red, thickness: 1pt, dash: "dashed"),
                )
                let start-arrow = (
                  (moving-edge.at(0).at(0) + moving-edge.at(1).at(0)) / 2,
                  (moving-edge.at(0).at(1) + moving-edge.at(1).at(1)) / 2,
                )

                let end-arrow = shift(start-arrow, dp: shift-red)
                line(start-arrow, end-arrow, mark: (end: ">"), stroke: red + 1.5pt, fill: red)
              },
            )
          ],
          caption: [Initial situation with one vertex.],
        ),
        figure(
          [
            #set text(fill: blue.darken(10%), size: 10pt, style: "italic")
            #cetz.canvas(
              x: scale,
              y: scale,
              {
                rect-size
                // Blue example
                for points in segments-black {
                  line(
                    ..points,
                    stroke: (paint: black, thickness: 1pt, dash: "dashed"),
                  )
                  for point in points.slice(1) {
                    circle(point, radius: 0.1, fill: black, stroke: none)
                  }
                }
                for points in segments-blue {
                  line(
                    ..points,
                    stroke: blue,
                  )
                  for point in points.slice(1) {
                    circle(point, radius: 0.1, fill: blue, stroke: none)
                  }
                }
              },
            )
          ],
          caption: [Result with two vertices.],
        ),
      )

      #subpar.super(
        caption: [A vertex shared by two polygons can be split.],
        label: <fig:illustration-shared-vertex>,
      )[
        #std.grid(
          columns: 2,
          column-gutter: 10mm,
          row-gutter: 5mm,
          ..figures
        )
      ]
    ],
  )
}

== Our simple approach

#[
  #import cetz.draw: *

  #let edge-stroke = (paint: blue, thickness: 1pt)
  #let bad-edge-stroke = (paint: red, thickness: 1pt)
  #let focus-edge-stroke = (paint: green, thickness: 1pt)
  #let point-color = black
  #let text-size = 10pt
  #let scale-value = 1.5
  #let scale-func(t) = { scale-value * t }

  #let points = (
    (-0.5, 0),
    (0.5, 0),
    (2, -1),
    (1.5, -1.5),
    (2, -3),
    (-3, -3.5),
    (-0.7, -0.8),
  )

  #let idx-mod(idx) = {
    let len = points.len()
    return calc.rem(idx, len)
  }

  #let shift-point(p, d) = {
    let (x, y) = p
    let (dx, dy) = d
    return (x + dx, y + dy)
  }

  #let intersection-edges(l1, l2) = {
    let ((x1, y1), (x2, y2)) = l1
    let ((x3, y3), (x4, y4)) = l2

    let intersec-x = (
      ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4))
        / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
    )
    let intersec-y = (
      ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4))
        / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
    )

    return (intersec-x, intersec-y)
  }

  #let points-to-edges(points) = {
    let edges = ()
    for idx in range(points.len()) {
      edges.push((points.at(idx), points.at(idx-mod(idx + 1))))
    }
    return edges
  }

  #let compute-configuration(edges, shift, to-shifts) = {
    if edges.len() != to-shifts.len() {
      panic("The lines and to-shift arguments of configuration should have the same size.")
    }

    let shifted-edges = ()
    for (edge, to-shift) in edges.zip(to-shifts) {
      let shifted-edge = if to-shift {
        let (p1, p2) = edge
        (shift-point(p1, shift), shift-point(p2, shift))
      } else {
        edge
      }
      shifted-edges.push(shifted-edge)
    }

    let initial-points = ()
    let shifted-points = ()
    for idx in range(shifted-edges.len()) {
      let intersection-initial = intersection-edges(edges.at(idx - 1), edges.at(idx))
      initial-points.push(intersection-initial)

      let intersection-shifted = intersection-edges(shifted-edges.at(idx - 1), shifted-edges.at(idx))
      shifted-points.push(intersection-shifted)
    }

    return (initial-points, shifted-points)
  }

  #let display-configuration(config-name, initial-points, shifted-points, strokes) = {
    for idx in range(0, shifted-points.len()) {
      let stroke = strokes.at(idx)

      let base-name = config-name + "-edge-" + str(idx)

      let name-init = base-name + "-init"
      let p0-init = initial-points.at(idx)
      let p1-init = initial-points.at(idx-mod(idx + 1))

      on-layer(0, line(p0-init, p1-init, stroke: stroke + ("dash": "dashed"), name: name-init))

      let name-shifted = base-name + "-shifted"
      let p0-shifted = shifted-points.at(idx)
      let p1-shifted = shifted-points.at(idx-mod(idx + 1))

      on-layer(1, line(p0-shifted, p1-shifted, stroke: stroke, name: name-shifted))
      on-layer(2, circle(p0-shifted, radius: 0.08, stroke: none, fill: point-color))
      on-layer(
        3,
        mark(
          (name-shifted + ".start", 50%, name-shifted + ".end"),
          name-shifted + ".end",
          symbol: ">>",
          anchor: "center",
          stroke: stroke,
          fill: white,
        ),
      )
    }
  }

  #let shift = (0.0, -1.3)

  #let edges = points-to-edges(points)
  #let configurations-infos = (
    "base": (
      shift: shift,
      to-shifts: (false, false, false, false, false, false, false),
      strokes: (
        focus-edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
      ),
      caption: [Initial state.],
    ),
    "step0": (
      shift: shift,
      to-shifts: (true, false, false, false, false, false, false),
      strokes: (
        focus-edge-stroke,
        bad-edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        bad-edge-stroke,
      ),
      caption: [After shifting the focus edge.],
    ),
    "step1": (
      shift: shift,
      to-shifts: (true, true, false, false, false, false, true),
      strokes: (
        focus-edge-stroke,
        edge-stroke,
        bad-edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        bad-edge-stroke,
      ),
      caption: [First step of the resolution.],
    ),
    "step2": (
      shift: shift,
      to-shifts: (true, true, true, false, false, true, true),
      strokes: (
        focus-edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
        edge-stroke,
      ),
      caption: [Second step of the resolution.],
    ),
  )

  // Compute the configurations
  #let configurations-points = (:)
  #for (config-key, config-infos) in configurations-infos.pairs() {
    let shift = config-infos.shift
    let to-shifts = config-infos.to-shifts
    let (initial-points, shifted-points) = compute-configuration(edges, shift, to-shifts)
    configurations-points.insert(config-key, (initial: initial-points, shifted: shifted-points))
  }

  // Compute the bounding box of all
  #let min = (calc.inf, calc.inf)
  #let max = (-calc.inf, -calc.inf)
  #for config-points in configurations-points.values() {
    for points in config-points.values() {
      for point in points {
        min = (calc.min(min.at(0), point.at(0)), calc.min(min.at(1), point.at(1)))
        max = (calc.max(max.at(0), point.at(0)), calc.max(max.at(1), point.at(1)))
      }
    }
  }
  // Add a margin
  #let margin = 0.2
  #{
    min = (min.at(0) - margin, min.at(1) - margin)
    max = (max.at(0) + margin, max.at(1) + margin)
  }

  #slide(repeat: configurations-infos.len(), self => [
    #let (uncover, only, alternatives) = utils.methods(self)

    #speaker-note[
      This illustrates the behavior of the polygon deformation algorithm, which is designed to *propagate the shift* in the polygon as long as there are *self-intersections* of *flipped edges*.
    ]

    #let scale-factor = 1.3
    #let figures = ()
    #for (idx, name) in configurations-infos.keys().enumerate() {
      let config-infos = configurations-infos.at(name)
      let config-points = configurations-points.at(name)
      let shift = config-infos.shift
      let to-shifts = config-infos.to-shifts
      let strokes = config-infos.strokes
      let caption = config-infos.caption
      let initial-points = config-points.initial
      let shifted-points = config-points.shifted

      // Display the configuration
      figures.push(uncover(str(idx + 1) + "-")[#figure(
        cetz.canvas(x: scale-factor, y: scale-factor, {
          display-configuration(name, initial-points, shifted-points, strokes)
          rect(min, max, fill: none, stroke: none)
        }),
        caption: caption,
      )])
    }

    #subpar.super(
      caption: [Illustration of the polygon deformation algorithm on an isolated polygon.],
      label: <fig:illustration-polygon-deformation>,
    )[
      #std.grid(
        columns: 2,
        column-gutter: 10mm,
        row-gutter: 5mm,
        ..figures
      )
    ]])
]


= Roof edge points

== Point cloud topology

#[
  #speaker-note[
    - This creates a *hierarchy* in the point cloud, with points belonging to pulses, pulses belonging to scan lines, and scan lines belonging to flight strips.
    - With multiple flight strips in the same area, this creates a sort of *irregular 3D structure*:
      - 1st dimension: the flight strip
      - 2nd dimension: the scan line
      - 3rd dimension: the pulse
      It is then possible to *navigate* in this structure along any of these dimensions.
  ]

  #let factor = 170%
  #set text(size: size-body * (100% / factor))
  #figure(
    box(scale(fig-point-cloud-topology(), factor, reflow: true), inset: 1em),
    caption: [Illustration of the structure of an ALS point cloud.],
  )
]

== Edge points detection

#[
  #speaker-note[
    We use the *height differences $Delta h$ between neighbor points* to identify points that are likely to be on the edges of roofs:
    - We look at the neighbors in the previous, current and next scan lines
    - Points at the edges of building roofs have *high values of $Delta h$*
    - Points from *high vegetation* also get high $Delta h$ and therefore need to be excluded
    - With circular ALS sensors, the scan lines are *curved* when looked at from above, but this is not a problem as the *angle is very small* between consecutive pulses
  ]

  #v(1fr)
  #figure(
    grid(
      rows: 40%,
      inset: 0.2em + 1pt,
      row-gutter: 0.5em,
      stroke: 1pt,
      image("../../images/results_A2/Edge_points/Scan_line-Vertical_gain-1.png"),
      image("../../images/results_A2/Edge_points/Scan_line-Vertical_gain-3.png"),
    ),
    caption: [Two examples of the height differences obtained on a scan line. Black points are vegetation points, and for the other points the color represents the value of $Delta h$, with blue-green-yellow-red from low to high values.],
  )
]

== Total energy to minimize

The energy that we try to minimize for each group of roofprints is the following:

$
  E = underbrace(- sum_(i in cal(P)) w_i max_(j in cal(L)) {"score"(p_i, l_j)}, "proximity to the points") + alpha underbrace(sum_(j in cal(L)) (|l_j| - |l_j^0|)^2, "similarity to the initial edges")
$

Where:

- $cal(P)$ is the set of points, and $cal(L)$ is the set of edges (lines).
  $cal(L)$ contains all the edges moved in any configuration and their neighbours.
- $w_i$ is the weight of point $p_i$, which is independent of the lines.
- $"score"(p_i, l_j)$ is the score of point $p_i$ for edge $l_j$, which is defined in the next slide.
- $|l_j|$ is the length of edge $l_j$ in the current configuration, and $|l_j^0|$ is its initial length.
- $alpha$ is a parameter to adjust between the two terms.

#speaker-note[
  #set text(size: 20pt)
  - The energy is divided in two terms:
    - The first term is a *proximity term* that both counts the number of points close to the edges while prioritizing points with higher weights.
    - The second term is a *regularization term* that entices the edges to keep their initial length, to prioritize a shape closer to the initial one.
  - Many regularization terms are possible, but we chose this one because it makes sure that by default, the edges will *keep their initial length* and otherwise *share the change equally* between them.
    This is desired if we assume that the scaling that we need to perform is the same on both sides for a given direction, no matter the size of the edges, because the roof overhang is the same.
]

#let figure-width = 6cm
#slide(composer: (1fr, figure-width))[

  #uncover("1-")[
    The score of a point $p_i$ for an edge $l_j$ is defined as follows:
    - The score is 0 if any of the following conditions is true:
      - The orthogonal projection $p_(i perp j)$ of $p_i$ on the supporting line of $l_j$ is outside of the segment $l_j$.
      - The distance from $p_i$ to $p_(i perp j)$ is greater than a certain threshold $epsilon$.
      - The dot product of the inward vector $v_i$ of $p_i$ with the normal $n_j$ of $l_j$ oriented towards the inside of the building is negative.
  ]
  #uncover("2-")[
    - Otherwise, the score is: $ "score"(p_i, l_j) = underbrace((v_i dot n_j), "alignment of\npoint and edge\n'normals'") times underbrace((1 - (|p_i - p_(i perp j)|) / epsilon), "proximity to the edge") >= 0 $

    We use $epsilon = 30 "centimetres"$.
  ]

  #speaker-note[
    - Any point *outside the rectangle* defined by extruding the edge along its normal by $epsilon$ has a score of 0.
      This geometric ensures that only points that are close enough to the edge will count.
    - Then, the dot product between the inward vector and the normal of the edge ensures that points that are part of a parallel but opposite edge will not count, *preventing matching to the neighbour building*.
  ]
][
  #uncover("1-")[#context {
      let illustration = fig-edge-matching-criterion(
        num-points-uniform: 100,
        num-points-around: 40,
        edge-start: (0, 0),
        edge-end: (2, 6),
        rand-seed: 1,
      )
      let fig = measure(illustration)
      let factor = figure-width / fig.width * 100%
      figure(
        scale(
          fig-edge-matching-criterion(
            num-points-uniform: 50,
            num-points-around: 30,
            edge-start: (0, 0),
            edge-end: (2, 6),
            rand-seed: 1,
          ),
          factor,
          reflow: true,
        ),
        caption: [Illustration of the proximity score for an isolated edge.],
      )
    }
  ]
]

== Definition of the inward direction

#slide[
  #speaker-note[
    - The idea behind this method is that points on the edge of the roof should have *many points towards the inside* of the building, and *few points towards the outside*.#pause#pause#pause
    - Using unit vectors and averaging them allows for all points in the neighbourhood to contribute equally, meaning that we are somewhat counting the *density of points* in each direction.
      Therefore, the *magnitude* of the inward vector is an indication of the confidence of the direction.
  ]

  The goal of the *inward direction* is to be as close as possible to the 2D normal of the roof edge, pointing towards the inside of the building.#pause
  To compute it for a given point $p_i$, we use the following method:
  1. Identify all the points $p_j$ that are less than a certain distance $delta$ from $p_i$.#pause
  2. For each point $p_j$, compute the vector from $p_i$ to $p_j$, and normalize it into a unit vector $u_(i -> j)$.#pause
  3. Compute the inward vector $v_i$ as the average of the vectors $u_(i -> j)$: $ v_i = 1/ (|cal(B)(p_i, delta)|) sum_(p_j in cal(B)(p_i, delta)) (p_j - p_i) / (|p_j - p_i|) $

  We use $delta = 2 "metres"$.
]

== Illustrations of matching the edges to the points

Illustrations can be viewed by following this link: #link("https://alexandre-bry.github.io/MSc_Thesis-Report/monthly_notes/2026_05_18.html#gifs-that-could-not-be-included-in-the-slides")


#slide[
  #v(1fr)
  #let image-width = 60%
  #subpar.grid(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_00-initial.png",
        width: image-width,
      ),
      caption: [Initial state],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.00$ (no regularization)],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_05-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.05$],
    ),

    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_20-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.20$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_50-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.50$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=1_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 1.00$],
    ),

    caption: [Matching a circle to a half-circle of points with different values of the regularization parameter $alpha$.],
  )
  #v(1fr)

  #speaker-note[
    We can see how regularization helps to get a shape more similar to the target even with half of the points missing.
  ]
]

#slide[
  #v(1fr)
  #let image-width = 60%
  #subpar.grid(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=0_00-initial.png",
        width: image-width,
      ),
      caption: [Initial state],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=0_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.00$ (no regularization)],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=0_05-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.05$],
    ),

    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=0_20-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.20$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=0_50-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.50$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=1_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 1.00$],
    ),

    caption: [Matching a square to points along two sides of a larger square with different values of the regularization parameter $alpha$.],
  )
  #v(1fr)

  #speaker-note[
    $alpha > 0$ encourages the shape to be closer to the initial one, which is better than $alpha = 0$, until a certain point where the regularization is too strong and prevents the shape from extending to capture all the points.
  ]
]

#slide[
  #v(1fr)
  #let image-width = 60%
  #subpar.grid(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=0_00-initial.png",
        width: image-width,
      ),
      caption: [Initial state],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=0_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.00$ (no regularization)],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=0_05-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.05$],
    ),

    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=0_20-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.20$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=0_50-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.50$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=1_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 1.00$],
    ),

    caption: [Matching a polygon to half of its shape with points with different values of the regularization parameter $alpha$.],
  )
  #v(1fr)

  #speaker-note[
    - $alpha > 0$ forces the shape to be closer to the initial one, but it takes many more steps to converge, because the more edges that don't have points take longer to balance the regularization term between each other.
    - If $alpha$ is too high, it prevents the shape from matching the points, because the proximity score is not good enough to balance the regularization term, which is the case here for $alpha >= 0.50$.
  ]
]

== Illustration with a real building

#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [The LiDAR HD data.],
  image("../../images/results-2026_04_20/Interesting_building_1/LiDAR_HD=Classification.png", height: 90%),
  image("../../images/results-2026_04_20/Interesting_building_1/LiDAR_HD=Height.png", height: 90%),
)

#speaker-note[
  - We can see *three different building parts* that are connected, one with a pitched roof and the two others with flat roofs.
  - The points are well classified overall, but there are a number of points *classified as Unassigned (grey)*, especially at the boundaries between the building and the vegetation.
]

---

#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [The detected roof edge points coloured by their inward vector.],
  image("../../images/results-2026_04_20/Interesting_building_1/Roof_edge_points=InwardVectorX.png", height: 90%),
  image("../../images/results-2026_04_20/Interesting_building_1/Roof_edge_points=InwardVectorY.png", height: 90%),
)

#speaker-note[
  - The detected roof edge points are shown here, coloured by their *inward vector* (the direction in which the building is located from the edge).
  - We can see that the inward vectors are *generally well oriented* towards the building, except in areas where the building is *very close to vegetation* at the same height.
]

---

#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [Comparison of BD TOPO outlines and roofprints computed with the old algorithm.],
  image("../../images/results-2026_04_20/Interesting_building_1/BD_TOPO.png", height: 90%),
  image("../../images/results-2026_04_20/Interesting_building_1/Old_algorithm.png", height: 90%),
)

#speaker-note[
  - Interestingly, this building unit is actually divided into *two parts in the BD TOPO*, even though we could expect 1 or 3 as well.
  - In the old algorithm, we processed edges individually, resulting in assessing the segments that are displayed on the right.
  - The results give a better alignment, but there is still an issue to fix: the bottom left edge of the small top right building was *matched incorrectly*.
    This could be fixed by *matching the whole initial line once* instead of keeping it split between buildings.
]

---

#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [Comparison of the roofprints computed with the new algorithm without and with inward vectors.],
  image("../../images/results-2026_04_20/Interesting_building_1/New_algorithm_without_inward_vectors.png", height: 90%),
  image("../../images/results-2026_04_20/Interesting_building_1/New_algorithm_with_inward_vectors.png", height: 90%),
)

#speaker-note[
  - The new algorithm allows *fix the issue* for the bottom left edge of the small top right building, thanks to its alignment with the almost collinear edge of the big building.
  - However, for the same building without using the inward vectors, one edge ends up *matching the neighbouring building* instead.
    This is fixed with the inward vectors, which prevent the points from the other building from counting in the score of the edge.
]

= Footprint points

== Footprint points

#{
  speaker-note[
    + Build the roof in 3D using a 3D roof constructor (such as #link("https://github.com/3DBAG/roofer")[roofer]) with the roofprints as input
    + Select all the points *under* the 3D roof with a small horizontal buffer (for the scoring function) and a small vertical buffer (for roof points slightly below the roof)
  ]
  let fig-height = 85%
  let caption = [Illustration of the 3D roof structure and the selected points for the footprint computation.]
  v(1fr)
  alternatives[#{
      subpar.grid(
        columns: (auto, auto),
        align: center + horizon,
        caption: caption,
        image("../../images/2026_05_18/Example_building-3D_roof-1.png", height: fig-height),
        image("../../images/2026_05_18/Example_building-Footprint_points-1.png", height: fig-height),
      )
    }
  ][#{
      subpar.grid(
        columns: (auto, auto),
        align: center + horizon,
        caption: caption,
        image("../../images/2026_05_18/Example_building-3D_roof-2.png", height: fig-height),
        image("../../images/2026_05_18/Example_building-Footprint_points-2.png", height: fig-height),
      )
    }
  ]
  v(1fr)
}

= Creation of the footprints

== Creation of the footprints

#speaker-note[
  #set text(size: 22pt)
  #pause
  - The ideas behind the two terms of the score are simple:
    - The proximity encourages finding a position with a concentration of points (likely to be the façade in 3D)
    - The penalty term discourages positions that have points behind them (likely to be points on the façade or on the ground outside the building)#pause
  - The difference between ground points and other classes of points comes from the ground points being very good indicators for the penalty term but much less for the proximity, while the others are assumed to be potential facade points, which are good indicators for the proximity but not necessarily for the penalty term.
]

- *Sweep each roof edge horizontally towards the inside* up to 1.5 metres and select the best scoring position #pause
- The score has two components:
  + A *proximity term* that counts the number of points close to the edge
  + A *penalty term* that penalizes points that are behind the edge (inside the building)

#pause

#{
  import "../../figures/footprints/footprints-loss.typ": fig-footprints-loss

  figure(
    fig-footprints-loss(width: 65%, height: 60%, title: [Score of a point $p$ for a footprint edge $e$]),
  )
}

---

#{
  speaker-note[
    Example where it works well:
    - the footprint is *properly aligned* with the façade points
    - we can see *significant roof overhangs for façades oriented west/east* and no significant roof overhangs for north/south, as expected from the orientation of the slanted roof
  ]
  let fig-height = 95%
  v(1fr)
  alternatives[
    #subpar.grid(
      columns: (auto, auto),
      align: center + horizon,
      caption: [Illustration of the computed footprints.],
      image("../../images/2026_05_07/Example_building-Footprint-Classification.png", height: fig-height),
      image("../../images/2026_05_07/Example_building-Footprint_with_roofprint-Classification.png", height: fig-height),
    )
  ][
    #subpar.grid(
      columns: (auto, auto),
      align: center + horizon,
      caption: [Illustration of the computed footprints.],
      image("../../images/2026_05_07/Example_building-Footprint-Height.png", height: fig-height),
      image("../../images/2026_05_07/Example_building-Footprint_with_roofprint-Height.png", height: fig-height),
    )
  ]
  v(1fr)
}

= Results

#import "../../figures/validation/validation.typ": (
  categories-infos, datasets-full, datasets-infos, datasets-labels, datasets-per-category, display-bars,
  display-evolutions, display-table, metrics-infos, nice-tables, roofprints-iter-n-label, simple-categories,
)

== Validation dataset

#slide[
  #speaker-note[
    We made a validation dataset for roofprints with buildings in four different categories (see @fig:validation-dataset):
    - #datasets-per-category.isolated_houses.at(0).len() #categories-infos.isolated_houses.name: medium houses and buildings having up to a few storeys, isolated from the buildings around,
    - #datasets-per-category.adjacent_houses.at(0).len() #categories-infos.adjacent_houses.name: blocks of adjacent and medium houses and buildings having up to a few storeys,
    - #datasets-per-category.low_sheds.at(0).len() #categories-infos.low_sheds.name: low buildings in height, usually in gardens,
    - #datasets-per-category.adjacent_blocks_of_flats.at(0).len() #categories-infos.adjacent_blocks_of_flats.name: blocks of adjacent and high buildings.
  ]

  #v(1fr)
  #subpar.super(
    caption: [Validation dataset.],
    label: <fig:validation-dataset>,
  )[
    #let height = auto
    #grid(
      columns: 3,
      gutter: 2mm,
      figure(
        image("../../images/Final_report/Validation_992/Validation_dataset-Ozoir_north.png", height: height),
        caption: [Area in Ozoir-la-Ferrière with isolated houses and small sheds.],
      ),
      [
        #figure(
          image("../../images/Final_report/Validation_992/Validation_dataset-Ozoir_south.png", height: height),
          caption: [Area in Ozoir-la-Ferrière with mainly adjacent houses.],
        ) <fig:validation-dataset-ozoir-south>
      ],
      figure(
        image("../../images/Final_report/Validation_992/Validation_dataset-Paris.png", height: height),
        caption: [Area in Paris with mainly adjacent blocks of flats.],
      ),
    )
  ]
  #v(1fr)
]

#slide[
  #speaker-note[
    The different metrics on the validation dataset show that the do improve the outlines by a lot in all categories except #categories-infos.low_sheds.name where the results are bad for a few buildings and from correct to very good for the rest.
  ]

  #v(1fr)
  #[
    #show: nice-tables

    #let text-size = 11pt
    #let figures = ()

    #let categories-captions = (
      all: [Whole dataset.],
      all_except_low_sheds: [Whole dataset except the #categories-infos.low_sheds.name category.],
    )
    #for (category, caption) in categories-captions.pairs() {
      let dataset = datasets-per-category.at(category)
      let fig-cat = [
        #figure(
          display-table(dataset, datasets-labels, metrics-infos, text-size: text-size),
          caption: caption,
        ) #label("fig:valid-res-table-" + category)
      ]
      figures.push(fig-cat)
    }

    #let fig-all = [
      #figure(
        display-table(datasets-full.values(), datasets-labels, metrics-infos, text-size: text-size),
        caption: [Whole dataset.],
      ) <fig:valid-res-table-all>
    ]

    #for category in simple-categories {
      let dataset = datasets-per-category.at(category)
      let fig-cat = [
        #figure(
          display-table(dataset, datasets-labels, metrics-infos, text-size: text-size),
          caption: [Category #categories-infos.at(category).name.],
        ) #label("fig:valid-res-table-" + category)
      ]
      figures.push(fig-cat)
    }

    #subpar.super(
      caption: [Average metrics over different subsets of the validation dataset.],
      label: <fig:valid-res-table>,
    )[
      #grid(
        columns: 3,
        column-gutter: 10mm,
        row-gutter: 5mm,
        ..figures
      )
    ]
  ]
  #v(1fr)
]


= The end <touying:hidden>

#ending-slide(
  title: [Thank you for your attention!],
  subtitle: [
    #import "@preview/tiaoma:0.3.0"
    #let slides-link = "https://alexandre-bry.github.io/MSc_Thesis-Report/monthly_notes/2026_05_18.html"

    Link to the slides:

    #link(slides-link)

    #v(spacing-md)

    #tiaoma.qrcode(slides-link, options: (
      scale: 2.5,
      fg-color: theme-colors.header-bg,
      bg-color: theme-colors.header-text,
    ))
  ],
  contact: ("abry@tudelft.nl",),
)

#bibliography-slide(
  bib-content: bibliography("../../references/MSc_Thesis-Bibliography.bib", style: "apa", title: none),
)

// #show: appendix

// #heading([Appendix], depth: 1, outlined: false)
