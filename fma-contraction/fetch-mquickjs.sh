#!/usr/bin/env bash
#
# fetch-mquickjs.sh -- clone MicroQuickJS at the pinned commit, without
# building it. Prints the checkout's path.
#
#   ./fma-contraction/fetch-mquickjs.sh
#
# Environment (defaults):
#   MQJS_SHA   commit of https://github.com/bellard/mquickjs
#              (6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9)
#   CACHE_DIR  where to put it (<repo root>/.cache)
#
# The repository has no tags and is young, so a result belongs to this commit,
# not to "MicroQuickJS". Needs git and network access. macOS or Linux.

set -euo pipefail
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
MQJS_SHA="${MQJS_SHA:-6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9}"
CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
DEST="$CACHE_DIR/mquickjs-src"

if [ ! -d "$DEST/.git" ]; then
	mkdir -p "$CACHE_DIR"
	git clone -q https://github.com/bellard/mquickjs.git "$DEST"
fi
git -C "$DEST" checkout -q "$MQJS_SHA"
got="$( git -C "$DEST" rev-parse HEAD )"
if [ "$got" != "$MQJS_SHA" ]; then
	echo "checked out $got, expected $MQJS_SHA" >&2
	exit 1
fi
echo "$DEST"
