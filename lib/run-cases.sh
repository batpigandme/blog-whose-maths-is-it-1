#!/usr/bin/env bash
#
# run-cases.sh -- evaluate every case with one engine and keep the raw bits.
#
#   ./lib/run-cases.sh OUT_DIR ENGINE [ENGINE_ARGS...]
#   PRELUDE=fma-contraction/stdlib-fns.bundle.js ./lib/run-cases.sh out/ mqjs --memory-limit 256M
#
# Writes OUT_DIR/<fn>.txt for each case file, one line per case, in case order:
# `<fn> <x hex> [<y hex>] <result hex>`. Each run of the engine gets one string
# literal holding CHUNK cases (default 2,000), then the optional PRELUDE file,
# then lib/driver.js, as one script. The cases go in as a literal because that
# works on every engine, shell or embedded.
#
# Environment (defaults):
#   CASES_DIR  case files from lib/gen-cases.js (<repo root>/.cache/cases)
#   CHUNK      cases per engine run (2000)
#   PRELUDE    a script defining erf, gamma and log1p, run before the driver
#              (none; those three functions are then skipped)
#   ONLY       space-separated case-file names to run, e.g. "Math.tan Math.sin"
#              (all)
#
# Needs node (to quote the cases) and the engine. Runs on macOS or Linux.

set -euo pipefail
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
OUT="${1:?usage: run-cases.sh OUT_DIR ENGINE [ARGS...]}"; shift
CASES_DIR="${CASES_DIR:-$ROOT/.cache/cases}"
CHUNK="${CHUNK:-2000}"
PRELUDE="${PRELUDE:-}"
ONLY="${ONLY:-}"
DRIVER="$ROOT/lib/driver.js"

TMP="$( mktemp -d )"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUT"
for f in "$CASES_DIR"/*.txt; do
	fn="$( basename "$f" .txt )"
	if [ -n "$ONLY" ]; then case " $ONLY " in *" $fn "*) ;; *) continue ;; esac; fi
	: > "$OUT/$fn.txt"
	split -l "$CHUNK" "$f" "$TMP/chunk."
	for c in "$TMP"/chunk.*; do
		{
			printf 'var CASES = '
			node -e 'process.stdout.write(JSON.stringify(require("fs").readFileSync(process.argv[1], "utf8")))' "$c"
			printf ';\n'
			if [ -n "$PRELUDE" ]; then cat "$PRELUDE"; fi
			cat "$DRIVER"
		} > "$TMP/run.js"
		"$@" "$TMP/run.js" >> "$OUT/$fn.txt"
		rm -f "$c"
	done
done
echo "$( cat "$OUT"/*.txt | wc -l | tr -d ' ' ) results from $( basename "$OUT" )"
