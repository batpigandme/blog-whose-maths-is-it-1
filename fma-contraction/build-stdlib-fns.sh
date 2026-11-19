#!/usr/bin/env bash
#
# build-stdlib-fns.sh -- bundle stdlib's erf, gamma and log1p into one ES5
# script, so MicroQuickJS (which has no module system) can run them.
#
#   ./fma-contraction/build-stdlib-fns.sh
#
# Writes .cache/stdlib-fns.bundle.js (at <repo root>, gitignored) and prints its
# SHA-256. Installs the three published packages pinned in
# stdlib-fns/package-lock.json, and the esbuild version pinned there, with
# `npm ci`. Needs node and npm and network access. macOS or Linux.
#
# erf, gamma and log1p are not part of `Math`; they are the three of the 17
# functions tested that are plain JavaScript, so they never call the C library
# and contraction cannot reach them. Their bits are the same in every build.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
OUT="${CACHE_DIR:-$ROOT/.cache}/stdlib-fns.bundle.js"
SHIM='if (typeof Object.getOwnPropertyNames !== "function") { Object.getOwnPropertyNames = Object.keys; }'

( cd "$HERE/stdlib-fns" && npm ci --no-audit --no-fund --ignore-scripts >/dev/null )
mkdir -p "$( dirname "$OUT" )"
"$HERE/stdlib-fns/node_modules/.bin/esbuild" "$HERE/stdlib-fns/entry.js" --bundle --format=iife \
	--global-name=stdlibFns --target=es5 --log-level=warning \
	--banner:js="$SHIM" --footer:js='var erf = stdlibFns.erf, gamma = stdlibFns.gamma, log1p = stdlibFns.log1p;' \
	--outfile="$OUT"
echo "$OUT"
shasum -a 256 "$OUT" | cut -d' ' -f1
