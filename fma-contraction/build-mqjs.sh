#!/usr/bin/env bash
#
# build-mqjs.sh -- build MicroQuickJS from a source checkout, in a fresh copy,
# with the Makefile's own flags and, optionally, extra compiler flags.
#
#   ./fma-contraction/build-mqjs.sh SRC DEST [EXTRA_CC_FLAGS]
#   ./fma-contraction/build-mqjs.sh .cache/mquickjs-src .cache/build/default
#   ./fma-contraction/build-mqjs.sh .cache/mquickjs-src .cache/build/nocontract -ffp-contract=off
#
# Copies SRC to DEST, then runs `make mqjs` with CC set to `gcc EXTRA_CC_FLAGS`.
# The flags go through CC, not CFLAGS, because a CFLAGS on the make command
# line replaces the Makefile's (-Os -fno-math-errno -fno-trapping-math ...)
# instead of adding to it, which would change the build in more ways than one.
# On macOS `gcc` is Apple clang; on Ubuntu it is GCC.
#
# Prints the compile line for libm.c and the number of fused multiply-add
# instructions in each object file (arm64: fmadd, fmsub, fnmadd, fnmsub;
# x86_64: the vfmadd and vfmsub families). Runs on macOS or Linux.

set -euo pipefail
SRC="${1:?usage: build-mqjs.sh SRC DEST [EXTRA_CC_FLAGS]}"
DEST="${2:?usage: build-mqjs.sh SRC DEST [EXTRA_CC_FLAGS]}"
shift 2
EXTRA="$*"

rm -rf "$DEST"
mkdir -p "$( dirname "$DEST" )"
cp -R "$SRC" "$DEST"
make -C "$DEST" clean >/dev/null 2>&1 || true
make -C "$DEST" CC="gcc $EXTRA" mqjs >/dev/null 2>&1

echo "libm.c compile line: $( make -C "$DEST" -n -B CC="gcc $EXTRA" libm.o | grep 'libm\.c' )"
case "$( uname -m )" in
	arm64|aarch64 ) PAT='\b(fmadd|fmsub|fnmadd|fnmsub)\b' ;;
	* ) PAT='\bvfn?m(add|sub)[0-9]*s[sd]\b' ;;
esac
for o in libm.o mquickjs.o dtoa.o cutils.o mqjs.o; do
	printf 'fused multiply-add instructions in %-11s %s\n' "$o:" "$( objdump -d "$DEST/$o" | grep -cE "$PAT" || true )"
done
