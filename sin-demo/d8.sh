#!/usr/bin/env bash
# d8.sh: Math.sin on one input in d8 and Node.js, compared with the correctly
# rounded value. macOS or Linux; the committed output is from macOS arm64.
#
#   ./d8.sh                          prints to the terminal
#   OUT=outputs/d8-mac.txt ./d8.sh   also writes the same text to a file
#
# Environment (defaults in brackets):
#   JSVU_HOME     [$HOME/.jsvu]      jsvu's directory; d8 builds are under engines/
#   JSVU_BIN      [$JSVU_HOME/bin]   jsvu's wrapper scripts, v8-<version>
#   D8_VERSIONS   [13.6.233 14.6.202 15.8.32]  d8 builds run default and with the flag
#   RUNS          [2]                runs of each configuration
#   NVM_DIR       [$HOME/.nvm]       where Node.js comes from
#   NODE_VERSION  [24.19.0]          the Node.js to run beside d8
#   NODE          [$NVM_DIR/versions/node/v$NODE_VERSION/bin/node]
#
# It needs the jsvu d8 builds (npm install -g jsvu; jsvu --engines=v8@13.6.233
# and so on) and Node.js 24.19.0, and takes a few seconds.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

JSVU_HOME="${JSVU_HOME:-$HOME/.jsvu}"
JSVU_BIN="${JSVU_BIN:-$JSVU_HOME/bin}"
D8_VERSIONS="${D8_VERSIONS:-13.6.233 14.6.202 15.8.32}"
RUNS="${RUNS:-2}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NODE_VERSION="${NODE_VERSION:-24.19.0}"
NODE="${NODE:-$NVM_DIR/versions/node/v$NODE_VERSION/bin/node}"
PROBE="$HERE/probe.js"
SCRIPT="sin-demo/d8.sh"

# glibc 2.39's bits for this input: the value in outputs/glibc-*.txt.
GLIBC=3cbb779ceaa3bc42
INPUT=5c99c487f2337e3a
CORRECT="$(python3 -I "$HERE/reference.py" "$INPUT" | sed 's/.* sin=//')"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# run LABEL CMD...: run the probe, print its lines prefixed with LABEL, and
# keep the sin bits for the table at the end. A non-zero exit is recorded and
# the run goes on, so one build that refuses a flag doesn't hide the others.
run() {
	local label="$1" o rc=0
	shift
	o="$("$@" "$PROBE" </dev/null 2>&1)" || rc=$?
	printf '%s\n' "$o" | sed "s|^|$label: |"
	if [ "$rc" -ne 0 ]; then
		echo "$label: exit $rc"
		return 0
	fi
	printf '%s\n' "$o" | awk '$1 == "sin" { print $2 }' >"$TMP/$label"
}

report() {
	local node_v
	node_v="$("$NODE" -p process.versions.v8)"
	{
		echo "# engines:  d8 $D8_VERSIONS; Node.js $("$NODE" -v) (V8 $node_v)"
		echo "# platform: $(platform_line)"
		echo "# obtained: d8 from jsvu; Node.js from nvm"
		echo "# date:     $(date -u +%Y-%m-%dT%H:%M:%SZ)"
		echo "# script:   $SCRIPT"
		echo "# input $INPUT, 1.1986535513718587e+138"
		echo "# correctly rounded $CORRECT (reference.py); glibc 2.39 $GLIBC"
		for v in $D8_VERSIONS; do
			local wrapper="$JSVU_BIN/v8-$v" bin="$JSVU_HOME/engines/v8-$v/v8-$v"
			echo
			echo "## d8 $v: version() says $("$wrapper" -e 'print(version())' </dev/null 2>&1), binary sha256 $(sha16 "$bin")"
			local helped
			helped="$("$bin" --help </dev/null 2>&1 | grep -A1 -e '--use-libm-trig-functions' | head -2 || true)"
			if [ -n "$helped" ]; then
				printf '%s\n' "$helped" | sed 's/^/help: /'
			else
				echo "help: this build's --help doesn't list use-libm-trig-functions, so the flagoff runs below are default runs"
			fi
			for i in $(seq 1 "$RUNS"); do
				run "$v-default-$i" "$wrapper"
				run "$v-flagoff-$i" "$wrapper" --no-use-libm-trig-functions
			done
		done
		echo
		echo "## Node.js $("$NODE" -v): V8 $node_v, binary sha256 $(sha16 "$NODE")"
		for i in $(seq 1 "$RUNS"); do
			run "node-$i" "$NODE"
		done
		echo
		echo "## distances, in ULP"
		printf '%-20s %-18s %12s %12s\n' run sin from-correct from-glibc
		local f b
		for f in "$TMP"/*; do
			b="$(cat "$f")"
			printf '%-20s %-18s %12s %12s\n' "$(basename "$f")" "$b" "$(ulp_dist "$b" "$CORRECT")" "$(ulp_dist "$b" "$GLIBC")"
		done
	}
}

if [ -n "${OUT:-}" ]; then
	report 2>&1 | tee "$OUT"
else
	report 2>&1
fi
