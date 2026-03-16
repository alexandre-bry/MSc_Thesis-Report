typst compile main.typ main.pdf --root ../.. --format pdf --input handout=false --input notes=true
typst compile main.typ main-handout.pdf --root ../.. --format pdf --input handout=true --input notes=true
typst compile main.typ main-handout_no_notes.pdf --root ../.. --format pdf --input handout=true --input notes=false