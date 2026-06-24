#import "../slides_theme/theme.typ": *

#import "@preview/lilaq:0.5.0" as lq
#import "@preview/subpar:0.2.2"

#import "illustrations.typ": *

#let handout = sys.inputs.at("handout", default: "false") == "true"
#let notes = sys.inputs.at("notes", default: "true") == "true"
#let theme = sys.inputs.at("theme", default: "ign")

#show: slides-theme.with(
  config-info(
    title: [From Points to Prints],
    subtitle: [Monthly Presentation (3)],
    author: [Alexandre Bry],
    date: datetime(day: 20, month: 4, year: 2026),
    institution: none,
  ),
  config-common(
    show-notes-on-second-screen: if notes { right } else { none },
    handout: handout,
    notes: notes,
  ),
  variant: "light",
  colortheme: theme,
  progressbar: "foot",
  header-style: "moloch",
)


#set par(justify: true)

#let SHOW-FIGURES = true

= Title <touying:hidden>

#title-slide(layout: "centered", logos: (
  place(
    bottom + left,
    box(width: 9em, align(center + bottom, image("../../images/TU_Delft_logo-cropped.svg", width: 9em))),
    dx: -3em,
    dy: -1em,
  ),
  place(
    bottom + right,
    box(width: 9em, align(center + bottom, image("../../images/IGN_logo-cropped.svg", width: 5em))),
    dx: 3em,
    dy: -1em,
  ),
))

= Outline <touying:hidden>

#outline-slide(title: "Outline")

= Context

== Planned pipeline

#image("../../diagrams/Overview_of_pipeline.drawio.png")

== General structure

General structure of the method:
- *Identifications of points* to deform the polygons on.
- *Creation of a set of candidate configurations*:
  - By translating each edge perpendicularly to itself.
  - The other edges are translated if necessary to keep the same topology.
- *Definition of a criterion to evaluate the quality of each configuration*, based on:
  - The position of the points.
  - Weights computed for the points.
  - The initial configuration of the edges.

= Point cloud topology

== Point cloud topology

#example-box(title: "Pulse")[
  A single emission of the LiDAR sensor, which may result in *zero, one or more echoes* (points) depending on the number of surfaces the pulse hits.
]

#example-box(title: "Scan line")[
  A *set of pulses* emitted during one rotation of the LiDAR scanner.
]

#example-box(title: "Flight strip")[
  A *set of scan lines* collected along one pass of the aircraft over the ground.
]

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

== Flight strips trajectories

- Trajectories are computed using *multi-echo pulses* (code written by #link("https://whuwuteng.github.io/")[Wu Teng])
- Necessity to *reconcatenate the different parts of each flight strip* for better precision (not done yet)

#highlight-box()[
  This method allows to use the trajectory *without relying on its availability*.
]

#speaker-note[
  - I use code written by #link("https://whuwuteng.github.io/")[Wu Teng] to *retrieve the trajectory* of the scanning vehicle, using *multi-echo pulses*
  - The precision of the method increases with the number of multi-echo pulses, meaning that it is necessary to *reconcatenate the different parts of each flight strip* (scattered between tiles) in order to get a good estimation of the trajectory.
  - This method allows to use the trajectory *without relying on its availability*, and therefore without adding new requirements on the input data.
]
== Edge points

We use the *height differences between consecutive points* on the same scan line to identify points that are likely to be on the edges of roofs (more details in the slides of the previous presentation).

#{
  let fig-height = 35%
  let line-width = 0.1em
  let images = (
    image("../../images/results_A2/Edge_points/Scan_line-Vertical_gain-1.png"),
    image("../../images/results_A2/Edge_points/Scan_line-Vertical_gain-3.png"),
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

= Candidate roofprint configurations

== Constraints over the movements

We modify the polygons by applying the following rules:
- *Never rotate an edge.*
- *Never flip an edge.*
- *Move overlapping edges together.*

#pause

This ensures that we *preserve some topology* while keeping a *lot of freedom* for the edges to move.
However, this *does not ensure that we preserve the same topology*, as can be seen in the examples in the next slides.

#pause

In practice, we only ensure that:
- At the level of one polygon, for each edge:
  - The edge is never flipped.
  - Therefore its two neighbours do not intersect.
- At the level of multiple buildings:
  - Two initially overlapping edges will remain collinear (not necessarily overlapping).

#slide[
  === One point becomes two

  #v(1fr)
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    image("../../images/results-2026_04_20/Topological_issues/One_point_becomes_two.png"),
    image("../../images/results-2026_04_20/Topological_issues/One_point_becomes_two-Annotated.png"),

    caption: [Two vertices at the exact same position become two distinct vertices at the boundary between two buildings.],
  )
  #v(1fr)

  #speaker-note[
    - Simplest example of topology breaking: the shared edge between two buildings was moved by the same extent for both, but *the neighbouring edge of each building was moved by a different extent*, resulting in the shared vertex being split into two distinct vertices.
    - Fixing this is *theoretically simple*: it requires only to authorize more than two edges per vertex, and therefore more than two neighbours per edge.
      However, it may not always be easy to identify which edges from different buildings are connected, especially when there is no shared vertex.
      This is the case with the final situation in red for the vertex on the right: it is part of one building but not of the other.
  ]
]

#slide[
  === One point becomes two

  #v(1fr)
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    image("../../images/results-2026_04_20/Topological_issues/Buildings_connected_by_vertex_lose_connection.png"),
    image(
      "../../images/results-2026_04_20/Topological_issues/Buildings_connected_by_vertex_lose_connection-Annotated.png",
    ),

    caption: [Two vertices at the exact same position become two distinct vertices at the boundary between two buildings.],
  )
  #v(1fr)

  #speaker-note[
    - Similar situation except there was not even a shared edge between the two buildings, only a shared vertex.
    - The conclusion about the solution is the same, if we manage to merge the two vertices into one, we can prevent this issue.
  ]
]

#slide[
  === One point becomes two and Two buildings intersect
  #let width = 90%

  #v(1fr)
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    figure(
      image("../../images/results-2026_04_20/Topological_issues/Buildings_intersection_and_switch.png", width: width),
      caption: [Before],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Topological_issues/Buildings_intersection_and_switch-Annotated.png",
        width: width,
      ),
      caption: [After],
    ),

    caption: [Two buildings that were initially separate end up intersecting after the deformation.],
  )
  #v(1fr)

  #speaker-note[
    - Here, the issue comes from the fact that the shared vertex is considered separately for each building.
      Therefore, moving the edge of the building on the right does not move the edge of the building on the left.
    - Like the previous examples, this could be fixed by *rebuilding the actual topology including shared vertices*, instead of only polygons and shared edges.
  ]
]

#slide[
  === Two buildings intersect

  #v(1fr)
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    figure(image("../../images/results-2026_04_20/Topological_issues/Buildings_intersection_1.png"), caption: [Before]),
    figure(image("../../images/results-2026_04_20/Topological_issues/Buildings_intersection_2.png"), caption: [After]),

    caption: [Two buildings that were initially separate end up intersecting after the deformation.],
  )
  #v(1fr)

  #speaker-note[
    - Here, we have a relatively simple situation where two non-overlapping buildings end up intersecting after the deformation.
    - Fixing this would require potentially complex operations and structures to *efficiently check for intersections between all pairs of edges of different buildings* at each iteration.
      This also means *increasing the number of edges to consider together for optimization*, as any two buildings that are close enough to potentially intersect would need to be optimized together.
  ]
]

#slide[
  === One building self-intersects
  #let width = 55%

  #v(1fr)
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    figure(
      image("../../images/results-2026_04_20/Topological_issues/Self_intersection_1.png", width: width),
      caption: [Before],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Topological_issues/Self_intersection_2.png",
        width: width,
      ),
      caption: [After],
    ),

    caption: [Two opposite sides of the same building that were initially close end up intersecting after the deformation.],
  )
  #v(1fr)

  #speaker-note[
    - Here we can see that *no edge was flipped*, but the left and the right side of the polygon were pulled closer together, resulting in a self-intersection.
    - This result is only possible because the polygon is *not convex*.
    - One way to prevent this would be to check not only for edge flips, but also for *intersections between non-neighbour edges* of the same polygon, but this would be much more costly to check.
  ]
]

== General idea

#uncover("1-")[
  We focus on *edges one by one*, except for overlapping edges which are treated together.
  Edges are treated as *directed lines*, which can be translated in any direction, but not rotated.
]

#uncover("2-")[
  Therefore, to satisfy the constraints described previously, there is only one property $cal(P)(l)$ that we need to preserve for each line $l$, regarding its previous line $l^-$ and next line $l^+$:

  #align(center, strong(emph(
    [The intersection between $l$ and $l^-$ should occur before the intersection between $l$ and $l^+$.],
  )))

  This property is *equivalent to not flipping the edge $l$*.
]

#uncover("3-")[
  Moreover, we know that if we shift $l$, $l^-$ and $l^+$ by the *same extent in the same direction*, this property will still hold for $l$.
]

#speaker-note[
  The ideas behind this slide is actually quite simple:
  - We want to *move edges* without rotating them, so it is easier to simply consider them as *lines* that we shift
  - By considering lines, the definition of points depends on the *intersection with the previous and next lines*, therefore not flipping edges becomes a simple property about 3 lines.
  - Translating the whole polygon in one direction preserves the topology completely, so we know that there will be a *solution for any shift applied to the focus edge*.
]

---

== Our simple approach

#uncover("1-")[
  Simple algorithm to find a correct configuration given a line $l_0$ to move by an extent $delta$:

  1. Compute the shift direction as the normal $arrow(n)$ of $l_0$.
  2. Move $l_0$ by $delta arrow(n)$.
  3. If $cal(P)(l_0)$ is not satisfied, move $l_0^-$ and $l_0^+$ by $delta arrow(n)$ as well.
    This ensures that $cal(P)(l_0)$ is satisfied.
  4. Set $l_p = l_0^-$.
    While either of $cal(P)(l_p)$, $cal(P)(l_p^-)$ or $cal(P)(l_p^+)$ is not satisfied, move $l_p$ by $delta arrow(n)$ (if not already moved) and set $l_p = l_p^-$.
  5. Set $l_n = l_0^+$.
    While either of $cal(P)(l_n)$, $cal(P)(l_n^-)$ or $cal(P)(l_n^+)$ is not satisfied, move $l_n$ by $delta arrow(n)$ (if not already moved) and set $l_n = l_n^+$.
]

#uncover("2-")[#alert-box[
    The only guarantees of this algorithm is that it will *terminate* and that the resulting configuration will *satisfy the constraints*.

    However, it will *not find an optimal solution*, and in particular, it is *not continuous* with respect to $delta$.
  ]
]

---

== Illustrations

#slide[
  #v(1fr)
  #let image-width = 85%
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Polygon_deformation/circle.gif",
      image("../../images/results-2026_04_20/Polygon_deformation/circle.gif", width: image-width),
    ),
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Polygon_deformation/polygon_simple.gif",
      image("../../images/results-2026_04_20/Polygon_deformation/polygon_simple.gif", width: image-width),
    ),

    caption: [Simple illustrations of the polygon deformation algorithm (click to view the animated versions).],
  )
  #v(1fr)
]

#slide[
  #v(1fr)
  #let image-width = 90%
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Polygon_deformation/polygon_simple_noisy-0.gif",
      image("../../images/results-2026_04_20/Polygon_deformation/polygon_simple_noisy-0.gif", width: image-width),
    ),
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Polygon_deformation/polygon_2-0.gif",
      image("../../images/results-2026_04_20/Polygon_deformation/polygon_2-0.gif", width: image-width),
    ),

    caption: [More complex illustrations of the polygon deformation algorithm (click to view the animated versions).],
  )
  #v(1fr)
]

#slide[
  #v(1fr)
  #let image-width = 90%
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Polygon_deformation/polygon_simple_noisy-4.gif",
      image("../../images/results-2026_04_20/Polygon_deformation/polygon_simple_noisy-4.gif", width: image-width),
    ),
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Polygon_deformation/polygon_3-13.gif",
      image("../../images/results-2026_04_20/Polygon_deformation/polygon_3-13.gif", width: image-width),
    ),

    caption: [Illustrations of self-intersections with the polygon deformation algorithm (click to view the animated versions).],
  )
  #v(1fr)

  #speaker-note[
    There we can see two different examples of how the algorithm can create configurations with *self-intersections*.
  ]
]

= Criterion

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

---

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

== Illustrations

#slide[
  #v(1fr)
  #let image-width = 85%
  #subpar.grid(
    columns: (1fr, 1fr),
    align: center + horizon,
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Criterion_toy_results/circle-default/alpha=0_20-iterations.gif",
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/circle-default/alpha=0_20-iterations.gif",
        width: image-width,
      ),
    ),
    link(
      "https://alexandre-bry.github.io/MSc_Thesis-Report/images/results-2026_04_20/Criterion_toy_results/weird_polygon-default/alpha=0_20-iterations.gif",
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/weird_polygon-default/alpha=0_20-iterations.gif",
        width: image-width,
      ),
    ),

    caption: [Simple illustrations of the full polygon deformation algorithm (click to view the animated versions).],
  )
  #v(1fr)

  #speaker-note[
    Here and in the following, this figures show:
    - In blue, the points we match to
    - In red, the current version of the polygon, with each edge numbered and vertices shown in orange
    - At the top, the number of iterations (i.e. the number of times we went through all the edges) and the sum of the shifts performed during the last iteration, which is an indication of the convergence of the algorithm.
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
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-large/alpha=0_00-initial.png",
        width: image-width,
      ),
      caption: [Initial state],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-large/alpha=0_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.00$ (no regularization)],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-large/alpha=0_05-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.05$],
    ),

    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-large/alpha=0_20-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.20$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-large/alpha=0_50-final.png",
        width: image-width,
      ),
      caption: [$alpha = 0.50$],
    ),
    figure(
      image(
        "../../images/results-2026_04_20/Criterion_toy_results/square-half-large/alpha=1_00-final.png",
        width: image-width,
      ),
      caption: [$alpha = 1.00$],
    ),

    caption: [Matching a square to points along two sides of a smaller square with different values of the regularization parameter $alpha$.],
  )
  #v(1fr)

  #speaker-note[
    $alpha > 0$ encourages the shape to be closer to the initial one, which is again better than $alpha = 0$, but this time even the smallest value of $alpha$ already keeps the shape the same size.
    The shape has no reason to be smaller: it would not give it a better proximity score, and it would give it a worse regularization score, so the algorithm converges to the same shape for all values of $alpha > 0$.
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


= Last results

== Computation of roofprints from BD TOPO

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

= Further improvements

== Point cloud semantic segmentation

#slide[
  === Planned

  - Look into using the *height* of points and normals to tell apart points on façades and roof edges.
  - Look into training a deep learning model to *classify points* into more specific classes (such as roof and façade)
][
  === Not planned

  - Consider *neighbours in other directions* than scan order (such as perpendicularly).
  - Identify *lines in the point cloud topology* with Wu Teng's method:
    - Could be used to estimate the *normals locally* in cases where segments are found to estimate if points are on façades or on roofs.
    - Could be used to identify the breaks of roof planes (out of scope for now).

  #speaker-note[
    - To create a dataset to train a deep learning model, we were thinking of using the *AHN* and the *3DBAG*, which are the Dutch equivalents of the LiDAR HD and the BD TOPO in 3D, and split the points between the different classes based on the *3DBAG building models*.
  ]
]

== Roofprint generation

#slide[
  === Planned

  - Experiment with the order of edge processing.
    For now it is *longer edges first*, but we could try random order.
  - Start with a single 2D translation for all edges, to see if it can improve the results.
  - (Maybe) run the *whole pipeline multiple times* with different conditions (different orders, different initial shifts, etc.) and pick the best result.
][
  === Not planned

  - Use the *repartition of points* on the edge in their score to prioritize a less points with a uniform repartition over a lot of points clustered on one side of the edge.
  - Use *combinatorial optimization* to pick the best set of edges with multiple solutions for difficult edges.
  - Allow for small *rotations* of the edges.
  - Look at edges in *3D* instead of 2D.

  #speaker-note[
    #set text(size: 19pt)
    - Different orders and especially changing orders could help untangling some situations.
    - *Different conditions* could really lead to *different results*, so it could be interesting, but it may be *difficult to pick the best result*.
    - *Reward uniform distribution* of points along the edge with a histogram-like metric.
    - Small rotations of the edges could drastically improve the results in some cases, but it makes preserving the topology more complex and goes against our assumption that angles are great in the initial outlines.
    - Looking at edges in 3D could help a lot to separate points on roof edges from points on façades or vegetation.
      But is much more complex because it adds two new dimensions: the base height and the angle of the edge.
      Moreover, what is one straight edge in 2D may be multiple segments in 3D.
  ]
]

== Footprint generation

#slide[
  === Planned

  - Find criteria to differentiate between roof edges and façade points (including training a deep learning model if needed).
  - Use the *height variations in acquisition order* with different thresholds.
  - Use *rays directions* to count points on potential façades *positively* and *negatively*.
  - *Adapt the matching criterion* to the façades:
    - Not easy to compute the *inward vector* (potentially with the ground points).
    - Care even more about *distribution of points along the Z axis* to avoid matching to roof edges or vegetation.
]

== Rest of the pipeline

#image("../../diagrams/Overview_of_pipeline.drawio.png")

= The end <touying:hidden>

#ending-slide(
  title: [Thank you for your attention!],
  subtitle: [Any questions?],
  contact: ("alexandre.bry@ign.fr",),
  middle-line: true,
)
