#import "../common_imports.typ": *
#show: isprs-heading

#import "../data/validation/validation.typ": datasets-infos, datasets-full, datasets-per-category, datasets-labels, simple-categories, categories-infos, metrics-infos, display-table, display-bars, display-evolutions, nice-tables

= Introduction

The geometry of buildings in 2D maps and databases is generally represented through 2D polygons describing either the @footprint or the @roofprint of the building, while in 3D buildings are typically represented by surfacic or volumic polyedral models.
@lod:pl have been extended by #cite(<Biljecki2016>, form:"prose") to characterise 16 different levels of precision of these models with generally increasing complexity and fidelity to the reality.
These @lod:pl are illustrated in @fig:lods-illustration.
As pointed out by the authors, the crucial properties of a building model depend completely on the application.
For example, an accurate footprint is more important than a proper roof shape to estimate the exact internal area available in a building.
Another example is the volume of a building which requires the combination of a correct roof and correct façades for precise computations.
These values are useful for energy estimations, property tax calculation, real estate valuation, and population counts #cite(<Boeters2015>, form: "normal") #cite(<Kaden2014>, form: "normal").

#figure(
  image("../figures/LoDs_illustration-Filip_Biljecki.jpg", width: 90%),
  caption: [Illustration of the @lod:pl #cite(<Biljecki2016>).],
  placement: auto,
) <fig:lods-illustration>

One distinction that is often overlooked and is not present even in the 2D #lod-version[0.x] models is the difference between the @footprint and the @roofprint of a building.
Even when representing buildings with a simple 2D polygon corresponding to the horizontal area it occupies, multiple choices can be made.
These choices are often data-driven: when measurements are made by experts directly on the terrain, the delimitations of the façades close to the ground are the easiest to measure, leading to the creation of a @footprint.
When measurements are made from aerial data -- usually images or @lidar -- the roof is the simplest element to identify and annotate, leading to the creation of a @roofprint.
Other decisions also have to be made when creating a single horizontal polygon for a building, the simplest example being the inclusion or exclusion of other overhanging objects such as balconies.

The difference between the @roofprint and the @footprint is only meaningful when the roof extends beyond the façades of the building.
These elements are called roof overhangs and can be found in many buildings in Europe.
These appear in the @lod classification at levels 2.3 and 3.1.
Sometimes, as in the example of the @bdtopo, buildings are represented as a mix of @footprint:pl and @roofprint:pl.
This awkward situations is explained by the fusion of two datasets that were historically created and maintained by two different French institutions.
The first one was focused on taxes and therefore looked for precise areas, with @footprint:pl measured by experts on the terrain.
The second used the best available data at that time at the scale of France, which was aerial imagery, leading to the creation of @roofprint:pl.

In the last decade, growing interest for high-density @als point clouds has lead many European countries to producing their own datasets.
This includes among others Denmark, Finland, France (@lidarhd), the Netherlands (@ahn) and Spain.
In the last few years, several methods have demonstrated their ability to produce high-quality #lod-version(2.2) building models from two inputs: a high-density @als point cloud and building @roofprint:pl #citen(<Paden2024>) #citen(<Huang2022>) #citen(<Bauchet2024>).
These methods are currently limited to #lod-version(2.2) due to the very nature of @als data.
Since it is acquired by planes shooting rays that are mostly vertical, it contains high density of points on horizontal surfaces (such as roofs) and low density on vertical surfaces (such as façades), as illustrated in @fig:illustration-vertical-gap.
This low density makes it difficult to use for the façades the same plane fitting techniques that are used for the roofs.
Furthermore, the roof overhangs create occlusion which reduces further the amount of points on the façades.

#[
  #import cetz.draw: *
  
  #let building-color = blue
  #let building-stroke = building-color + 1pt
  #let pulse-color = green.darken(20%)
  #let pulse-stroke = (paint: pulse-color, thickness: 1pt, dash: "dashed")
  #let point-color = orange

  #let pulses-1 = (
    (10deg, (-0.4, -0.2, 0.0, 0.2, 0.4)),
  )
  #let pulses-2 = (
    (10deg, (-0.3, -0.1, 0.1, 0.3)),
  )
  #let pulse-start-y = 3.5
  #let limits-x = (0, 1.9, 3.9, 5.6, 7.4)
  #let scenarios = (
    (
      data: ((limits-x.at(0), 0), 2, 0.8, 30deg, 0.4, pulse-start-y, pulses-1), 
      label: ([Multi-echo hitting the ground], limits-x.at(0), limits-x.at(1))
    ),
    (
      data: ((limits-x.at(1), 0), 2, 0.8, 30deg, 0.4, pulse-start-y, pulses-2),
      label: ([Single-echo with next point on the ground], limits-x.at(1), limits-x.at(2))
    ),
    (
      data: ((limits-x.at(2), 0), 3, 0.8, 30deg, 0.2, pulse-start-y, pulses-1),
      label: ([Multi-echo hitting the façade], limits-x.at(2), limits-x.at(3))
    ),
    (
      data: ((limits-x.at(3), 0), 3, 0.8, 30deg, 0.2, pulse-start-y, pulses-2),
      label: ([Single-echo with next point on the façade], limits-x.at(3), limits-x.at(4))
    ),
  )

  #let intersection-lines(l1, l2) = {
    let ((x1, y1), (x2, y2)) = l1
    let ((x3, y3), (x4, y4)) = l2

    let intersec-x = ((x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4)) / ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))
    let intersec-y = ((x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4)) / ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))

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
    if (start-shift-x <= 0 ) {
      // Intersection with the roof edge
      hit-roof = true
      roof-point = intersection-lines(roof-edge, ((start-x, start-y), (start-x + 1, start-y + 1 / calc.tan(vertical-angle))))
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
        pulse(roof-edge, vertical-angle, pulse-height, x-shift, sx+width, sy)
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
        inset: (left: 0.0em, right: 0.8em)
      ),
    )
  }
  
  #figure(
    cetz.canvas(
      {
        for scenario in scenarios {
          let (data, label) = scenario
          house(..data)
          scenario-label(..label)
        }
        legend((-0.5, 4), "north-west", 0.3)
      }
    ),
    caption: [Illustration in profile view of the different scenarios for consecutive pulses around a roof edge.],
  ) <fig:illustration-vertical-gap>
]

Therefore, with these methods, the façades are most often only a downwards extrusion of the roof.
This results in incorrectly positioned façades, and the volume of the building is often overvalued. 
Some applications like lighting simulations or texturing of the façades would benefit from correctly positioning both the end of the roof and the façades, which is not possible for building with overhangs in #lod-version(2.2).
An illustration of the strengths and weaknesses of these methods is the @3dbag, which contains more than 10M buildings covering the whole of the Netherlands #cite(<Peters2022>, form: "normal") and was generated using the @ahn and the @bag as inputs, the Dutch equivalents of the @lidarhd and the @bdtopo respectively.
The 3D models have very accurate roofs, but the façades depend on the input that was used, either a @footprint or a @roofprint.

As explained in @hea:related-work, there is little research on the distinction between @footprint:pl and @roofprint:pl, as well as in the ability to produce both from @als data.
This is also the case for modelling the roof overhangs to create #lod-version(2.3) buildings, which is the 3D counterpart of this 2D distinction.

In this context, we propose in this paper a method to address at the same time the registration of building @outline:pl and the creation of both a @roofprint and a @footprint for each building in @hea:methodology.
Our method takes as input building @outline:pl (which can be anything between a @footprint and a @roofprint) and high-density @als data, to create consecutively for each building a @roofprint and a @footprint coherent with the input point cloud (see @hea:input-data).

The method was tested on the two French datasets @bdtopo and @lidarhd with promising results displayed in @hea:experiments.
These experiments displayed how the method is capable of repositioning the initial imprecise @outline:pl while deforming them if necessary.
#{
  let format-averages-cat(category-key) = {
    let formattings = (
      iou : avg => [#{calc.round(100 * avg, digits: 2)}%],
      centroid_distance: avg => [#{calc.round(avg, digits: 3)}~m],
      chamfer: avg => [#{calc.round(avg, digits: 3)}~m],
    )
    let values = (:)
    for metric-infos in metrics-infos.values() {
      let metric-key = metric-infos.key
      let formatting = formattings.at(metric-key)
      let metric-values = (:)
      for (idx, dataset-infos) in datasets-infos.values().enumerate() {
        let metric-dataset-values = datasets-per-category.at(category-key).at(idx).values().map(t => t.at(metric-key))
        let avg = metric-dataset-values.sum() / metric-dataset-values.len()
        metric-values.insert(dataset-infos.key, formatting(avg))
      }
      values.insert(metric-key, metric-values)
    }

    [
      - the average #metrics-infos.iou.name with the ground-truth polygon went from #values.iou.bdtopo to #values.iou.iter3,
      - the average distance to the ground-truth centroid went from #values.centroid_distance.bdtopo to #values.centroid_distance.iter3,
      - the average #metrics-infos.chamfer.name to the ground-truth polygon went from #values.chamfer.bdtopo to #values.chamfer.iter3.
    ]
  }

  [
    On all buildings except low sheds, when comparing to the ground-truth in our validation dataset, the scores significantly improved after 3 iterations of our algorithm compared to the initial outlines in the @bdtopo:
    #format-averages-cat("all_except_low_sheds")

    The best results were reached with the isolated, medium-sized houses, which are the main target of this algorithm:
    #format-averages-cat("isolated_houses")
  ]
}

The main contributions of this paper are:
- a simple but effective method to extract and use evidence of roof edges from @als point clouds with topological-aware operations,
- a basic method to extract and use evidence for the @footprint:pl despite their sparsity,
- an algorithm to deform polygons while keeping the angles of the edges and the connections between adjacent polygons,
- a fast and iterative optimisation method with specific variations for @roofprint:pl and @footprint:pl,
- all combined in a method to create coherent polygonal @roofprint:pl and @footprint:pl directly from @als point cloud data and an initially imprecise but topologically accurate @outline.
