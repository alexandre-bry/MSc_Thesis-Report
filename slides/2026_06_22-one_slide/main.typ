#let ign-color = rgb("#8FBF4A")
#let tu-delft-color = rgb("#00A6D6")

#let header-height = 3cm
#let grid-square-size = 10cm
#let caption-height = 1cm
#let footer-height = 3cm

#let page-height = header-height + 2 * (caption-height + grid-square-size) + footer-height
#let page-width = 3 * grid-square-size

#let grid-inset = 0mm

#set page(
  margin: 0em,
  fill: gradient.linear(white, ign-color, angle: 30deg, space: color.linear-rgb),
  width: page-width,
  height: page-height,
)

#set text(size: 18pt, font: ("Source Sans 3", "Source Serif 4", "Source Serif Pro"))

// Header content
#let header-content = grid(
  columns: (auto, auto),
  rows: 100%,
  column-gutter: 1fr,
  align(left + horizon, text(size: 32pt, weight: "bold", [From Points to Prints])),
  align(right + horizon, [
    #text(
      size: 30pt,
      weight: "light",
      style: "italic",
      [Alexandre Bry],
    )
    #linebreak()
    #text(
      size: 18pt,
      style: "italic",
      weight: "semibold",
      [Supervised by Bruno Vallet, Hugo Ledoux],
    )]),
)

// Main images content
#let images = (
  image("../../images/2026_06_22/Example_building-BD_TOPO.png"),
  image("../../images/2026_06_22/Roof_edge_points_3D-square.png"),
  image("../../images/2026_06_22/Example_building-Roofprint.png"),
  image("../../images/2026_06_22/Roof_3D-square.png"),
  image("../../images/2026_06_22/Footprints_points_3D-square.png"),
  image("../../images/2026_06_22/Example_building-Roofprint_and_footprint.png"),
)
#let captions = (
  [BD TOPO shifted],
  [Roof edge points],
  [Roofprint],
  [3D roof model],
  [Façade and ground points],
  [Footprint],
)

// #for (idx, (image, caption)) in images.zip(captions).enumerate() {
//   images.at(idx) = [
//     #image
//     #place(
//       top + left,
//       dx: -grid-inset,
//       dy: -grid-inset,
//       box(
//         stroke: 1pt + black,
//         width: grid-square-size,
//         // fill: gradient.linear(white, ign-color, angle: 30deg),
//         fill: white,
//         inset: 3mm,
//         align(center, text(size: 20pt, weight: "bold", [#(idx + 1). #caption])),
//       ),
//     )
//   ]
// }

#let main-content-cells = ()
#for (idx, (image, caption)) in images.zip(captions).enumerate() {
  main-content-cells.push(
    grid(
      rows: (caption-height, grid-square-size),
      box(
        stroke: 1pt + black,
        width: grid-square-size,
        // fill: gradient.linear(white, ign-color, angle: 30deg),
        // fill: white,
        inset: 3mm,
        align(center, text(size: 20pt, weight: "bold", [#(idx + 1). #caption])),
      ),
      image,
    ),
  )
}

// Footer content

#let footer-content = [
  #import "@preview/tiaoma:0.3.0"
  #let footer-links = (
    "github": (
      name: [GitHub],
      url: "https://github.com/alexandre-bry/MSc_Thesis-Code",
    ),
    "website": (
      name: [Website],
      url: "https://alexandre-bry.github.io/MSc_Thesis-Code/",
    ),
  )

  #let cells = ()
  #for footer-link in footer-links.values() {
    let (name, url) = footer-link
    cells.push(grid(
      columns: (auto, auto),
      align: (left, left),
      column-gutter: 5mm,
      [
        #set text(size: 16pt)
        *#name*: #link(url)
      ],
      tiaoma.qrcode(url, options: (
        scale: 1.5,
        fg-color: black,
        bg-color: none,
      )),
    ))
  }
  #grid(
    columns: (100mm,) * cells.len(),
    column-gutter: 20mm,
    align: (center, center),
    ..cells
  )
]

#let rows = (header-height,) + (caption-height + grid-square-size,) * 2 + (footer-height,)

#grid(
  columns: (1fr,) * 3,
  align: center + horizon,
  inset: grid-inset,
  rows: rows,
  grid.cell(colspan: 3, inset: (x: 5mm), header-content),
  ..main-content-cells,
  grid.cell(colspan: 3, inset: (x: 5mm), footer-content),
)
