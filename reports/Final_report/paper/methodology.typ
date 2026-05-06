#import "../common_imports.typ": *
#show: isprs-heading

= Methodology <hea:methodology>

#block-todo[Things to mention][
  - First roofprint then footprint because roofprints are easier to estimate from airborne LiDAR data (less occlusions, more points, etc.)
]

The different parts of the proposed method are shown in @fig:overview-pipeline.
The method aims at generating two 2D polygons for each building --- one for the @roofprint and one for the @footprint --- from two main inputs: @als data and an initial building @outline.
Due to the nature of @als data, the density of points on roof surfaces is significantly higher than on façades, which is the reason why we first focus on the estimation of roofprints and then footprints.

#figure(
  image("../../../diagrams/Overview_of_pipeline-updated.drawio.svg"),
  caption: [Overview of the proposed pipeline for generating building roofprints and footprints.],
) <fig:overview-pipeline>

The pipeline can be summarized as:
+ Identify points corresponding to roof edges,
+ Use these points to make a roofprint,
+ Identify points corresponding to façades and ground below the roof,
+ Use the points to make a footprint.

== Input data

#block-todo[Things to mention][
  - Airborne LiDAR data (point cloud):
    - High point density (e.g., 10-20 points/m²) and high precision and accuracy (e.g., 10-20 cm).
    - Semantic segmentation between vegetation and non-vegetation points
  - Initial building outlines (e.g., from cadastral data, building detection algorithms, etc.) with:
    - Correct topology and shapes (angles between walls)
    - Approximately correct size
    - Poor georeferencing (displacement of up to a few meters)
  - Point cloud trajectory (can be automatically computed using multi-echo rays)
]

This method expects a high-density @als point cloud as an input (at least 10 points/m²).
This point cloud should be semantically segmented and contain at least a separate class for vegetation and ground.
It should also contain enough information to isolate the flight strips and order the points in acquisition order.
A GPS time attached to each point is sufficient for this purpose, and an ID specific to each flight strip can simplify the process.
Finally, the trajectory of the sensor is also necessary, but it can be computed automatically using for example the multi-echo pulses of the point cloud. \[HOW TO CITE THE ALGO OF WU TENG?\]

The second input consists in building @outline:pl.
These building @outline:pl can be either @footprint:pl, @roofprint:pl or a mix of both.
They are expected to be roughly the correct size and roughly in the right spot up to a few metres.
But their main characteristic is that their overall shape and topology, as well as the angles of their edges, are expected to be perfect.
#review-alexandre[Maybe an illustration of the expected input with an example from BD TOPO would help?]
These two requirements come from the constraints imposed on the optimization process: never flip an edge and never rotate an edge.
@hea:roofprints gives more details about the optimization process.


== Identification of roof edge points

#block-todo[Things to mention][
  - Point cloud topology (flight strips, scan lines, pulses)
  - Computing maximum vertical gap with neighbours in same and adjacent scan lines
  - Displacement of single-echo points to be closer to the roof edge
]

== Construction of roofprints <hea:roofprints>

#block-todo[Things to mention][
  - Optimization of all connected edges together to preserve topology
  - Description of the edge shifting algorithm
  - Energy function to minimize which combines two terms:
    - Proximity to the roof edge points (requires to define the proximity score and the inward direction)
    - Similarity to the initial edges (to preserve the shape and size of the building)
  - Multiple iterations to converge to the final roofprint
]

== Identification of wall and ground points

#block-todo[Things to mention][
  - Transfer of the 2D roofprints into 3D by identifying the best 3D segments corresponding to each 2D edge of the roofprint
  - Extract points below and towards the inside (points on walls or on the ground indicating the presence of a roof overhang)
]

== Construction of footprints

#block-todo[Things to mention][
  - Optimization of each edge individually
  - Corresponds to the estimation of the roof overhang for each edge of the roofprint
  - Other energy function to minimize which combines two terms to try to use both the wall points and the ground points (in 2D):
    - Proximity to the wall and ground points
    - Absence of points more towards the inside
]

