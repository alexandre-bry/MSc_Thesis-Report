#import "../common_imports.typ": *

= Preliminary Materials <sec:preliminary-materials>

This chapter aims at introducing the knowledge and vocabulary necessary to understanding the core of the thesis (@sec:paper).
It is intended for readers who are not expert in the topic at hand, however the @sec:paper is self-contained.

== @roofprint:short:noref:cap:pl and @footprint:short:noref:pl

As presented in @sec:introduction, the difference between @roofprint:pl and @footprint:pl is central for this thesis.
One of the reasons why both of them are important is that different sources of data often make it easier to get one of the two:
- surveyors in the field mostly use the walls and therefore measure the @footprint,
- experts working on aerial imagery can only use the roof as some walls will not be visible, meaning that they measure the @roofprint,
- @als point clouds (such as the @lidarhd and the @ahn) give many points on the roofs and therefore make it easier to extract the @roofprint,
- @tls and @mls point clouds give many points on the walls and therefore make it easier to extract the @footprint.

Even with the definitions given before, some aspects still need to be clarified to be able to unequivocally draw a @roofprint and a @footprint for every building.
First, the inclusion of balconies and other outdoor elements of buildings is unclear in many scenarios, as illustrated in @fig:balconies-in-roofprint-footprint.
In blocks of flats with multiple storeys where every storey except the ground floor has the same exact balcony (see @fig:balconies-in-roofprint-footprint-simple-balconies), does the end of the balcony become the position of the façade?
Sometimes, the whole building is extruded horizontally except the ground floor (see @fig:balconies-in-roofprint-footprint-extruded-facade), in a structure which looks like balconies except they are not open, are these considered as balconies?
There are many more questions to consider when trying to properly characterise 2D @outline:pl to create a coherent dataset, and many of these questions do not have a right or wrong answer: the best answer depends on the final application.
There are even cases, such as buildings with non-vertical façades, which completely break the purpose of defining a simple and unique 2D @outline.

#[
  #import cetz.draw: *

  #let building-color = blue
  #let building-stroke = (paint: building-color, thickness: 4pt)
  #let window-stroke = (paint: blue, thickness: 1.5pt)
  #let balcony-color = green
  #let balcony-stroke = (paint: balcony-color, thickness: 4pt)
  #let facade-color = orange
  #let chosen-facade-color = purple
  #let facade-stroke = (paint: facade-color, thickness: 1.5pt, dash: "dashed")
  #let chosen-facade-stroke = (paint: chosen-facade-color, thickness: 1.5pt, dash: "dashed")
  #let text-size = 10pt
  #let storey-height = 2.5
  #let building-width = 5
  #let scale-value = 0.3
  #let scale-func(t) = { scale-value * t }

  #let shift-point(p, d) = {
    let (x, y) = p
    let (dx, dy) = d
    return (x + dx, y + dy)
  }
  #let scale-point(p) = {
    return (scale-func(p.at(0)), scale-func(p.at(1)))
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

  #let update-bbox(bbox, point) = {
    bbox = (
      (
        calc.min(bbox.at(0).at(0), point.at(0)),
        calc.min(bbox.at(0).at(1), point.at(1)),
      ),
      (
        calc.max(bbox.at(1).at(0), point.at(0)),
        calc.max(bbox.at(1).at(1), point.at(1)),
      ),
    )
    return bbox
  }

  #let compute-configuration(
    storeys: 5,
    balconies: range(1, 5),
    balcony-height: 0.4 * storey-height,
    balcony-width: 1.5,
    footprint-width: 1.5,
    facades-extrusions: none,
    ..other,
  ) = {
    if (facades-extrusions == none) {
      facades-extrusions = (0,) * storeys
    }
    if facades-extrusions.len() != storeys {
      panic("facades-extrusions.len() != storeys")
    }

    let building = ()
    let text-content = ()
    let facade-xs = ()

    let base-point = (0, 0)

    // Main part of the building
    for (storey, facade-extrusion) in range(storeys).zip(facades-extrusions) {
      let storey-base-point = shift-point(base-point, (0, storey-height * storey))
      let total-width = building-width + facade-extrusion
      facade-xs.push(total-width + base-point.at(0))

      let windows = if (storey == 0) or (storey in balconies) {
        (0.1, 0.8)
      } else {
        (0.4, 0.8)
      }

      let window-bottom = shift-point(storey-base-point, (total-width, storey-height * windows.at(0)))
      let window-top = shift-point(storey-base-point, (total-width, storey-height * windows.at(1)))
      // Bottom
      building.push(
        (
          line-string: (
            storey-base-point,
            shift-point(storey-base-point, (total-width, 0)),
            window-bottom,
          ),
          stroke: building-stroke,
          layer: 2,
        ),
      )
      // Window
      building.push(
        (
          line-string: (window-bottom, window-top),
          stroke: window-stroke,
          layer: 2,
        ),
      )
      // Top
      building.push(
        (
          line-string: (
            window-top,
            shift-point(storey-base-point, (total-width, storey-height)),
            shift-point(storey-base-point, (0, storey-height)),
          ),
          stroke: building-stroke,
          layer: 2,
        ),
      )

      // Storey
      text-content.push(
        (
          start: storey-base-point,
          end: shift-point(storey-base-point, (total-width, storey-height)),
          cont: box(
            align(center + horizon)[#storey],
            width: 100%,
            height: 100%,
          ),
          anchor: "north-west",
          layer: 1,
        ),
      )
    }

    // Balconies
    for balcony in balconies {
      let full-building-width = building-width + facades-extrusions.at(balcony)
      let balcony-x = full-building-width + balcony-width + base-point.at(0)
      facade-xs.push(balcony-x)

      let balcony-point = shift-point(base-point, (full-building-width, storey-height * balcony))
      building.push(
        (
          line-string: (
            balcony-point,
            shift-point(balcony-point, (balcony-width, 0)),
            shift-point(balcony-point, (balcony-width, balcony-height)),
          ),
          stroke: balcony-stroke,
        ),
      )
    }

    // Potential façades
    for facade-x in facade-xs.dedup() {
      building.push(
        (
          line-string: (
            shift-point(base-point, (facade-x, -2)),
            shift-point(base-point, (facade-x, storey-height * storeys + 2)),
          ),
          stroke: facade-stroke,
          layer: -1,
        ),
      )
    }
    let facade-total-x = footprint-width + base-point.at(0) + building-width
    if footprint-width != none {
      building.push(
        (
          line-string: (
            shift-point(base-point, (facade-total-x, -2)),
            shift-point(base-point, (facade-total-x, storey-height * storeys + 2)),
          ),
          stroke: chosen-facade-stroke,
          layer: -1,
        ),
      )
    }

    // Scale
    for (bdg-part-idx, bdg-part) in building.enumerate() {
      for (idx, point) in bdg-part.line-string.enumerate() {
        building.at(bdg-part-idx).line-string.at(idx) = scale-point(point)
      }
    }
    for (txt-cont-idx, txt-cont) in text-content.enumerate() {
      text-content.at(txt-cont-idx).start = scale-point(text-content.at(txt-cont-idx).start)
      text-content.at(txt-cont-idx).end = scale-point(text-content.at(txt-cont-idx).end)
    }

    let bbox = (
      base-point,
      base-point,
    )
    for bdg-part in building {
      for point in bdg-part.line-string {
        bbox = update-bbox(bbox, point)
      }
    }

    return (building, text-content, bbox)
  }

  #let display-configuration(config-name, building, text-content) = {
    for line-string-info in building {
      let (line-string, stroke) = line-string-info
      let layer = line-string-info.at("layer", default: 0)
      on-layer(layer, line(..line-string, fill: none, stroke: stroke))
    }
    for txt-cont in text-content {
      let (start, end, cont) = txt-cont
      on-layer(0, content(
        start,
        end,
        cont,
      ))
    }
  }

  #let configurations-infos = (
    "simple-balconies": (
      storeys: 7,
      balconies: range(1, 7),
      balcony-height: 1.5,
      balcony-width: 2,
      footprint-width: 2,
      caption: [Same balcony at every storey.],
    ),
    "alternated-balconies": (
      storeys: 7,
      balconies: range(5, 7, step: 1),
      balcony-height: 1.5,
      balcony-width: 2,
      footprint-width: 0,
      caption: [Only a few balconies.],
    ),
    "extruded-facade": (
      storeys: 7,
      balconies: (),
      facades-extrusions: (0,) + (1.5,) * 6,
      footprint-width: 1.5,
      caption: [Extruded façade.],
    ),
    "different-facades": (
      storeys: 7,
      balconies: (4, 5, 6),
      balcony-width: 2,
      facades-extrusions: (2, 4, 4, 4, 2, 0, -2),
      footprint-width: 4,
      caption: [Different façades with some balconies.],
    ),
  )

  // Compute the configurations
  #let configurations-geoms = (:)
  #for (config-key, config-infos) in configurations-infos.pairs() {
    let (building, text-content, bbox) = compute-configuration(..config-infos)

    configurations-geoms.insert(config-key, (building: building, text-content: text-content, bbox: bbox))
  }

  #let fig-label = "fig:balconies-in-roofprint-footprint"

  #let figures = ()
  #for (idx, name) in configurations-infos.keys().enumerate() {
    let config-infos = configurations-infos.at(name)
    let config-geom = configurations-geoms.at(name)
    let building = config-geom.building
    let text-content = config-geom.text-content
    let caption = config-infos.caption

    // Display the configuration
    figures.push([
      #figure(
        cetz.canvas({
          display-configuration(name, building, text-content)
        }),
        caption: caption,
      ) #label(fig-label + "-" + name)])
  }

  #subpar.super(
    caption: [
      Illustration in profile view of the unclear definition of the façade with balconies.
      The buildings are in blue with thin lines representing windows and the balconies in green.
      Dotted lines represent potential façades and the purple one is the one we chose in our definition.
    ],
    label: label(fig-label),
  )[
    #std.grid(
      columns: 4,
      column-gutter: 10mm,
      row-gutter: 5mm,
      ..figures
    )
  ]
]

In our case, the potential usage of @footprint:pl and @roofprint:pl which is considered is the possibility to turn #lod-version(2.2) buildings into #lod-version(2.3) by modelling roof overhangs, as shown in @fig:lods-illustration.
Since methods like @roofer use the points from the roof to reconstruct buildings, they require a @roofprint to work properly.
But then, since there is only a sparse distribution of points on the façades (if there are any points), identifying planes is often impossible, and the roofs are simply extruded down, creating #lod-version(2.2) buildings.
If the @footprint was known precisely, it would be possible to instead extrude it up to the roof, assuming that it is contained in the @roofprint.

Therefore, our definitions for @footprint:pl and @roofprint:pl should be the ones that would lead to the most accurate reconstruction of the buildings in 3D.
In practice, this means that the façades are defined as the most prevalent vertical surfaces, or in other terms, the vertical plane which has the largest intersection with the actual building (see @fig:balconies-in-roofprint-footprint).
This will often be the end of the balcony when the exact same balcony is present at every storey such as in @fig:balconies-in-roofprint-footprint-simple-balconies.
With this definition, the balconies have a significant advantage because in @als data, a balcony occludes the façade below it in the same way as roof overhangs, so they prevent the potential façade behind them to be seen.

== @als:short:noindex point clouds <sec:als-point-clouds>

@als:both:cap point clouds are sets of points acquired by a @lidar sensor mounted on a flying vehicle.
These @lidar sensors emit laser pulses at a very high frequency with a varying direction.
At the same time, the vehicle usually moves as much as possible in a straight line, at a constant speed and constant height.
Each pulse results in a continuous return signal, where peaks correspond to objects on the pulse trajectory, and are called echos.
By combining the trajectory of the scanning vehicle, the angle of the @lidar sensor and the time between emitting the pulse and receiving the returned peak, a 3D position can be computed for each echo, corresponding to an object in the scene.

The characteristics of the point clouds obtained with this method depend on many parameters #cite(<Wu2026>, form: "normal"):
- the pulse frequency: a higher pulse frequency results in denser point clouds along the scan lines,
- the altitude of the vehicle: a lower altitude results in denser point clouds covering smaller areas,
- the speed of the vehicle: a slower vehicle results in denser point clouds along the direction of the vehicle,
- the type of @lidar sensor: one or multiple fibres (laser emitters) with different motions (planar rotations, conical rotations, oscillations, or even more complex motions) result in different structures.

During this thesis, the main focus was the @lidarhd, which present similar characteristics to its Dutch counterpart the @ahn.
However, multiple different @als sensors have been used by the different contractors who took part in the acquisition of the @lidarhd.
Based on the work of #citep(<Wu2026>), the different motions for the sensors  found in the @lidarhd are illustrated in @fig:als-sensors.

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

  #let canvas-length = 2cm
  #let fig-height-row-1 = 6em
  #let fig-height-row-2 = 13em

  #let planar-figure = figure(
    box(
      align(horizon, cetz.canvas(
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

  #subpar.grid(
    planar-figure, sine-wave-figure,
    cross-figure, ellipse-figure,
    columns: 2,
    align: bottom,
    caption: [Illustration of different types of @als sensors, with multiple consecutive scan lines in orange, green and blue (the scanning vehicle is moving towards the bottom of the figures), inspired from @Wu2026.],
    label: <fig:als-sensors>,
  )
]

Even though they look completely different, these share common characteristics.
First, the motions of the fibres are continuous except for potential jumps between the end of a scan line and the beginning of the next scan line.
This means that except for rare exceptions, two consecutive pulses are very close geometrically.
Then, the directions of the pulses are almost vertical, with an angle rarely reaching more than 20°.
This property will be crucial for our method, as will be explained later.
Finally, we can always reconstruct a sort of multi-dimensional topology over the point cloud, because:
- all the echos acquired from a single pulse are ordered,
- all the pulses acquired along a single scan line are ordered,
- all the scan lines acquired along a single flight strip are ordered.

Therefore, one can move along any of these three dimensions to make computations in a comparable and predictable way.
Compared to the inherently chaotic nature of 3D point clouds, with every point having potentially a very different geometric neighbourhood, this can facilitate studying the properties of the point cloud.
More specifically, since the flight strips often overlap, they are merged into a point cloud which topological structure can be defined as illustrated in @fig:als-topological-structure.
In the @lidarhd, a tile corresponds to a square area of 1~km by 1~km.

#[
  #figure(
    cetz.canvas({
      import cetz.draw: *
      let rect-around(i) = {
        set text(size: 9pt)
        context {
          box(stroke: 1pt, inset: (x: 5pt), radius: 4pt, align(horizon, [#i]), height: text.size + 8pt)
        }
      }

      cetz.tree.tree(
        grow: 0.5,
        spread: 0.5,
        (
          rect-around([Tile]),
          rect-around([Flight strip]),
          [...],
          (
            rect-around([Flight strip]),
            rect-around([Scan line]),
            [...],
            (
              rect-around([Scan line]),
              rect-around([Pulse ]),
              [...],
              (
                rect-around([Pulse]),
                rect-around([Echo ]),
                [...],
                rect-around([Echo]),
                [...],
                rect-around([Echo]),
              ),
              [...],
              rect-around([Pulse]),
            ),
            [...],
            rect-around([Scan line]),
          ),
          [...],
          rect-around([Flight strip]),
        ),
      )
    }),
    caption: [Illustration of the topological structure of a tile of an @als point cloud.],
  ) <fig:als-topological-structure>
]

== Polygon deformation and topology

Polygons are complex shapes on which many different operations are possible.
A significant problem about them is the complexity associated with verifying their validity.
For example, a simple and brute-force approach to verifying that no pair of edges intersect in a polygon requires $n(n-1)$ checks if the polygon has $n$ edges.

In that regard, modifying a polygon instead of creating a new one from scratch can have some good properties.
Depending on the operations that are performed, checking the validity of the polygon can be very simple, or even unnecessary.
This is the case for most of the simple global operations on polygons: translations, rotations, scaling and even skewing, as long as they are applied globally, will never break the validity of a polygon.
This is because these are rigid transformations: the relative positions of the vertices remain unchanged.
However, these operations are very limited in their capabilities: their global aspect prevents them from patching specific regions of the polygons in different ways.

This is where local operations are necessary.
For these operations, the two most basic elements to work with are vertices and edges.
Choosing between the two is crucial and completely depends on the applications.
This choice and the number of constraints enforced in the movement determine how much freedom and how much complexity will be associated with the operation.
Here are a few examples, among many different possibilities #review-ravi[illustrate/explain further. I dont understand especially the middle one. Do you mean translation with ‘moving’? And then you can move an edge by translating in x and y, so 2 dimensions? Just like a point? Or are there constraints applicable here? like the line must remain parallel to original edge?]:
- translating a point freely gives 2 dimensions of freedom: one dimension for each axis (x and y).
- translating the line associated with an edge along its normal gives only 1 dimension of freedom: the distance between the initial and the final line.
- translating and rotating the line associated with an edge gives 2 dimensions of freedom: one for the translation distance and one for the rotation angle.


For most of these local operations, there will be bounds to how much each element can be modified before breaking the validity of the polygon.
These bounds correspond to a simple interval if there is only 1 dimension of freedom, and become more and more complex as the number of dimensions of freedom increases.
On top of that, these bounds are not independent for every point or edge.
Moving one point has an influence on how far its neighbour can be moved at the same time without breaking the polygon.
Therefore, the complexity of these operations increases when performing many of them at the same time, and depending on the type of operation, it can be very complex to express and manipulate these relations.

For this thesis, the constraints that we imposed on the initial polygons were the following (more details in @sec:paper):
- do not rotate any edge,
- do not flip any edge (see @fig:flipping-edge).

#[
  #import cetz.draw: *

  #let scale = 1.0
  #figure(
    [
      #set text(fill: blue.darken(10%), size: 10pt, style: "italic")
      #cetz.canvas(
        x: scale,
        y: scale,
        {
          content((-3, 1), [Before], anchor: "south", padding: (bottom: 0.3))
          line((-5, 0.4), (-3, 0), (-3, 1.0), (-1, 0.9), stroke: black + 1pt)
          mark((-3, 0.55), (-3, 1.0), symbol: ">>", stroke: black + 0.5pt, fill: red, anchor: "center", scale: 1.5)

          line((-0.5, 0), (0.5, 0), mark: (end: ">"), stroke: blue + 3pt, fill: blue)

          content((3, 1), [After], anchor: "south", padding: (bottom: 0.3))
          line((1, 0.4), (3, 0), (3, -0.9), (5, -1.0))
          mark((3, -0.5), (3, -0.9), symbol: ">>", stroke: black + 0.5pt, fill: red, anchor: "center", scale: 1.5)
          line((3, 0), (3, 1.0), (5, 0.9), stroke: (paint: black, thickness: 1pt, dash: "dashed"))
        },
      )
    ],
    caption: [Illustration an edge being flipped by the translation of a neighbour edge.],
  ) <fig:flipping-edge>
]

With these constraints in mind, the simplest way to understand and express the remaining movements is the following.
First, each edge is replaced by the infinite line that passes through it.
The polygon is therefore defined by a set of ordered lines, which intersections define the vertices (i.e. the two ends of the edges).
The only modification allowed is to replace any line by any parallel line, as long as this does not break the validity of the polygon.
In practice, this means that there can be a maximum distance to which this line can be shifted in both directions (see @fig:overshifting-edge).
The two directions have different maximum shifts, and only one of them can be infinite.

#[
  #import cetz.draw: *

  #let shift(p, dp: (0, 0)) = {
    return (p.at(0) + dp.at(0), p.at(1) + dp.at(1))
  }

  #let scale = 1.0
  #figure(
    [
      #set text(fill: blue.darken(10%), size: 10pt, style: "italic")
      #cetz.canvas(
        x: scale,
        y: scale,
        {
          // Black initial situation
          let points-black = (
            (-1.5, 1),
            (-1.5, 1.5),
            (-0.5, 2.5),
            (0.5, 2.5),
            (1.5, 2),
            (1.5, 1),
          )
          line(
            ..points-black,
            stroke: black,
          )
          line(
            (-0.5, 2.5),
            (0.5, 2.5),
            stroke: red,
          )
          for point in points-black {
            circle(point, radius: 0.1, fill: black, stroke: none)
          }

          // Blue example
          line((0, 2.5), (0, 3.25), mark: (end: ">"), stroke: blue, fill: blue)
          line((-2, 0.8), (-3.5, -0.3), mark: (end: ">"), stroke: blue + 5pt, fill: blue)
          line(
            (-2.5, 3.25),
            (2.5, 3.25),
            stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
          )
          let points-blue = (
            (-1.5, 1),
            (-1.5, 1.5),
            (0.25, 3.25),
            (-1, 3.25),
            (1.5, 2),
            (1.5, 1),
          )
          points-blue = points-blue.map(shift.with(dp: (-5, -3)))
          line(
            ..points-blue,
            stroke: (paint: blue, thickness: 1pt),
          )
          for point in points-blue {
            circle(point, radius: 0.1, fill: blue, stroke: none)
          }

          // Green example
          line((0, 2.5), (0, 1.75), mark: (end: ">"), stroke: green, fill: green)
          line((2, 0.8), (3.5, -0.3), mark: (end: ">"), stroke: green + 5pt, fill: green)
          line(
            (-2.5, 1.75),
            (2.5, 1.75),
            stroke: (paint: green, thickness: 1pt, dash: "dashed"),
          )
          let points-green = (
            (-1.5, 1),
            (-1.5, 1.5),
            (-1.25, 1.75),
            (2, 1.75),
            (1.5, 2),
            (1.5, 1),
          )
          points-green = points-green.map(shift.with(dp: (5, -3)))
          line(
            ..points-green,
            stroke: (paint: green, thickness: 1pt),
          )
          for point in points-green {
            circle(point, radius: 0.1, fill: green, stroke: none)
          }
        },
      )
    ],
    caption: [Illustration of an edge being shifted too far in the two directions.],
  ) <fig:overshifting-edge>
]

Additionally, since the polygons at hand represent buildings, several different polygons may share edges in situations where the buildings are adjacent.
If that is the case in the initial configuration of polygons, our method also tries to keep these adjacencies.
One way to consider it is to say that edges that are collinear should remain collinear.
This is a rather limited constraint, as it still allows shared vertices to be split into two different vertices.
The stronger version of this constraint is to enforce all shared vertices to remain the same vertex.
This results in harder constraints that preserve the topology better at the cost of some freedom on the movements of the lines.
In this case, if a vertex is shared by 3 non-collinear edges, keeping the vertex unique when shifting one of the edges implies to move at least one of the other edges, even if it was not necessary for the validity of the polygon.
@fig:topology-constraints illustrates these different constraints on a simple example.

#[
  #import cetz.draw: *

  #let shift(p, dp: (0, 0)) = {
    return (p.at(0) + dp.at(0), p.at(1) + dp.at(1))
  }

  #let fig-label = "fig:topology-constraints"

  #let figures = ()

  #{
    let update-bbox(bbox, point) = {
      bbox = (
        (
          calc.min(bbox.at(0).at(0), point.at(0)),
          calc.min(bbox.at(0).at(1), point.at(1)),
        ),
        (
          calc.max(bbox.at(1).at(0), point.at(0)),
          calc.max(bbox.at(1).at(1), point.at(1)),
        ),
      )
      return bbox
    }

    // Black initial situation
    let moving-edge = ((0.3, -1.5), (0, 0))
    let segments-black = (
      ((-2, 1), (0, 0)),
      ((2, 1), (0, 0)),
      moving-edge,
    )
    // Red line and arrow
    let line-red = ((0.4, -2), (-0.3, 1.5))
    let shift-red = (-0.75, -0.15)
    line-red = line-red.map(shift.with(dp: shift-red))
    let start-arrow = (
      (moving-edge.at(0).at(0) + moving-edge.at(1).at(0)) / 2,
      (moving-edge.at(0).at(1) + moving-edge.at(1).at(1)) / 2,
    )
    let end-arrow = shift(start-arrow, dp: shift-red)
    // Blue example
    let segments-blue = (
      ((-2, 1), (-0.88, 0.44)),
      ((2, 1), (-0.71, -0.355)),
      ((-0.45, -1.65), (-0.88, 0.44)),
    )
    // Orange example
    let segments-orange = (
      ((-2, 1), (-0.88, 0.44)),
      ((1.12, 1.44), (-0.88, 0.44)),
      ((-0.45, -1.65), (-0.88, 0.44)),
    )
    // Green example
    let segments-green = segments-black.map(s => s.map(shift.with(dp: shift-red)))

    // Bbox
    let bbox = (
      (calc.inf, calc.inf),
      (-calc.inf, -calc.inf),
    )
    for segments in (segments-black, segments-blue, segments-orange, segments-green, (line-red,)) {
      for segment in segments {
        for point in segment {
          bbox = update-bbox(bbox, point)
        }
      }
    }
    let margin = 0.2
    bbox = (
      (bbox.at(0).at(0) - margin, bbox.at(0).at(1) - margin),
      (bbox.at(1).at(0) + margin, bbox.at(1).at(1) + margin),
    )
    let add-invisible-bbox() = { rect(..bbox, stroke: none, fill: none) }

    figures.push(
      std.grid.cell(
        [#figure(
            cetz.canvas({
              for points in segments-black {
                line(
                  ..points,
                  stroke: black,
                )
                for point in points {
                  circle(point, radius: 0.1, fill: black, stroke: none)
                }
              }
              line(
                ..line-red,
                stroke: (paint: red, thickness: 1pt, dash: "dashed"),
              )
              line(start-arrow, end-arrow, mark: (end: ">"), stroke: red + 1.5pt, fill: red)
              add-invisible-bbox()
            }),
            caption: [Initial situation],
          ) #label(fig-label + "-initial")],
        colspan: 3,
      ),
    )

    figures.push(
      [#figure(
          cetz.canvas({
            for points in segments-black {
              line(
                ..points,
                stroke: (paint: black, thickness: 1pt, dash: "dashed"),
              )
              for point in points {
                circle(point, radius: 0.1, fill: black, stroke: none)
              }
            }
            for points in segments-blue {
              line(
                ..points,
                stroke: blue,
              )
              for point in points {
                circle(point, radius: 0.1, fill: blue, stroke: none)
              }
            }
            add-invisible-bbox()
          }),
          caption: [Softer constraint on shared edges.],
        ) #label(fig-label + "-soft")],
    )

    figures.push(
      [#figure(
          cetz.canvas({
            for points in segments-black {
              line(
                ..points,
                stroke: (paint: black, thickness: 1pt, dash: "dashed"),
              )
              for point in points {
                circle(point, radius: 0.1, fill: black, stroke: none)
              }
            }
            for points in segments-orange {
              line(
                ..points,
                stroke: orange,
              )
              for point in points {
                circle(point, radius: 0.1, fill: orange, stroke: none)
              }
            }
            add-invisible-bbox()
          }),
          caption: [Harder constraint on shared vertices: a solution.],
        ) #label(fig-label + "-hard-1")],
    )

    figures.push(
      [#figure(
          cetz.canvas({
            for points in segments-black {
              line(
                ..points,
                stroke: (paint: black, thickness: 1pt, dash: "dashed"),
              )
              for point in points {
                circle(point, radius: 0.1, fill: black, stroke: none)
              }
            }
            for points in segments-green {
              line(
                ..points,
                stroke: green,
              )
              for point in points {
                circle(point, radius: 0.1, fill: green, stroke: none)
              }
            }
            add-invisible-bbox()
          }),
          caption: [Harder constraint on shared vertices: another solution.],
        ) #label(fig-label + "-hard-2")],
    )
  }

  #subpar.super(
    caption: [
      Illustration of an edge being shifted with one of its vertex shared by three edges. Three different results are shown: @fig:topology-constraints-soft displays the softer constraint on shared edges, while @fig:topology-constraints-hard-1 and @fig:topology-constraints-hard-2 show two different solutions to the harder constraint on shared vertices.
    ],
    label: label(fig-label),
  )[
    #std.grid(
      columns: 3,
      column-gutter: 10mm,
      row-gutter: 5mm,
      ..figures
    )
  ]
]


== Optimisation and energy

Once a set of constraints are defined for the deformation of the polygons, this results in an infinite set of potential polygons.
The goal is then to find the best polygon for a specific use case.
This is called optimisation, and it usually needs two elements that will work together:
+ a criterion, also called energy, which is used to estimate how good a given polygon is,
+ an exploration strategy, which tries to navigate in the complex space of potential solutions to find the polygon giving the best energy.

In this report, the best energy is assumed to be the lowest energy, so the goal of optimisation is to find the polygon that minimises the energy.
There are infinitely many ways to create a formula for an energy, and these different ways will result in a different polygon being the best.
For the optimisation of the @roofprint:pl, the energy should be something that is minimal when the polygon corresponds perfectly to the edges of the roof.
More details are given in @sec:paper about the energy used in our method.

Often, the energy can be a high-dimensional function, with many parameters to optimise together.
In our case, with the constraints that we set on the polygons, there are usually $n$ variables to optimise at the same time if the polygon has $n$ vertices.
Moreover, we consider that our starting point is already a good first guess: the initial @outline:pl of our method are assumed to be up to a few meters off, with only small local deformations of the polygon being necessary.
In this situation, the simplest procedure is to optimise every single parameter iteratively.
In practice, this means:
+ picking one line,
+ computing the energy of the polygon obtained after shifting this line by many different amounts in both directions,
+ picking the polygon with the best energy as the new polygon,
+ starting again with a new line and the new polygon.

This kind of iterative and simplified process can however lead to completely incorrect final configurations.
One of its downsides is that the first iterations are the most crucial: since it may start relatively far from its optimal solution, the first iterations may find their minimal values in the wrong direction, which can snowball into finding an incorrect locally minimal configuration.
Moreover, the order of the iterations matter: the result may be completely different depending on which lines were treated first.
This means that picking a good order is important, and also that it is possible to try different orders and pick the best final solution.
In our case, treating the longest edges first seems to be a smart choice, as longer edges are relatively less impacted by their initial incorrect translation than smaller edges.
But the main advantage of this method is its simplicity and its speed: it reduces the optimisation of a complex function into a series of simpler one-dimensional problems, which is computationally very quick.
#review-ravi[Did you measure the runtime performance as a function of relevant variables like number of polygon edges?]

== 3D city modelling

Even if this thesis is focussed on producing 2D polygons, its outputs could greatly improve the generation of 3D building models.
To understand why, it is necessary to know about the current existing methods to produce #lod-version(2.2) buildings.

In the last few years, several methods have demonstrated their ability to produce high-quality #lod-version(2.2) building models from two inputs: a high-density @als point cloud and building @outline:pl #citen(<Paden2024>) #citen(<Huang2022>) #citen(<Bauchet2024>).
Since @als data is acquired by planes shooting rays that are mostly vertical, it contains high density of points on horizontal surfaces (such as roofs) and low density on vertical surfaces (such as façades), as illustrated in @fig:illustration-vertical-gap.
This low density makes it difficult to use for the façades the same plane fitting techniques that are used for the roofs.
Furthermore, the roof overhangs create occlusion which reduces further the amount of points on the façades.
For these reasons, the methods mentioned above focus on creating a precise and accurate model of the roof and simply extrude down the roof to get the façades, which results in #lod-version(2.2) models.

#[
  #import cetz.draw: *

  #let building-color = blue
  #let building-stroke = building-color + 1pt
  #let pulse-color = green.darken(20%)
  #let pulse-stroke = (paint: pulse-color, thickness: 1pt, dash: "dashed")
  #let point-color = orange
  #let text-size = 10pt
  #let scale-value = 1.5
  #let scale-func(t) = { scale-value * t }

  #let pulses-1 = (
    (10deg, (-0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6).map(scale-func)),
  )
  #let pulses-2 = (
    (10deg, (-0.5, -0.3, -0.1, 0.1, 0.3, 0.5).map(scale-func)),
  )
  #let pulse-start-y = 3.5 * scale-value
  #let limits-x = (0, 2.4, 4.9, 7.1, 9.4).map(scale-func)
  #let scenarios = (
    (
      data: ((limits-x.at(0), 0), 3, 1.2, 30deg, 0.6, pulse-start-y, pulses-1),
      label: ([Multi-echo hitting the ground], limits-x.at(0), limits-x.at(1)),
    ),
    (
      data: ((limits-x.at(1), 0), 3, 1.2, 30deg, 0.6, pulse-start-y, pulses-2),
      label: ([Single-echo with next point on the ground], limits-x.at(1), limits-x.at(2)),
    ),
    (
      data: ((limits-x.at(2), 0), 4.5, 1.2, 30deg, 0.3, pulse-start-y, pulses-1),
      label: ([Multi-echo hitting the façade], limits-x.at(2), limits-x.at(3)),
    ),
    (
      data: ((limits-x.at(3), 0), 4.5, 1.2, 30deg, 0.3, pulse-start-y, pulses-2),
      label: ([Single-echo with next point on the façade], limits-x.at(3), limits-x.at(4)),
    ),
  )

  #let intersection-lines(l1, l2) = {
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

  #let optimal-pulse(roof-edge-xy, vertical-angle, start-y, facade-x, ground-y, color) = {
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

  #let pulse(roof-edge, vertical-angle, start-y, start-shift-x, facade-x, ground-y) = {
    let ((roof-edge-sx, roof-edge-sy), (roof-edge-ex, roof-edge-ey)) = roof-edge
    let optimal-start-x = roof-edge-ex + (start-y - roof-edge-ey) * calc.tan(vertical-angle)
    let start-x = optimal-start-x + start-shift-x

    let hit-roof = false
    let roof-point = (0, 0)
    if (start-shift-x <= 0) {
      // Intersection with the roof edge
      hit-roof = true
      roof-point = intersection-lines(roof-edge, (
        (start-x, start-y),
        (start-x + 1, start-y + 1 / calc.tan(vertical-angle)),
      ))
    }

    let hit-bdg-grnd = false
    let bdg-grnd-point = (0, 0)
    if (start-shift-x >= 0) {
      // Intersection with the ground or the façade
      hit-bdg-grnd = true
      let ground-x = start-x + (ground-y - start-y) * calc.tan(vertical-angle)

      if ground-x > facade-x {
        bdg-grnd-point = (ground-x, ground-y)
      } else {
        let facade-y = start-y + (facade-x - start-x) / calc.tan(vertical-angle)
        bdg-grnd-point = (facade-x, facade-y)
      }
    }

    let end = (0, 0)
    if (hit-bdg-grnd) {
      end = bdg-grnd-point
    } else {
      end = roof-point
    }

    line((start-x, start-y), end, stroke: pulse-stroke)

    if (hit-bdg-grnd) {
      circle(bdg-grnd-point, radius: 0.08, stroke: none, fill: point-color)
    }
    if (hit-roof) {
      circle(roof-point, radius: 0.08, stroke: none, fill: point-color)
    }
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

    let roof-edge = overhang-points

    line(..house-points, close: true, stroke: building-stroke, fill: building-color)
    line(..overhang-points, stroke: building-stroke)

    for (vertical-angle, x-shifts) in pulses {
      for x-shift in x-shifts {
        pulse(roof-edge, vertical-angle, pulse-height, x-shift, sx + width, sy)
      }
    }
  }

  #let legend(position, anchor, space-between) = {
    let (px, py) = position

    {
      let start = (px, py - 0.4)
      let end = (px + 0.5, py - 0.6)
      let label-pos = (px + 0.5, py - 0.5)
      rect(start, end, stroke: none, fill: building-color)
      content(label-pos, padding: 0.1, text(size: text-size, [Building]), anchor: "west")
    }

    py -= space-between

    {
      let start = (px, py - 0.5)
      let end = (px + 0.5, py - 0.5)
      line(start, end, stroke: pulse-stroke)
      content(end, padding: 0.1, text(size: text-size, [Pulse]), anchor: "west")
    }

    py -= space-between

    {
      let start = (px, py - 0.5)
      let end = (px + 0.5, py - 0.5)
      let mid = ((start.at(0) + end.at(0)) / 2, (start.at(1) + end.at(1)) / 2)
      circle(mid, radius: 0.08, stroke: none, fill: point-color)
      content(end, padding: 0.1, text(size: text-size, [Point]), anchor: "west")
    }
  }

  #let scenario-label(body, start-x, end-x, start-y: -0.3, height: 1.3) = {
    let text-formatted = align(center, text(size: text-size, par(justify: false, body)))
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

  #figure(
    cetz.canvas({
      for scenario in scenarios {
        let (data, label) = scenario
        house(..data)
        scenario-label(..label)
      }
      legend((-1, pulse-start-y), "north-west", 0.4)
    }),
    caption: [Illustration in profile view of the lack or sparsity of points on the façades.],
  ) <fig:illustration-vertical-gap>
]

In all of these methods, the @outline:pl are used initially to select which points in the point cloud should be used for the reconstruction of each building.
This is a crucial step, as having too many or too few points can lead to incorrect results.
Therefore, to reconstruct a perfect roof, a @roofprint would be the best input for these methods, even though the papers mention @footprint:pl due to the difference often not being made.
On top of that, precise @outline:pl could help extracting precise and well-oriented edges for the roof model, as extracting precise directions from @als data is difficult.

Besides guiding the reconstruction process better with a @roofprint, these methods could also use a @footprint to create more detailed models.
Instead of using the outline of the final 3D roof model to extrude down and get the final 3D building model, these methods could use the @footprint and extrude it up until it reaches the roof model.
This would allow to very simply move from #lod-version(2.2) to #lod-version(2.3), assuming that the @footprint:pl are correct.

