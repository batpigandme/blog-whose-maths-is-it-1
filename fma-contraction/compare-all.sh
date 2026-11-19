#!/usr/bin/env bash
#
# compare-all.sh -- put the three builds' hashes side by side, and check the
# emulated Linux run against the earlier run on a real x86_64 machine.
#
#   ./fma-contraction/compare-all.sh
#
# Reads the result columns that run-contract-mac.sh and run-contract-linux.sh
# left in .cache/results (mac-default, mac-nocontract, linux-x86_64), and
# results/captured-linux-x86_64-2026-10-22.txt. Writes results/compare.txt.
#
# Environment (defaults):
#   OUT        output file (fma-contraction/results/compare.txt)
#   CACHE_DIR  <repo root>/.cache
#
# Needs node. macOS or Linux.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
RES="${CACHE_DIR:-$ROOT/.cache}/results"
OUT="${OUT:-$HERE/results/compare.txt}"
CAPTURED="$HERE/results/captured-linux-x86_64-2026-10-22.txt"
. "$ROOT/lib/header.sh"

{
	echo "# engine:   MicroQuickJS 6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9; builds mac-default, mac-nocontract, linux-x86_64"
	echo "# platform: $( platform_string ) (comparison only; see the three run outputs for each build's platform)"
	echo "# obtained: result columns left by run-contract-mac.sh and run-contract-linux.sh"
	echo "# date:     $( date -u +%Y-%m-%dT%H:%M:%SZ )"
	echo "# script:   fma-contraction/compare-all.sh"
	echo
	echo "## the three builds, by hash of each function's result column"
	"$HERE/compare.sh" "$RES" mac-default mac-nocontract linux-x86_64
	echo
	echo "## the emulated linux-x86_64 run against the earlier run on a real x86_64 machine"
	node "$ROOT/lib/colhash.js" "$RES/linux-x86_64" > "$( dirname "$RES" )/linux-hashes.tmp"
	grep -E '^(Math\.[a-z0-9]+|erf|gamma|log1p) [0-9a-f]{12}$' "$CAPTURED" | sort > "$( dirname "$RES" )/captured-hashes.tmp"
	sort "$( dirname "$RES" )/linux-hashes.tmp" > "$( dirname "$RES" )/linux-hashes-sorted.tmp"
	if diff -q "$( dirname "$RES" )/linux-hashes-sorted.tmp" "$( dirname "$RES" )/captured-hashes.tmp" >/dev/null; then
		echo "same hash on all $( wc -l < "$( dirname "$RES" )/captured-hashes.tmp" | tr -d ' ' ) functions"
	else
		echo "DIFFERENT:"; diff "$( dirname "$RES" )/linux-hashes-sorted.tmp" "$( dirname "$RES" )/captured-hashes.tmp" || true
	fi
	rm -f "$( dirname "$RES" )"/*.tmp
} 2>&1 | tee "$OUT"
