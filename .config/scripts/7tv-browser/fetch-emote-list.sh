#!/usr/bin/env -S bash

set -o pipefail

query="$1"
[ -z "$query" ] && exit 0

limit="${2:-100}"

request_body="$(jq --arg limit "$limit" --arg query "${query}" \
    -c '.variables.limit = ($limit | tonumber) | .variables.query = $query' \
    <~/.config/scripts/7tv-browser/request.json)"
[ -z "$request_body" ] && exit

curl --fail -X POST \
    -H 'Content-Type: application/json' \
    -d "$request_body" \
    'https://7tv.io/v3/gql' | \
jq -r \
    '.data.emotes.items[] | { name: .name, id: .id, url: .host.url, file: (.host.files | max_by(.width).name) } | join("\t")' | \
awk \
    '{printf "%s\t%s\thttps:%s/%s\n", $1, $2, $3, $4}'

