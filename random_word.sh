#!/bin/bash -e
MYDIR="$(dirname "$(readlink -f "$0")")"
word1="$(shuf -n1 "${MYDIR}"/dictionary.txt)"
word2="$(shuf -n1 "${MYDIR}"/dictionary.txt)"

jq -n --arg word1 "${word1}" --arg word2 "${word2}" '{"word1":$word1,"word2":$word2}'
