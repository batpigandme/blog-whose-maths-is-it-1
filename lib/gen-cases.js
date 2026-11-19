/**
* gen-cases.js -- turn stdlib's own test fixtures into exact test cases.
*
*   node lib/gen-cases.js
*
* Environment (defaults):
*   STDLIB_DIR  a checkout of https://github.com/stdlib-js/stdlib with the
*               fixtures (the path printed by lib/fetch-stdlib-fixtures.sh,
*               <repo root>/.cache/stdlib-550666096f34)
*   CASES_DIR   where to write the case files (<repo root>/.cache/cases)
*
* For each function, reads every fixture file and writes <fn>.txt: one line per
* input, `<fn> <x hex> [<y hex>] <fixture expected hex>`. Every value is the raw
* IEEE 754 binary64 bit pattern as 16 hex digits, so nothing is lost to decimal
* formatting. Duplicate inputs are kept once, and inputs with no expected value
* are dropped.
*
* The fixtures are not a higher-precision reference: the Julia fixtures are
* Julia's own Float64 functions, and gamma's are Boost's tgamma for double. The
* correctly rounded reference comes from lib/reference.jl instead. The case
* files are about 15 MB, so they are not committed; lib/cases.sha256 holds the
* SHA-256 of each file this script writes, and `node lib/gen-cases.js --check`
* compares against it.
*/
'use strict';

var fs = require( 'fs' );
var path = require( 'path' );
var crypto = require( 'crypto' );

var ROOT = path.join( __dirname, '..' );
var STDLIB = process.env.STDLIB_DIR || path.join( ROOT, '.cache', 'stdlib-550666096f34' );
var BASE = path.join( STDLIB, 'lib', 'node_modules', '@stdlib', 'math', 'base', 'special' );
var OUT = process.env.CASES_DIR || path.join( ROOT, '.cache', 'cases' );
var CHECK = process.argv.indexOf( '--check' ) >= 0;

// name in the driver -> [ stdlib package holding the fixtures, fixture subdirectory, arity ]
var FUNCS = {
	'erf': [ 'erf', 'julia', 1 ],
	'gamma': [ 'gamma', 'cpp', 1 ],
	'log1p': [ 'log1p', 'julia', 1 ],
	'Math.exp': [ 'exp', 'julia', 1 ],
	'Math.log': [ 'ln', 'julia', 1 ],
	'Math.sin': [ 'sin', 'julia', 1 ],
	'Math.cos': [ 'cos', 'julia', 1 ],
	'Math.tan': [ 'tan', 'julia', 1 ],
	'Math.asin': [ 'asin', 'julia', 1 ],
	'Math.acos': [ 'acos', 'julia', 1 ],
	'Math.atan': [ 'atan', 'julia', 1 ],
	'Math.atan2': [ 'atan2', 'julia', 2 ],
	'Math.pow': [ 'pow', 'julia', 2 ],
	'Math.sqrt': [ 'sqrt', 'julia', 1 ],
	'Math.log2': [ 'log2', 'julia', 1 ],
	'Math.log10': [ 'log10', 'julia', 1 ]
};

var buf = new DataView( new ArrayBuffer( 8 ) );
function hex( v ) {
	buf.setFloat64( 0, v );
	return buf.getBigUint64( 0 ).toString( 16 ).padStart( 16, '0' );
}
function sha( text ) {
	return crypto.createHash( 'sha256' ).update( text ).digest( 'hex' );
}

fs.mkdirSync( OUT, { recursive: true } );
var sums = [];
var all = new Set();
function write( name, lines ) {
	var text = lines.join( '\n' ) + '\n';
	fs.writeFileSync( path.join( OUT, name + '.txt' ), text );
	sums.push( sha( text ) + '  ' + name + '.txt' );
}
Object.keys( FUNCS ).forEach( function each( fn ) {
	var spec = FUNCS[ fn ];
	var dir = path.join( BASE, spec[ 0 ], 'test', 'fixtures', spec[ 1 ] );
	var seen = new Set();
	var lines = [];
	fs.readdirSync( dir ).filter( function ( f ) {
		return f.endsWith( '.json' );
	}).sort().forEach( function ( f ) {
		var j = JSON.parse( fs.readFileSync( path.join( dir, f ), 'utf8' ) );
		var i;
		for ( i = 0; i < j.x.length; i++ ) {
			// atan2's fixtures store atan(y, x); the driver calls Math.atan2(y, x).
			var key = ( spec[ 2 ] === 2 ) ? ( hex( j.x[ i ] ) + ' ' + hex( j.y[ i ] ) ) : hex( j.x[ i ] );
			if ( seen.has( key ) || j.expected[ i ] === null ) {
				continue;
			}
			seen.add( key );
			lines.push( fn + ' ' + key + ' ' + hex( j.expected[ i ] ) );
			all.add( hex( j.x[ i ] ) );
		}
	});
	write( fn, lines );
	console.log( fn + '\t' + lines.length + ' cases from ' + spec[ 0 ] + '/test/fixtures/' + spec[ 1 ] );
});

// Math.fround has no stdlib fixture; it is exactly specified, so it gets every
// distinct x above, with no fixture value (written as "-").
var fr = Array.from( all ).sort().map( function ( h ) {
	return 'Math.fround ' + h + ' -';
});
write( 'Math.fround', fr );
console.log( 'Math.fround\t' + fr.length + ' cases (every distinct x above; no fixture)' );

sums.sort( function ( a, b ) {
	return ( a.slice( 66 ) < b.slice( 66 ) ) ? -1 : 1;
});
var table = sums.join( '\n' ) + '\n';
if ( CHECK ) {
	var want = fs.readFileSync( path.join( __dirname, 'cases.sha256' ), 'utf8' );
	if ( want !== table ) {
		console.error( 'cases differ from lib/cases.sha256' );
		process.exit( 1 );
	}
	console.log( 'cases match lib/cases.sha256' );
} else {
	console.log( '\nSHA-256 of each case file (lib/cases.sha256 holds these):\n' + table );
}
