#!/usr/bin/env bash

echo this is the test!

echo "file: '$INPUT_FILES'"
echo "ref: $INPUT_REF"

while IFS= read -r file; do
    echo "... $file ..."
    wc -c <"$file"
done < <(printf '%s\n' "$INPUT_FILES")
