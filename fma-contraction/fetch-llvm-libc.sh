#!/usr/bin/env bash
#
# fetch-llvm-libc.sh -- check out LLVM libc at the revision V8 15.4.8 vendors.
# Prints the checkout's path.
#
#   ./fma-contraction/fetch-llvm-libc.sh
#
# Environment (defaults):
#   LIBC_SHA   commit of Chromium's mirror of llvm-project's libc directory
#              (6fd5620cc4fd3c55ee749e9bf71f52038431f76d, the revision in V8
#              15.4.8's DEPS for third_party/llvm-libc/src)
#   CACHE_DIR  <repo root>/.cache
#
# A blobless clone of https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libc.git,
# about 75 MB, so that only the files the build reads are downloaded. Needs
# git and network access. macOS or Linux.

set -euo pipefail
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
LIBC_SHA="${LIBC_SHA:-6fd5620cc4fd3c55ee749e9bf71f52038431f76d}"
CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
DEST="$CACHE_DIR/llvm-libc-${LIBC_SHA:0:12}"
if [ ! -d "$DEST/.git" ]; then
	git clone -q --filter=blob:none --no-checkout https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libc.git "$DEST"
fi
git -C "$DEST" checkout -q "$LIBC_SHA"
got="$( git -C "$DEST" rev-parse HEAD )"
[ "$got" = "$LIBC_SHA" ] || { echo "checked out $got, expected $LIBC_SHA" >&2; exit 1; }
echo "$DEST"
