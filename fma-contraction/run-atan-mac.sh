#!/usr/bin/env bash
#
# run-atan-mac.sh -- LLVM libc's atan, as V8 15.4 and later call it, with and
# without fused multiply-adds, against the d8 builds that call it.
#
#   ./fma-contraction/run-atan-mac.sh
#
# V8 15.4.8's src/base/ieee754.cc calls LLVM libc's atan; LLVM libc's
# multiply_add picks a fused multiply-add when the target has one (arm64 always
# does; x86_64 only with -mavx2 -mfma, which baseline x86_64 builds, including
# V8's, don't use). This script
#   1. prints the pins and the source lines that say so;
#   2. runs d8 14.6.202, 15.4.8 and 15.8.32 on the 6,498 Math.atan cases and
#      hashes each result column;
#   3. builds LLVM libc's atan natively four ways (default; fused path off and
#      compiler contraction off; library path only; compiler contraction only),
#      counts fused instructions, and hashes the output on the same cases;
#   4. runs the one input reported in
#      https://github.com/llvm/llvm-project/issues/197072 on the same builds.
# The Linux half is run-atan-linux.sh. Writes the output to $OUT.
#
# Environment (defaults):
#   OUT        output file (fma-contraction/results/atan-mac-arm64.txt)
#   CACHE_DIR  <repo root>/.cache
#   CXX        C++ compiler (clang++)
#
# Needs macOS arm64 with Apple clang, git, curl, unzip, node, and network
# access (downloads three d8 builds of about 19 MB each, LLVM libc's sources of
# about 75 MB, and stdlib's fixtures of about 45 MB). Takes a few minutes.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
export CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
CXX="${CXX:-clang++}"
OUT="${OUT:-$HERE/results/atan-mac-arm64.txt}"
V8_TAG=15.4.8
V8_SHA=332c967a18581b884d6d684005bd02d84bf970ac   # refs/tags/15.4.8
LIBC_SHA=6fd5620cc4fd3c55ee749e9bf71f52038431f76d # V8 15.4.8's DEPS
mkdir -p "$( dirname "$OUT" )" "$CACHE_DIR/results"

STDLIB_DIR="$( "$ROOT/lib/fetch-stdlib-fixtures.sh" )"; export STDLIB_DIR
node "$ROOT/lib/gen-cases.js" --check >/dev/null || { echo "cases differ from lib/cases.sha256" >&2; exit 1; }
CASES="$CACHE_DIR/cases/Math.atan.txt"
LIBC="$( "$HERE/fetch-llvm-libc.sh" )"
for v in 14.6.202 15.4.8 15.8.32; do "$ROOT/lib/fetch-d8.sh" "$v" >/dev/null 2>&1; done
. "$ROOT/lib/header.sh"
hash12() { node "$ROOT/lib/colhash.js" -; }

{
	emit_header "d8 14.6.202, 15.4.8, 15.8.32; LLVM libc at $LIBC_SHA" \
		"d8 from V8's build bucket (lib/fetch-d8.sh); LLVM libc built from commit $LIBC_SHA with $( $CXX --version | head -1 )" \
		"fma-contraction/run-atan-mac.sh"
	echo "# cases:    $( wc -l < "$CASES" | tr -d ' ' ) Math.atan inputs (lib/gen-cases.js), sha256 $( shasum -a 256 "$CASES" | cut -c1-16 )"
	echo
	echo "## pins"
	echo "v8 $V8_TAG -> $( git ls-remote https://github.com/v8/v8.git "refs/tags/$V8_TAG" | cut -f1 ) (expected $V8_SHA)"
	curl -sf "https://raw.githubusercontent.com/v8/v8/$V8_SHA/DEPS" | grep -A1 "'third_party/llvm-libc/src'" | sed 's/^/  DEPS: /'
	curl -sf "https://raw.githubusercontent.com/v8/v8/$V8_SHA/src/base/ieee754.cc" | grep -n -E 'llvm-libc/src/shared/math.h|double atan\(double x\)' | sed 's/^/  src\/base\/ieee754.cc:/'
	curl -sf "https://raw.githubusercontent.com/v8/v8/$V8_SHA/third_party/llvm-libc/BUILD.gn" | grep -n 'LIBC_NAMESPACE' | sed 's/^/  third_party\/llvm-libc\/BUILD.gn:/'
	echo "libc: $( git -C "$LIBC" log -1 --format='%H %cs %s' )"
	echo "  where multiply_add switches on FMA availability:"
	grep -n -E '^#if defined\(__ARM_FEATURE_FMA\)' "$LIBC/src/__support/macros/properties/cpu_features.h" | sed 's/^/  cpu_features.h:/'
	grep -n -E 'return x \* y \+ z;|__builtin_fma\(x, y, z\)' "$LIBC/src/__support/FPUtil/multiply_add.h" | sed 's/^/  multiply_add.h:/'
	echo

	echo "## the d8 columns: hash of the result column on the Math.atan cases (lib/colhash.js)"
	for v in 14.6.202 15.4.8 15.8.32; do
		D="$( "$ROOT/lib/fetch-d8.sh" "$v" 2>/dev/null )"
		rm -rf "${CACHE_DIR:?}/results/atan-d8-$v"
		ONLY="Math.atan" "$ROOT/lib/run-cases.sh" "$CACHE_DIR/results/atan-d8-$v" "$D" >/dev/null
		printf 'macOS d8 %-8s sha256 %s  %s   issue input -> %s\n' "$v" "$( shasum -a 256 "$D" | cut -c1-16 )" "$( node "$ROOT/lib/colhash.js" "$CACHE_DIR/results/atan-d8-$v/Math.atan.txt" | cut -d' ' -f2 )" "$( "$D" "$HERE/atan-issue-probe.js" )"
	done
	echo

	echo "## LLVM libc atan, arm64, native ($( $CXX --version | head -1 ))"
	W="$( mktemp -d )"; trap 'rm -rf "$W"' EXIT
	build() { # name, flags...
		local n="$1" f h i
		shift
		$CXX -std=c++20 -O2 -DLIBC_NAMESPACE=__llvm_libc_cr -I "$LIBC" "$@" "$HERE/llvm-atan-fma.cc" -o "$W/a-$n" 2>/dev/null
		f="$( objdump -d --no-show-raw-insn "$W/a-$n" | grep -c -E '\bf(n)?m(add|sub)\b' || true )"
		h="$( "$W/a-$n" < "$CASES" 2> "$W/err" | hash12 )"
		i="$( echo 'Math.atan 40600e99e0bbf8d4 0' | "$W/a-$n" 2>/dev/null )"
		printf '%-50s fused=%-3s hash=%s  issue input -> %s  (%s)\n' "$n [$*]" "$f" "$h" "$i" "$( cat "$W/err" )"
	}
	build default
	build nofma -U__ARM_FEATURE_FMA -ffp-contract=off
	build library-path-only -ffp-contract=off
	build compiler-contraction-only -U__ARM_FEATURE_FMA
	echo
	echo "## reading the hashes"
	echo "A build's hash matches a d8 column when it gives the same bits on every one of the cases. Compare the lines above; run-atan-linux.sh adds the Linux columns."
	echo
	echo "## llvm-project issue 197072, read-only (GitHub REST API)"
	curl -sf -H 'Accept: application/vnd.github+json' https://api.github.com/repos/llvm/llvm-project/issues/197072 | node -e '
		var i = JSON.parse( require( "fs" ).readFileSync( 0, "utf8" ) );
		console.log( "state=" + i.state + " created=" + i.created_at + " title=" + i.title );'
} 2>&1 | tee "$OUT"
sleep 1
