#!/usr/bin/env bash
#
# check.sh -- where V8's sin, cos and pow come from, measured.
#
#   ./v8-sources/check.sh
#
# Part 1. V8's vendored copy of glibc's sin and cos, fetched at 13.6.233.17 and
#         compiled three ways (contraction off, on, fast), against d8's sin and
#         cos with the trig flag at its default and turned off, and against
#         Node.js, and against this platform's C library.
# Part 2. V8's pow, with --use-std-math-pow at its default and turned off, with
#         and without the JIT, against this platform's pow.
# Part 3. Whether Node.js accepts the two flags at all.
#
# Environment (defaults):
#   (d8 13.6.233, 14.6.202 and 15.8.32 are downloaded from V8's build bucket by
#   lib/fetch-d8.sh into CACHE_DIR; they are the same binaries jsvu installs)
#   NVM_DIR     nvm's directory ($HOME/.nvm); needs Node.js 24.19.0 and 26.13.1
#   CASES_DIR   case files from lib/gen-cases.js (<repo root>/.cache/cases)
#   CACHE_DIR   <repo root>/.cache
#   CC          C compiler (clang); the harness is built with -ffp-contract
#   OUT         output file (v8-sources/results/math-sources-<os>-<arch>.txt)
#
# Needs curl, unzip, node, a C compiler and objdump, and Node.js 24.19.0 and
# 26.13.1 installed with nvm. The d8 and Node.js builds are the macOS arm64
# ones; on another platform the glibc-copy and
# d8 columns are still comparable with each other, but the platform column and
# the counts of differing results are that platform's. Takes about a minute.

set -u
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
N="${NVM_DIR:-$HOME/.nvm}/versions/node"
CASES="${CASES_DIR:-$ROOT/.cache/cases}"
CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
CC="${CC:-clang}"
OUT="${OUT:-$HERE/results/math-sources-$( [ "$( uname -s )" = Darwin ] && echo mac || echo linux )-$( uname -m ).txt}"
PROBE="$HERE/probe.js"
PLATFORM_C="$ROOT/lib/platform.c"
HARNESS_C="$HERE/glibc-copy-harness.c"
V8SHA=b0a55a7dad7f536cce1f9aaddba89894c8533946   # V8 13.6.233.17
GLIBC_FILES="branred.c branred.h dla.h endian.h mydefs.h s_sin.c sincostab.c trig.h usncs.h"

. "$ROOT/lib/header.sh"
# d8 builds, from V8's build bucket (the same files jsvu installs).
D8_136="$( "$ROOT/lib/fetch-d8.sh" 13.6.233 2>/dev/null )"
D8_146="$( "$ROOT/lib/fetch-d8.sh" 14.6.202 2>/dev/null )"
D8_158="$( "$ROOT/lib/fetch-d8.sh" 15.8.32 2>/dev/null )"
d8bin() { case "$1" in 13.6.233 ) echo "$D8_136" ;; 14.6.202 ) echo "$D8_146" ;; 15.8.32 ) echo "$D8_158" ;; esac; }
TMP="$( mktemp -d )"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$( dirname "$OUT" )"

sha() { shasum -a 256 "$1" | cut -c1-16; }

# col LABEL CMD...: run CMD, keep its stdout as column LABEL, minus any leading
# `Math.<fn> ` field (platform.c prints one; the probe and harness don't).
col() {
	local label="$1" rc
	shift
	"$@" > "$TMP/$label.raw" 2> "$TMP/$label.err"
	rc=$?
	sed -E 's/^Math\.[a-z0-9]+ //' "$TMP/$label.raw" > "$TMP/$label"
	printf '  %-34s exit %s, %6s lines, sha256 %s\n' "$label" "$rc" "$( wc -l < "$TMP/$label" | tr -d ' ' )" "$( sha "$TMP/$label" )"
	if [ "$rc" -ne 0 ]; then
		sed 's/^/    stderr: /' "$TMP/$label.err" | head -5
	fi
}

# vs A B K: how many results differ between columns A and B, with K input
# fields per line. Differences where both results are NaN are counted apart,
# since only the payload differs there.
vs() {
	paste -d' ' "$TMP/$1" "$TMP/$2" | awk -v k="$3" -v a="$1" -v b="$2" '
		function isnan( h ) { p = substr( h, 1, 3 ); return ( p == "7ff" || p == "fff" ) && substr( h, 4 ) != "0000000000000"; }
		{
			for ( i = 1; i <= k; i++ ) if ( $i != $( k + 1 + i ) ) { bad++; next }
			ra = $( k + 1 ); rb = $( 2 * k + 2 );
			if ( ra != rb ) { if ( isnan( ra ) && isnan( rb ) ) nan++; else d++ }
			n++
		}
		END { printf "  %-34s vs %-28s %6d of %d differ%s%s\n", a, b, d, n, ( nan ? sprintf( " (and %d NaN payloads)", nan ) : "" ), ( bad ? sprintf( " MISALIGNED %d", bad ) : "" ) }'
}

# fused FILE: number of fused multiply-add instructions in a compiled binary.
fused() {
	case "$( uname -m )" in
		arm64|aarch64 ) objdump -d "$1" | grep -c -E '\bf(n)?m(add|sub)\b' ;;
		* ) objdump -d "$1" | grep -c -E '\bvfn?m(add|sub)[0-9]*s[sd]\b' ;;
	esac
}

for need in "$CASES/Math.sin.txt" "$CASES/Math.cos.txt" "$CASES/Math.pow.txt"; do
	[ -f "$need" ] || { echo "missing $need: run node lib/gen-cases.js first" >&2; exit 2; }
done

{
	echo "# engines:  d8 13.6.233, 14.6.202, 15.8.32; Node.js 24.19.0 and 26.13.1; versions and binary hashes below"
	echo "# platform: $( platform_string )"
	echo "# obtained: d8 from V8's build bucket (lib/fetch-d8.sh); Node.js from nvm; V8's glibc copy fetched at $V8SHA"
	echo "# date:     $( date -u +%Y-%m-%dT%H:%M:%SZ )"
	echo "# script:   v8-sources/check.sh"
	echo "# cc:       $( $CC --version | head -1 )"
	echo "# cases:    $( for f in sin cos pow; do printf 'Math.%s %s lines, sha256 %s; ' "$f" "$( wc -l < "$CASES/Math.$f.txt" | tr -d ' ' )" "$( sha "$CASES/Math.$f.txt" )"; done )"
	for v in 13.6.233 14.6.202 15.8.32; do
		D="$( d8bin "$v" )"
		echo "# d8 $v: sha256 $( sha "$D" ), version() $( echo 'print(version())' > "$TMP/version.js"; "$D" "$TMP/version.js" 2>&1 )"
		echo "#   --help lists: $( "$D" --help </dev/null 2>&1 | grep -o -E -e '--(use-libm-trig-functions|use-std-math-pow)' | sort -u | tr '\n' ' ')"
	done
	for v in 24.19.0 26.13.1; do
		echo "# node v$v: sha256 $( sha "$N/v$v/bin/node" ), V8 $( "$N/v$v/bin/node" -p process.versions.v8 )"
	done

	echo
	echo "## Part 1. sin and cos against V8's own copy of glibc's code"
	echo
	echo "V8's third_party/glibc at $V8SHA, fetched with curl; each file's sha256 is checked against glibc-files.sha256:"
	mkdir -p "$TMP/glibc"
	for f in $GLIBC_FILES; do
		curl -sf -o "$TMP/glibc/$f" "https://raw.githubusercontent.com/v8/v8/$V8SHA/third_party/glibc/src/sysdeps/ieee754/dbl-64/$f" \
			|| { echo "  could not fetch $f, stopping"; exit 2; }
		printf '  %-12s sha256 %s\n' "$f" "$( sha "$TMP/glibc/$f" )"
	done
	( cd "$TMP/glibc" && shasum -a 256 -c "$HERE/glibc-files.sha256" >/dev/null 2>&1 ) && echo "  all nine files match glibc-files.sha256" || { echo "  FILES DIFFER from glibc-files.sha256, stopping"; exit 2; }
	G="$TMP/glibc"
	for c in off on fast; do
		$CC -O3 -ffp-contract=$c -w -I"$G" -o "$TMP/harness-$c" "$HARNESS_C" "$G/s_sin.c" "$G/branred.c" "$G/sincostab.c" \
			|| { echo "harness build failed (-ffp-contract=$c), stopping"; exit 2; }
		echo "  built harness-$c: $CC -O3 -ffp-contract=$c, $( fused "$TMP/harness-$c" ) fused multiply-add instructions"
	done
	cc -O2 -fno-builtin -o "$TMP/platform" "$PLATFORM_C" -lm || { echo "platform build failed, stopping"; exit 2; }

	for fn in sin cos; do
		C="$CASES/Math.$fn.txt"
		echo
		echo "### Math.$fn"
		for c in off on fast; do col "$fn-copy-contract-$c" "$TMP/harness-$c" "$C"; done
		col "$fn-platform-libm" "$TMP/platform" "$C"
		for v in 13.6.233 14.6.202; do
			for i in 1 2; do
				col "$fn-d8-$v-default-$i" "$( d8bin "$v" )" "$PROBE" -- "$C"
				col "$fn-d8-$v-trigoff-$i" "$( d8bin "$v" )" --no-use-libm-trig-functions "$PROBE" -- "$C"
			done
		done
		col "$fn-d8-15.8.32-default" "$D8_158" "$PROBE" -- "$C"
		for v in 24.19.0 26.13.1; do col "$fn-node-$v" "$N/v$v/bin/node" "$PROBE" "$C"; done
		echo
		for v in 13.6.233 14.6.202; do
			vs "$fn-d8-$v-default-1" "$fn-d8-$v-default-2" 1
			vs "$fn-d8-$v-trigoff-1" "$fn-d8-$v-trigoff-2" 1
			for c in off on fast; do vs "$fn-d8-$v-default-1" "$fn-copy-contract-$c" 1; done
			vs "$fn-d8-$v-trigoff-1" "$fn-copy-contract-off" 1
			vs "$fn-d8-$v-default-1" "$fn-platform-libm" 1
		done
		for v in 24.19.0 26.13.1; do
			vs "$fn-node-$v" "$fn-d8-13.6.233-trigoff-1" 1
			vs "$fn-node-$v" "$fn-copy-contract-off" 1
		done
		vs "$fn-d8-15.8.32-default" "$fn-copy-contract-off" 1
	done

	echo
	echo "## Part 2. pow, with --use-std-math-pow at its default and off"
	C="$CASES/Math.pow.txt"
	echo
	col "pow-platform-libm" "$TMP/platform" "$C"
	for v in 13.6.233 14.6.202 15.8.32; do
		for i in 1 2; do
			col "pow-d8-$v-default-$i" "$( d8bin "$v" )" "$PROBE" -- "$C"
		done
		col "pow-d8-$v-stdoff" "$( d8bin "$v" )" --no-use-std-math-pow "$PROBE" -- "$C"
		col "pow-d8-$v-jitless" "$( d8bin "$v" )" --jitless "$PROBE" -- "$C"
		col "pow-d8-$v-jitless-stdoff" "$( d8bin "$v" )" --jitless --no-use-std-math-pow "$PROBE" -- "$C"
	done
	for v in 24.19.0 26.13.1; do col "pow-node-$v" "$N/v$v/bin/node" "$PROBE" "$C"; done
	echo
	for v in 13.6.233 14.6.202 15.8.32; do
		vs "pow-d8-$v-default-1" "pow-d8-$v-default-2" 2
		vs "pow-d8-$v-default-1" "pow-platform-libm" 2
		vs "pow-d8-$v-jitless" "pow-platform-libm" 2
		vs "pow-d8-$v-stdoff" "pow-platform-libm" 2
		vs "pow-d8-$v-jitless-stdoff" "pow-d8-$v-stdoff" 2
		vs "pow-d8-$v-stdoff" "pow-d8-13.6.233-stdoff" 2
	done
	for v in 24.19.0 26.13.1; do vs "pow-node-$v" "pow-platform-libm" 2; done

	echo
	echo "## Where pow's differing results are: inputs where the column differs from the platform's pow, and how many of those have y = 2 (bits 4000000000000000)"
	for col in pow-d8-13.6.233-default-1 pow-d8-14.6.202-default-1 pow-d8-15.8.32-default-1 pow-node-24.19.0 pow-node-26.13.1; do
		paste -d' ' "$TMP/$col" "$TMP/pow-platform-libm" | awk -v c="$col" '{ if ( $3 != $6 ) { n++; if ( $2 == "4000000000000000" ) two++; list = list " (x=" $1 ")" } } END { printf "  %-28s %d differ, %d with y = 2%s\n", c, n, two, list }'
	done
	echo
	echo "d8 13.6.233's two, in full:"
	paste -d' ' "$TMP/pow-d8-13.6.233-default-1" "$TMP/pow-platform-libm" | awk '{ if ( $3 != $6 ) print "  x = " $1 ", y = " $2 ": d8 " $3 ", platform " $6 }'

	echo "## Part 3. Do Node.js builds accept the flags?"
	for v in 24.19.0 26.13.1; do
		for fl in --no-use-libm-trig-functions --use-libm-trig-functions --no-use-std-math-pow; do
			o="$( "$N/v$v/bin/node" $fl -e 'console.log("accepted")' </dev/null 2>&1 | head -1 | sed "s#$N#<nvm>#g" )"
			printf '  node v%-8s %-32s %s\n' "$v" "$fl" "$o"
		done
	done
} 2>&1 | sed "s#$HOME#~#g" | tee "$OUT"
