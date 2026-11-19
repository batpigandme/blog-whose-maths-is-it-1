#!/usr/bin/env bash
#
# sources.sh -- read V8's source and commit history at pinned commits, and
# print the lines each claim rests on.
#
#   ./v8-sources/sources.sh
#
# Reads, over HTTPS and read-only: files from github.com/v8/v8 at 13.6.233.17
# (b0a55a7dad7f536cce1f9aaddba89894c8533946) through raw.githubusercontent.com,
# and commit metadata through GitHub's REST API, by full SHA. The claims:
#   - V8 vendors a handful of files forked from glibc, and names a glibc revision;
#   - the build sets v8_use_libm_trig_functions = is_clang;
#   - the trig flag and --use-std-math-pow default to on;
#   - Math.pow's code, after special cases and two shortcuts, calls std::pow;
#   - the switch to glibc's sin and cos landed on 30 November 2022, in 11.0,
#     was reverted, and relanded (the committer date of the reland is the one to
#     read as the landing date; the author date can precede it);
#   - tan moved to LLVM's libm on 11 May 2026, and the glibc copy and its flag
#     were removed on 6 July 2026.
#
# Environment (defaults):
#   GITHUB_TOKEN  optional; raises the API rate limit (unauthenticated is 60
#                 requests an hour, and this script uses about 12)
#   OUT           output file (v8-sources/results/sources.txt)
#
# Needs curl and node. Any OS. Takes a few seconds.

set -u
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUT="${OUT:-$HERE/results/sources.txt}"
V8=b0a55a7dad7f536cce1f9aaddba89894c8533946   # 13.6.233.17
RAW="https://raw.githubusercontent.com/v8/v8"
mkdir -p "$( dirname "$OUT" )"

raw() { curl -sf "$RAW/$1/$2"; }
api() { # path
	if [ -n "${GITHUB_TOKEN:-}" ]; then
		curl -sf -H "Authorization: Bearer $GITHUB_TOKEN" -H 'Accept: application/vnd.github+json' "https://api.github.com/$1"
	else
		curl -sf -H 'Accept: application/vnd.github+json' "https://api.github.com/$1"
	fi
}
# commit SHA: full sha, author date, committer date, first line of the message.
# A prefix works as the argument; the full SHA printed is what it resolves to.
commit() {
	api "repos/v8/v8/commits/$1" | node -e '
		var c = JSON.parse( require( "fs" ).readFileSync( 0, "utf8" ) );
		console.log( "  " + c.sha + "  author " + c.commit.author.date.slice( 0, 10 ) + "  committer " + c.commit.committer.date.slice( 0, 10 ) + "  " + c.commit.message.split( "\n" )[ 0 ] );'
}

{
	echo "# engine:   none run; reads V8's source at 13.6.233.17 ($V8) and commits by SHA"
	echo "# platform: any; curl and node"
	echo "# obtained: https://raw.githubusercontent.com/v8/v8 and https://api.github.com/repos/v8/v8, read-only"
	echo "# date:     $( date -u +%Y-%m-%dT%H:%M:%SZ )"
	echo "# script:   v8-sources/sources.sh"
	echo
	echo "## third_party/glibc/README.v8 at $V8"
	raw $V8 third_party/glibc/README.v8 | grep -E -n 'Revision|forked from glibc|^URL|^License:'
	echo
	echo "## gni/v8.gni at $V8"
	raw $V8 gni/v8.gni | grep -n 'v8_use_libm_trig_functions'
	echo
	echo "## src/flags/flag-definitions.h at $V8"
	raw $V8 src/flags/flag-definitions.h | grep -n -A1 -E 'DEFINE_BOOL\((use_std_math_pow|use_libm_trig_functions)'
	echo
	echo "## src/numbers/ieee754.cc at $V8: Math.pow"
	raw $V8 src/numbers/ieee754.cc | sed -n '14,51p' | grep -n -E 'use_std_math_pow|y == 2|y == 0\.5|x \* x|sqrt\(x|std::pow\(x, y\)|legacy::pow'
	echo
	echo "## src/base/ieee754.cc at $V8: V8's own code, line 1"
	raw $V8 src/base/ieee754.cc | sed -n '1p'
	echo
	echo "## the switch to glibc's sin and cos: commits, by full SHA"
	commit 4588fe544f78784f5d3a8861886cd4d73f20ab1e
	commit ea18ee8ff8
	commit 7519793938af3bb5e74594a45da10bc04bd33f20
	printf '  include/v8-version.h at 4588fe5: '
	raw 4588fe544f78784f5d3a8861886cd4d73f20ab1e include/v8-version.h | grep -E 'define V8_(MAJOR|MINOR|BUILD_NUMBER)_VERSION|define V8_(MAJOR|MINOR)_VERSION' | awk '{ printf "%s=%s ", $2, $3 }'; echo
	echo "  (ea18ee8ff8 is the revert, a prefix resolved by the API; the reland is 7519793)"
	echo
	echo "## the move to LLVM's libm, and the removal of the glibc copy"
	commit cc1a6fcbdabbe4c912948bebe29371c084eade33
	commit 8787f0842a158b0be8de8b4ae9b1d2f89a40d8ab
} 2>&1 | tee "$OUT"
