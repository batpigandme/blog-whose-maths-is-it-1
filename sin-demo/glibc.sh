#!/usr/bin/env bash
# glibc.sh: sin on one input through glibc 2.39 (Ubuntu 24.04's package) and
# glibc 2.43 and 2.44 built from source, in Docker containers. Runs on any host
# with Docker (macOS or Linux). The committed regenerated outputs are from
# OrbStack on macOS; the captured x86_64 output came from a Claude Code Cloud
# x86_64 VM.
#
#   ./glibc.sh                                  prints to the terminal
#   OUT=outputs/glibc-arm64.txt ./glibc.sh      also writes the same text to a file
#
# Environment (defaults in brackets):
#   DOCKER      [docker]           the Docker CLI
#   PLATFORM    [linux/arm64]     the container platform; use
#                                  linux/amd64 for x86_64 (emulated on an Apple
#                                  silicon Mac, so no FMA or AVX2 variants run)
#   JOBS        [8]                make -j for the glibc builds
#
# It needs network access (apt, and git clone from sourceware.org), about 1.5 GB
# of disk per platform for the builds, and takes about 3 minutes the first time on an M1 Pro for two
# glibc builds; the builds are kept in a Docker volume, so a rerun takes about 30 seconds.
# One platform per call; run it again for another.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER="${DOCKER:-docker}"
PLATFORM="${PLATFORM:-linux/arm64}"
JOBS="${JOBS:-8}"

# Base image, by the digest of the multi-platform index (checked 2026-11-19).
IMAGE="ubuntu:24.04@sha256:73b999393d07f2bf65a40373778a44dc9a6d54ad7718d29247d8ff9413c4d6a8"
# glibc release tags, by the commit each one points at (git ls-remote on
# sourceware.org, 2026-11-19, annotated tags dereferenced). The container
# checks the clone against these. The 2.39 commit is also
# https://github.com/bminor/glibc/commit/ef321e23c20eebc6d6fb4044425c00e6df27b05f
# (tag glibc-2.39); the GitHub mirror has no 2.43 or 2.44 tag.
PINS="2.43=f762ccf84f122d1354f103a151cba8bde797d521 2.44=c3a3a9808ad3ab4a3336836833f83288b672ccbf"
MAIN_IN=5c99c487f2337e3a    # 1.1986535513718587e+138
CTRL_IN=6414c96c11134d36    # 0x1.4c96c11134d36p+578, the example in glibc bug 34376
SCRIPT="sin-demo/glibc.sh"

ref() { python3 -I "$HERE/reference.py" "$1" | sed 's/.* sin=//'; }
MAIN_REF="$(ref "$MAIN_IN")"
CTRL_REF="$(ref "$CTRL_IN")"
VOLUME="glibc-sin-demo-build-${PLATFORM#linux/}"

run_it() {
	"$DOCKER" run --rm --platform "$PLATFORM" \
		-v "$HERE:/src:ro" -v "$VOLUME:/build" \
		-e MAIN_IN="$MAIN_IN" -e MAIN_REF="$MAIN_REF" -e CTRL_IN="$CTRL_IN" -e CTRL_REF="$CTRL_REF" \
		-e IMAGE="$IMAGE" -e PINS="$PINS" -e JOBS="$JOBS" -e SCRIPT="$SCRIPT" \
		"$IMAGE" bash /src/glibc-in-container.sh
}

if [ -n "${OUT:-}" ]; then
	run_it | tee "$OUT"
else
	run_it
fi
