#import "../slides_theme/theme.typ": *

#import "@preview/lilaq:0.5.0" as lq
#import "@preview/subpar:0.2.2"

#import "illustrations.typ": *

#let handout = sys.inputs.at("handout", default: "false") == "true"
#let notes = sys.inputs.at("notes", default: "true") == "true"
#let theme = sys.inputs.at("theme", default: "tu-delft")

#let variant = "light"

#show: slides-theme.with(
  config-info(
    title: [From Points to Prints#linebreak()#text(size: 20pt)[Generating Building Roofprints and Footprints from Airborne Lidar Data and Inaccurate Outlines]],
    subtitle: [A4 Presentation],
    author: [Alexandre Bry, supervised by Hugo Ledoux (TUD), Ravi Peters (TUD) and Bruno Vallet (IGN)],
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
]
#v(1fr)

== Overview of the methodology

#{
  let images = (
    image("../../images/2026_06_22/Example_building-BD_TOPO.png"),
    image("../../images/2026_06_22/Roof_edge_points_3D-square.png"),
    image("../../images/2026_06_22/Example_building-Roofprint.png"),
    image("../../images/2026_06_22/Roof_3D-square.png"),
    image("../../images/2026_06_22/Footprints_points_3D-square.png"),
    image("../../images/2026_06_22/Example_building-Roofprint_and_footprint.png"),
  )
  let captions = (
    [BD TOPO and LiDAR HD],
    [Find roof edge points],
    [Align into a roofprint],
    [Generate 3D roof model],
    [Find façade and ground points],
    [Align into a footprint],
  )
  let speaker-notes = (
    [The BD TOPO and the LiDAR HD datasets are initially not aligned.
      The first step is to identify the points which are at the edge of the roof.],
    [Then, these points are used to deform the initial outline and align it on the roof edge points to create a roofprint.],
    [After that, this clean roofprint can be used to produce and clean 3D roof model.],
    [This 3D roof model can then be used to identify useful points on the façades and on the ground, by simply filtering the points geometrically under the roof.],
    [The filtered points are finally used to deform the previous roofprint into a footprint.],
  )
  let captions-content = captions.enumerate().map(ic => text(size: 20pt, weight: "bold", [#(ic.at(0) + 1). #ic.at(1)]))

  let slides = ()
  for i in range(images.len() - 1) {
    let img-1 = images.at(i)
    let img-2 = images.at(i + 1)
    let cap-1 = captions-content.at(i)
    let cap-2 = captions-content.at(i + 1)
    let curr-speaker-notes = speaker-notes.at(i)

    let current-slide = grid(
      columns: (1fr, 1fr),
      rows: (auto, 1fr),
      row-gutter: 1em,
      cap-1, cap-2,
      img-1, img-2,
    )
    slide[
      #align(center + horizon, current-slide)

      #speaker-note[#curr-speaker-notes]
    ]
  }
}


= Polygon deformation

== Our simple approach

#[
  #import cetz.draw: *

  #let edge-stroke = (paint: blue, thickness: 1pt)
  #let bad-edge-stroke = (paint: red, thickness: 1pt)
  #let moved-edge-stroke = (paint: green, thickness: 1pt)
  #let point-color = black

  #let points = (
    (-0.5, 0),
    (0.75, 0),
    (2, -0.75),
    (1.5, -2.25),
    (2, -3),
    (-1.5, -2.5),
    (-0.25, -0.5),
  )
  #let shift = (0.0, -1.4)

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

  #let display-configuration(config-name, initial-points, shifted-points, to-shifts, bad-directions) = {
    for idx in range(0, shifted-points.len()) {
      let to-shift = to-shifts.at(idx)
      let is-bad = bad-directions.contains(idx)
      let curr-edge-stroke = if to-shift { moved-edge-stroke } else { edge-stroke }
      let arrow-stroke = if is-bad { bad-edge-stroke } else { edge-stroke }

      let base-name = config-name + "-edge-" + str(idx)

      let name-init = base-name + "-init"
      let p0-init = initial-points.at(idx)
      let p1-init = initial-points.at(idx-mod(idx + 1))

      on-layer(0, line(p0-init, p1-init, stroke: curr-edge-stroke + ("dash": "dashed"), name: name-init))

      let name-shifted = base-name + "-shifted"
      let p0-shifted = shifted-points.at(idx)
      let p1-shifted = shifted-points.at(idx-mod(idx + 1))

      on-layer(1, line(p0-shifted, p1-shifted, stroke: curr-edge-stroke, name: name-shifted))
      on-layer(2, circle(p0-shifted, radius: 0.09, stroke: none, fill: point-color))
      on-layer(
        3,
        mark(
          (name-shifted + ".start", 50%, name-shifted + ".end"),
          name-shifted + ".end",
          symbol: ">",
          anchor: "center",
          stroke: arrow-stroke,
          fill: arrow-stroke.paint,
          scale: 1.2,
        ),
      )
    }
  }

  #let edges = points-to-edges(points)
  #let configurations-infos = (
    "base": (
      shift: shift,
      to-shifts: (false, false, false, false, false, false, false),
      bad-directions: (),
      caption: [Initial state.],
    ),
    "step0": (
      shift: shift,
      to-shifts: (true, false, false, false, false, false, false),
      bad-directions: (1, 6),
      caption: [After shifting the focus edge.],
    ),
    "step1": (
      shift: shift,
      to-shifts: (true, true, false, false, false, false, true),
      bad-directions: (6,),
      caption: [First step of the resolution.],
    ),
    "step2": (
      shift: shift,
      to-shifts: (true, true, false, false, false, true, true),
      bad-directions: (),
      caption: [Second and final step of the resolution.],
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

    #let scale-factor = 1.5
    #let figures = ()
    #for (idx, name) in configurations-infos.keys().enumerate() {
      let config-infos = configurations-infos.at(name)
      let config-points = configurations-points.at(name)
      let shift = config-infos.shift
      let to-shifts = config-infos.to-shifts
      let bad-directions = config-infos.bad-directions
      let caption = config-infos.caption
      let initial-points = config-points.initial
      let shifted-points = config-points.shifted

      // Display the configuration
      figures.push(uncover(str(idx + 1) + "-")[#figure(
        cetz.canvas(x: scale-factor, y: scale-factor, {
          display-configuration(name, initial-points, shifted-points, to-shifts, bad-directions)
          rect(min, max, fill: none, stroke: none)
        }),
        caption: caption,
      )])
    }


    #subpar.super(
      caption: [
        Illustration of the polygon deformation algorithm on a single polygon.
      ],
      label: <fig:illustration-polygon-deformation>,
    )[
      #std.grid(
        columns: 2,
        column-gutter: 0em,
        row-gutter: 0.5em,
        ..figures
      )
    ]

    #speaker-note[
      Flipped edges are indicated with red arrows, and shifted edges are green.
    ]
  ])
]


= Roofprints

== Point cloud topology

#[
  #import cetz.draw: *

  #let traj-stroke = (paint: black, thickness: 0.5pt)

  #let legend(position, anchor, space-between) = {
    let (px, py) = position

    {
      let start = (px, py - 0.4)
      let end = (px + 0.5, py - 0.6)
      let label-pos = (px + 0.5, py - 0.5)
      rect(start, end, stroke: none, fill: building-color)
      content(label-pos, padding: 0.1, text(size: 7pt, [Building]), anchor: "west")
    }

    py -= space-between

    {
      let start = (px, py - 0.5)
      let end = (px + 0.5, py - 0.5)
      line(start, end, stroke: pulse-stroke)
      content(end, padding: 0.1, text(size: 7pt, [Pulse]), anchor: "west")
    }

    py -= space-between

    {
      let start = (px, py - 0.5)
      let end = (px + 0.5, py - 0.5)
      let mid = ((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2)
      circle(mid, radius: 0.08, stroke: none, fill: point-color)
      content(end, padding: 0.1, text(size: 7pt, [Point]), anchor: "west")
    }
  }

  #let scenario-label(body, start-x, end-x, start-y: -0.3, height: 0.8) = {
    let text-formatted = align(center, text(size: 7pt, par(justify: false, body)))
    content(
      (start-x, start-y),
      (end-x, start-y - height),
      box(
        text-formatted,
        width: 100%,
        height: 100%,
        inset: (left: 0.0em, right: 0.8em),
      ),
    )
  }

  #let points-on-ellipse(center, radius, n-points) = {
    let (cx, cy) = center
    let (rx, ry) = radius
    let points = ()
    for i in range(n-points) {
      let angle = i * 360deg / n-points
      let right = calc.cos(angle)
      let up = calc.sin(angle)
      let x = cx + right * rx
      let y = cy + up * ry
      points.push((x, y))
    }
    return points
  }

  #let points-on-segment(start, end, n-points) = {
    let (sx, sy) = start
    let (ex, ey) = end
    let points = ()
    for i in range(n-points) {
      let x = sx + (ex - sx) * i / (n-points - 1)
      let y = sy + (ey - sy) * i / (n-points - 1)
      points.push((x, y))
    }
    return points
  }

  #let display-ellipse(center, radius, arrows: (1 / 12, 5 / 12, 9 / 12)) = {
    circle(center, radius: radius, stroke: traj-stroke, mark: (mark: ">"))

    let (cx, cy) = center
    let (rx, ry) = radius

    for arrow in arrows {
      let sx = cx + calc.cos(arrow * 360deg) * rx
      let sy = cy + calc.sin(arrow * 360deg) * ry
      let mark-start = (sx, sy)
      let mark-end = (sx + calc.sin(arrow * 360deg), sy - calc.cos(arrow * 360deg))

      mark(mark-start, mark-end, symbol: ")>", anchor: "center", stroke: none, fill: black)
    }
  }

  #let display-segment(start, end, arrows: (0.33, 0.67)) = {
    line(start, end, stroke: traj-stroke)

    let (sx, sy) = start
    let (ex, ey) = end
    let length = calc.sqrt(calc.pow(sx - ex, 2) + calc.pow(sy - ey, 2))

    for arrow in arrows {
      let mark-start = (arrow * sx + (1 - arrow) * ex, arrow * sy + (1 - arrow) * ey)
      let mark-end = end

      mark(mark-start, mark-end, symbol: ")>", anchor: "center", stroke: none, fill: black)
    }
  }

  #let display-points(points, radius: 0.05, point-color: orange) = {
    for point in points {
      circle(point, radius: radius, fill: point-color, stroke: none)
    }
  }

  #let planars = (
    (
      start: (0, 0),
      end: (2, -0.3),
      point-color: orange,
    ),
    (
      start: (0, -0.3),
      end: (2, -0.6),
      point-color: green,
    ),
    (
      start: (0, -0.6),
      end: (2, -0.9),
      point-color: blue,
    ),
  )
  #let planars-n-points = 8

  #let sine-waves = (
    (
      start: (0, 0),
      end: (2, -0.3),
      point-color: orange,
    ),
    (
      start: (2, -0.3),
      end: (0, -0.6),
      point-color: green,
    ),
    (
      start: (0, -0.6),
      end: (2, -0.9),
      point-color: blue,
    ),
  )
  #let sine-waves-n-points = 8

  #let crosses = (
    (
      start: (0, 0),
      end: (2, -0.5),
      point-color: orange,
    ),
    (
      start: (0, -0.5),
      end: (2, 0),
      point-color: orange,
    ),
    (
      start: (0, -0.3),
      end: (2, -0.8),
      point-color: green,
    ),
    (
      start: (0, -0.8),
      end: (2, -0.3),
      point-color: green,
    ),
    (
      start: (0, -0.6),
      end: (2, -1.1),
      point-color: blue,
    ),
    (
      start: (0, -1.1),
      end: (2, -0.6),
      point-color: blue,
    ),
  )
  #let crosses-n-points = 8

  #let ellipses = (
    (
      center: (0, 0),
      radius: (1, 0.8),
      point-color: orange,
    ),
    (
      center: (0, -0.3),
      radius: (1, 0.8),
      point-color: green,
    ),
    (
      center: (0, -0.6),
      radius: (1, 0.8),
      point-color: blue,
    ),
  )
  #let ellipses-n-points = 18

  #let scale = 1.6
  #let fig-height-row-1 = 5.5em
  #let fig-height-row-2 = 12.5em
  #let row-gutter = 1em
  #let column-gutter = 3em

  #let planar-figure = figure(
    box(
      align(horizon, cetz.canvas(
        x: scale,
        y: scale,
        length: 2cm,
        {
          for (start, end, point-color) in planars {
            on-layer(0, display-segment(start, end))
            on-layer(1, display-points(points-on-segment(start, end, planars-n-points), point-color: point-color))
          }
        },
      )),
      height: fig-height-row-1,
    ),
    caption: [Planar scan.],
  )

  #let sine-wave-figure = figure(
    box(
      align(horizon, cetz.canvas(
        x: scale,
        y: scale,
        length: 2cm,
        {
          for (start, end, point-color) in sine-waves {
            on-layer(0, display-segment(start, end))
            on-layer(1, display-points(points-on-segment(start, end, sine-waves-n-points), point-color: point-color))
          }
        },
      )),
      height: fig-height-row-1,
    ),
    caption: [Sine-wave scan.],
  )

  #let cross-figure = figure(
    box(
      align(horizon, cetz.canvas(
        x: scale,
        y: scale,
        length: 2cm,
        {
          for (start, end, point-color) in crosses {
            on-layer(0, display-segment(start, end))
            on-layer(1, display-points(points-on-segment(start, end, crosses-n-points), point-color: point-color))
          }
        },
      )),
      height: fig-height-row-2,
    ),
    caption: [Cross scan.],
  )

  #let ellipse-figure = figure(
    box(
      align(horizon, cetz.canvas(
        x: scale,
        y: scale,
        length: 2cm,
        {
          for (center, radius, point-color) in ellipses {
            on-layer(0, display-ellipse(center, radius))
            on-layer(1, display-points(points-on-ellipse(center, radius, ellipses-n-points), point-color: point-color))
          }
        },
      )),
      height: fig-height-row-2,
    ),
    caption: [Circular scan.],
  )

  #subpar.super(
    caption: [Illustration in 2D (view from the top) of different types of ALS sensors. inspired from @Wu2026.],
    label: <fig:als-sensors>,
    // align: bottom,
  )[#std.grid(
      columns: 2,
      row-gutter: row-gutter,
      column-gutter: column-gutter,
      planar-figure, sine-wave-figure,
      cross-figure, ellipse-figure,
    )
  ]

  #speaker-note[
    These are the four types of Airborne Lidar Scanning (ALS) sensors used in the LiDAR HD project.
  ]
]

== Roofprints evidence

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
    caption: [Two examples of the height differences obtained on a scan line. Black points are vegetation points, and for the other points the colour represents the value of $Delta h$, with blue-green-yellow-red from low to high values.],
  )
  #v(1fr)
]

== Assign a score to roofprints

#{
  let factor = 250%
  figure(
    scale(
      fig-edge-matching-criterion(
        num-points-uniform: 30,
        num-points-around: 50,
        edge-start: (0, 0),
        edge-end: (6, 3),
        rand-seed: 1,
      ),
      factor,
      reflow: true,
    ),
    caption: [Illustration in 2D (view from the top) of the proximity score for an edge.],
  )

  speaker-note[
    The score assigned to each edge is based on the projection of each point on the edge and the distance to it.
    A comparison between the normal of the edge and the normal of the points is also used to enforce correct orientations.
  ]
}

== Need for regularization

#slide(repeat: 2, self => [
  #let (uncover, only, alternatives) = utils.methods(self)

  #v(1fr)
  #let image-width = 5cm
  #subpar.grid(
    columns: (1fr,) * 4,
    align: center + top,
    row-gutter: 0.0cm,
    column-gutter: 0.0cm,
    grid.cell(
      figure(
        image(
          "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_00-initial.png",
          width: image-width,
        ),
        caption: [Initial state],
      ),
      colspan: 4,
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.00$ (no regularisation)],
    ),
    uncover("2-")[#figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_05-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.05$],
    )],
    uncover("2-")[#figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=0_20-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.20$],
    )],
    uncover("2-")[#figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-half/alpha=1_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 1.00$],
    )],

    caption: [#uncover(
      "2-",
    )[Matching a circle to a half-circle of points with different values of the regularization parameter $alpha$.]],
  )
  #v(1fr)

  #speaker-note[
    #only("1")[
      There is also a need for regularization, because without it, the shape can be arbitrarily deformed into a shape very different from the initial one.
    ]
    #only("2")[
      We can see how regularization helps to get a shape more similar to the target even with half of the points missing.
    ]
  ]
])

#slide[
  #v(1fr)
  #let image-width = 5cm
  #subpar.grid(
    columns: (1fr,) * 4,
    align: center + top,
    row-gutter: 0.0cm,
    column-gutter: 0.0cm,
    grid.cell(
      figure(
        image(
          "../../images/results-2026_04_20/Criterion_toy_results/square-half-small/alpha=0_00-initial.png",
          width: image-width,
        ),
        caption: [Initial state],
      ),
      colspan: 4,
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
  #let image-width = 5cm
  #subpar.grid(
    columns: (1fr,) * 4,
    align: center + top,
    row-gutter: 0.0cm,
    column-gutter: 0.0cm,
    grid.cell(
      figure(
        image(
          "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-half/alpha=0_00-initial.png",
          width: image-width,
        ),
        caption: [Initial state],
      ),
      colspan: 4,
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
  figure(
    image("../../images/results-2026_04_20/Interesting_building_1/LiDAR_HD=Classification.png", height: 90%),
    caption: [Coloured by classification.],
  ),
  figure(
    image("../../images/results-2026_04_20/Interesting_building_1/LiDAR_HD=Height.png", height: 90%),
    caption: [Coloured by height.],
  ),
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
  figure(
    image("../../images/results-2026_04_20/Interesting_building_1/Roof_edge_points=InwardVectorX.png", height: 90%),
    caption: [Coloured by the X component.],
  ),
  figure(
    image("../../images/results-2026_04_20/Interesting_building_1/Roof_edge_points=InwardVectorY.png", height: 90%),
    caption: [Coloured by the Y component.],
  ),
)

#speaker-note[
  - The detected roof edge points are shown here, coloured by their *inward vector* (the direction in which the building is located from the edge).
  - We can see that the inward vectors are *generally well oriented* towards the building, except in areas where the building is *very close to vegetation* at the same height.
]

---

#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [Comparison of BD TOPO outlines and roofprints computed with our algorithm.],
  figure(
    image("../../images/results-2026_04_20/Interesting_building_1/BD_TOPO.png", height: 90%),
    caption: [Initial outlines in the BD TOPO.],
  ),
  figure(
    image("../../images/results-2026_04_20/Interesting_building_1/New_algorithm_with_inward_vectors.png", height: 90%),
    caption: [Final roofprint produced by the algorithm.],
  ),
)

#speaker-note[
  - Interestingly, this building unit is actually divided into *two parts in the BD TOPO*, even though we could expect 1 or 3 as well.
  - The results give a much better alignment, despite:
    - the neighbouring building that is very close
    - the lack of identified points on roof edges between the two polygons
    - the wrong identification of some vegetation points as roof edges
]

= Footprints

== Footprints evidence

#{
  let current-speaker-notes = [
    - Process:
      + Build the roof in 3D using a 3D roof constructor (such as #link("https://github.com/3DBAG/roofer")[roofer]) with the roofprints as input
      + Select all the points *under* the 3D roof with a small horizontal buffer (for the scoring function) and a small vertical buffer (for roof points slightly below the roof)
    - It seems very simple in practice but actually requires to use the complex roof reconstruction algorithms developed in the past few years.
  ]
  speaker-note[
    #current-speaker-notes
  ]
  let fig-height = 85%
  let caption = [Illustration of the 3D roof structure and the selected points for the footprint computation.]
  v(1fr)

  subpar.grid(
    columns: (auto, auto),
    align: center + horizon,
    caption: caption,
    image("../../images/2026_06_22/Roof_3D.png", height: fig-height),
    image("../../images/2026_06_22/Footprints_points_3D.png", height: fig-height),
  )

  v(1fr)
}

== Illustration with a real building

#{
  speaker-note[
    Example where it works well:
    - the footprint is *properly aligned* with the façade points
    - we can see *significant roof overhangs for façades oriented west/east* and no significant roof overhangs for north/south, as expected from the orientation of the slanted roof
    - the final footprint is *very close to the initial one from BD TOPO* in terms of shape, with a much better alignment on the point cloud
  ]
  let fig-height = 95%
  v(1fr)

  subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    caption: [Illustration of the computed footprints.],
    image("../../images/2026_06_12/Footprints-Example_1-Points_Classification.png", height: fig-height),
    image("../../images/2026_06_12/Footprints-Example_1-Points_Z.png", height: fig-height),
  )

  v(1fr)

  [---]

  speaker-note[
    Example where it doesn't work well:
    - many points were selected even though they are actually on the roof
    - this resulted in some edges aligning on structures in the roof instead of on the façades
  ]
  let fig-height = 95%
  v(1fr)

  subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    caption: [Illustration of the computed footprints.],
    image("../../images/2026_06_12/Footprints-Example_2-Points_Classification.png", height: fig-height),
    image("../../images/2026_06_12/Footprints-Example_2-Points_Z.png", height: fig-height),
  )

  v(1fr)
}

= Conclusion

== Conclusion

#slide[
  #set text(size: 20pt)
  #align(center + horizon, table(
    columns: 2,
    inset: (x: 1.0em, y: 0.4em),
    table.header([Result of the thesis], [Benefit]),
    table.cell(rowspan: 2, [Roofprint and footprint]), [More precise computations with 2D data], [LoD2.2 -> LoD2.3],
    table.cell(rowspan: 2, [Better georeferencing]), [Better visualisation in context], [Better 3D roof models],
  ))
]

= The end <touying:hidden>

#ending-slide(
  title: [Thank you for your attention!],
  subtitle: none,
  content: [
    #import "@preview/tiaoma:0.3.0"
    #let slides-link = "https://alexandre-bry.github.io/MSc_Thesis-Report/slides_pages/2026_06_26-A4.html"

    Link to the slides:

    #link(slides-link)

    #v(spacing-md)

    #tiaoma.qrcode(slides-link, options: (
      scale: 2.5,
      fg-color: theme-colors.header-bg,
      bg-color: theme-colors.header-text,
    ))
  ],
  contact: ("alexandre.bry@ign.fr", "abry@tudelft.nl"),
)

#bibliography-slide(
  bib-content: bibliography("../../references/MSc_Thesis-Bibliography.bib", style: "apa", title: none),
)

#show: appendix

#heading([Appendix], depth: 1, outlined: false)

== Results

#slide[
  #figure(
    image("../../images/Final_report/Validation_992/Validation_dataset-Ozoir_north-BD_TOPO.png"),
    caption: [BD TOPO.],
  )
][
  #figure(
    image("../../images/Final_report/Validation_992/Validation_dataset-Ozoir_north-Roofprints_3.png"),
    caption: [Roofprints after 3 iterations.],
  )
]

#slide[
  #figure(
    image("../../images/Final_report/Validation_992/Validation_dataset-Ozoir_south-BD_TOPO.png"),
    caption: [BD TOPO.],
  )
][
  #figure(
    image("../../images/Final_report/Validation_992/Validation_dataset-Ozoir_south-Roofprints_3.png"),
    caption: [Roofprints after 3 iterations.],
  )
]
#slide[
  #figure(
    image("../../images/Final_report/Validation_992/Validation_dataset-Paris-BD_TOPO.png"),
    caption: [BD TOPO.],
  )
][
  #figure(
    image("../../images/Final_report/Validation_992/Validation_dataset-Paris-Roofprints_3.png"),
    caption: [Roofprints after 3 iterations.],
  )
]

== Overview of the methodology

#figure(
  image("../../diagrams/Overview_of_pipeline-updated-v2.drawio.png", width: 70%),
  caption: [Overview of the pipeline.],
)

#speaker-note[
  - We start with the roofprint because aerial LiDAR data gives a much higher density of points on the roof than on the façades, making the roof much easier to identify.
  - Then, once the roofprint is accurately registered on the point cloud, we can use it to generate an accurate 3D roof model that allows to select all the points below the roof (hopefully façade and ground points), which are all the points that provide information about the façades and the roof overhangs.
]
