= References <bibliography>

#text(style: "italic")[
  This section only contains the references mentioned outside of @hea:paper.
  They are treated independently of the references in @hea:paper, meaning that there could be duplicates.
  #linebreak()
  #linebreak()
]

#{
  // show "https://doi.org/": w => {[DOI: ]}
  bibliography(
    "MSc_Thesis-Bibliography.yaml",
    style: "custom-isprs.csl",
    title: none,
  )
}
