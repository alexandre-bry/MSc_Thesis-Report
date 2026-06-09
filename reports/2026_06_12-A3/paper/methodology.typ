#import "../common_imports.typ": *
#show: isprs-heading

= Methodology <hea:methodology>

The method, shown in @fig:overview-pipeline, aims at generating two 2D polygons for each building --- one for the @roofprint and one for the @footprint --- from two main inputs: @als data and an initial building @outline.
Due to the nature of @als data, the density of points on roof surfaces is significantly higher than on façades, which is the reason why we first focus on the estimation of roofprints and then footprints.

#figure(
  image("../figures/Overview_of_pipeline.drawio.png", width: 90%),
  caption: [Overview of the proposed pipeline for generating building @roofprint:pl and @footprint:pl.],
) <fig:overview-pipeline>

The pipeline can be summarised as follows:
+ identify points corresponding to roof edges,
+ use these points to deform the initial @outline into a @roofprint,
+ identify points corresponding to façades and ground below the roof,
+ use these points to deform the @roofprint into a @footprint.

== Input data <hea:input-data>

Our method has only been tested with a high-density @als point cloud as the first input (about 10 points/m²) so the minimum density for accurate results is unknown.
The point cloud should be semantically segmented and contain at least separate classes for vegetation and ground, while the rest is considered as potential building points.
A better input would also contain specific and reliable classes for the buildings, and even potentially a separation between roof and façade points.
But building annotations often follow different conventions (sometimes roof only, sometimes the façades as well), and the separation between the two is rare, as it requires more complex 3D annotations.
Therefore, we aimed for our method to have the least requirements possible on classification.

The point cloud should also contain enough information to isolate the flight strips and order the points in acquisition order.
A GPS time attached to each point is sufficient for this purpose, and an ID specific to each flight strip can simplify the process.
GPS time can be used because every return coming from the same pulse gets the same exact GPS time, and the GPS time is different for every pulse.
To isolate flight strips, one can use their specific IDs if they are available, but it is also possible to isolate them based on their GPS times, as there will be very large gaps between the flight strips.
Finally, the trajectory of the sensor is also necessary, but if it is missing it can be computed automatically using for example the multi-echo pulses of the point cloud #cite(<Wu2026>, form: "normal").

The second input consists of building @outline:pl.
These can be either @footprint:pl, @roofprint:pl, or a mix of both.
They are expected to be roughly the correct size and roughly in the right location up to a few metres.
However their main characteristic is that the directions of their edges and their connections to the other polygons (topology) are assumed to be perfect and will not be modified.
These two requirements come from the constraints imposed on the optimisation process, as explained in @hea:polygon-deformation.

Our method expects the point cloud to be precisely and accurately georeferenced, contrarily to the @outline:pl which are only expected to have an approximate position because they might come from another acquisition method such as imagery or field work.
@fig:illustration-lidarhd-bdtopo-differences presents examples of the expected relations between the @als data and the initial @outline:pl.

#[
  #let height = 4.5cm
  #subpar.grid(
    columns: 3,
    image("../figures/Comparison_BD_TOPO_LiDAR_HD-1.png", height: height),
    image("../figures/Comparison_BD_TOPO_LiDAR_HD-2.png", height: height),
    image("../figures/Comparison_BD_TOPO_LiDAR_HD-3.png", height: height),
    gutter: 0.1cm,
    caption: [A few examples of inputs with the expected strengths and weaknesses: great shape, approximate positioning and size. Buildings from the @bdtopo located in Ozoir-la-Ferrière.],
    label: <fig:illustration-lidarhd-bdtopo-differences>
  )
]


== Identification of @roofprint and @footprint location evidence <hea:identification-points>

To compute the @roofprint:pl and @footprint:pl, a crucial part of the process is to extract evidences of their location.
In both cases, the deformation of the polygon are conducted in 2D by dropping the vertical component of the points, but the process of selecting the points is inherently 3D.
After selecting the points, the process to produce @roofprint:pl and @footprint:pl is explained in @hea:polygon-deformation.

=== @roofprint:cap:pl evidences <hea:roofprint-points>

To select points of interest for the @roofprint, we look for points at the edges of the roof.
We use two properties of @als point clouds:
+ the angle between the pulses and the vertical direction is small,
+ neighbour pulses in the same scan line or in consecutive scan lines can be identified and are very close.

Together, these two properties imply that when the scanner hits the edge of the roof, assuming a scanning direction towards the outside of the building #review-florent[When is the scanning direction not towards the outside of the building ? Do you mean the direction not being parallel to the edge ?]#review-alexandre[Je veux dire que ça va vers l'extérieur plutôt que vers l'intérieur, et donc ça fait toit puis sol et pas sol puis toit], one of the two situations is very likely:
- the pulse hits first the roof and then either the ground or the façade at a lower vertical position, or
- the pulse hits only the roof and the next pulse hits either the façade or the ground at a lower vertical position.

These different scenarios are illustrated in @fig:illustration-vertical-gap.
In both cases, the roof edge is therefore characterised by a high vertical gap between points from the same pulse or from neighbouring pulses.
Each pulse can have up to 4 neighbouring pulses: the previous and next pulses in the same scan line, and the closest pulse in the previous and next scan lines.

This property can be used by setting a threshold defining the minimum vertical gap to be considered a point on a roof edge.
However, there are three main types of points which would also get a high value with this criterion.
The first one are vegetation points, and more precisely points coming from sparse vegetation.
Sparse vegetation often results in many returns including a return for the ground, and therefore all the points above the ground could get a high vertical gap.
The second one are surfaces such as glass which create a return but also let the pulse through.
Elements with glass roof such as greenhouses or conservatories result in pulses very similar to roof edges, with one return on the roof and one on the ground.
The third one are vertical façades, which can get several points below each other at different heights.

=== @footprint:cap:pl evidences <hea:footprint-points>

Points useful for the @footprint:pl are sparser and more difficult to identify than points on the roof.
Therefore, we look for these points only once the @roofprint has already been computed to use it as a guide.

Since we assume that the façade can only be inside of the @roofprint, our method uses a roof reconstruction algorithm to build the roof in 3D.
#review-hugo[Add a figure.]
We use #gloss-ref-and-footnote("roofer") #citen(<Paden2024>) in our pipeline, but other algorithms could be used as long as they allow to produce 3D roofs that match with the 2D @roofprint:pl.
Once the roof is built, all the points directly below it are selected to match the @footprint on it.
This mostly includes four types of points (see @fig:illustration-vertical-gap):
- points on the façades which can be used to directly estimate the position on the façade,
- points on the ground outside of the building which indicate that the façade is likely behind them,
- points on a lower part of the roof, which can be used similarly to ground points,
- points inside of the building which are rather misleading for our method.

== Polygon deformation for @roofprint:pl and @footprint:pl <hea:polygon-deformation>

To be able to transform the initial @outline:pl into accurate @roofprint:pl and @footprint:pl, we need a deformation algorithm flexible enough to handle two different errors at the same time:
+ a global shift of the polygon in one direction to account for imprecise georeferencing,
+ individual displacements of edges to account for size and shape differences between @footprint:pl and @roofprint:pl.

On the other hand, based on the previous work of #cite(<Boussik2026>, form:"prose"), some constraints are necessary to reduce the complexity of the search and to preserve the quality of the initial @outline:pl.
The three main constraints are the following:
+ edges cannot be rotated, as their angles are assumed to be accurate,
+ polygons should keep their shape and edges cannot be flipped (see @fig:flipping-edge) but can be reduced to a single point,
+ adjacencies between buildings should be preserved as much as possible, in our case by ensuring that edges shared between different building remain collinear.

#[
  #import cetz.draw: *

  #let scale = 0.8  
  #figure(
    [
      #set text(fill: blue.darken(10%), size: 8pt, style: "italic")
      #cetz.canvas(
        x: scale,
        y: scale,
        {
          content((-3, 1), [Before], anchor: "south", padding: (bottom: 0.3),)
          line((-5, 0.4), (-3, 0), (-3, 1.0), (-1, 0.9), stroke: black + 1pt)
          mark((-3, 0.55), (-3, 1.0), symbol: ">>", stroke: black + 0.5pt, fill: red, anchor: "center", scale: 1.5)
          line((-0.5, 0), (0.5, 0), mark: (end: ">"), stroke: blue, fill: blue)
          content((3, 1), [After], anchor: "south", padding: (bottom: 0.3),)
          line((1, 0.4), (3, 0), (3, -0.9), (5, -1.0))
          mark((3, -0.5), (3, -0.9), symbol: ">>", stroke: black + 0.5pt, fill: red, anchor: "center", scale: 1.5)
          line((3, 0), (3, 1.0), (5, 0.9), stroke: (paint: black, thickness:1pt, dash: "dashed"))
        }
      )
    ],
    caption: [Illustration an edge being flipped by the translation of a neighbour edge.]
  ) <fig:flipping-edge>
]


We therefore define the polygon deformation problem as an optimisation problem, combining two parts.
First, we define an energy that the optimal polygon should minimise, which is based on the input point cloud.
This energy is completely different for the @roofprint:pl and the @footprint:pl, as presented respectively in @hea:particularities-roofprints and @hea:particularities-footprints.
Then, we propose in @hea:deformation-algo a method to produce new propositions of polygons which satisfy the aforementioned constraints.
Finally, these two elements are combined in @hea:matching_algo into an iterative algorithm to incrementally improve the polygon. 

=== Matching algorithm <hea:matching_algo>

The general idea behind the matching algorithm is simple.
For each group of lines:
+ a set of potential shifts is defined,
+ for each shift, the final configuration of the polygon is computed with the polygon deformation algorithm described in @hea:deformation-algo,
+ the best configuration is identified with a criterion and replaces the previous one,
+ a new group of lines is picked.

A pseudocode implementation of the algorithm is shown in @alg:polygon-matching.
This algorithm takes as input all the groups of lines $G$ and all the points $P$ that the polygons must be deformed on.

#[
  #import algorithmic: algorithm

  #show figure: set align(start)
  #figure(
    algorithm(
      vstroke: .5pt + luma(200),
      {
        import algorithmic: *
        Function(
          "matching_algorithm",
          ($G$, $P$),
          {
            Comment[_The order to iterate over $G$ matters_]
            For(
              [$g_0$ in $G$],
              {
                Assign[$S$][a list of potential shifts perpendicular to the lines in $G$]
                LineBreak
                Comment[_Compute the deformed polygons and their energy_]
                Assign[$"shifted_groups"$][empty dictionary]
                Assign[$"energies"$][empty dictionary]
                For(
                  [$arrow(s)$ in $S$],
                  {
                    Assign(
                      $"shifted_groups"[arrow(s)]$,
                      FnInline("deformation_one_edge", [$g_0$, $arrow(s)$])
                    )
                    Assign(
                      $"energies"[arrow(s)]$,
                      FnInline("compute_energy", [$"shifted_groups"[arrow(s)]$, $arrow(s)$, $P$])
                    )
                  }
                )
                LineBreak
                Comment[_Select the best shift and apply it to the relevant lines_]
                Assign[$arrow(s)_("max")$][shift $arrow(s)$ with the lowest energy]
                For(
                  [$g$ in $"shifted_groups"[arrow(s)_max]$],
                  {
                    [Shift all the lines in $g$ by $arrow(s)_max$]
                  }
                )
              }
            )
          },
        )
      }
    ),
    kind: "algorithm",
    supplement: [Algorithm],
    caption: [Polygon matching algorithm. This represents one iteration, which consecutively focuses on each group of lines to find its optimal shift.]
  ) <alg:polygon-matching>
]

It must be noted that the order in which the groups of edges are processed can lead to significantly different results, as shifting one group can lead to moving many other groups, and this temporary result will be the starting point for the next group.
However, it is unclear which ordering strategy is the best.
Two simple strategies however emerged with their own advantages:
- random order allows next iterations of the algorithm to potentially fix biases introduced by the previous iteration,
- ordering groups by the length of the edges in decreasing order makes the algorithm start with the easiest edges, as long edges are less affected than small edges by the same absolute shift in the input data.

This blueprint algorithm is then adapted to produce @roofprint:pl or @footprint:pl, because they use different evidences, with different distributions and different objectives, so the energy depends on the application.

=== Deformation algorithm <hea:deformation-algo>

To satisfy all the properties listed at the beginning of @hea:polygon-deformation, our algorithm is designed as an iterative process where each iteration focuses on moving a specific edge along its normal while allowing the displacement of this edge to influence the whole polygon in order to avoid self-intersections and edge flips.
Let's assume that we have a polygon with $n$ vertices defined as a set of consecutive points ${ p_i, i in [| 0, n - 1 |] }$.
For the rest of the paper, we assume that the indices of the objects are modulo $n$, meaning that $p_n$ refers to $p_0$.
We consider the polygon as a set of oriented lines ${ l_i, i in [| 0, n-1 |] }$, where $l_i$ is the infinite line passing through $p_i$ and $p_(i+1)$ and oriented from $p_i$ to $p_(i+1)$.
The direction $d_i$ is the unit direction vector of $l_i$.
@fig:mathematical-definitions illustrates all these definitions.

#[
  #import cetz.draw: *

  #let layers = (
    line: 0,
    edge: 1,
    point: 2,
    direction: 3,
  )

  #let edge-with-name(v1, v2, label: none, name: none, stroke: auto) = {
    on-layer(layers.edge, line(v1, v2, stroke: stroke, name: name, ))
    if label != none {
      content(
        (name + ".start", 50%, name + ".end"),
        angle: name + ".end",
        padding: .1,
        anchor: "south",
        label
      )
    }
  }

  #let point-with-name(p, label: none, name: none, stroke: none, fill: color.black, anchor: "north") = {
    on-layer(layers.point, circle(p, radius: 0.1, stroke: stroke, fill: fill, name: name))
    if label != none {
      content(
        p,
        padding: .1,
        anchor: anchor,
        label
      )
    }
  }

  #let intersection(p, d, l) = {
    if (l.at("x", default: none) != none) {
      return (l.at("x") - p.at(0)) * d.at(1) / d.at(0) + p.at(1)
      if d.at(0) == 0 {
        return none
      }
    } else if (l.at("y", default: none) != none) {
      if d.at(1) == 0 {
        return none
      }
      return (l.at("y") - p.at(1)) * d.at(0) / d.at(1) + p.at(0)
    } else {
      panic("Expected the line to be a dictionary with 'x' or 'y' as a key")
    }
  }
  
  #let line-with-name(v1, v2, min: (-3, -1), max:(4.5, 2.5), label: none, name: none, color: blue, dashed: true) = {
    let stroke = (paint: color)
    if dashed { stroke.insert("dash", "dashed") }
    
    let (min-x, min-y) = min
    let (max-x, max-y) = max
    let (v1-x, v1-y) = v1
    
    let dir = (v2.at(0) - v1.at(0), v2.at(1) - v1.at(1))

    let y-intersec-min-x = intersection(v1, dir, (x: min-x))
    let y-intersec-max-x = intersection(v1, dir, (x: max-x))
    let x-intersec-min-y = intersection(v1, dir, (y: min-y))
    let x-intersec-max-y = intersection(v1, dir, (y: max-y))

    let points
    if dir.at(0) == 0.0 {
      points = ((v1-x, min-y), (v1-x, max-y))
    } else if dir.at(1) == 0.0 {
      points = ((min-x, v1-y), (max-x, v1-y))      
    } else if dir.at(0) * dir.at(1) > 0.0 {
      let v1-ext-x = calc.max(x-intersec-min-y, min-x)
      let v1-ext-y = calc.max(y-intersec-min-x, min-y)
      let v2-ext-x = calc.min(x-intersec-max-y, max-x)
      let v2-ext-y = calc.min(y-intersec-max-x, max-y)
      points = ((v1-ext-x, v1-ext-y), (v2-ext-x, v2-ext-y))
    } else {
      let v1-ext-x = calc.max(x-intersec-max-y, min-x)
      let v1-ext-y = calc.min(y-intersec-min-x, max-y)
      let v2-ext-x = calc.min(x-intersec-min-y, max-x)
      let v2-ext-y = calc.max(y-intersec-max-x, min-y)
      points = ((v1-ext-x, v1-ext-y), (v2-ext-x, v2-ext-y))
    }

    if (dir.at(0) < 0.0) {
      points = (points.at(1), points.at(0))
    }
    
    on-layer(layers.line, line(points.at(0), points.at(1), stroke: stroke, name: name, mark: (end: ")>", fill: color)))
    if label != none {
      content(
        (v1, 50%, v2),
        angle: name + ".end",
        padding: .1,
        anchor: "north",
        label
      )
    }
  }

  #let edge-direction-with-name(v1, v2, label: none, name: none, stroke: red) = {
    let final-norm = 0.7
    
    let dir = (v2.at(0) - v1.at(0), v2.at(1) - v1.at(1))
    let dir-norm = calc.sqrt(dir.at(0) * dir.at(0) + dir.at(1) * dir.at(1)) / final-norm
    let dir-unit = (dir.at(0) / dir-norm, dir.at(1) / dir-norm)
    let v2-new = (v1.at(0) + dir-unit.at(0), v1.at(1) + dir-unit.at(1))
    
    on-layer(layers.direction, line(v1, v2-new, stroke: stroke, name: name, mark: (end: ")>", fill: stroke, scale: 1.0)))
    if label != none {
      content(
        (name + ".start", 50%, name + ".end"),
        angle: name + ".end",
        padding: .1,
        anchor: "south",
        label
      )
    }
  }

  #let scale = 1.0 
  #figure(
    [
      #set text(size: 8pt)
      #cetz.canvas(
        x: scale,
        y: scale,
        {
          edge-with-name((-3, 2), (-2, 1), label: $e_(i-2)$, name: "e_(i-2)", stroke: (dash: "dotted"))
          
          point-with-name((-2, 1), label: $p_(i-1)$, name: "p_(i-1)")
          
          line-with-name((-2, 1), (0, 0), label: text(fill: blue, $l_(i-1)$), name: "l_(i-1)")
          edge-with-name((-2, 1), (0, 0), label: $e_(i-1)$, name: "e_(i-1)")
          edge-direction-with-name((-2, 1), (0, 0), label: text(fill: red, $d_(i-1)$), name: "d_(i-1)", stroke: red)
          
          point-with-name((0, 0), label: $p_(i)$, name: "p_(i)")
          
          line-with-name((0, 0), (2, 0), label: text(fill: blue, $l_(i)$), name: "l_(i)")
          edge-with-name((0, 0), (2, 0), label: $e_(i)$, name: "e_(i)")
          edge-direction-with-name((0, 0), (2, 0), label: text(fill: red, $d_(i)$), name: "d_(i)", stroke: red)
          
          point-with-name((2, 0), label: $p_(i+1)$, name: "p_(i+1)", anchor: "north-west")
          
          line-with-name((2, 0), (3, 1.5), label: text(fill: blue, $l_(i+1)$), name: "l_(i+1)")
          edge-with-name((2, 0), (3, 1.5), label: $e_(i+1)$, name: "e_(i+1)")
          edge-direction-with-name((2, 0), (3, 1.5), label: text(fill: red, $d_(i+1)$), name: "d_(i+1)", stroke: red)
          
          point-with-name((3, 1.5), label: $p_(i+2)$, name: "p_(i+2)", anchor: "north-west")
          
          edge-with-name((3, 1.5), (4.5, 2), label: $e_(i+2)$, name: "e_(i+2)", stroke: (dash: "dotted"))
        }
      )
    ],
    caption: [Illustration of the mathematical objects for a few edges of a polygon.]
  ) <fig:mathematical-definitions>
]

With these considerations, if we assume that two consecutive lines are never parallel, the point $p_i$ can be retrieved as the intersection between $l_(i-1)$ and $l_i$, meaning that the lines contain the full definition of the polygon.
These lines are however more convenient to handle compared to the points, as they can be translated freely along their normals without breaking the constraints.

#let show-property(body) = {
  align(center,
    block(inset: (x: 1em),
      text(style: "italic",
        body
      )
    )
  )
}

With this, the property that an edge $e_i$ should not be flipped can still be checked relatively easily by intersecting $l_i$ with both $l_(i-1)$ and $l_(i+1)$ and comparing the edge obtained with $d_i$.
Let's call this property #show-property[$cal(P)_1(l_i)$: the edge defined by $l_(i-1)$, $l_i$ and $l_(i+1)$ is not flipped.]
This property is enough in practice in most cases to ensure that the final polygon will be valid, because it prevents self-intersections between $l_(i-1)$ and $l_(i+1)$.
However, to prevent all potential self-intersections, it is necessary to check for intersections between each shifted edge and all other edges, which is much more computationally extensive.
Let's call this new property #show-property[$cal(P)_2(l_i)$: the edge defined by $l_(i-1)$, $l_i$ and $l_(i+1)$ does not intersect any other edge in the polygon.]

These two properties are enough to create valid polygons that satisfy the first and second constraints mentioned in the introduction of @hea:polygon-deformation.
The last constraint is to keep edges shared by adjacent polygons collinear.
This is accomplished by grouping together the lines corresponding to these edges and shifting them by same amounts in the same directions.

The proposed algorithm is detailed in @alg:polygon-deformation, taking as input a line group to shift $g_0$ and a shift to apply $arrow(s)$.
Its main idea is to propagate the shift through the connections between groups (both connections in polygons and between polygons), as long as $cal(P)_1$ or $cal(P)_2$ is not verified.
Here are descriptions for the functions used in this pseudocode:
- #algorithmic.CallInline[get_group][$l$]: returns the group of overlapping lines from different polygons which contains $l$,
- #algorithmic.CallInline[check_p1][$arrow(s)$, $"shifted_groups"$, $l$]: returns a boolean stating whether the property $cal(P)_1(l)$ is verified for the current polygon if the groups in $"shifted_groups"$ are shifted by $arrow(s)$.
- #algorithmic.CallInline[check_p2][$arrow(s)$, $"shifted_groups"$, $l$]: same as #algorithmic.CallInline[check_p1][$arrow(s)$, $"shifted_groups"$, $l$] but for $cal(P)_2(l)$.


#[
  #import algorithmic: algorithm

  #show figure: set align(start)
  #figure(
    algorithm(
      vstroke: .5pt + luma(200),
      {
        import algorithmic: *
        Function(
          "deformation_one_edge",
          ($g_0$, $arrow(s)$),
          {
            Assign[$"shifted_groups"$][${ }$]
            Assign[$"groups_to_process"$][${ g_0 }$]
            LineBreak
            While(
              $"groups_to_process" "is not empty"$,
              {
                LineComment(Assign([$g$], CallInline[pop][$"groups_to_process"$]), [_Order does not matter_])
                If(
                  $g in.not "shifted_groups"$,
                  Assign[$"to_shift"$][False],
                  LineBreak,
                  Comment[_Decide whether to shift the group $g$_],
                  For(
                    [$l$ in $g$],
                    If(
                      [not #CallInline[check_p1][$arrow(s)$, $"shifted_groups"$, $l$] or not #CallInline[check_p2][$arrow(s)$, $"shifted_groups"$, $l$]],
                      Assign[$"to_shift"$][True],
                      Break
                    )
                  ),
                  LineBreak,
                  Comment[_If necessary, shift the group $g$ and add its neighbours_],
                  If(
                    $"to_shift"$,
                    CallInline[push][$"shifted_groups"$, $g$],
                    For(
                      [$l_i$ in $g$],
                      Assign[$g_"prev"$][#CallInline[get_group][$l_(i-1)$]],
                      Assign[$g_"next"$][#CallInline[get_group][$l_(i+1)$]],
                      CallInline[push][$"groups_to_process"$, ($g_"prev"$, $g_"next"$)],
                    )
                  )
                )
              },
            )
            Return[$"shifted_groups"$]
          },
        )
      }
    ),
    kind: "algorithm",
    supplement: [Algorithm],
    caption: [Polygon deformation algorithm, responsible for computing the new configuration of all the adjacent polygons after one group of shared edges ($g_0$) was shifted (by $arrow(s)$).]
  ) <alg:polygon-deformation>
]

@alg:polygon-deformation is not optimised for speed but rather simplified for clarity.
For a given line group $g$, we use its perpendicular unit vector $arrow(n)$ as the direction for the shift.
Along this direction, we define a set of shifts to try in both directions, ${ k t arrow(n), k in [| -m, m |] }$, with user-defined values for the step size $t$ and maximum shift length $m s$.
A full iteration of the algorithm in @alg:polygon-matching calls this function once for every pair of group $g$ and shift $arrow(s)$.
Moreover, if computing the resulting deformed polygon for increasing shifts such as ${ k t arrow(n), k in [| 1, m |] }$, the result obtained for $k t arrow(n)$ can be used as a starting point for $(k+1) t arrow(n)$, therefore increasing the computing speed.
On a side note, the order in which the groups are processed in $"groups_to_process"$ does not matter: the algorithm will always terminate and return the same results.

=== Particularities for the @roofprint:pl <hea:particularities-roofprints>

To compute the @roofprint, the algorithm given in @hea:matching_algo is adapted to use the points identified as explained in @hea:roofprint-points.
The energy presented below is based on careful analyses of portions of @bdtopo and @lidarhd, as it is the central part of the optimisation.
We use our properties which we expect to find in most @als point clouds with similar or higher density.

First, to prevent lines from matching with points that correspond to neighbouring building, we define what we call the inward direction of a point.
The goal of the inward direction is to be as close as possible to the 2D normal of the corresponding roof edge, oriented towards the inside of the building.
To compute it for a given point $p$, we use the following method:
+ identify the set of points $p_j in cal(B)(p, delta)$ that are less than a certain distance $delta$ from $p$,
+ compute the inward vector $v$ as the average of the vectors unit vectors from $p$ to $p_j$: $ v = 1/ (|cal(B)(p, delta)|) sum_(p_j in cal(B)(p, delta)) (p_j - p) / (|p_j - p|) $

The idea behind this formula is that points on the edge of the roof should have in their neighbourhood many points towards the inside of the building, and few points towards the outside.
Using unit vectors and averaging them gives all points in the neighbourhood the same weight, resulting in a value that could be interpreted as a proxy of the density imbalance direction.
Moreover, the magnitude of the inward vector is an indication of the confidence.

With this inward direction, the score of a point $p_i$ for a line $l_j$ can be defined.
It is 0 if any of the following conditions is true:
- the orthogonal projection $p_(i perp j)$ of $p_i$ on the line $l_j$ is outside of the segment defined by $l_(i-1)$ and $l_(i+1)$, or
- the distance from $p_i$ to $p_(i perp j)$ is greater than a certain threshold $epsilon$, or
- the dot product of the inward vector $v_i$ of $p_i$ with the normal $n_j$ of $l_j$ oriented towards the inside of the building is negative.
Otherwise, the score is:
$ 
"score"(p_i, l_j) = underbrace((v_i dot n_j), "alignment of\npoint and edge\n'normals'") times underbrace((1 - (|p_i - p_(i perp j)|) / epsilon), "proximity to the edge") >= 0
$

We also associate an intrinsic weight to every point in the point cloud to give more value to the most promising points.
The weight $w_i$ is a product of two factors between 0 and 1:
- one giving higher values to points coming from multi-echo pulses because they should give a more accurate position for the roof edge,
- one giving higher values to points classified as building if the input point cloud has this classification.

Finally, the energy to minimise can be defined as:
$
E = underbrace(- sum_(i in P) w_i max_(j in cal(L)) {"score"(p_i, l_j)}, "proximity to the points") + alpha underbrace(sum_(j in cal(L)) (|l_j| - |l_j^0|)^2, "similarity to the initial edges")
$

where:
- $P$ is the set of points, and $cal(L)$ is the set of lines,
- $|l_j|$ and $|l_j^0|$ are the length of edge $l_j$ in the current and initial configurations respectively,
- $alpha$ is a parameter to adjust between the two terms.

In this energy, 5 main parameters need to be tuned: $delta$ for the inward direction, $epsilon$ for the score of a point on a line, $alpha$ to balance the proximity and regularisation terms in the energy, and two parameters for the intrinsic weights of points.

=== Particularities for the @footprint:pl <hea:particularities-footprints>

To compute the @footprint:pl, we also need to adapt the algorithm, but this time for different reasons.

First, a constraint specific to @footprint:pl is that we want to force them to be included in the @roofprint:pl.
It is tempting to try to enforce this by allowing the polygon deformation algorithm to only shift edges towards the inside of the polygon.
However, this would create two problems.
Firstly, if two edges make an angle smaller than 90°, their inward directions are opposite, meaning that the first one could limit the movements of the second one.
Secondly, if the movement of one edge brings another edge too far towards the inside, this last edge will not be able to go back to a better position.
For these two reasons, trying to enforce the inclusion in the algorithm is not trivial and would require deeper changes.
We therefore decided to enforce the inclusion at a later stage as post-processing by intersecting the @footprint with the @roofprint.

Then, the energy for the @footprint:pl must cater to the particularities of its relevant evidences, such as the high variance in the amount of pulses that reached the façades.
As illustrated in @fig:illustration-facade-points-variation, the amount of such points depends on many variables for which small variations can have a significant impact:
- the height of the building,
- the size of the roof overhang,
- the geometry of the @lidar scanning device,
- the alignment between the flight axes and the façades.

#[
  #import cetz.draw: *

  #let scale = 0.4
  
  #let building-color = color.red
  #let building-stroke = building-color + 1pt

  #let pulses = (
    (5deg, color.green.darken(50%)),
    (10deg, color.green.darken(10%)),
    (15deg, color.green.darken(-30%)),
  )
  
  #let pulse(roof-edge-xy, vertical-angle, start-y, facade-x, ground-y, color) = {
    let (roof-edge-x, roof-edge-y) = roof-edge-xy
    let start-x = roof-edge-x + (start-y - roof-edge-y) * calc.tan(vertical-angle)
    let ground-x = roof-edge-x + (ground-y - roof-edge-y) * calc.tan(vertical-angle)

    let (end-x, end-y) = if ground-x > facade-x {
      (ground-x, ground-y)
    } else {
      let facade-y = roof-edge-y + (facade-x - roof-edge-x) / calc.tan(vertical-angle)
      (facade-x, facade-y)
    }
    line((start-x, start-y), (end-x, end-y), stroke: color + 1pt, dash: "dashed")
    circle((end-x, end-y), radius: 0.15, stroke: none, fill: color)
  }

  #let house(start-point, height, width, roof-angle, overhang, pulse-height, pulses) = {
    let (sx, sy) = start-point
    let roof-factor = calc.tan(roof-angle)
    let house-points = (
      (sx, sy),
      (sx, sy + height),
      (sx + width, sy + height - width * roof-factor),
      (sx + width, sy),
    )
    let overhang-points = (
      (sx + width, sy + height - width * roof-factor),
      (sx + width + overhang, sy + height - (width + overhang) * roof-factor), 
    )

    let roof-edge = overhang-points.at(1)
    
    line(..house-points, close: true, stroke: color.blue, fill: color.blue)
    line(..overhang-points, stroke: color.blue)

    for pulse-instance in pulses {
      let (vertical-angle, color) = pulse-instance
      pulse(roof-edge, vertical-angle, pulse-height, sx+width, sy, color)      
    }
  }

  #let pulses-legend(pulses, position, anchor, space-between) = {
    let (px, py) = position
    for (i, pulse-instance) in array.enumerate(pulses) {
      let (angle, color) = pulse-instance
      let start = (px, py - i * space-between - 0.5)
      let end = (px + 1, py - i * space-between - 0.5)
      let name = "line-" + str(i)
      line(start, end, name: name, stroke: color)
      content(name + ".end", padding: 0.1, [#calc.round(angle.deg())°], anchor: anchor)
    }
  }
  
  #figure(
    cetz.canvas(
      x: scale,
      y: scale,
      {
        house((0, 0), 5, 2, 30deg, 1, 10, pulses)
        house((5, 0), 8, 2, 30deg, 1, 10, pulses)
        house((10, 0), 4, 2, 30deg, 0.2, 10, pulses)
        house((15, 0), 6, 2, 30deg, 0.5, 10, pulses)
        pulses-legend(pulses, (0, 10), "mid-west", 0.7)
      }
    ),
    caption: [Illustration in profile view of the highest possible hit on the façade depending on the building and the angle of the pulse.]
  ) <fig:illustration-facade-points-variation>
]

However, even when there is no point on a façade, a pulse can still hit the ground under the roof.
Assuming that these hits happen outside of the building, which is the case unless the building is made of transparent materials, these points can be used to push the façade further towards the inside.

Therefore, the energy that we use for @footprint:pl tries to combine these two elements:
- a concentration of points close to the segment,
- as little points as possible behind the façade.

We use the energy illustrated in @fig:energy-footprints.
The general idea is to count positively the points close enough to the edge (clustering), and negatively the points further towards the inside of the building (penalty).
To achieve this, we use a signed distance defined as $d_s (p, e) = (p - p_(perp e)) dot e_perp$ where $p_(perp e)$ is the projection of $p$ on $e$ and $e_perp$ is the unit vector perpendicular to $e$ pointing towards the inside of the building.
This distance is therefore positive if the point is towards the inside of the building and negative otherwise.
On top of that, based on experiments and qualitative observations, the values of the energy are scaled differently for ground points.
The intuition behind this is the following.
For clustering, points on the façades are the most important.  
For the penalty, we want to prioritise a high density of points instead of having a more inward candidate to win simply with the penalty.  
 
#[
  #let x-axis-values = (-0.8, -0.3, 0, 0.3, 1.3, 1.3, 1.8)
  #let y-axis-values-ground = (0, 0, -0.3, 0, 1.0, 0, 0)
  #let y-axis-values-other = (0, 0, -1.0, 0, 0.3, 0, 0)
  #let stroke = 1pt
  #show lq.selector(lq.label): set text(size: 8pt)
  #show lq.selector(lq.legend): set text(size: 8pt)
  #show: lq.set-legend(position: bottom)
  #figure(
    lq.diagram(
      width: 100%,
      height: 3cm,
      xlabel: [Signed distance $d_s (p, e)$ from $p$ to $e$ (m)],
      ylabel: [Energy],
      xaxis: (ticks: x-axis-values.slice(1, -1), subticks: none),
      // yaxis: (ticks: (-1, 0, 1), subticks: none),
  
      lq.plot(x-axis-values, y-axis-values-ground, mark: none, label: [Ground], stroke: stroke),
      lq.plot(x-axis-values, y-axis-values-other, mark: none, label: [Other classes], stroke: stroke),
    ),
    caption: [Energy of a point $p$ for a footprint edge $e$.],
  ) <fig:energy-footprints>
]
