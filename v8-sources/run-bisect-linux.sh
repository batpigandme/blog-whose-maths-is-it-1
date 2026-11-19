#!/usr/bin/env bash
#
# run-bisect-linux.sh -- bisect.js on the published linux64 d8 builds, in an
# ubuntu:24.04 container.
#
#   ./v8-sources/run-bisect-linux.sh
#
# Starts a linux/amd64 container (emulated on an arm64 Mac), installs nodejs,
# curl, unzip, and ca-certificates from Ubuntu's apt, and runs
# `PLATFORM=linux64 node v8-sources/bisect.js` on the repository mounted at
# /repo. Writes v8-sources/results/bisect-linux64.txt.
#
# Environment (defaults):
#   IMAGE   container image (ubuntu:24.04)
#
# Needs Docker and network access. Downloads about 40 builds of about 20 MB
# each into the container; takes about 10 minutes under emulation.

set -euo pipefail
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "$HERE/.." && pwd )"
IMAGE="${IMAGE:-ubuntu:24.04}"
docker run --rm --platform linux/amd64 -v "$ROOT:/repo" -e CACHE_DIR=/tmp/cache -e PLATFORM_LABEL="${PLATFORM_LABEL:-}" "$IMAGE" bash -c '
	set -euo pipefail
	export DEBIAN_FRONTEND=noninteractive
	apt-get update -qq >/dev/null
	apt-get install -y -qq nodejs curl unzip ca-certificates >/dev/null 2>&1
	cd /repo
	PLATFORM=linux64 node v8-sources/bisect.js > /dev/null
'
