// math-control.js: the engine's own Math functions on fixed inputs, printed as
// raw float64 bit patterns, so that two runs can be compared byte for byte.
//
// Used by versions.sh as a control: if two Node.js patch releases print the
// same bytes here, their Math functions agree on all of these inputs.
//
// ES5 plus typed arrays, no imports. Hex comes from 4-bit groups rather than
// Number.prototype.toString(16), so the output doesn't depend on any engine's
// number formatting. A function an engine lacks prints "<fn> absent" once
// instead of throwing. Inputs are fixed edge cases plus a xorshift32 sweep per
// function using integer operators only, so every engine generates the same
// doubles.

var out = ( typeof print === 'function' ) ? print : console.log;

var F64 = new Float64Array( 1 );
var U32 = new Uint32Array( F64.buffer );
var LE = ( new Uint8Array( new Uint16Array( [ 1 ] ).buffer ) )[ 0 ] === 1;
var HI = ( LE ) ? 1 : 0;
var LO = ( LE ) ? 0 : 1;
var HEX = '0123456789abcdef';

function hex8( n ) {
	var s = '';
	var k;
	for ( k = 28; k >= 0; k -= 4 ) {
		s += HEX.charAt( ( n >>> k ) & 15 );
	}
	return s;
}

function bits( x ) {
	F64[ 0 ] = x;
	return hex8( U32[ HI ] ) + hex8( U32[ LO ] );
}

var state = 2463534242;
function next() {
	state ^= state << 13;
	state ^= state >>> 17;
	state ^= state << 5;
	state >>>= 0;
	return state;
}
function uniform() {
	var a = next() >>> 5;
	var b = next() >>> 6;
	return ( ( a * 67108864 ) + b ) / 9007199254740992;
}

var N = 300;
var EDGE = [ 0, -0, NaN, 1 / 0, -1 / 0, 5e-324, 1e-300, 1e-10, 0.5, 1, 2, 3, 10, 100, 1e10, 1e300, -0.5, -1, -2, -100 ];

// Name, then the lower and upper bounds of the sweep.
var UN = [
	'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'sinh', 'cosh', 'tanh', 'asinh', 'acosh',
	'atanh', 'exp', 'expm1', 'log', 'log1p', 'log2', 'log10', 'sqrt', 'cbrt', 'fround'
];
var ULO = [ -10, -10, -10, -1, -1, -10, -20, -20, -20, -100, 1, -1, -50, -5, 0, -1, 0, 0, 0, -1000, -1000 ];
var UHI = [ 10, 10, 10, 1, 1, 10, 20, 20, 20, 100, 100, 1, 50, 5, 1000, 10, 1000, 1000, 1000, 1000, 1000 ];

// Binary functions: name, then the x bounds and the y bounds.
var BN = [ 'pow', 'atan2', 'hypot' ];
var BXL = [ 0, -10, -100 ];
var BXH = [ 10, 10, 100 ];
var BYL = [ -20, -10, -100 ];
var BYH = [ 20, 10, 100 ];

var i;
var j;
var f;
var x;
var y;
var count = 0;
for ( i = 0; i < UN.length; i++ ) {
	f = Math[ UN[ i ] ];
	if ( typeof f !== 'function' ) {
		out( UN[ i ] + ' absent' );
		continue;
	}
	for ( j = 0; j < EDGE.length; j++ ) {
		out( UN[ i ] + ' ' + bits( EDGE[ j ] ) + ' ' + bits( f( EDGE[ j ] ) ) );
		count += 1;
	}
	for ( j = 0; j < N; j++ ) {
		x = ULO[ i ] + ( uniform() * ( UHI[ i ] - ULO[ i ] ) );
		out( UN[ i ] + ' ' + bits( x ) + ' ' + bits( f( x ) ) );
		count += 1;
	}
}
for ( i = 0; i < BN.length; i++ ) {
	f = Math[ BN[ i ] ];
	if ( typeof f !== 'function' ) {
		out( BN[ i ] + ' absent' );
		continue;
	}
	for ( j = 0; j < N; j++ ) {
		x = BXL[ i ] + ( uniform() * ( BXH[ i ] - BXL[ i ] ) );
		y = BYL[ i ] + ( uniform() * ( BYH[ i ] - BYL[ i ] ) );
		out( BN[ i ] + ' ' + bits( x ) + ' ' + bits( y ) + ' ' + bits( f( x, y ) ) );
		count += 1;
	}
}
// Integer exponents, where one engine's pow was found many units off.
for ( i = 0; i < 200; i++ ) {
	x = uniform() * 10;
	y = ( next() % 41 ) - 20;
	out( 'pow ' + bits( x ) + ' ' + bits( y ) + ' ' + bits( Math.pow( x, y ) ) );
	count += 1;
}
out( 'cases ' + count );
