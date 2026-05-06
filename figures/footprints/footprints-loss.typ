// #import "@preview/cetz:0.5.0": *
#import "@preview/lilaq:0.5.0" as lq

#let fig-footprints-loss(
  width: 14cm,
  height: 8cm,
  title: [Score of a point $p$ for a footprint edge $e$],
  stroke: 2pt,
) = {
  let x-axis-values = (-0.8, -0.3, 0, 0.3, 1.3, 1.3, 1.8)
  let y-axis-values-ground = (0, 0, 0.3, 0, -1.0, 0, 0)
  let y-axis-values-other = (0, 0, 1.0, 0, -0.3, 0, 0)
  lq.diagram(
    width: width,
    height: height,
    title: title,
    xlabel: [Signed distance between $p$ and $e$, positive if $p$ is inside of the building (m)],
    ylabel: [Score],
    xaxis: (ticks: x-axis-values.slice(1, -1), subticks: none),
    // yaxis: (ticks: (-1, 0, 1), subticks: none),

    lq.plot(x-axis-values, y-axis-values-ground, mark: none, label: [Ground], stroke: stroke),
    lq.plot(x-axis-values, y-axis-values-other, mark: none, label: [Other clases], stroke: stroke),
  )
}

#set text(font: "Source Serif 4", size: 11pt)
#set page(width: auto, height: auto, margin: 0.5cm)

#figure(fig-footprints-loss(width: 14cm, height: 8cm))
