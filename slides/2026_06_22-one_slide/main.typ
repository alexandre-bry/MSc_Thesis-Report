#let ign-color = rgb("#8FBF4A")
#let tu-delft-color = rgb("#00A6D6")

#show link: set text(fill: blue.darken(20%), weight: "medium", style: "italic")

#let footer-on-right = sys.inputs.at("footer-on-right", default: "false") == "true"

#let header-height = 3cm
#let grid-square-size = 10cm
#let caption-height = 1cm
#let footer-height = 3cm

#let page-height = header-height + 2 * (caption-height + grid-square-size) + footer-height
#let page-width = 3 * grid-square-size
// #let page-width = 16 / 9 * page-height

#let grid-inset = 0mm

#set page(
  margin: 0em,
  fill: gradient.linear(white, tu-delft-color, angle: 30deg, space: color.linear-rgb),
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
  [BD TOPO and LiDAR HD],
  [Find roof edge points],
  [Align into a roofprint],
  [Generate 3D roof model],
  [Find façade and ground points],
  [Align into a footprint],
)

#let main-content-cells = ()
#for (idx, (image, caption)) in images.zip(captions).enumerate() {
  main-content-cells.push(
    grid(
      rows: (caption-height, grid-square-size),
      box(
        stroke: (x: 2pt + black, top: 2pt + black),
        width: grid-square-size,
        inset: 3mm,
        align(center, text(size: 18pt, weight: "bold", [#(idx + 1). #caption])),
      ),
      box(
        stroke: (x: 2pt + black, bottom: 2pt + black),
        inset: 1pt,
        image,
      ),
    ),
  )
}
#let main-content = grid(
  columns: (grid-square-size,) * 3,
  rows: (caption-height + grid-square-size,) * 2,
  column-gutter: 0cm,
  row-gutter: 0cm,
  ..main-content-cells,
)

// Footer content
#let footer-col-width = 12cm
#let footer-text-qr-space = 5mm
#let footer-space-between = (page-width - 2 * footer-col-width - 2 * footer-text-qr-space) / 2

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
      column-gutter: footer-text-qr-space,
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
    columns: (footer-col-width,) * cells.len(),
    column-gutter: footer-space-between,
    align: (center, center),
    ..cells
  )
]

#let rows = (header-height, (caption-height + grid-square-size) * 2, footer-height)

#grid(
  columns: (1fr,) * 3,
  align: center + horizon,
  inset: grid-inset,
  rows: rows,
  grid.cell(colspan: 3, inset: (x: 5mm), header-content),
  grid.cell(colspan: 3, main-content),
  grid.cell(colspan: 3, inset: (x: 5mm), footer-content),
)

/* -------------------------------------------------------------------------- */
/*                            Left to right version                           */
/* -------------------------------------------------------------------------- */

#let page-height = 2 * (caption-height + grid-square-size)
#let page-width = 16 / 9 * page-height
#let main-width = 3 * grid-square-size
#let left-width = 0.6 * (page-width - main-width)
#let right-width = 0.4 * (page-width - main-width)
#let grid-inset = 0mm

#set page(
  margin: 0em,
  fill: gradient.linear(white, tu-delft-color, angle: 30deg, space: color.linear-rgb),
  width: page-width,
  height: page-height,
)

// Left content
#let left-content = grid(
  columns: left-width,
  row-gutter: 1fr,
  inset: 5mm,
  rows: (1fr, 1fr),
  align: (left + top, left + bottom),
  align(left + horizon, text(size: 32pt, weight: "bold", [From Points to Prints])),
  align(left + horizon, [
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

// Right content
#let right-row-height = 12cm
#let right-text-qr-space = 5mm
#let right-space-between = (page-height - 2 * right-row-height - 2 * right-text-qr-space) / 2

#let right-content = [
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
      columns: 1fr,
      row-gutter: right-text-qr-space,
      align: center + horizon,
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
    rows: (right-row-height,) * cells.len(),
    row-gutter: right-space-between,
    inset: 2mm,
    align: (center + horizon, center + horizon),
    ..cells
  )
]

#let columns = (left-width, main-width, right-width)

#grid(
  columns: columns,
  align: center + horizon,
  rows: 1fr,
  inset: grid-inset,
  left-content, main-content, right-content,
)
