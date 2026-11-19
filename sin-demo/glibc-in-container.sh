#!/usr/bin/env bash
# glibc-in-container.sh: runs inside the Ubuntu container that glibc.sh starts.
# Not meant to be run by hand. It expects /src (this folder, read-only), /build
# (a persistent volume for the glibc builds), and these variables from glibc.sh:
# MAIN_IN, MAIN_REF, CTRL_IN, CTRL_REF, IMAGE, PINS, JOBS, SCRIPT.
set -euo pipefail

# shellcheck source=lib.sh
. /src/lib.sh

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -y -qq --no-install-recommends build-essential gawk bison python3 git ca-certificates file >/dev/null

EXE=/tmp/sin-check
gcc -O0 -fno-builtin -Wall -o "$EXE" /src/sin-check.c -lm -ldl

ARCH="$(uname -m)"
echo "# engines:  glibc $(ldd --version | head -1 | sed 's/.* //') (system, package libc6 $(dpkg-query -W -f='${Version}' libc6))"
for pin in $PINS; do
	echo "#           glibc ${pin%%=*} (built from tag glibc-${pin%%=*}, commit ${pin##*=})"
done
echo "# platform: $(platform_line), in a container"
echo "# obtained: system glibc from apt in image $IMAGE; the others built from https://sourceware.org/git/glibc.git at the commit named, checked after cloning"
echo "# date:     $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "# script:   $SCRIPT"
echo "# gcc: $(gcc --version | head -1)"
if [ "$ARCH" = x86_64 ]; then
	echo "# cpu flags: $(grep -m1 '^flags' /proc/cpuinfo | tr ' ' '\n' | grep -xE 'fma|avx2|avx|fma4' | tr '\n' ' ')"
fi
echo "# correctly rounded (reference.py, on the host): main in=$MAIN_IN sin=$MAIN_REF; control in=$CTRL_IN sin=$CTRL_REF"

run() { # LABEL, then the command prefix
	local label="$1" in
	shift
	for in in "$MAIN_IN" "$CTRL_IN"; do
		printf '%-30s ' "$label"
		"$@" "$EXE" "$in"
	done
}

echo
echo "## system glibc"
run "system default" env -u GLIBC_TUNABLES
if [ "$ARCH" = x86_64 ]; then
	run "system -AVX2,-FMA" env GLIBC_TUNABLES=glibc.cpu.hwcaps=-AVX2,-FMA
	run "system -AVX,-AVX2,-FMA" env GLIBC_TUNABLES=glibc.cpu.hwcaps=-AVX,-AVX2,-FMA
fi

for pin in $PINS; do
	v="${pin%%=*}"
	want="${pin##*=}"
	src="/build/src-$v"
	bld="/build/build-$v"
	if [ ! -x "$bld/testrun.sh" ] || [ ! -e "$bld/.built-$want" ]; then
		rm -rf "$src" "$bld"
		git clone -q --depth 1 --branch "glibc-$v" https://sourceware.org/git/glibc.git "$src" >&2
		got="$(git -C "$src" rev-parse HEAD)"
		if [ "$got" != "$want" ]; then
			echo "tag glibc-$v is at $got, not the pinned $want; stopping" >&2
			exit 1
		fi
		mkdir -p "$bld"
		(cd "$bld" && "$src/configure" --prefix="/opt/glibc-$v" --disable-werror --disable-nscd --disable-mathvec >&2 && make -j"$JOBS" >&2)
		touch "$bld/.built-$want"
	fi
	echo
	echo "## glibc $v, tag glibc-$v, commit $want"
	run "$v default" env -u GLIBC_TUNABLES "$bld/testrun.sh"
	if [ "$ARCH" = x86_64 ]; then
		run "$v -AVX2,-FMA" env GLIBC_TUNABLES=glibc.cpu.hwcaps=-AVX2,-FMA "$bld/testrun.sh"
		run "$v -AVX,-AVX2,-FMA" env GLIBC_TUNABLES=glibc.cpu.hwcaps=-AVX,-AVX2,-FMA "$bld/testrun.sh"
		echo "# sin variants in this build (nm):"
		nm "$bld/math/libm.so" | grep -E ' t __sin_(sse2|avx|fma|fma4)$' | sed 's/^/#   /'
	fi
done
