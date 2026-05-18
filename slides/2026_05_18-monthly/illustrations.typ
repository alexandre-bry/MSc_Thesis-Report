#import "@preview/suiji:0.5.1": *
#import "@preview/cetz:0.5.0"

#let get-edge-vector(edge-start, edge-end) = (edge-end.at(0) - edge-start.at(0), edge-end.at(1) - edge-start.at(1))

#let get-edge-length(edge-start, edge-end) = {
  let edge-vector = get-edge-vector(edge-start, edge-end)
  calc.sqrt(edge-vector.at(0) * edge-vector.at(0) + edge-vector.at(1) * edge-vector.at(1))
}

#let get-edge-perpendicular-dir(edge-start, edge-end) = {
  let edge-vector = get-edge-vector(edge-start, edge-end)
  let edge-length = get-edge-length(edge-start, edge-end)
  (-edge-vector.at(1) / edge-length, edge-vector.at(0) / edge-length)
}

#let generate-random-points-in-box(
  num-points: 10,
  low-x: 0,
  high-x: 10,
  low-y: 0,
  high-y: 10,
  rand-seed: 0,
) = {
  let rng = gen-rng-f(rand-seed)
  let points = ()

  for i in range(num-points) {
    let x
    let y
    (rng, x) = uniform-f(rng, low: low-x, high: high-x, size: 1)
    (rng, y) = uniform-f(rng, low: low-y, high: high-y, size: 1)

    points.push((x.at(0), y.at(0)))
  }

  points
}

#let generate-random-points-around-edge(
  num-points: 10,
  edge-start: (0, 0),
  edge-end: (2, 5),
  scale: 0.5,
  rand-seed: 0,
) = {
  let rng = gen-rng-f(rand-seed)
  let points = ()

  let edge-vector = get-edge-vector(edge-start, edge-end)
  let edge-perpendicular-dir = get-edge-perpendicular-dir(edge-start, edge-end)

  for i in range(num-points) {
    let t
    let distance
    (rng, t) = uniform-f(rng, low: 0, high: 1, size: 1)
    (rng, distance) = normal-f(rng, loc: 0, scale: scale, size: 1)

    let projection = (edge-start.at(0) + t.at(0) * edge-vector.at(0), edge-start.at(1) + t.at(0) * edge-vector.at(1))
    let point = (
      projection.at(0) + distance.at(0) * edge-perpendicular-dir.at(0),
      projection.at(1) + distance.at(0) * edge-perpendicular-dir.at(1),
    )
    points.push(point)
  }

  points
}

#let project-points-on-edge(points, edge-start, edge-end) = {
  let edge-vector = get-edge-vector(edge-start, edge-end)
  let edge-length = get-edge-length(edge-start, edge-end)

  let points-projections = ()
  let points-distances = ()

  for point in points {
    let point-vector = (point.at(0) - edge-start.at(0), point.at(1) - edge-start.at(1))
    let t = (
      (point-vector.at(0) * edge-vector.at(0) + point-vector.at(1) * edge-vector.at(1)) / (edge-length * edge-length)
    )

    // If outside of the line segment, return None
    if t < 0 or t > 1 {
      points-projections.push(none)
      points-distances.push(none)
      continue
    }

    let projection = (edge-start.at(0) + t * edge-vector.at(0), edge-start.at(1) + t * edge-vector.at(1))
    let distance = calc.sqrt(
      (point.at(0) - projection.at(0)) * (point.at(0) - projection.at(0))
        + (point.at(1) - projection.at(1)) * (point.at(1) - projection.at(1)),
    )

    points-projections.push(projection)
    points-distances.push(distance)
  }

  (points-projections, points-distances)
}

#let translate-edge-perp(edge-start, edge-end, translation) = {
  let edge-perpendicular-dir = get-edge-perpendicular-dir(edge-start, edge-end)

  let edge-start-translated = (
    edge-start.at(0) + edge-perpendicular-dir.at(0) * translation,
    edge-start.at(1) + edge-perpendicular-dir.at(1) * translation,
  )
  let edge-end-translated = (
    edge-end.at(0) + edge-perpendicular-dir.at(0) * translation,
    edge-end.at(1) + edge-perpendicular-dir.at(1) * translation,
  )

  (edge-start-translated, edge-end-translated)
}

#let fig-edge-matching-criterion(
  num-points-uniform: 30,
  num-points-around: 20,
  edge-start: (0, 0),
  edge-end: (2, 5),
  buffer: 2,
  criterion-distance: 0.5,
  rand-seed: 0,
) = {
  let rng = gen-rng-f(rand-seed)

  let edge-vector = get-edge-vector(edge-start, edge-end)
  let edge-length = get-edge-length(edge-start, edge-end)
  let edge-perpendicular-dir = get-edge-perpendicular-dir(edge-start, edge-end)

  let points = ()

  // Generate random points in the box defined by the line segment and the buffer around it
  let low-x = calc.min(edge-start.at(0), edge-end.at(0)) - buffer * 0.5
  let high-x = calc.max(edge-start.at(0), edge-end.at(0)) + buffer * 0.5
  let low-y = calc.min(edge-start.at(1), edge-end.at(1)) - buffer * 0.5
  let high-y = calc.max(edge-start.at(1), edge-end.at(1)) + buffer * 0.5

  let random-points = generate-random-points-in-box(
    num-points: num-points-uniform,
    low-x: low-x,
    high-x: high-x,
    low-y: low-y,
    high-y: high-y,
    rand-seed: rand-seed,
  )
  points += random-points

  // Generate random points around the line segment with a normal distribution
  let uniform-points = generate-random-points-around-edge(
    num-points: num-points-around,
    edge-start: edge-start,
    edge-end: edge-end,
    scale: criterion-distance * 0.5,
    rand-seed: rand-seed + 1,
  )
  points += uniform-points

  // Compute for each point its projection on the line and its distance to the line
  let (points-projections, points-distances) = project-points-on-edge(points, edge-start, edge-end)

  let points-colors = ()
  let point-gradient = gradient.linear(..color.map.rocket)
  for i in range(points.len()) {
    if (points-distances.at(i) != none and points-distances.at(i) > criterion-distance) {
      points-projections.at(i) = none
      points-distances.at(i) = none
    }

    if points-distances.at(i) == none {
      points-colors.push(point-gradient.sample(0%))
    } else {
      let score = calc.max(0, 1 - points-distances.at(i) / criterion-distance) * 100%
      points-colors.push(point-gradient.sample(score))
    }
  }

  cetz.canvas({
    import cetz.draw: *

    // Draw the line segment
    line(edge-start, edge-end, stroke: (paint: green, thickness: 0.05))

    // Draw the lines from points to their projections
    for (point, projection) in points.zip(points-projections) {
      if projection != none {
        line(point, projection, stroke: (paint: gray, thickness: 0.02))
      }
    }

    // Draw the points
    for (point, color) in points.zip(points-colors) {
      circle(point, radius: 0.05, fill: color, stroke: (paint: black, thickness: 0.01))
    }

    // Draw the buffer around the line segment
    let buffer-vector = (
      -criterion-distance * edge-vector.at(1) / edge-length,
      criterion-distance * edge-vector.at(0) / edge-length,
    )
    let buffer-corners = (
      (edge-start.at(0) + buffer-vector.at(0), edge-start.at(1) + buffer-vector.at(1)),
      (edge-start.at(0) - buffer-vector.at(0), edge-start.at(1) - buffer-vector.at(1)),
      (edge-end.at(0) - buffer-vector.at(0), edge-end.at(1) - buffer-vector.at(1)),
      (edge-end.at(0) + buffer-vector.at(0), edge-end.at(1) + buffer-vector.at(1)),
    )
    buffer-corners.push(buffer-corners.at(0)) // Close the polygon
    line(..buffer-corners, fill: none, stroke: (dash: "dashed", paint: blue, thickness: 0.02))
  })
}

// #figure(
//   scale(fig-edge-matching-criterion(num-points-uniform: 20, num-points-around: 20, rand-seed: 1), 100%, reflow: true),
// )

#let fig-edge-matching-translation-steps = 3

#let fig-edge-matching-translation(
  fig-step,
  num-points-uniform: 30,
  num-points-around: 20,
  edge-start: (0, 0),
  edge-end: (2, 5),
  buffer: 2,
  criterion-distance: 0.5,
  rand-seed: 0,
) = {
  let rng = gen-rng-f(rand-seed)

  let edge-vector = get-edge-vector(edge-start, edge-end)
  let edge-length = get-edge-length(edge-start, edge-end)
  let edge-perpendicular-dir = get-edge-perpendicular-dir(edge-start, edge-end)

  let points = ()

  // Generate random points in the box defined by the line segment and the buffer around it
  let low-x = calc.min(edge-start.at(0), edge-end.at(0)) - buffer * 0.5
  let high-x = calc.max(edge-start.at(0), edge-end.at(0)) + buffer * 0.5
  let low-y = calc.min(edge-start.at(1), edge-end.at(1)) - buffer * 0.5
  let high-y = calc.max(edge-start.at(1), edge-end.at(1)) + buffer * 0.5

  let random-points = generate-random-points-in-box(
    num-points: num-points-uniform,
    low-x: low-x,
    high-x: high-x,
    low-y: low-y,
    high-y: high-y,
    rand-seed: rand-seed,
  )
  points += random-points

  // Generate random points around the line segment with a normal distribution
  let edges-translated = ()
  let min-translation = -1
  let max-translation = 1
  let step-translation = 0.2
  let best-translation = step-translation * 2
  let current-translation = min-translation
  while current-translation <= max-translation {
    edges-translated.push(translate-edge-perp(edge-start, edge-end, current-translation))
    current-translation += step-translation
  }
  let best-edge = translate-edge-perp(edge-start, edge-end, best-translation)
  let uniform-points = generate-random-points-around-edge(
    num-points: num-points-around,
    edge-start: best-edge.at(0),
    edge-end: best-edge.at(1),
    scale: criterion-distance * 0.5,
    rand-seed: rand-seed + 1,
  )
  points += uniform-points

  cetz.canvas({
    import cetz.draw: *

    // Draw the line segment
    line(edge-start, edge-end, stroke: (paint: green, thickness: 0.05))

    // Draw the points
    for point in points {
      circle(point, radius: 0.05, fill: black, stroke: (paint: black, thickness: 0.01))
    }

    // Draw all the translated edges
    if (fig-step == 1) {
      for (translated-start, translated-end) in edges-translated {
        line(translated-start, translated-end, stroke: (dash: "dashed", paint: gray, thickness: 0.02))
      }
    }

    // Draw the best translated edge
    if (fig-step == 2) {
      line(
        best-edge.at(0),
        best-edge.at(1),
        stroke: (dash: "dashed", paint: red, thickness: 0.03),
      )
    }
  })
}

// #{
//   let figures = ()
//   for fig-step in range(fig-edge-matching-translation-steps) {
//     figures.push(figure(
//       scale(
//         fig-edge-matching-translation(
//           fig-step,
//           num-points-uniform: 20,
//           num-points-around: 40,
//           rand-seed: 2,
//         ),
//         100%,
//         reflow: true,
//       ),
//     ))
//   }
//   grid(columns: fig-edge-matching-translation-steps, ..figures)
// }


#let fig-point-cloud-topology() = {
  cetz.canvas({
    import cetz.draw: *
    let rect-around(i) = {
      std.box(stroke: 1pt, inset: 4pt, radius: 4pt, [#i])
    }

    // set-style(content: (padding: 0.1em))
    cetz.tree.tree(
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
  })
}

// #set page(width: auto, height: auto, margin: .5cm)
// #fig-point-cloud-topology()
