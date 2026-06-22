#!/bin/bash

INPUT_FILE="main.typ"
TEMP_FILE="temp.pdf"

FILE_NAMES=(
  "summary-square"
  "summary-16_9"
)
FILE_PAGES=(
  "1-1"
  "2-2"
)
FILE_FORMATS=(
  "pdf"
  "png"
)

for i in "${!FILE_NAMES[@]}"; do
  for FILE_FORMAT in "${FILE_FORMATS[@]}"; do
    FILE_NAME="${FILE_NAMES[$i]}"
    FILE_PAGE="${FILE_PAGES[$i]}"

    FINAL_FILE="${FILE_NAME}.${FILE_FORMAT}"

    typst compile "$INPUT_FILE" "$TEMP_FILE" \
      --root ../.. \
      --format "$FILE_FORMAT" \
      --pages "$FILE_PAGE"

    # Compress the temporary file with Ghostscript (only for PDF)
    if [ "$FILE_FORMAT" == "pdf" ]; then
      gs -sDEVICE=pdfwrite \
          -dCompatibilityLevel=1.4 \
          -dPDFSETTINGS=/printer \
          -dNOPAUSE -dQUIET -dBATCH \
          -dDownsampleColorImages=true \
          -dColorImageResolution=200 \
          -dDownsampleGrayImages=true \
          -dGrayImageResolution=200 \
          -sOutputFile="$FINAL_FILE" "$TEMP_FILE"
    else
      mv "$TEMP_FILE" "$FINAL_FILE"
    fi

    # Remove the temporary file
    rm -f "$TEMP_FILE"
  done
done
