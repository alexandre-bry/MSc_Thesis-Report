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
    institution: [IGN, TU Delft],
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

= Outline <touying:hidden>

#outline-slide(title: "Outline")

= Context

== Planned pipeline

#image("../../diagrams/Overview_of_pipeline.drawio.png")

= Point cloud topology

== Point cloud topology

- TODO: Quickly summarize what was mentioned last time

== Flight strips trajectories

- TODO: Quickly summarize what was mentioned last time

== Edge points

- TODO: Quickly summarize what was mentioned last time

= Edge matching

== General structure

- TODO: Explain the general structure of the edge matching process:
  - Identifications of points to align the edges to.
  - Definition of a criterion to evaluate the quality of an edge position, based on:
    - The position of the points.
    - Weights computed for the points.
    - The initial configuration of the edges.
  - Creation of a set of candidate configurations for set of connected edges:
    - By translating each edge perpendicularly to itself.
    - The other edges are translated if necessary to keep the same topology.

== New algorithm

= Current results

== Identification of edge points

== New polygon deformation algorithm

- TODO: Update the figures

#let deformation-figures-height = 80%
#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [Results of the new algorithm.],
  image("../../weekly_notes/2026_04_06/Edge_matching-Square.gif", height: deformation-figures-height),
  image("../../weekly_notes/2026_04_06/Edge_matching-Square_missing_edges.gif", height: deformation-figures-height),
)

---

#subpar.grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  caption: [Results of the new algorithm.],
  image("../../weekly_notes/2026_04_06/Edge_matching-Circle.gif", height: deformation-figures-height),
  image("../../weekly_notes/2026_04_06/Edge_matching-Weird_shape.gif", height: deformation-figures-height),
)

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
]


== Edge matching

#slide[
  === Planned


][
  === Not planned

  - Use the *repartition of points* on the edge in their score to prioritize a less points with a uniform repartition over a lot of points clustered on one side of the edge.

  #speaker-note[
    #set text(size: 20pt)
    - Two ideas to use the repartition of points on the edge:
      - Divide the score by the *length* of the edge.
      - *Reward uniform distribution* of points along the edge with a histogram-like metric.
    - Not sure about using the distance to the current edge as an indication, because the assumption that a closer edge is better is often wrong due to the shift in BD TOPO.
      If we still decide to try it, a simple solution would be to add a penalty proportional to the distance, but this would need to be tested.
  ]
]

#slide[
  === For each edge

  - Try (maybe) to use the *distance to the current edge* as an indication as well.

  #speaker-note[
    #set text(size: 20pt)
    - Matching with the two neighbours could improve results for *tiny edges* and prevent matching edges from *other buildings*.
    - Two ideas to use the repartition of points on the edge:
      - Divide the score by the *length* of the edge.
      - *Reward uniform distribution* of points along the edge with a histogram-like metric.
    - Not sure about using the distance to the current edge as an indication, because the assumption that a closer edge is better is often wrong due to the shift in BD TOPO.
      If we still decide to try it, a simple solution would be to add a penalty proportional to the distance, but this would need to be tested.
  ]
]

#slide[
  === For the whole building

  - Matching *longer edges first*.
  - Run the matching *algorithm multiple times in a row*, or until it converges.
  - Use *combinatorial optimization* to pick the best set of edges with multiple solutions for difficult edges.

  #speaker-note[
    - Matching longer edges first may help matching the *smaller edges* properly, if we shift the starting point of the neighbouring edges.
    - Running the matching algorithm multiple times in a row may help for *small edges*, where a translation along the direction of the edge is problematic.
      It could also allow for *more iterations with smaller frames*.
    - Combinatorial optimization would be a more complex solution, but it would allow to *globally optimize* the matching of all edges together, to avoid local mistakes.
  ]
]

== Edge matching - Other ideas

#slide[
  - Use *regularization* before or after.
  - Use the *classification* of the points in combination with the outlines to crop the point clouds better.
  - Try to make better edges:
    - With a *RANSAC-like* approach (potentially using the BD TOPO to guide the process) in *2D or 3D*.
    - By other means in 3D?
    - By *recomputing the edge* after identifying the inlier points with the current process.
    - Try to estimate *where the edge starts and stops* from the point cloud.

  #speaker-note[
    - *Regularization before* could help removing small artefacts in the edges due to touching buildings and ensure right angles.
    - *Regularization after* could be necessary if computing edges not parallel to the initial edges.
    - Using the *classification* of the points to crop could prevent matching edges from other buildings.
  ]
]

== Rest of the pipeline

#image("../../diagrams/Overview_of_pipeline.drawio.png")

= The end <touying:hidden>

#ending-slide(
  title: [Thank you for your attention!],
  subtitle: [Any questions?],
  contact: ("alexandre.bry@ign.fr",),
)
