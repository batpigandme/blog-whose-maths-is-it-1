// tan-pair.js -- Math.tan of one input, printed as raw bits.
//
//   mqjs fma-contraction/tan-pair.js
//
// The input is 0xc0322052fd59ea32 (about -18.03). ES5, no host APIs beyond
// `print` or `console.log`, so it runs on MicroQuickJS, d8 and Node.js.
var out = ( typeof print === 'function' ) ? print : console.log;
var F = new Float64Array( 1 );
var U = new Uint32Array( F.buffer );

function pad8( n ) {
	var s = n.toString( 16 );
	while ( s.length < 8 ) {
		s = '0' + s;
	}
	return s;
}
U[ 1 ] = 0xc0322052;
U[ 0 ] = 0xfd59ea32;
var x = F[ 0 ];
F[ 0 ] = Math.tan( x );
out( 'Math.tan c0322052fd59ea32 ' + pad8( U[ 1 ] ) + pad8( U[ 0 ] ) );
