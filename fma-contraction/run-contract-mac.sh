#!/usr/bin/env bash
#
# run-contract-mac.sh -- MicroQuickJS's libm.c under Apple clang, with
# contraction (fused multiply-add) on, which is the default, and off.
#
#   ./fma-contraction/run-contract-mac.sh
#
# Builds MicroQuickJS twice from the pinned commit (the Makefile's own flags,
# and the same plus -ffp-contract=off), counts fused multiply-add instructions
# in the compiled objects, runs the `tan` input on both, runs every case on
# both (all 17 functions, 392,083 cases), and prints a hash of each function's
# result column. Writes the output to $OUT as well as the terminal.
#
# Environment (defaults):
#   OUT        output file (fma-contraction/results/contract-mac-arm64.txt)
#   CACHE_DIR  <repo root>/.cache
#
# Needs: macOS (arm64) with Apple clang and make, node and npm, git, and
# network access (first run fetches MicroQuickJS and stdlib's fixtures).
# Takes about 10 to 15 minutes. Run the Linux half with run-contract-linux.sh.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
export CACHE_DIR
OUT="${OUT:-$HERE/results/contract-mac-arm64.txt}"
RES="$CACHE_DIR/results"
mkdir -p "$( dirname "$OUT" )" "$RES"

# Everything below is also the committed output.
exec > >( tee "$OUT" ) 2>&1
. "$ROOT/lib/header.sh"

SRC="$( "$HERE/fetch-mquickjs.sh" )"
STDLIB_DIR="$( "$ROOT/lib/fetch-stdlib-fixtures.sh" )"
export STDLIB_DIR
node "$ROOT/lib/gen-cases.js" --check >/dev/null || { echo "cases differ from lib/cases.sha256" >&2; exit 1; }
PRELUDE_FILE="$( "$HERE/build-stdlib-fns.sh" | sed -n 1p )"

emit_header "MicroQuickJS $( git -C "$SRC" rev-parse HEAD ), libm.c built two ways" \
	"built from commit $( git -C "$SRC" rev-parse HEAD ) ($( git -C "$SRC" log -1 --format=%cs )) with $( cc --version | head -1 )" \
	"fma-contraction/run-contract-mac.sh"
echo "# cc:       $( cc --version | head -1 ); $( cc --version | sed -n 2p )"
echo "# make:     $( make --version | head -1 ); objdump: $( objdump --version | head -1 )"
echo "# default contraction: $( echo 'double f(double a, double b, double c) { return a * b + c; }' > "$CACHE_DIR/f.c"; cc -### -c "$CACHE_DIR/f.c" 2>&1 | grep -o -E 'ffp-contract=[a-z]+' | head -1 ) (the flag Apple clang passes when none is given)"
echo "# cases:    lib/gen-cases.js from stdlib $( git -C "$STDLIB_DIR" rev-parse HEAD ), checked against lib/cases.sha256"
echo

for v in default:"" nocontract:"-ffp-contract=off"; do
	name="${v%%:*}"; flags="${v#*:}"
	echo "## build mac-$name${flags:+ (extra flag: $flags)}"
	"$HERE/build-mqjs.sh" "$SRC" "$CACHE_DIR/build/mac-$name" $flags
	echo
done

echo "## the tan input, 0xc0322052fd59ea32"
for name in default nocontract; do
	printf '%-18s ' "mac-$name:"
	"$CACHE_DIR/build/mac-$name/mqjs" "$HERE/tan-pair.js"
done
echo

echo "## all cases, both builds"
for name in default nocontract; do
	rm -rf "${RES:?}/mac-$name"
	start=$SECONDS
	PRELUDE="$PRELUDE_FILE" "$ROOT/lib/run-cases.sh" "$RES/mac-$name" "$CACHE_DIR/build/mac-$name/mqjs" --memory-limit 256M
	echo "mac-$name: $(( SECONDS - start )) s"
done
echo
echo "## hash of each function's result column (lib/colhash.js)"
"$HERE/compare.sh" "$RES" mac-default mac-nocontract

# let tee finish writing before the script exits
sleep 2
