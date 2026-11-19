#!/usr/bin/env bash
#
# glibc-diff.sh -- V8's vendored copy of glibc's sin and cos, file by file,
# against glibc at the revision V8's README names.
#
#   ./v8-sources/glibc-diff.sh
#
# Fetches V8's third_party/glibc files at 13.6.233.17 and the same seven files
# from glibc (the bminor/glibc mirror) at revision
# 4e21c2075193e406a92c0d1cb091a7c804fda4d9, which README.v8 names, and prints
# for each file the number of differing lines and, for the small diffs, the
# differing lines themselves. endian.h and trig.h have no counterpart in glibc
# (V8 wrote them). The output is how "glibc's code apart from build glue" is
# read; it does not run anything. The third-party lines it prints are the diff
# only, a few dozen at most.
#
# Environment (defaults):
#   OUT   output file (v8-sources/results/glibc-diff.txt)
#
# Needs curl and diff. Any OS. Takes a few seconds.

set -u
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUT="${OUT:-$HERE/results/glibc-diff.txt}"
V8SHA=b0a55a7dad7f536cce1f9aaddba89894c8533946
GLIBC=4e21c2075193e406a92c0d1cb091a7c804fda4d9
TMP="$( mktemp -d )"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$( dirname "$OUT" )" "$TMP/v8" "$TMP/glibc"

{
	echo "# engine:   none run; V8 third_party/glibc at 13.6.233.17 ($V8SHA) against glibc at $GLIBC"
	echo "# platform: any; curl and diff"
	echo "# obtained: https://raw.githubusercontent.com/v8/v8 and https://raw.githubusercontent.com/bminor/glibc, read-only"
	echo "# date:     $( date -u +%Y-%m-%dT%H:%M:%SZ )"
	echo "# script:   v8-sources/glibc-diff.sh"
	for f in branred.c branred.h dla.h endian.h mydefs.h s_sin.c sincostab.c trig.h usncs.h; do
		curl -sf -o "$TMP/v8/$f" "https://raw.githubusercontent.com/v8/v8/$V8SHA/third_party/glibc/src/sysdeps/ieee754/dbl-64/$f" || { echo "could not fetch V8's $f"; exit 2; }
		if curl -sf -o "$TMP/glibc/$f" "https://raw.githubusercontent.com/bminor/glibc/$GLIBC/sysdeps/ieee754/dbl-64/$f"; then
			n="$( diff "$TMP/glibc/$f" "$TMP/v8/$f" | grep -c '^[<>]' )"
			echo
			echo "## $f: $n differing lines ('<' glibc, '>' V8's copy), $( wc -l < "$TMP/v8/$f" | tr -d ' ' ) lines in V8's"
			if [ "$n" -le 40 ]; then diff "$TMP/glibc/$f" "$TMP/v8/$f" | grep '^[<>]'; fi
		else
			echo
			echo "## $f: not in glibc at that revision under sysdeps/ieee754/dbl-64/ (V8's own file)"
		fi
	done
} 2>&1 | tee "$OUT"
