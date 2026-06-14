# MSc Thesis - Website

[![CC BY 4.0][cc-by-shield]][cc-by]

## Introduction

This repository contains the notes taken during my MSc Thesis with TU Delft and the IGN (*Institut national de l'information géographique et forestière*) from November 2025 to June 2026.
It also contains the source of the reports and slides made during the project.
Everything is published at: <https://alexandre-bry.github.io/MSc_Thesis-Report/>.

## Structure

The current organization of the repository is the following:

```tree
.
├── 404.html
├── index.qmd
├── _quarto.yml
├── README.md
├── references/
│   └── MSc_Thesis-Bibliography.bib
└── weekly_notes/
```

## Publication

The website can be very easily published by running `quarto publish gh-pages --no-prompt`.
I use one extension to embed PDFs ([embedpdf](https://github.com/jmgirard/embedpdf)) and one to embed RevealJS presentations ([embedio](https://github.com/coatless-quarto/embedio)).

## License

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
