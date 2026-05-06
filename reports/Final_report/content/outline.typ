#outline(title: [Outline], depth: 3)

#{
  let kinds = (
    "figures": image,
    "tables": table,
    "algorithms": "algorithm",
  )

  for (kind-name, kind-search) in kinds.pairs() {
    outline(
      title: [List of #kind-name],
      target: figure.where(kind: kind-search),
    )
  }
}
