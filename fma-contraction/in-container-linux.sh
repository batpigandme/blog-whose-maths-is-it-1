#!/usr/bin/env bash
#
# in-container-linux.sh -- the half of run-contract-linux.sh that runs inside
# the container. Not meant to be run by hand.
#
# Reads /repo (the repository, mounted by run-contract-linux.sh), builds into
# /repo/.cache/build/linux-x86_64, and writes the output to $OUT.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -y -qq gcc make nodejs binutils >/dev/null 2>&1

ROOT=/repo
HERE=/repo/fma-contraction
CACHE_DIR=/repo/.cache
RES="$CACHE_DIR/results"
LABEL="linux-$( uname -m )"
mkdir -p "$( dirname "$OUT" )" "$RES"
exec > >( tee "$OUT" ) 2>&1
. "$ROOT/lib/header.sh"

SRC="$CACHE_DIR/mquickjs-src"
emit_header "MicroQuickJS $( git -C "$SRC" rev-parse HEAD 2>/dev/null || cat "$SRC/.git/HEAD" )" \
	"built from the pinned commit with $( gcc --version | head -1 ), in image ${IMAGE_ID:-ubuntu:24.04}; gcc, make and nodejs from Ubuntu's apt" \
	"fma-contraction/run-contract-linux.sh"
echo "# gcc:      $( gcc --version | head -1 ); make: $( make --version | head -1 ); objdump: $( objdump --version | head -1 )"
echo "# node:     $( node --version ) (Ubuntu's nodejs package; only quotes the cases and hashes the results)"
echo "# default contraction: -ffp-contract=$( gcc -Q --help=common 2>/dev/null | sed -n 's/^ *-ffp-contract=.*[[:space:]]\([a-z]*\)$/\1/p' ) (from gcc -Q --help=common)"
echo "# CPU has FMA flag: $( grep -m1 -o -w fma /proc/cpuinfo || echo no ); kernel: $( uname -sr )"
echo "# cases:    lib/gen-cases.js from stdlib 550666096f34c73f90f4bf86139935e4214fe421, checked against lib/cases.sha256"
echo

echo "## build $LABEL (GCC's default flags, plus nothing)"
"$HERE/build-mqjs.sh" "$SRC" "$CACHE_DIR/build/$LABEL"
echo

echo "## the tan input, 0xc0322052fd59ea32"
printf '%-18s ' "$LABEL:"
"$CACHE_DIR/build/$LABEL/mqjs" "$HERE/tan-pair.js"
echo

echo "## all cases"
rm -rf "${RES:?}/$LABEL"
start=$SECONDS
PRELUDE="$CACHE_DIR/stdlib-fns.bundle.js" "$ROOT/lib/run-cases.sh" "$RES/$LABEL" "$CACHE_DIR/build/$LABEL/mqjs" --memory-limit 256M
echo "$LABEL: $(( SECONDS - start )) s"
echo
echo "## hash of each function's result column (lib/colhash.js)"
node "$ROOT/lib/colhash.js" "$RES/$LABEL"

# let tee finish writing before the container exits
sleep 2
