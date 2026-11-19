#!/usr/bin/env bash
# lib.sh: small helpers shared by d8.sh, glibc.sh and versions.sh. Source it; don't run it.

# Where an output's header says the run happened: OS and version, arch, CPU if known.
# PLATFORM_LABEL, if set, names the environment and is printed first, before a
# semicolon (see lib/header.sh for the labels the committed outputs use).
platform_line() {
	local os cpu
	case "$(uname -s)" in
		Darwin)
			os="macOS $(sw_vers -productVersion)"
			cpu="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || true)"
			;;
		Linux)
			os="$(. /etc/os-release 2>/dev/null && printf '%s' "${PRETTY_NAME:-Linux}")"
			cpu="$(sed -n 's/^model name[[:space:]]*: //p' /proc/cpuinfo 2>/dev/null | head -1)"
			;;
		*)
			os="$(uname -sr)"
			cpu=""
			;;
	esac
	printf '%s%s, %s' "${PLATFORM_LABEL:+$PLATFORM_LABEL; }" "$os" "$(uname -m)"
	if [ -n "$cpu" ]; then
		printf ', %s' "$cpu"
	fi
}

# Absolute difference between two 16-digit hex float64 patterns of one sign, in
# ULP. Adjacent float64s of one sign have adjacent bit patterns.
ulp_dist() {
	local a=$((16#$1)) b=$((16#$2))
	if [ "$a" -gt "$b" ]; then
		echo $((a - b))
	else
		echo $((b - a))
	fi
}

# The first 16 hex digits of a file's sha256.
sha16() {
	if command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | cut -c1-16
	else
		sha256sum "$1" | cut -c1-16
	fi
}
