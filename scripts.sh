#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Missing filename."
  echo "Usage: $0 <filename>"
  exit 1
fi

cd "./workdir"
filename="$1"
basename=$(basename "$filename" .pdf | iconv -f utf8 -t ascii//TRANSLIT)
outputdir="./$basename"

# Ensure outputdir is empty
if [ -d "$outputdir" ]; then
  rm -rf "$outputdir"
fi

mkdir -p "$outputdir/pdf" "$outputdir/tif" "$outputdir/txt"

# Split pdf
pdfseparate "$filename" "$outputdir/pdf/$basename-%d.pdf"

# Convert to TIFs
find "$outputdir/pdf" -name '*.pdf' | parallel 'b=$(basename {} .pdf); pdftoppm -tiff -r 300 -mono -tiffcompression lzw {} '"$outputdir"'/tif/$b'

# OCR TIFs to txt
find "$outputdir/tif" -name '*.tif' | parallel 'b=$(basename {} .tif); tesseract -l eng {} '"$outputdir"'/txt/$b'

# Concatenate files
for f in "$outputdir/txt"/*.txt; do
  cat "$f" >> "$outputdir/master.txt"
  echo >> "$outputdir/master.txt"
  echo >> "$outputdir/master.txt"
done

# Make epub
pandoc "$outputdir/master.txt" -o "$outputdir/$basename.epub" -s --css=style.css
