#!/usr/bin/env bash

set -euo pipefail

filename=${INPUT_FILE:?"No filename provided"}
name=${INPUT_NAME:-$filename}
ref=${INPUT_REF:?"No ref provided"}

size="$(wc -c <"$filename" | xargs)"

echo "::set-output name=size::$size"

JQ_FILTER=$(cat <<-'END'
{ name: $name,
  filename: $filename,
  size_bytes: $size,
  type: "file-size",
}
END
)

jq_args=(
    --arg name "$name"
    --arg filename "$INPUT_FILE"
    --arg size "$size"
)

out_file=$(mktemp)
jq "${jq_args[@]}" "$JQ_FILTER" -n -c -M >"$out_file"

>&2 echo "JSON output:"
>&2 cat "$out_file"

logged() {
    ( set -x && "$@" )
}

git config user.name "file-size action"
git config user.email "<>"

logged git fetch origin "refs/$ref:refs/$ref" || echo "could not fetch $ref, assuming doesn't exist yet"
logged git notes append --file "$out_file"
rm "$out_file"

logged git push origin "refs/$ref"
