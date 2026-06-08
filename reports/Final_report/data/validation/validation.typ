#import "../../common_imports.typ" : *

#let string-to-array(inner-func, s) = {
  s = s.trim("[").trim("]")
  s = s.split(", ").map(inner-func)
  return s
}

#let string-to-bool-array = s => string-to-array(t => lower(t) == "true", s)

#let replace-if-unique(arr) = {
  if arr.len() == 0 {
    panic("Empty array")
  }
  let value = arr.at(0)
  for v in arr {
    if v != value {
      panic(str(v) + " is different from " + str(value))
    }
  }
  return value
}

#let filter-col(data, filters) = {
  let filtered-data = (:)
  for (key, value) in data {
    let keep = true
    for (filter-key, filter-values) in filters.pairs() {
      let keep-for-filter = false
      if type(filter-values) != array {
        filter-values = (filter-values,)
      }
      let current-col-value = value.at(filter-key)
      for filter-value in filter-values {
        if current-col-value == filter-value {
          keep-for-filter = true
          break
        }
      }
      if not keep-for-filter {
        keep = false
        break
      }
    }
    if keep {
      filtered-data.insert(key, value) 
    }
  }
  return filtered-data
}

#let read-scores-data-json(json-file) = {
  let data = json(json-file)

  let id-col = "ground_truth_aggregate_id"
  let columns = (
    area: "ground_truth_area_m2",
    iou: "iou",
    chamfer: "symmetric_boundary_distance_m",
    half_chamfer_from_gt: "ground_truth_to_scored_boundary_distance_m",
    half_chamfer_to_gt: "scored_to_ground_truth_boundary_distance_m",
    centroid_distance: "centroid_distance_m",
    category: "custom_category"
  )

  // Gather and organise the necessary data
  let buildings = (:)
  for building in data {
    let building-id = building.at(id-col)
    let building-data = (:)
    for (col-new-name, col-old-name) in columns.pairs() {
      let col-value = building.at(col-old-name)
      if (col-new-name in ("small_building", "category")) {
        col-value = replace-if-unique(col-value)
      }
      building-data.insert(col-new-name, col-value)
    }
    buildings.insert(building-id, building-data)
  }
  
  buildings
}

#let average-stddev(scores-data, score-column) = {
  if scores-data.len() == 0 {
    return (none, none)
  }
  let total-avg = 0
  for building-data in scores-data.values() {
    total-avg += float(building-data.at(score-column))
  }
  let avg = total-avg / scores-data.len()
  let total-stddev = 0
  for building-data in scores-data.values() {
    total-stddev += calc.pow(float(building-data.at(score-column)) - avg, 2)
  }
  let stddev = total-stddev / scores-data.len()
  return (avg, stddev)
}

#let format-rows(datasets, datasets-names, metrics-infos) = {
  // Compute the values
  let rows-values = ()
  for (dataset, dataset-name) in datasets.zip(datasets-names) {
    let row = ()
    for metric-col-name in metrics-infos.keys() {
      let (avg, stddev) = average-stddev(dataset, metric-col-name)
      let avg-rounded = calc.round(avg, digits: 3)
      let stddev-rounded = calc.round(stddev, digits: 3)
      row.push(avg-rounded)
    }
    rows-values.push(row)
  }

  // Compute the best value for each column
  let best-values = ()
  for (col, best-func) in metrics-infos.values().map(m => m.best).enumerate() {
    best-values.push(best-func(..rows-values.map(t => t.at(col))))
  }

  // Format the rows with the best value highlighted
  let rows-content = ()
  for (dataset-row, dataset-name) in rows-values.zip(datasets-names) {
    let row = (dataset-name,)
    for (col, value) in dataset-row.enumerate() {
      let content = if value == best-values.at(col) { strong([#value]) } else { [#value] }
      row.push(content)
      //row.push([$#avg-rounded plus.minus #stddev-rounded$])
    }
    rows-content.push(row)
  }
  
  return rows-content
}

#let display-table(datasets, datasets-names, metrics-infos, text-size: none) = {
  set text(size: text-size) if text-size != none
  let rows = format-rows(datasets, datasets-names, metrics-infos)

  let header-cells = (table.cell(rowspan: 1, [Dataset]),)
  let columns = 1 + metrics-infos.len()
  for metric-label in metrics-infos.values().map(m => m.label) {
    header-cells.push(table.cell(colspan: 1, metric-label))
  }

  table(
    columns: columns,
    table.header(..header-cells),
    ..rows.flatten()
  )
}

#let build-hist(dataset, col-name, min: 0.0, max: 1.0, steps: 10) = {
  let centers = ()
  let counts = (0,) * steps
  let step-size = (max - min) / steps
  for i in range(0, steps) {
    centers.push((i + 0.5) * step-size + min)
  }
  
  for scores in dataset.values() {
    let value = scores.at(col-name)
    let bin = calc.floor((value - min) / step-size)
    bin = calc.min(bin, steps - 1)
    counts.at(bin) += 1
  }
  (centers, step-size, counts)
}

#let build-hists(datasets, col-name, min: 0.0, max: 1.0, steps: 10) = {
  let real-centers = ()
  let placement-centers = ()
  let all-counts = ()

  let n-datasets = datasets.len()
  let margin = 0.3
  let step-size = (max - min) / steps
  let final-width = (1 - margin) * step-size / n-datasets
  
  for (i, dataset) in datasets.enumerate() {
    let (centers, step-size, counts) = build-hist(dataset, col-name, min:min, max:max, steps:steps)

    real-centers = centers

    placement-centers.push(centers.map(c => c + (i - (n-datasets - 1) / 2) * final-width))

    all-counts.push(counts)
  }

  return (real-centers, placement-centers, final-width, all-counts)
}

#let display-hists(datasets, labels, col-name, legend-placement, min: 0.0, max: 1.0, steps: 10, height: 4cm) = {
  let (real-centers, placement-centers, final-width, all-counts) = build-hists(datasets, col-name, min:min, max:max, steps:steps)

  show: lq.set-tick(
    inset: 0pt,
    outset: 2pt, 
  )

  let bars = ()
  for (centers, counts, label) in placement-centers.zip(all-counts, labels) {
    bars.push(
      lq.bar(
        centers,
        counts,
        align: center,
        width: final-width,
        label: label
      )
    )
  }

  lq.diagram(
    xaxis: (
      label: [Bins centers],
      ticks: real-centers,
      lim: (min - final-width, max + final-width),
      subticks: none,
      mirror: (ticks: false),
    ),
    yaxis: (
      label: [Counts],
      subticks: none,
      mirror: (ticks: false),
    ),
    height: height,
    width: 100%,
    legend: (position: legend-placement),
    ..bars
  )
}

#let display-violins(datasets, labels, col-name, col-label, bandwidth: 0.01, min: none, max: none, height: 4cm) = {
  show: lq.set-tick(
    inset: 0pt,
    outset: 2pt, 
  )

  let datasets-values = ()
  for dataset in datasets {
    datasets-values.push(dataset.values().map(d => d.at(col-name)))
  }

  // Clip if necessary
  let clipped-min = false
  let clipped-max = false
  if (min != none) {
    for (idx, values) in datasets-values.enumerate() {
      if (calc.min(..values) < min) {
        clipped-min = true
        datasets-values.at(idx) = values.map(v => calc.max(v, min))
      }
    }
  }

  if (max != none) {
    for (idx, values) in datasets-values.enumerate() {
      if (calc.max(..values) > max) {
        clipped-max = true
        datasets-values.at(idx) = values.map(v => calc.min(v, max))
      }
    }
  }

  // Compute the actual min and max
  let min-for-lim = calc.inf
  let max-for-lim = -calc.inf
  if (min == none) {
    for values in datasets-values {
      min-for-lim = calc.min(min-for-lim, ..values)
    }
  } else {
    min-for-lim = min
  }
  if (max == none) {
    for values in datasets-values {
      max-for-lim = calc.max(max-for-lim, ..values)
    }
  } else {
    max-for-lim = max
  }

  // Compute the limits
  let interval-size = max-for-lim - min-for-lim
  let lim = (min-for-lim - 0.05 * interval-size, max-for-lim + 0.05 * interval-size)
  
  let violins = ()
  let labels-y-values = ()
  for (idx, (values, label)) in datasets-values.zip(labels).enumerate() {
    let y-value = -idx
    labels-y-values.push((y-value, label))
    violins.push(
      lq.hviolin(
        values,
        width: 80%,
        y: y-value,
        median: none,
        mean: "o",
        boxplot: none,
        bandwidth: bandwidth,
      )
    )
  }

  let x-axis-label = col-label
  if clipped-min or clipped-max {
    x-axis-label += [ (clipped between #min and #max)]
  }
  
  lq.diagram(
    yaxis: (
      label: [Dataset],
      ticks: labels-y-values,
      subticks: none,
      mirror: (ticks: false),
    ),
    xaxis: (
      label: x-axis-label,
      subticks: none,
      mirror: (ticks: false),
      lim: lim
    ),
    height: height,
    width: 100%,
    ..violins
  )
}

#let display-bars(datasets, labels, metric-infos, steps: 10, min: none, max: none, height: 4cm, width: 2cm) = {
  show: lq.set-tick(
    inset: 0pt,
    outset: 2pt, 
  )

  let datasets-values = ()
  for dataset in datasets {
    datasets-values.push(dataset.values().map(d => d.at(metric-infos.key)))
  }

  // Clip if necessary
  let clipped-min = false
  let clipped-max = false
  if (min not in (none, auto)) {
    for (idx, values) in datasets-values.enumerate() {
      if (calc.min(..values) < min) {
        clipped-min = true
        datasets-values.at(idx) = values.map(v => calc.max(v, min))
      }
    }
  }

  if (max not in (none, auto) ) {
    for (idx, values) in datasets-values.enumerate() {
      if (calc.max(..values) > max) {
        clipped-max = true
        datasets-values.at(idx) = values.map(v => calc.min(v, max))
      }
    }
  }

  // Compute the actual min and max
  let min-for-lim = calc.inf
  let max-for-lim = -calc.inf
  if (min not in (none, auto)) {
    min-for-lim = min
  } else {
    for values in datasets-values {
      min-for-lim = calc.min(min-for-lim, ..values)
    }
  }
  if (max not in (none, auto)) {
    max-for-lim = max
  } else {
    for values in datasets-values {
      max-for-lim = calc.max(max-for-lim, ..values)
    }
  }

  let step-size = (max-for-lim - min-for-lim) / steps
  let bars-x = ()
  for i in range(steps) {
    bars-x.push(min-for-lim + i * step-size)
  }

  // Compute the limits
  let interval-size = max-for-lim - min-for-lim
  let lim = (min-for-lim - 0.05 * interval-size, max-for-lim + 0.05 * interval-size)

  // Prepare the counts
  let counts-all = ()
  let max-counts = 0
  for values in datasets-values {    
    let counts = (0,) * steps
    for value in values {
      let bin = calc.floor((value - min-for-lim) / step-size)
      bin = calc.min(bin, steps - 1)
      counts.at(bin) += 1
    }
    max-counts = calc.max(max-counts, ..counts)
    counts-all.push(counts)
  }

  let colors = lq.color.map.petroff10

  let bars = ()
  let labels-y-values = ()
  for (idx, (counts, label, color)) in counts-all.zip(labels, colors).enumerate() {
    let y-value = idx
    labels-y-values.push((y-value, label))
    bars.push(
      lq.hbar(
        counts,
        bars-x,
        align: top,
        width: 100%,
        fill: color,
      )
    )
  }
  
  let y-ticks-step = calc.round(0.33 * max-counts)
  let displayed-values = (0, y-ticks-step, 2*y-ticks-step)
  let x-ticks-top = ()
  for value in displayed-values {
    x-ticks-top.push((value, [#value]))
  }

  let x-axis-label = metric-infos.label
  if clipped-min or clipped-max {
    x-axis-label += [ (clipped between #min and #max)]
  }

  let diagrams = ()
  for (idx, (bar, label, color)) in bars.zip(labels, colors).enumerate() {
    let yaxis = if (idx == 0) {
      (
        label: x-axis-label,
        format-ticks: auto,
        subticks: none,
        mirror: (ticks: false),
        lim: lim,
      )
    } else {
      (
        format-ticks: none,
        subticks: none,
        mirror: (ticks: false),
      )
    }
    diagrams.push(lq.diagram(
      width: width,
      height: height,
      xaxis: (
        label: rotate(label, 45deg, reflow:true),
        ticks: none,
        subticks: none,
        mirror: (ticks: false),
        lim: (0, max-counts),
      ),
      yaxis: yaxis,

      bar,

      lq.xaxis(
        position: top,
        // label: [Counts],
        ticks: x-ticks-top,
        subticks: none
      ),
    ))
  }
    
  show: lq.layout

  let row-gutter = 1em
  grid(
    columns: (auto,) + (width,) * 3,
    align: right,
    row-gutter: 1em,
    ..diagrams,
  )
}


#let display-evolutions(datasets, labels, metric-infos, flip-color-map: false, height: 4cm) = {
  let buildings-keys = datasets.at(1).keys()
  let plots = ()
  // let colors = color.map.inferno
  let colors = lq.color.map.viridis
  if flip-color-map { colors = colors.rev() }
  let color-grad = gradient.linear(..colors)

  let initial-values = ()
  for building-key in buildings-keys {
    initial-values.push(datasets.at(0).at(building-key).at(metric-infos.key))
  }

  let labels-y-values = range(0, -datasets.len(), step: -1)
  if (initial-values.len() > 0) {
    let initial-min = calc.min(..initial-values)
    let initial-max = calc.max(..initial-values)
    
    for building-key in buildings-keys {
      let values = ()
      for dataset in datasets {
        values.push(dataset.at(building-key).at(metric-infos.key))
      }
  
      let value-percent = (values.at(-1) - initial-min) / (initial-max - initial-min) * 80% + 10%

      plots.push(
        lq.plot(
          values,
          labels-y-values,
          color: color-grad.sample(value-percent),
          stroke: 1pt,
        )
      )
    }
  }

  lq.diagram(
    yaxis: (
      label: [Step],
      ticks: labels-y-values.zip(labels.map(l => rotate(l, -90deg, reflow: true))),
      subticks: none,
      mirror: (ticks: false),
    ),
    xaxis: (
      label: metric-infos.label,
      mirror: (ticks: false),
    ),
    height: height,
    width: 100%,
    ..plots,
  )
}

#let roofprints-iter-n-label(n) = [Rfpt #n iter]

#let datasets-infos = (
  bdtopo: (
    key: "bdtopo",
    sources: ("bdtopo-indiv.json",),
    name: [BD TOPO],
    label: [BD TOPO]
  ),
  iter1: (
    key: "iter1",
    sources: (
      "656_6861-roofprints-1-indiv.json",
      "676_6851-roofprints-1-indiv.json",
      "676_6852-roofprints-1-indiv.json",
    ),
    name: [Roofprints with 1 iteration],
    label: roofprints-iter-n-label(1)
  ),
  iter2: (
    key: "iter2",
    sources: (
      "656_6861-roofprints-2-indiv.json",
      "676_6851-roofprints-2-indiv.json",
      "676_6852-roofprints-2-indiv.json",
    ),
    name: [Roofprints with 2 iterations],
    label: roofprints-iter-n-label(2)
  ),
  iter3: (
    key: "iter3",
    sources: (
      "656_6861-roofprints-3-indiv.json",
      "676_6851-roofprints-3-indiv.json",
      "676_6852-roofprints-3-indiv.json",
    ),
    name: [Roofprints with 3 iteration],
    label: roofprints-iter-n-label(3)
  ),
)

#let simple-categories = (
  "low_sheds",
  "isolated_houses",
  "adjacent_houses",
  "adjacent_blocks_of_flats",
)
#let categories-infos = (
  "low_sheds": (
    key: "low_sheds",
    name: ["low sheds"],
    label: ["low sheds"],
    filter: ("category": "low_height")
  ),
  "isolated_houses": (
    key: "isolated_houses",
    name: ["isolated houses"],
    label: ["isolated houses"],
    filter: ("category": "isolated")
  ),
  "adjacent_houses": (
    key: "adjacent_houses",
    name: ["adjacent houses"],
    label: ["adjacent houses"],
    filter: ("category": "adjacent_house")
  ),
  "adjacent_blocks_of_flats": (
    key: "adjacent_blocks_of_flats",
    name: ["adjacent blocks of flats"],
    label: ["adjacent blocks of flats"],
    filter: ("category": "adjacent_tall")
  ),
  all: (
    key: "all",
    name: ["all buildings"],
    label: ["all buildings"],
    filter: (:)
  ),
  all_except_low_sheds: (
    key: "all_except_low_sheds",
    name: ["all except low sheds"],
    label: ["all except low sheds"],
    filter: ("category": ("isolated", "adjacent_house", "adjacent_tall",))
  )
)

#let metrics-infos = (
  "iou": (
    key: "iou",
    name: [IoU],
    label: [IoU],
    best: calc.max,
  ),
  "chamfer": (
    key: "chamfer",
    name: [Chamfer distance],
    label: [Chamfer (m)],
    best: calc.min,
  ),
  "centroid_distance": (
    key: "centroid_distance",
    name: [Centroid distance],
    label: [Centroid (m)],
    best: calc.min,
  ),
)

#let metrics = (
  "iou": [IoU],
  "chamfer": [Chamfer distance],
  "centroid_distance": [Centroid distance],
)
#let metrics-best = (
  "iou": calc.max,
  "chamfer": calc.min,
  "centroid_distance": calc.min,
)

#let datasets-full = (:)
#let datasets-names = ()
#let datasets-labels = ()
#let datasets-per-category = (:)
#for cat-key in categories-infos.keys() {
  datasets-per-category.insert(cat-key, ())
}

#for (dataset-key, dataset-info) in datasets-infos.pairs() {
  datasets-names.push(dataset-info.name)
  datasets-labels.push(dataset-info.label)
  
  let data = (:)
  for source in dataset-info.sources {
    data += read-scores-data-json(source)
  }
  datasets-full.insert(dataset-key, data)
  for (category-key, category-info) in categories-infos.pairs() {
    datasets-per-category.at(category-key).push(filter-col(data, category-info.filter))
  }
}

#let nice-tables(body) = {
  set par(justify: false)
  set table(
    stroke: (x, y) => (
      top: if y <= 1 { 1pt } else { 0.4pt },
      bottom: 1pt,
    ),
    inset: 6pt,
    align: center + horizon,
  )
  show table.cell.where(y: 0): set text(weight: "bold")

  body
}

#{
  set page(columns: 2, margin: 2em)
  set text(9pt)
  set columns(gutter: 1em)

  [
    The different datasets contain:
    #{
      for (dataset-key, dataset) in datasets-full {
        list.item([#dataset-key: #dataset.len() buildings])
      }
    }
    There are:
    #{
      for (category, dataset) in datasets-per-category.pairs() {
        list.item([#dataset.at(0).len() buildings in the category "#category"])
      }
    }
  ]

  show lq.selector(lq.diagram): set text(8pt)
  
  for category in simple-categories {
    let category-name = categories-infos.at(category).name
    let datasets = datasets-per-category.at(category)
    figure(
      display-table(datasets, datasets-labels, metrics-infos, text-size: 8pt),
      caption: [Metrics for "#category-name".]
    )
  }
  
  pagebreak()
  
  let metrics-violin = ("iou", "chamfer", "centroid_distance",)
  let bandwidths-violin = (
    "iou": 0.02,
    "chamfer": 0.03,
    "centroid_distance": 0.02,
  )
  let mins-maxs-violin = (
    "iou": (0.0, 1.0),
    "chamfer": (0.0, 1.0),
    "centroid_distance": (0.0, 1.0),
  )
  for category in simple-categories {
    let category-name = categories-infos.at(category).name
    let datasets = datasets-per-category.at(category)
    for metric-key in metrics-violin {
      let metric-label = metrics.at(metric-key)
      let bandwidth = bandwidths-violin.at(metric-key)
      let (min, max) = mins-maxs-violin.at(metric-key)
      figure(
        display-violins(datasets, datasets-labels, metric-key, metric-label, bandwidth: bandwidth, min:min, max: max, height: 3cm),
        caption: [Distribution of the #metric-label for "#category-name".]
      )
    }
  }
  
  pagebreak()
  
  let metrics-hists = ("iou", "chamfer", "centroid_distance",)
  let steps-hists = (
    "iou": 10,
    "chamfer": 10,
    "centroid_distance": 10,
  )
  for category in simple-categories {
    let category-name = categories-infos.at(category).name
    let datasets = datasets-per-category.at(category)
    for metric-key in metrics-hists {
      let metric-label = metrics.at(metric-key)
      let steps = steps-hists.at(metric-key)
      figure(
        display-hists(datasets, datasets-labels, metric-key, center + top, steps: steps, height: 3cm),
        caption: [Histograms of the #metric-label for "#category-name".]
      )
    }
  }
  
  pagebreak()
  
  let metrics-bars = ("iou", "chamfer", "centroid_distance",)
  let steps-bars = (
    "iou": 50,
    "chamfer": 50,
    "centroid_distance": 50,
  )
  let mins-maxs-bars = (
    "iou": (0.0, 1.0),
    "chamfer": (0.0, 1.0),
    "centroid_distance": (0.0, 1.0),
  )
  for category in simple-categories {
    let category-name = categories-infos.at(category).name
    let datasets = datasets-per-category.at(category)
    for metric-key in metrics-bars {
      let metric-infos = metrics-infos.at(metric-key)
      let steps = steps-bars.at(metric-key)
      let (min, max) = mins-maxs-bars.at(metric-key)
      figure(
        display-bars(datasets, datasets-labels, metric-infos, steps: steps, min:min, max:max, height: 4cm),
        caption: [Bar of the #metric-infos.name for "#category-name".]
      )
    }
  }

  [
    #show: lq.layout

    #let width = 2cm
    #let height = 6cm
    #show: lq.set-diagram(
      width: width,
      height: height,
      yaxis: (format-ticks: none),
      ylim: (0, 1), 
      xlim: (0, 3),
      xaxis: (filter: (tick, pos) => tick < 3) // filter overlapping ticks
    )
    
    // Reactivate $y$-tick-labels for the first column
    #show grid.cell.where(x: 0): it => {
      show: lq.set-diagram(yaxis: (format-ticks: auto), ylabel: [velocity])
      it
    }
    

    #let row-gutter = 1em
    #grid(
      columns: (auto, width , width, width),
      align: right,
      row-gutter: 1em,
      ..(lq.diagram(),) * 4,
    )
  ]
  
  pagebreak()
  
  // let metrics-evolutions = ("iou", "chamfer", "centroid_distance",)
  // let flip-color-map-evolutions = (
  //   "iou": false,
  //   "chamfer": true,
  //   "centroid_distance": true,
  // )
  // for category in simple-categories {
  //   let category-name = categories-infos.at(category).name
  //   let datasets = datasets-per-category.at(category)
  //   for metric-key in metrics-evolutions {
  //     let metric-infos = metrics-infos.at(metric-key)
  //     let flip-color-map = flip-color-map-evolutions.at(metric-key)
  //     figure(
  //       display-evolutions(datasets, datasets-labels, metric-infos, flip-color-map: flip-color-map, height: 3cm),
  //       caption: [Evolution of the #metric-infos.label for "#category-name".]
  //     )
  //   }
  // }
}