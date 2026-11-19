/*
 * glibc-copy-harness.c -- V8's vendored glibc sin and cos, compiled here.
 * Run by v8-sources/check.sh.
 *
 * Links against V8's own copy of the glibc files (third_party/glibc at
 * 13.6.233.17, fetched by the script at a pinned commit) and calls the two
 * functions V8 calls, glibc_sin and glibc_cos. Reads a case file (the format
 * lib/gen-cases.js writes) and prints `<x hex> <result hex>`, like
 * probe.js. If d8's default column matches this one, d8's sin and cos are
 * this code. Runs on macOS or Linux.
 */
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "trig.h"

static double from( const char *h ) {
	uint64_t u;
	double d;
	sscanf( h, "%16llx", (unsigned long long *)&u );
	memcpy( &d, &u, 8 );
	return d;
}

static void hex( double d ) {
	uint64_t u;
	memcpy( &u, &d, 8 );
	printf( "%016llx\n", (unsigned long long)u );
}

int main( int argc, char **argv ) {
	char fn[ 32 ], a[ 32 ];
	char line[ 256 ];
	FILE *f;
	if ( argc < 2 ) {
		return 2;
	}
	f = fopen( argv[ 1 ], "r" );
	if ( !f ) {
		return 2;
	}
	while ( fgets( line, sizeof line, f ) ) {
		if ( sscanf( line, "%31s %31s", fn, a ) != 2 ) {
			continue;
		}
		printf( "%s ", a );
		if ( !strcmp( fn, "Math.sin" ) ) {
			hex( glibc_sin( from( a ) ) );
		} else if ( !strcmp( fn, "Math.cos" ) ) {
			hex( glibc_cos( from( a ) ) );
		} else {
			return 3;
		}
	}
	return 0;
}
