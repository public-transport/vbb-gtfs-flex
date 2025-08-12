#!/bin/bash

set -e
set -o pipefail
set -x

sudo apt install -y \
	curl jq unzip

ua='bbnavi/gtfs-flex CI'
qsv_release='6.0.1'
# `…/releases/tag/$tag` currently fails despite being documented:
# https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-a-release-by-tag-name
# see also https://github.com/orgs/community/discussions/169572
# release_url="https://api.github.com/repos/dathere/qsv/releases/tag/$qsv_release"
# assets_url="$(
# 	curl "$release_url" -H 'Accept: application/json' -H "User-Agent: $ua" -L -fsS \
# 	| jq -r '.assets_url'
# )"
releases_url='https://api.github.com/repos/dathere/qsv/releases'
assets_url="$(
	curl "$releases_url" -H 'Accept: application/json' -H "User-Agent: $ua" -L -fsS \
	| jq -r ".[] | select(.tag_name | test(\"$qsv_release\")) | .assets_url"
)"
qsv_x64_url="$(
	curl "$assets_url" -H 'Accept: application/json' -H "User-Agent: $ua" -L -fsS \
	| jq -r '.[] | select(.name | test("qsv-[0-9.]+-x86_64-unknown-linux-gnu.zip")) | .browser_download_url'
)"

zip="$(mktemp)"
curl -o "$zip" "$qsv_x64_url" -H "User-Agent: $ua" -L -fsS

mkdir -p "$HOME/.local/bin"
unzip -j -q -d "$HOME/.local/bin" "$zip" qsv
chmod +x "$HOME/.local/bin/qsv"

$HOME/.local/bin/qsv --version
