#!/usr/bin/env bash

echo this is the test!

echo "file: '$INPUT_FILE'"
echo "ref: $INPUT_REF"

size="$(wc -c <"$INPUT_FILE")"

echo "::set-output name=size::$size"
