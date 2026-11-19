// probe.js -- one case file through Math, printed as raw bits.
// Run by v8-sources/check.sh.
//
//   d8 v8-sources/probe.js -- .cache/cases/Math.sin.txt
//   node v8-sources/probe.js .cache/cases/Math.sin.txt
//
// Reads a case file (`Math.<fn> <x hex> [<y hex>] <reference hex>`, the format
// lib/gen-cases.js writes) and prints `<x hex> [<y hex>] <result hex>` per case,
// the same shape as lib/platform.c without its function-name field, so the
// columns diff line for line. Handles sin, cos, tan and pow. Works in d8
// (`read`, `arguments`, `print`) and in Node.js (`fs`, `argv`).
var isNode = ( typeof process === 'object' && process.versions && process.versions.node );
var path = isNode ? process.argv[ 2 ] : arguments[ 0 ];
var text = isNode ? require( 'fs' ).readFileSync( path, 'utf8' ) : read( path );
var emit = isNode ? function emit( s ) { process.stdout.write( s + '\n' ); } : print;

var f = new Float64Array( 1 );
var u = new Uint32Array( f.buffer );

function hex8( x ) {
	var s = x.toString( 16 );
	while ( s.length < 8 ) {
		s = '0' + s;
	}
	return s;
}

function bits( x ) {
	f[ 0 ] = x;
	return hex8( u[ 1 ] ) + hex8( u[ 0 ] );
}

function fromHex( h ) {
	u[ 1 ] = parseInt( h.slice( 0, 8 ), 16 );
	u[ 0 ] = parseInt( h.slice( 8, 16 ), 16 );
	return f[ 0 ];
}

var lines = text.split( '\n' );
var out = [];
var p;
var i;
for ( i = 0; i < lines.length; i++ ) {
	p = lines[ i ].split( ' ' );
	if ( p[ 0 ] === 'Math.pow' ) {
		out.push( p[ 1 ] + ' ' + p[ 2 ] + ' ' + bits( Math.pow( fromHex( p[ 1 ] ), fromHex( p[ 2 ] ) ) ) );
	} else if ( p[ 0 ] === 'Math.sin' ) {
		out.push( p[ 1 ] + ' ' + bits( Math.sin( fromHex( p[ 1 ] ) ) ) );
	} else if ( p[ 0 ] === 'Math.cos' ) {
		out.push( p[ 1 ] + ' ' + bits( Math.cos( fromHex( p[ 1 ] ) ) ) );
	} else if ( p[ 0 ] === 'Math.tan' ) {
		out.push( p[ 1 ] + ' ' + bits( Math.tan( fromHex( p[ 1 ] ) ) ) );
	} else if ( p[ 0 ] !== '' ) {
		throw new Error( 'unexpected case: ' + lines[ i ] );
	}
}
emit( out.join( '\n' ) );
