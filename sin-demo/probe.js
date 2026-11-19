// probe.js: one input through Math.sin, printed as raw bits and as a decimal.
//
// Runs unchanged in d8 (V8's own shell, which has print) and in Node.js. The
// input is the one in Chromium bug 511271840, set from its bits so that no
// number parser can move it: 5c99c487f2337e3a, 1.1986535513718587e+138.
var out = ( typeof print === 'function' ) ? print : console.log;
var f = new Float64Array( 1 );
var u = new Uint32Array( f.buffer );

function hex8( x ) {
	var s = x.toString( 16 );
	while ( s.length < 8 ) {
		s = '0' + s;
	}
	return s;
}

// Big-endian hex of the float64, assuming a little-endian host (true of arm64
// and x86_64, the only platforms this repo's scripts target).
function bits( x ) {
	f[ 0 ] = x;
	return hex8( u[ 1 ] ) + hex8( u[ 0 ] );
}

u[ 1 ] = 0x5c99c487;
u[ 0 ] = 0xf2337e3a;
var input = f[ 0 ];
if ( input !== 1.1986535513718587e+138 ) {
	throw new Error( 'input bits do not parse back to the decimal' );
}
var result = Math.sin( input );
out( 'input ' + bits( input ) + ' ' + input );
out( 'sin ' + bits( result ) + ' ' + result );
