/**
* driver.js -- evaluate every case in the global string CASES and print the
* result as a raw bit pattern. ECMAScript 5, no host APIs beyond `print` or
* `console.log`, so the same file runs unchanged on MicroQuickJS, d8 and
* Node.js.
*
* CASES is prepended by lib/run-cases.sh: lines of
* `<fn> <x hex> [<y hex>] <fixture>`. Output, one line per case:
* `<fn> <x hex> [<y hex>] <result hex>`.
*
* erf, gamma and log1p are not part of `Math`; when the globals `erf`, `gamma`
* and `log1p` exist (fma-contraction/stdlib-fns.js defines them, from stdlib's
* published packages), their cases are evaluated, and otherwise skipped.
*
* Bits move through a Float64Array aliased by a Uint32Array, never through a
* decimal string, so formatting can neither hide a difference nor invent one.
* Both engines tested are little-endian (word 1 is the high word).
*/
var out = ( typeof print === 'function' ) ? print : console.log;
var F = new Float64Array( 1 );
var U = new Uint32Array( F.buffer );

var UNARY = {
	'Math.exp': Math.exp,
	'Math.log': Math.log,
	'Math.sin': Math.sin,
	'Math.cos': Math.cos,
	'Math.tan': Math.tan,
	'Math.asin': Math.asin,
	'Math.acos': Math.acos,
	'Math.atan': Math.atan,
	'Math.sqrt': Math.sqrt,
	'Math.log2': Math.log2,
	'Math.log10': Math.log10,
	'Math.fround': Math.fround
};
if ( typeof erf === 'function' ) {
	UNARY.erf = erf;
}
if ( typeof gamma === 'function' ) {
	UNARY.gamma = gamma;
}
if ( typeof log1p === 'function' ) {
	UNARY.log1p = log1p;
}

function pad8( n ) {
	var s = n.toString( 16 );
	while ( s.length < 8 ) {
		s = '0' + s;
	}
	return s;
}
function fromHex( h ) {
	U[ 1 ] = parseInt( h.substring( 0, 8 ), 16 );
	U[ 0 ] = parseInt( h.substring( 8, 16 ), 16 );
	return F[ 0 ];
}
function toHex( v ) {
	F[ 0 ] = v;
	return pad8( U[ 1 ] ) + pad8( U[ 0 ] );
}

var start = 0;
var end;
var line;
var parts;
var fn;
while ( start < CASES.length ) {
	end = CASES.indexOf( '\n', start );
	if ( end < 0 ) {
		end = CASES.length;
	}
	line = CASES.substring( start, end );
	start = end + 1;
	if ( line.length === 0 ) {
		continue;
	}
	parts = line.split( ' ' );
	fn = parts[ 0 ];
	if ( fn === 'Math.atan2' ) {
		// The fixture fields are x and y, and the fixture is atan(y, x).
		out( fn + ' ' + parts[ 1 ] + ' ' + parts[ 2 ] + ' ' + toHex( Math.atan2( fromHex( parts[ 2 ] ), fromHex( parts[ 1 ] ) ) ) );
	} else if ( fn === 'Math.pow' ) {
		// The fixture is x^y.
		out( fn + ' ' + parts[ 1 ] + ' ' + parts[ 2 ] + ' ' + toHex( Math.pow( fromHex( parts[ 1 ] ), fromHex( parts[ 2 ] ) ) ) );
	} else if ( UNARY[ fn ] ) {
		out( fn + ' ' + parts[ 1 ] + ' ' + toHex( UNARY[ fn ]( fromHex( parts[ 1 ] ) ) ) );
	}
}
