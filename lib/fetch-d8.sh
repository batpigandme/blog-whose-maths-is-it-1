#!/usr/bin/env bash
#
# fetch-d8.sh -- download a published d8 build from V8's build bucket, the same
# files jsvu installs, without installing anything.
#
#   ./lib/fetch-d8.sh VERSION [PLATFORM]        # prints the path to d8
#   ./lib/fetch-d8.sh 15.4.8                    # this machine's platform
#   ./lib/fetch-d8.sh 15.4.8 linux64
#
# VERSION is a V8 version such as 15.4.8. PLATFORM is mac-arm64, mac64,
# linux64 or win64 (default: this machine's mac-arm64, mac64 or linux64).
# The build is unpacked into <repo root>/.cache/d8/<platform>-<version>/ (or
# $CACHE_DIR/d8/...) and reused on later calls; its SHA-256 and the zip's are
# printed to standard error. Needs curl and unzip. Runs on macOS or Linux.
#
# The URL is https://storage.googleapis.com/chromium-v8/official/canary/
# v8-<platform>-rel-<version>.zip, which is where jsvu gets V8 (jsvu's
# `predict-url`). The bucket serves release builds by version number, so a
# given version's file does not change.

set -euo pipefail
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
CACHE_DIR="${CACHE_DIR:-$ROOT/.cache}"
VERSION="${1:?usage: fetch-d8.sh VERSION [PLATFORM]}"
if [ -n "${2:-}" ]; then
	PLATFORM="$2"
else
	case "$( uname -s )-$( uname -m )" in
		Darwin-arm64 ) PLATFORM=mac-arm64 ;;
		Darwin-x86_64 ) PLATFORM=mac64 ;;
		Linux-x86_64 ) PLATFORM=linux64 ;;
		* ) echo "no published d8 build for $( uname -s ) $( uname -m ); name a platform" >&2; exit 2 ;;
	esac
fi
sha256_of() { if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1; else shasum -a 256 "$1" | cut -d' ' -f1; fi; }
DEST="$CACHE_DIR/d8/$PLATFORM-$VERSION"
if [ ! -x "$DEST/d8" ]; then
	URL="https://storage.googleapis.com/chromium-v8/official/canary/v8-$PLATFORM-rel-$VERSION.zip"
	mkdir -p "$DEST"
	curl -sfo "$DEST.zip" "$URL" || { rm -rf "$DEST" "$DEST.zip"; echo "no build at $URL" >&2; exit 1; }
	unzip -q -o "$DEST.zip" -d "$DEST"
	chmod +x "$DEST/d8"
	echo "zip sha256 $( sha256_of "$DEST.zip" )" >&2
	rm -f "$DEST.zip"
fi
echo "d8 $VERSION $PLATFORM sha256 $( sha256_of "$DEST/d8" )" >&2
echo "$DEST/d8"
