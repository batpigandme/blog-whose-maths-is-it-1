#!/usr/bin/env bash
# versions.sh: do two Node.js patch releases that carry the same V8 give the
# same Math answers, and what V8 does Node.js 26.13.1 carry? macOS or Linux;
# the committed output is from macOS arm64.
#
#   ./versions.sh                         prints to the terminal
#   OUT=outputs/versions.txt ./versions.sh   also writes the same text to a file
#
# Environment (defaults in brackets):
#   NVM_DIR        [$HOME/.nvm]                     where the Node.js versions are
#   NODE_VERSIONS  [24.19.0 24.22.3 26.13.1]        installed under $NVM_DIR/versions/node/
#   OFFLINE        [unset]                          set to skip the source files fetched from GitHub
#
# Part 1 runs each Node.js on math-control.js (7,820 Math calls printed as bits)
# and on probe.js, and compares the first two byte for byte. Part 2 reads each
# release's V8 version and embedder suffix from its own source, fetched from
# GitHub at the release's commit and checked against a sha256. Needs curl for
# part 2. Takes a few seconds.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NODE_VERSIONS="${NODE_VERSIONS:-24.19.0 24.22.3 26.13.1}"
SCRIPT="sin-demo/versions.sh"

# Release commits (the tag objects dereferenced with gh api repos/nodejs/node/git/tags/...),
# and the sha256 of the two files read at each.
commit_of() {
	case "$1" in
		24.19.0) echo cdc1b38d40cb567b7ad0b39c86addf830a0af0ae ;;
		24.22.3) echo e63cab040c09d43ceef8cb35508c40044614e906 ;;
		26.13.1) echo e9c277643b0249c50f6e6de5413be8a88ea11b6a ;;
	esac
}
sha_of() { # VERSION FILE
	case "$1:$2" in
		24.19.0:deps/v8/include/v8-version.h) echo 7a945b923eec649417fc366a50b1439af006869ca764f37d1d07be15eed47802 ;;
		24.19.0:common.gypi) echo 83a690f0991bb5d30fe27e638ad500fb97618de4956fd10127c7d0cf3157b871 ;;
		24.22.3:deps/v8/include/v8-version.h) echo 7a945b923eec649417fc366a50b1439af006869ca764f37d1d07be15eed47802 ;;
		24.22.3:common.gypi) echo 3c4090d3faf964998a89bad9e501cb4dac953ef9e03e9d03ede9812ae78161b2 ;;
		26.13.1:deps/v8/include/v8-version.h) echo ce7ce832371e2ffd6e56bd51f3b3f819262a01366074c660f6ea8e0d8e3b5ba3 ;;
		26.13.1:common.gypi) echo d8048c8c74dbc930646a6fadb55789e383179d137cc9fbc6c886afdf60b13454 ;;
	esac
}
sha256_of_file() {
	if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1; else sha256sum "$1" | cut -d' ' -f1; fi
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

report() {
	echo "# engines:  Node.js $NODE_VERSIONS"
	echo "# platform: $(platform_line)"
	echo "# obtained: Node.js from nvm; V8 version files from GitHub at each release's commit"
	echo "# date:     $(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "# script:   $SCRIPT"

	echo
	echo "## part 1: the same Math calls, release by release"
	local v node
	for v in $NODE_VERSIONS; do
		node="$NVM_DIR/versions/node/v$v/bin/node"
		"$node" "$HERE/math-control.js" >"$TMP/control-$v"
		"$node" "$HERE/probe.js" >"$TMP/probe-$v"
		echo "v$v: process.versions.v8 $("$node" -p process.versions.v8), binary sha256 $(sha16 "$node")"
		echo "  math-control.js: $(wc -l <"$TMP/control-$v" | tr -d ' ') lines, sha256 $(sha256_of_file "$TMP/control-$v")"
		echo "  probe.js: $(grep '^sin ' "$TMP/probe-$v")"
	done
	local first="" other
	for v in $NODE_VERSIONS; do
		if [ -z "$first" ]; then
			first="$v"
			continue
		fi
		other="$v"
		# Only releases that carry the same V8 version are compared as a
		# patch-release pair; the rest are listed above for reference.
		if [ "$("$NVM_DIR/versions/node/v$other/bin/node" -p 'process.versions.v8.split("-")[0]')" = \
			"$("$NVM_DIR/versions/node/v$first/bin/node" -p 'process.versions.v8.split("-")[0]')" ]; then
			echo "v$first against v$other (same V8 version, different embedder suffix):"
			if cmp -s "$TMP/control-$first" "$TMP/control-$other"; then
				echo "  math-control.js: identical (cmp)"
			else
				echo "  math-control.js: DIFFERENT"
			fi
			if cmp -s "$TMP/probe-$first" "$TMP/probe-$other"; then
				echo "  probe.js: identical (cmp)"
			else
				echo "  probe.js: DIFFERENT"
			fi
		fi
	done

	echo
	echo "## part 2: the V8 each release's own source names"
	if [ -n "${OFFLINE:-}" ]; then
		echo "skipped (OFFLINE is set)"
		return 0
	fi
	local c f got want maj min bld pat emb
	for v in $NODE_VERSIONS; do
		c="$(commit_of "$v")"
		[ -n "$c" ] || continue
		for f in deps/v8/include/v8-version.h common.gypi; do
			curl -sfL "https://raw.githubusercontent.com/nodejs/node/$c/$f" -o "$TMP/src-$v-$(basename "$f")"
			got="$(sha256_of_file "$TMP/src-$v-$(basename "$f")")"
			want="$(sha_of "$v" "$f")"
			if [ "$got" != "$want" ]; then
				echo "v$v $f at $c has sha256 $got, not the pinned $want; stopping" >&2
				return 1
			fi
		done
		maj="$(sed -n 's/^#define V8_MAJOR_VERSION //p' "$TMP/src-$v-v8-version.h")"
		min="$(sed -n 's/^#define V8_MINOR_VERSION //p' "$TMP/src-$v-v8-version.h")"
		bld="$(sed -n 's/^#define V8_BUILD_NUMBER //p' "$TMP/src-$v-v8-version.h")"
		pat="$(sed -n 's/^#define V8_PATCH_LEVEL //p' "$TMP/src-$v-v8-version.h")"
		emb="$(sed -n "s/^ *'v8_embedder_string': '\(.*\)',/\1/p" "$TMP/src-$v-common.gypi")"
		echo "v$v, commit $c: v8-version.h says $maj.$min.$bld.$pat; common.gypi v8_embedder_string '$emb'; together $maj.$min.$bld.$pat$emb"
	done
}

if [ -n "${OUT:-}" ]; then
	report 2>&1 | tee "$OUT"
else
	report 2>&1
fi
