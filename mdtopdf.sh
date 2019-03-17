#!/bin/bash

rm *.pdf

for f in *.md; do
  echo "markdown-pdf $f"
  markdown-pdf $f
done

mv Readme.pdf output.pdf
