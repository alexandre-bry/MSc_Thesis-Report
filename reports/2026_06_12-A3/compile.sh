#!/bin/bash
# This script compiles and optimises the thesis report

THESIS_FILE="_thesis_only.pdf"
PAPER_FILE="_paper_only.pdf"
TEMP_FINAL_FILE="MSc_Thesis-A3-Alexandre_BRY.tmp.pdf"
FINAL_FILE="MSc_Thesis-A3-Alexandre_BRY.pdf"
PAPER_INSERTION_PAGE=16

# Compile the main thesis and paper documents to PDF
echo "Compiling thesis document..."
typst compile main.typ "$THESIS_FILE" --input hide-comments=true --root ..
echo "Compiling paper document..."
typst compile paper/main.typ "$PAPER_FILE" --input hide-comments=true --root ..

# Insert the paper PDF into the thesis PDF at the specified page
echo "Inserting paper into thesis after page $PAPER_INSERTION_PAGE..."
pdftk A="$THESIS_FILE" B="$PAPER_FILE" cat A1-$PAPER_INSERTION_PAGE B1-end A$((PAPER_INSERTION_PAGE + 1))-end output "$TEMP_FINAL_FILE"

# Compress the temporary file with Ghostscript
echo "Compressing the final PDF..."
gs -sDEVICE=pdfwrite \
    -dCompatibilityLevel=1.4 \
    -dPDFSETTINGS=/printer \
    -dNOPAUSE -dQUIET -dBATCH \
    -dDownsampleColorImages=true \
    -dColorImageResolution=200 \
    -dDownsampleGrayImages=true \
    -dGrayImageResolution=200 \
    -sOutputFile="$FINAL_FILE" "$TEMP_FINAL_FILE"

# Remove the temporary file
echo "Cleaning up temporary files..."
rm -f "$TEMP_FINAL_FILE"