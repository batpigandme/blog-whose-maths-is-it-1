#!/usr/bin/env bash
#
# header.sh -- the metadata header every committed output starts with.
# Source it, then call:
#
#   . lib/header.sh
#   emit_header "<engine name and version or commit>" "<how it got onto the machine>" "<repo-relative script path>"
#
# Prints five comment lines:
#
#   # engine:   ...
#   # platform: <OS and version>, <arch>, <CPU if known>
#   # obtained: ...
#   # date:     <UTC ISO 8601>
#   # script:   ...
#
# Works on macOS and Linux. For a container, the platform line says what the
# container reports; under emulation the CPU line says so (it names the
# virtual CPU, not the host's).

# platform_string: "<OS and version>, <arch>[, <CPU>]".
platform_string() {
	local os cpu
	if [ "$( uname -s )" = Darwin ]; then
		os="$( sw_vers -productName ) $( sw_vers -productVersion )"
		cpu="$( sysctl -n machdep.cpu.brand_string 2>/dev/null || true )"
	else
		os="$( . /etc/os-release 2>/dev/null && echo "${PRETTY_NAME:-Linux}" || echo Linux )"
		cpu="$( sed -n 's/^model name[[:space:]]*: *//p' /proc/cpuinfo 2>/dev/null | head -1 )"
		[ -n "$cpu" ] || cpu="$( sed -n 's/^Hardware[[:space:]]*: *//p' /proc/cpuinfo 2>/dev/null | head -1 )"
	fi
	printf '%s, %s%s' "$os" "$( uname -m )" "${cpu:+, $cpu}"
}

emit_header() {
	local engine="$1" obtained="$2" script="$3"
	printf '# engine:   %s\n' "$engine"
	printf '# platform: %s\n' "$( platform_string )"
	printf '# obtained: %s\n' "$obtained"
	printf '# date:     %s\n' "$( date -u +%Y-%m-%dT%H:%M:%SZ )"
	printf '# script:   %s\n' "$script"
}
