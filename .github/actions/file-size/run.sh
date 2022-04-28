#!/usr/bin/env bash

set -euo pipefail

filename=${INPUT_FILE:?"No filename provided"}
save=${INPUT_SAVE}
name="$filename"
ref="notes/file-size"

size="$(wc -c <"$filename" | xargs)"

>&2 echo "Size: $size"
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
    # NOTE: can potentially get filter from action input
    --arg name "$name"
    --arg filename "$filename"
    --arg size "$size"

    --null-input # TODO
    --compact-output # TODO
    --monochrome-output # TODO
)

out_file=$(mktemp)
jq "${jq_args[@]}" "$JQ_FILTER" >"$out_file"

>&2 echo "JSON output:"
>&2 cat "$out_file"

logged() {
    ( set -x && "$@" )
}

if [ "$save" = "true" ]
then
    >&2 echo "Saving size to git notes"
    git config user.name "file-size action"
    git config user.email "<>"

    logged git fetch origin "refs/$ref:refs/$ref" || echo "could not fetch $ref, assuming doesn't exist yet"
    logged git notes --ref "$ref" append --file "$out_file"
    rm "$out_file"

    logged git push origin "refs/$ref"
fi
