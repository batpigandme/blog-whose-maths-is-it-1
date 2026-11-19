#!/usr/bin/env bash
#
# tan-pair.sh -- the three answers for Math.tan of 0xc0322052fd59ea32, side by
# side, with each one's distance from the correctly rounded value.
#
#   ./fma-contraction/tan-pair.sh
#
# Takes MicroQuickJS's answers from the outputs of run-contract-mac.sh and
# run-contract-linux.sh (results/contract-*.txt), and the correctly rounded
# value from MPFR, through Julia's BigFloat (tan-mpfr.jl). If Julia isn't
# installed, the MPFR value is the one printed by an earlier run of
# tan-mpfr.jl (3fec40c1bc40f28d) and the output says so.
#
# Environment (defaults):
#   OUT   output file (fma-contraction/results/tan-pair.txt)
#
# Needs node; Julia is optional. macOS or Linux.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
OUT="${OUT:-$HERE/results/tan-pair.txt}"
. "$ROOT/lib/header.sh"

answer() { sed -n "s/^$1: *Math.tan c0322052fd59ea32 \([0-9a-f]*\)\$/\1/p" "$2"; }
MAC="$( answer mac-default "$HERE/results/contract-mac-arm64.txt" )"
MACOFF="$( answer mac-nocontract "$HERE/results/contract-mac-arm64.txt" )"
LINUX="$( answer linux-x86_64 "$HERE/results/contract-linux-x86_64.txt" )"
if command -v julia >/dev/null 2>&1; then
	MPFR="$( julia "$HERE/tan-mpfr.jl" | sed -n 's/^Math.tan c0322052fd59ea32 //p' )"
	MPFR_FROM="MPFR through Julia $( julia --version | cut -d' ' -f3 ) (tan-mpfr.jl, run now)"
else
	MPFR=3fec40c1bc40f28d
	MPFR_FROM="MPFR (captured from an earlier run of tan-mpfr.jl; Julia is not installed here)"
fi

{
	echo "# engine:   MicroQuickJS 6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9 (three builds); $MPFR_FROM"
	echo "# platform: assembled on $( platform_string ); each answer's platform is in its own output file"
	echo "# obtained: lines of results/contract-mac-arm64.txt and results/contract-linux-x86_64.txt"
	echo "# date:     $( date -u +%Y-%m-%dT%H:%M:%SZ )"
	echo "# script:   fma-contraction/tan-pair.sh"
	echo
	echo "Math.tan of 0xc0322052fd59ea32"
	node - "$MAC" "$MACOFF" "$LINUX" "$MPFR" <<'JS'
var a = process.argv.slice( 2 );
var rows = [
	[ 'macOS arm64, Apple clang 21.0.0, default (fused)', a[ 0 ] ],
	[ 'macOS arm64, Apple clang 21.0.0, -ffp-contract=off', a[ 1 ] ],
	[ 'Ubuntu 24.04 x86_64, GCC 13.3.0, default', a[ 2 ] ],
	[ 'correctly rounded (MPFR)', a[ 3 ] ]
];
var ref = BigInt( '0x' + a[ 3 ] );
rows.forEach( function ( r ) {
	var d = BigInt( '0x' + r[ 1 ] ) - ref;
	console.log( r[ 1 ] + '  ' + ( d === 0n ? 'exact' : ( d > 0n ? '+' : '' ) + d + ' ulp' ).padEnd( 8 ) + '  ' + r[ 0 ] );
});
JS
} 2>&1 | tee "$OUT"
