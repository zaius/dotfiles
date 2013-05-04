#!/bin/bash

# TODO: handle different image types
for file in *.jpg; do
  # Skip if thumb is already in the name
  echo "$file" | grep -q "thumb.jpg" && continue
  THUMB="`basename "$file" .jpg`_thumb.jpg"
  convert -define jpeg:size=100x100 $file -thumbnail 100x100^ -gravity center -extent 100x100 $THUMB
done
