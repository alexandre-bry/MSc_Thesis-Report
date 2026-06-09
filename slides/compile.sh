#!/bin/bash

INPUT_FILE="$1"
OUTPUT_DIR="$2"
THEME="$3"

echo "Compiling $INPUT_FILE to $OUTPUT_DIR with theme $THEME..."

typst compile "$INPUT_FILE" "$OUTPUT_DIR/slides-animations-notes.pdf" --root ../.. --format pdf --input handout=false --input notes=true --input theme="$THEME"
typst compile "$INPUT_FILE" "$OUTPUT_DIR/slides-handout-notes.pdf" --root ../.. --format pdf --input handout=true --input notes=true --input theme="$THEME"
typst compile "$INPUT_FILE" "$OUTPUT_DIR/slides-animations-no_notes.pdf" --root ../.. --format pdf --input handout=false --input notes=false --input theme="$THEME"
typst compile "$INPUT_FILE" "$OUTPUT_DIR/slides-handout-no_notes.pdf" --root ../.. --format pdf --input handout=true --input notes=false --input theme="$THEME"
