#import "../slides_theme/theme.typ": *

#import "@preview/lilaq:0.5.0" as lq
#import "@preview/subpar:0.2.2"

#import "illustrations.typ": *

#let handout = sys.inputs.at("handout", default: "false") == "true"
#let notes = sys.inputs.at("notes", default: "true") == "true"
#let theme = sys.inputs.at("theme", default: "ign")

#let variant = "light"

#show: slides-theme.with(
  config-info(
    title: [From Points to Prints],
    subtitle: [Monthly Meeting (3)],
    author: [Alexandre Bry],
    date: datetime(day: 18, month: 5, year: 2026),
    institution: [IGN, TU Delft],
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
    image("../../images/IGN_logo-cropped.svg", width: 5em),
    dx: -2em,
    dy: 2em,
  ),
  place(
    bottom + right,
    image("../../images/TU_Delft_logo-cropped.svg", width: 9em),
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

== Objective

#v(7em)
#highlight-box()[
  #set text(style: "italic", size: 24pt)
  Generate for each building a *roofprint* and a *footprint* coherent with that roofprint, and by doing so estimate the *roof overhangs*.
]

#speaker-note[
  In practice our goal is to identify the roof overhangs in 3D, which is equivalent to finding the horizontal gap between the roof edge and the façade if the roof plane is known.
  Therefore, generating a roofprint and a footprint is enough, and we assume that the footprint is most of the time coherent with the roofprint, meaning that its edges will be parallel to the roof edges.
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

= Roof edge points

== Point cloud topology

#{
  let factor = 170%
  set text(size: size-body * (100% / factor))
  figure(
    box(scale(fig-point-cloud-topology(), factor, reflow: true), inset: 1em),
    caption: [Illustration of the structure of an ALS point cloud.],
  )
}

#speaker-note[
  - This creates a *hierarchy* in the point cloud, with points belonging to pulses, pulses belonging to scan lines, and scan lines belonging to flight strips.
  - With multiple flight strips in the same area, this creates a sort of *irregular 3D structure*:
    - 1st dimension: the flight strip
    - 2nd dimension: the scan line
    - 3rd dimension: the pulse
    It is then possible to *navigate* in this structure along any of these dimensions.
]

---

#v(1fr)
#subpar.grid(
  columns: (auto, auto, auto),
  align: center + horizon,
  caption: [Different visualizations of one flight strip.],
  figure(
    image("../../images/results_A2/Flight_strip/Flight_strip-Intensity.png", height: 90%),
    caption: [Points coloured by intensity.],
  ),
  figure(
    image("../../images/results_A2/Flight_strip/Flight_strip-Height.png", height: 90%),
    caption: [Points coloured by height.],
  ),
  figure(
    image("../../images/results_A2/Flight_strip/Flight_strip-Classification.png", height: 90%),
    caption: [Points coloured by classification.],
  ),
)
#v(1fr)

#speaker-note[
  Different visualizations of a part of a flight strip, cropped to fit in a given LiDAR HD tile.
]

---

#v(1fr)
#subpar.grid(
  columns: (auto, auto, auto),
  align: center + horizon,
  caption: [Visualization of the topology of the point cloud, with points coloured by their GPS Time.],
  figure(
    image("../../images/results_A2/Flight_strip/Flight_strip-GpsTime-All.png", height: 90%),
    caption: [All points of one flight strip.],
  ),
  figure(
    image("../../images/results_A2/Flight_strip/Flight_strip-GpsTime-ScanDirectionFlag=0.png", height: 90%),
    caption: [Front scan line.],
  ),
  figure(
    image("../../images/results_A2/Flight_strip/Flight_strip-GpsTime-ScanDirectionFlag=1.png", height: 90%),
    caption: [Back scan line.],
  ),

  column-gutter: 0em,
)
#v(1fr)

#speaker-note[
  Due to the ellipsoidal scanning pattern of the LiDAR scanner, the GPS Time values follow a *curved pattern*, and are mixed up when looking at the whole flight strip.
  However, using the *Scan Direction Flag* to separate front and back scan lines shows the distribution.
]

== Edge points detection

We use the *height differences between consecutive points* on the same scan line to identify points that are likely to be on the edges of roofs.

#{
  let images = (
    image("../../images/results_A2/Edge_points/Scan_line-Vertical_gain-1.png"),
    image("../../images/results_A2/Edge_points/Scan_line-Vertical_gain-3.png"),
  )
  figure(
    grid(
      rows: 35%,
      inset: 0.2em + 1pt,
      row-gutter: 0.5em,
      stroke: 1pt,
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

= Creation of the roofprints

== Constraints over the movements

We modify the polygons by applying the following rules:
- *Never rotate an edge.*
- *Never flip an edge.*
- *Move overlapping edges together.*

#pause

This ensures that we *preserve some topology* while keeping a *lot of freedom* for the edges to move.

#pause

#v(0.5em)
#{
  let fig-height = 50%
  grid(
    columns: (7em, auto),
    align: (left + top, center + horizon),
    [
      #set par(justify: false)
      However it is not perfect as it can *separate two points* that were initially at the same position.
    ],
    subpar.grid(
      columns: (1fr, 1fr),
      align: center + horizon,
      image("../../images/results-2026_04_20/Topological_issues/One_point_becomes_two.png", height: fig-height),
      image(
        "../../images/results-2026_04_20/Topological_issues/One_point_becomes_two-Annotated.png",
        height: fig-height,
      ),

      caption: [Two vertices at the exact same position become two distinct vertices at the boundary between two buildings.],
    ),
  )
}

== General idea

#speaker-note[
  The ideas behind this slide is actually quite simple:
  - We want to *move edges* without rotating them, so it is easier to simply consider them as *lines* that we shift
  - By considering lines, the definition of points depends on the *intersection with the previous and next lines*, therefore not flipping edges becomes a simple property about 3 lines.
  - Translating the whole polygon in one direction preserves the topology completely, so we know that there will be a *solution for any shift applied to the focus edge*.
]

We modify the polygons by applying the following rules:
- *Never rotate an edge.*
- *Never flip an edge.*
- *Move overlapping edges together.*

#pause

We focus on *edges one by one*, except for overlapping edges which are treated together.
Edges are treated as *directed lines*, which can be translated in any direction, but not rotated.

#pause

Therefore, to satisfy the constraints described previously, there is only one property $cal(P)(l)$ that we need to preserve for each line $l$, regarding its previous line $l^-$ and next line $l^+$:

#align(center, strong(emph(
  [The intersection between $l$ and $l^-$ should occur before the intersection between $l$ and $l^+$.],
)))

This property is *equivalent to not flipping the edge $l$*.

#pause

Moreover, we know that if we shift $l$, $l^-$ and $l^+$ by the *same extent in the same direction*, this property will still hold for $l$.

---

== Our simple approach

#speaker-note[
  The general idea behind this algorithm is simple.
  The only configuration where we know for sure that three lines satisfy the property $cal(P)$ is when they are all shifted by the same extent in the same direction.
  Therefore, as soon as we have an issue somewhere, we move into this configuration, and keep iterating over the consecutive edges until there is no issue any more.

  This is not optimal at all, but trying to shift the edges exactly by the extent needed to satisfy the property $cal(P)$ turned out to be much more complex and difficult when experimenting with it.
]

Simple algorithm to find a correct configuration given a line $l_0$ to move by an extent $delta$:

1. Compute the shift direction as the normal $arrow(n)$ of $l_0$.
2. Move $l_0$ by $delta arrow(n)$.
3. If $cal(P)(l_0)$ is not satisfied, move $l_0^-$ and $l_0^+$ by $delta arrow(n)$ as well.
  This ensures that $cal(P)(l_0)$ is satisfied.
4. Set $l_p = l_0^-$.
  While either of $cal(P)(l_p)$, $cal(P)(l_p^-)$ or $cal(P)(l_p^+)$ is not satisfied, move $l_p$ by $delta arrow(n)$ (if not already moved) and set $l_p = l_p^-$.
5. Set $l_n = l_0^+$.
  While either of $cal(P)(l_n)$, $cal(P)(l_n^-)$ or $cal(P)(l_n^+)$ is not satisfied, move $l_n$ by $delta arrow(n)$ (if not already moved) and set $l_n = l_n^+$.

#pause

#alert-box[
  The only guarantees of this algorithm is that it will *terminate* and that the resulting configuration will *satisfy the constraints*.

  However, it will *not find an optimal solution*, and in particular, it is *not continuous* with respect to $delta$.
]

== Illustrations of the polygon deformation algorithm

Illustrations can be viewed by following this link: #link("https://alexandre-bry.github.io/MSc_Thesis-Report/monthly_notes/2026_04_20.html#gifs-that-could-not-be-included-in-the-slides")

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

== Definition of the proximity score

#let figure-width = 6cm
#slide(composer: (1fr, figure-width))[

  The score of a point $p_i$ for an edge $l_j$ is defined as follows:
  - The score is 0 if any of the following conditions is true:
    - The orthogonal projection $p_(i perp j)$ of $p_i$ on the line supporting of $l_j$ is outside of the segment $l_j$.
    - The distance from $p_i$ to $p_(i perp j)$ is greater than a certain threshold $epsilon$.
    - The dot product of the inward vector $v_i$ of $p_i$ with the normal $n_j$ of $l_j$ oriented towards the inside of the building is negative.
  - Otherwise, the score is: $ "score"(p_i, l_j) = underbrace((v_i dot n_j), "alignment of\npoint and edge\n'normals'") times underbrace((1 - (|p_i - p_(i perp j)|) / epsilon), "proximity to the edge") >= 0 $

  We use $epsilon = 30 "centimetres"$.

  #speaker-note[
    - Any point *outside the rectangle* defined by extruding the edge along its normal by $epsilon$ has a score of 0.
      This geometric ensures that only points that are close enough to the edge will count.
    - Then, the dot product between the inward vector and the normal of the edge ensures that points that are part of a parallel but opposite edge will not count, *preventing matching to the neighbour building*.
  ]
][
  #context {
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

== Definition of the inward direction

#slide[
  The goal of the *inward direction* is to be as close as possible to the 2D normal of the roof edge, pointing towards the inside of the building.
  To compute it for a given point $p_i$, we use the following method:
  1. Identify all the points $p_j$ that are less than a certain distance $delta$ from $p_i$.
  2. For each point $p_j$, compute the vector from $p_i$ to $p_j$, and normalize it into a unit vector $u_(i -> j)$.
  3. Compute the inward vector $v_i$ as the average of the vectors $u_(i -> j)$: $ v_i = 1/ (|cal(B)(p_i, delta)|) sum_(p_j in cal(B)(p_i, delta)) (p_j - p_i) / (|p_j - p_i|) $

  We use $delta = 2 "metres"$.

  #speaker-note[
    - The idea behind this method is that points on the edge of the roof should have *many points towards the inside* of the building, and *few points towards the outside*.
    - Using unit vectors and averaging them allows for all points in the neighbourhood to contribute equally, meaning that we are somewhat counting the *density of points* in each direction.
      Therefore, the *magnitude* of the inward vector is an indication of the confidence of the direction.
  ]
]

== Illustrations of matching the edges to the points

Illustrations can be viewed by following this link: #link("https://alexandre-bry.github.io/MSc_Thesis-Report/monthly_notes/2026_04_20.html#gifs-that-could-not-be-included-in-the-slides")


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

#slide[
  #v(1fr)
  #let image-width = 60%
  #subpar.grid(
    columns: (1fr, 1fr, 1fr),
    align: center + horizon,
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-holed/alpha=0_00-initial.png",
        width: image-width,
      ),
      caption: [Initial state],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-holed/alpha=0_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.00$ (no regularization)],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-holed/alpha=0_05-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.05$],
    ),

    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-holed/alpha=0_20-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.20$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-holed/alpha=0_50-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.50$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-holed/alpha=1_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 1.00$],
    ),

    caption: [Matching a circle to points along half of its boundary with different values of the regularization parameter $alpha$.],
  )
  #v(1fr)

  #speaker-note[
    At the cost of more iterations, *a larger $alpha$ outputs a more regular shape*, closer in proportions to the initial one.
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

+ Move the 2D roofprints to 3D creating a *3D roof outline*
+ Look for points *under* the 3D roof outline and *towards the inside* of the building

#alternatives[][#{
    let fig-height = 67%
    v(1fr)
    subpar.grid(
      columns: (auto, auto),
      align: center + horizon,
      caption: [Illustration of the 3D roof outline.],
      image("../../images/2026_05_07/Example_building-3D_roofprints-1.png", height: fig-height),
      image("../../images/2026_05_07/Example_building-3D_roofprints-2.png", height: fig-height),
    )
    v(1fr)
  }
][#{
    let fig-height = 67%
    v(1fr)
    subpar.grid(
      columns: (auto, auto),
      align: center + horizon,
      caption: [Illustration of the footprint points.],
      image("../../images/2026_05_07/Example_building-Footprint_points-1.png", height: fig-height),
      image("../../images/2026_05_07/Example_building-Footprint_points-2.png", height: fig-height),
    )
    v(1fr)
  }
]

= Creation of the footprints

== Creation of the footprints

- *Sweep each roof edge towards the inside* up to 1.5 metres and select the best scoring position #pause
- The score has two components:
  + A *proximity term* that counts the number of points close to the edge
  + A *penalty term* that penalizes points that are behind the edge (inside the building)

#pause

#{
  import "../../figures/footprints/footprints-loss.typ": fig-footprints-loss

  figure(
    fig-footprints-loss(width: 65%, height: 65%, title: [Score of a point $p$ for a footprint edge $e$]),
  )
}

---

#{
  let fig-height = 95%
  v(1fr)
  subpar.grid(
    columns: (auto, auto),
    align: center + horizon,
    caption: [Illustration of the computed footprints.],
    image("../../images/2026_05_07/Example_building-Footprint-Classification.png", height: fig-height),
    image("../../images/2026_05_07/Example_building-Footprint_with_roofprint-Classification.png", height: fig-height),
  )
  v(1fr)
}

---

#{
  let fig-height = 95%
  v(1fr)
  subpar.grid(
    columns: (auto, auto),
    align: center + horizon,
    caption: [Illustration of the computed footprints.],
    image("../../images/2026_05_07/Example_building-Footprint-Height.png", height: fig-height),
    image("../../images/2026_05_07/Example_building-Footprint_with_roofprint-Height.png", height: fig-height),
  )
  v(1fr)
}

= The end <touying:hidden>

#ending-slide(
  title: [Thank you for your attention!],
  subtitle: [
    #import "@preview/tiaoma:0.3.0"

    #tiaoma.qrcode("https://alexandre-bry.github.io/MSc_Thesis-Report/monthly_notes/2026_05_18.html", options: (
      scale: 3.5,
      fg-color: theme-colors.header-bg,
      bg-color: theme-colors.header-text,
    ))
  ],
  contact: ("alexandre.bry@ign.fr",),
)

#bibliography-slide(
  bib-content: bibliography("../../references/MSc_Thesis-Bibliography.bib", style: "apa", title: none),
)

// #show: appendix

// #heading([Appendix], depth: 1, outlined: false)
