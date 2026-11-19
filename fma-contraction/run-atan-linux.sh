#!/usr/bin/env bash
#
# run-atan-linux.sh -- the Linux half of run-atan-mac.sh, in containers.
#
#   ./fma-contraction/run-atan-linux.sh
#
# Runs in-container-atan.sh in an ubuntu:24.04 container twice: linux/amd64
# (baseline x86_64, where LLVM libc's atan takes its non-fused path, and the
# same source built with -mavx2 -mfma takes its fused path; then the published
# Linux d8 builds 14.6.202, 15.4.8 and 15.8.32 on the same cases) and
# linux/arm64 (where the default build is fused). Writes
# results/atan-linux-x86_64.txt and results/atan-linux-aarch64.txt.
#
# Environment (defaults):
#   IMAGE     container image (ubuntu:24.04)
#   OUT_DIR   output directory (fma-contraction/results)
#
# Needs Docker, git, node and network access. On an arm64 Mac the amd64
# container is emulated, so its `fma` build may fail to run (the output says
# whether it did); the arm64 container is native. Takes about 10 minutes.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
export CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
IMAGE="${IMAGE:-ubuntu:24.04}"
OUT_DIR="${OUT_DIR:-$HERE/results}"

STDLIB_DIR="$( "$ROOT/lib/fetch-stdlib-fixtures.sh" )"; export STDLIB_DIR
node "$ROOT/lib/gen-cases.js" --check >/dev/null || { echo "cases differ from lib/cases.sha256" >&2; exit 1; }
"$HERE/fetch-llvm-libc.sh" >/dev/null

for p in linux/amd64:x86_64 linux/arm64:aarch64; do
	docker run --rm --platform "${p%%:*}" -v "$ROOT:/repo" \
		-e OUT=/repo/"${OUT_DIR#"$ROOT"/}/atan-linux-${p##*:}.txt" \
		-e IMAGE_ID="$( docker image inspect "$IMAGE" --format '{{index .RepoDigests 0}}' 2>/dev/null || echo "$IMAGE" )" \
		"$IMAGE" bash /repo/fma-contraction/in-container-atan.sh
done
