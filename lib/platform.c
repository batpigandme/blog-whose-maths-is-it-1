/*
 * platform.c -- the same cases through the C library, as one more column.
 *
 *   cc -O2 -fno-builtin -o platform lib/platform.c && ./platform .cache/cases/Math.sin.txt
 *
 * Reads a case file (see lib/gen-cases.js) and prints
 * `<fn> <x hex> [<y hex>] <result hex>` like the JavaScript driver, computing
 * each value with <math.h>. Its point is attribution: if an engine's bits match
 * this column on every input, that engine is, measurably, calling this
 * platform's library. erf, gamma (tgamma) and log1p here are the C library's
 * own functions. -fno-builtin keeps the compiler from substituting its own
 * versions. Runs on macOS or Linux.
 */
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

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
	char fn[ 32 ], a[ 32 ], b[ 32 ], c[ 32 ];
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
		int n = sscanf( line, "%31s %31s %31s %31s", fn, a, b, c );
		if ( !strcmp( fn, "Math.atan2" ) ) {
			// The fixture fields are x and y, and the fixture is atan(y, x).
			printf( "%s %s %s ", fn, a, b ); hex( atan2( from( b ), from( a ) ) );
			continue;
		}
		if ( !strcmp( fn, "Math.pow" ) ) {
			printf( "%s %s %s ", fn, a, b ); hex( pow( from( a ), from( b ) ) );
			continue;
		}
		(void)n;
		double x = from( a ), r;
		if ( !strcmp( fn, "erf" ) ) r = erf( x );
		else if ( !strcmp( fn, "gamma" ) ) r = tgamma( x );
		else if ( !strcmp( fn, "log1p" ) ) r = log1p( x );
		else if ( !strcmp( fn, "Math.exp" ) ) r = exp( x );
		else if ( !strcmp( fn, "Math.log" ) ) r = log( x );
		else if ( !strcmp( fn, "Math.sin" ) ) r = sin( x );
		else if ( !strcmp( fn, "Math.cos" ) ) r = cos( x );
		else if ( !strcmp( fn, "Math.tan" ) ) r = tan( x );
		else if ( !strcmp( fn, "Math.asin" ) ) r = asin( x );
		else if ( !strcmp( fn, "Math.acos" ) ) r = acos( x );
		else if ( !strcmp( fn, "Math.atan" ) ) r = atan( x );
		else if ( !strcmp( fn, "Math.sqrt" ) ) r = sqrt( x );
		else if ( !strcmp( fn, "Math.log2" ) ) r = log2( x );
		else if ( !strcmp( fn, "Math.log10" ) ) r = log10( x );
		else if ( !strcmp( fn, "Math.fround" ) ) r = (double)(float)x;
		else return 3;
		printf( "%s %s ", fn, a ); hex( r );
	}
	return 0;
}
