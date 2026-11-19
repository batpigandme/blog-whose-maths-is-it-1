#!/usr/bin/env bash
#
# fetch-stdlib-fixtures.sh -- fetch stdlib's test fixtures for the maths
# functions at a pinned commit, into a sparse checkout.
#
#   ./lib/fetch-stdlib-fixtures.sh            # prints the checkout's path
#
# Environment (defaults):
#   STDLIB_SHA   commit of https://github.com/stdlib-js/stdlib to fetch
#                (550666096f34c73f90f4bf86139935e4214fe421)
#   CACHE_DIR    where to put it (<repo root>/.cache)
#
# Fetches only the `test/fixtures` directories that lib/gen-cases.js reads
# (about 20 MB), not the repository. Needs git and network access.
# Runs on macOS or Linux.

set -euo pipefail
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
STDLIB_SHA="${STDLIB_SHA:-550666096f34c73f90f4bf86139935e4214fe421}"
CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
DEST="$CACHE_DIR/stdlib-${STDLIB_SHA:0:12}"
BASE="lib/node_modules/@stdlib/math/base/special"

if [ ! -d "$DEST/.git" ]; then
	mkdir -p "$DEST"
	git -C "$DEST" init -q
	git -C "$DEST" remote add origin https://github.com/stdlib-js/stdlib.git
	git -C "$DEST" config core.sparseCheckout true
	for p in erf gamma log1p exp ln sin cos tan asin acos atan atan2 pow sqrt log2 log10; do
		echo "/$BASE/$p/test/fixtures/" >> "$DEST/.git/info/sparse-checkout"
	done
	git -C "$DEST" fetch -q --depth 1 --filter=blob:none origin "$STDLIB_SHA"
	git -C "$DEST" checkout -q FETCH_HEAD
fi
got="$( git -C "$DEST" rev-parse HEAD )"
if [ "$got" != "$STDLIB_SHA" ]; then
	echo "fetched $got, expected $STDLIB_SHA" >&2
	exit 1
fi
echo "$DEST"
