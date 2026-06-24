#!/bin/bash

INPUT_FILE="$1"
OUTPUT_DIR="$2"
THEME="$3"

echo "Compiling $INPUT_FILE to $OUTPUT_DIR with theme $THEME..."

ROOT="$(dirname $INPUT_FILE)/../.."

mkdir -p "$OUTPUT_DIR"

# Values that change
HANDOUT_VALUES=("false" "true")
NOTES_VALUES=("false" "true")

for handout in "${HANDOUT_VALUES[@]}"; do
  for notes in "${NOTES_VALUES[@]}"; do
    # Name parts for the temp and final files
    if [ "$handout" = "true" ]; then
      handout_part="handout"
    else
      handout_part="animations"
    fi

    if [ "$notes" = "true" ]; then
      notes_part="notes"
    else
      notes_part="no_notes"
    fi

    base_name="slides-${handout_part}-${notes_part}"

    TEMP_FILE="$OUTPUT_DIR/${base_name}.tmp.pdf"
    FINAL_FILE="$OUTPUT_DIR/${base_name}.pdf"

    # 1. Compile to a temporary file
    typst compile "$INPUT_FILE" "$TEMP_FILE" \
      --root "$ROOT" \
      --format pdf \
      --input handout="$handout" \
      --input notes="$notes" \
      --input theme="$THEME"

    # 2. Compress the temporary file with Ghostscript
    gs -sDEVICE=pdfwrite \
       -dCompatibilityLevel=1.4 \
       -dPDFSETTINGS=/printer \
       -dNOPAUSE -dQUIET -dBATCH \
       -dDownsampleColorImages=true \
       -dColorImageResolution=200 \
       -dDownsampleGrayImages=true \
       -dGrayImageResolution=200 \
       -sOutputFile="$FINAL_FILE" "$TEMP_FILE"

    # Remove the temporary file
    rm -f "$TEMP_FILE"
  done
done
