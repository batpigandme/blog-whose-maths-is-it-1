#!/usr/bin/env bash
#
# in-container-atan.sh -- the half of run-atan-linux.sh that runs inside a
# container. Not meant to be run by hand.
#
# Reads /repo (the repository, mounted by run-atan-linux.sh), builds LLVM libc's
# atan with clang, and, on x86_64, runs published Linux d8 builds. Writes the
# output to $OUT.

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -y -qq clang binutils nodejs curl unzip ca-certificates >/dev/null 2>&1

ROOT=/repo
HERE=/repo/fma-contraction
CACHE_DIR=/repo/.cache
export CACHE_DIR
LIBC="$CACHE_DIR/llvm-libc-6fd5620cc4fd"
CASES="$CACHE_DIR/cases/Math.atan.txt"
ARCH="$( uname -m )"
mkdir -p "$( dirname "$OUT" )" "$CACHE_DIR/results"
exec > >( tee "$OUT" ) 2>&1
. "$ROOT/lib/header.sh"
hash12() { node "$ROOT/lib/colhash.js" -; }
W="$( mktemp -d )"

emit_header "LLVM libc at 6fd5620cc4fd3c55ee749e9bf71f52038431f76d$( [ "$ARCH" = x86_64 ] && echo '; d8 14.6.202, 15.4.8, 15.8.32 (linux64)' )" \
	"LLVM libc built from that commit with $( clang++ --version | head -1 ), in image ${IMAGE_ID:-ubuntu:24.04}; clang, binutils, nodejs from Ubuntu's apt$( [ "$ARCH" = x86_64 ] && echo "; d8 from V8's build bucket (lib/fetch-d8.sh)" )" \
	"fma-contraction/run-atan-linux.sh"
if [ "$ARCH" = x86_64 ]; then
	echo "# CPU flags: $( grep -m1 -o -w fma /proc/cpuinfo || echo 'no fma' ), $( grep -m1 -o -w avx2 /proc/cpuinfo || echo 'no avx2' ) (as /proc/cpuinfo reports them); kernel: $( uname -sr )"
else
	echo "# kernel:   $( uname -sr ); this container's architecture is the host's, so nothing is emulated"
fi
echo "# cases:    $( wc -l < "$CASES" | tr -d ' ' ) Math.atan inputs (lib/gen-cases.js), sha256 $( sha256sum "$CASES" | cut -c1-16 )"
echo

build() { # name, flags...
	local n="$1" f h i
	shift
	clang++ -std=c++20 -O2 -DLIBC_NAMESPACE=__llvm_libc_cr -I "$LIBC" "$@" "$HERE/llvm-atan-fma.cc" -o "$W/a-$n" 2>/dev/null || { echo "$n [$*]: build failed"; return; }
	if [ "$ARCH" = x86_64 ]; then
		f="$( objdump -d --no-show-raw-insn "$W/a-$n" | grep -c -E '\bvfn?m(add|sub)[0-9]+s[sd]\b' || true )"
	else
		f="$( objdump -d --no-show-raw-insn "$W/a-$n" | grep -c -E '\bf(n)?m(add|sub)\b' || true )"
	fi
	if "$W/a-$n" < "$CASES" > "$W/out-$n" 2> "$W/err"; then
		h="$( hash12 < "$W/out-$n" )"
		i="$( echo 'Math.atan 40600e99e0bbf8d4 0' | "$W/a-$n" 2>/dev/null )"
		printf '%-44s fused=%-3s hash=%s  issue input -> %s  (%s)\n' "$n [$*]" "$f" "$h" "$i" "$( cat "$W/err" )"
	else
		printf '%-44s fused=%-3s did not run (exit %s)\n' "$n [$*]" "$f" "$?"
	fi
}

echo "## LLVM libc atan, $ARCH, native to this container's architecture ($( clang++ --version | head -1 ))"
if [ "$ARCH" = x86_64 ]; then
	build base
	build fma -mavx2 -mfma
else
	build default
	build nofma -U__ARM_FEATURE_FMA -ffp-contract=off
fi
echo

if [ "$ARCH" = x86_64 ]; then
	echo "## published Linux d8 builds: hash of the result column on the Math.atan cases (lib/colhash.js)"
	for v in 14.6.202 15.4.8 15.8.32; do
		D="$( "$ROOT/lib/fetch-d8.sh" "$v" linux64 2>/dev/null )"
		rm -rf "${CACHE_DIR:?}/results/atan-d8-linux-$v"
		ONLY="Math.atan" "$ROOT/lib/run-cases.sh" "$CACHE_DIR/results/atan-d8-linux-$v" "$D" >/dev/null
		printf 'Linux d8 %-8s sha256 %s  %s   issue input -> %s\n' "$v" "$( sha256sum "$D" | cut -c1-16 )" "$( node "$ROOT/lib/colhash.js" "$CACHE_DIR/results/atan-d8-linux-$v/Math.atan.txt" | cut -d' ' -f2 )" "$( "$D" "$HERE/atan-issue-probe.js" )"
	done
fi
rm -rf "$W"
sleep 2
