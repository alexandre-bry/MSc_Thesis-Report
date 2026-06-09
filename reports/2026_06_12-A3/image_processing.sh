#! /bin/bash

SOURCE_DIR=figures/Validation
TARGET_DIR=figures/Validation_992

mkdir -p $TARGET_DIR

for file in $SOURCE_DIR/*.png; do
    filename=$(basename "$file")
    png-resizer -o $TARGET_DIR/$filename -w 992 $file
done

oxipng -o 6 $TARGET_DIR/*.png