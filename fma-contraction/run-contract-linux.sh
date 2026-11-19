#!/usr/bin/env bash
#
# run-contract-linux.sh -- MicroQuickJS's libm.c under GCC on Ubuntu 24.04
# x86_64, in a container, with GCC's default flags.
#
#   ./fma-contraction/run-contract-linux.sh          # from a Mac or Linux host
#
# Starts a linux/amd64 ubuntu:24.04 container with Docker, installs gcc, make
# and nodejs from Ubuntu's own packages, builds MicroQuickJS at the pinned
# commit with the Makefile's flags (GCC 13.3.0 uses -ffp-contract=fast by
# default, and baseline x86_64 has no fused multiply-add instruction to fuse
# into), runs the `tan` input and every case (17 functions, 392,083 cases), and
# prints a hash of each function's result column. The output goes to $OUT.
#
# Environment (defaults):
#   OUT      output file (fma-contraction/results/contract-linux-x86_64.txt)
#   IMAGE    container image (ubuntu:24.04)
#   PLATFORM docker platform (linux/amd64)
#
# On an arm64 Mac the container is emulated (the CPU line of the output says
# VirtualApple). GCC for baseline x86_64 emits only SSE2 double arithmetic,
# which an emulator reproduces exactly; the output's last section compares the
# result hashes with those of a run on a real x86_64 machine. Needs Docker, git,
# node and npm on the host (to prepare the cases and the stdlib bundle), and
# network access. Takes about 10 minutes.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
export CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
IMAGE="${IMAGE:-ubuntu:24.04}"
PLATFORM="${PLATFORM:-linux/amd64}"
OUT="${OUT:-$HERE/results/contract-linux-x86_64.txt}"

# Prepare on the host what needs no container: the sources, cases and bundle.
"$HERE/fetch-mquickjs.sh" >/dev/null
STDLIB_DIR="$( "$ROOT/lib/fetch-stdlib-fixtures.sh" )"
export STDLIB_DIR
node "$ROOT/lib/gen-cases.js" --check >/dev/null || { echo "cases differ from lib/cases.sha256" >&2; exit 1; }
"$HERE/build-stdlib-fns.sh" >/dev/null

# The mounts: the repository at /repo, where the container writes the cache and
# its output. Paths inside the container never reach the output.
docker run --rm --platform "$PLATFORM" -v "$ROOT:/repo" -e OUT=/repo/"${OUT#"$ROOT"/}" \
	-e IMAGE_ID="$( docker image inspect "$IMAGE" --format '{{index .RepoDigests 0}}' 2>/dev/null || echo "$IMAGE" )" \
	"$IMAGE" bash /repo/fma-contraction/in-container-linux.sh
