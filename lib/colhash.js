/**
* colhash.js -- print a short hash of the result column of each file.
*
*   node lib/colhash.js DIR              # one line per <fn>.txt in DIR
*   node lib/colhash.js a.txt b.txt ...  # or named files
*   some-command | node lib/colhash.js - # standard input, printed as just the hash
*
* The hash is the first 12 hex digits of the SHA-256 of the file's result
* column (the last space-separated field of each line), joined by newlines,
* with no trailing newline. Two runs have the same hash exactly when they give
* the same bits on every case.
*/
'use strict';
var fs = require( 'fs' );
var path = require( 'path' );
var crypto = require( 'crypto' );

function hashOf( file ) {
	var col = fs.readFileSync( file === '-' ? 0 : file, 'utf8' ).split( '\n' ).filter( Boolean ).map( function ( l ) {
		return l.split( ' ' ).pop();
	});
	return crypto.createHash( 'sha256' ).update( col.join( '\n' ) ).digest( 'hex' ).slice( 0, 12 );
}
var args = process.argv.slice( 2 );
if ( args[ 0 ] === '-' ) {
	console.log( hashOf( '-' ) );
	process.exit( 0 );
}
var files = [];
args.forEach( function ( a ) {
	if ( fs.statSync( a ).isDirectory() ) {
		fs.readdirSync( a ).filter( function ( f ) {
			return f.endsWith( '.txt' );
		}).sort().forEach( function ( f ) {
			files.push( path.join( a, f ) );
		});
	} else {
		files.push( a );
	}
});
files.forEach( function ( f ) {
	console.log( path.basename( f, '.txt' ) + ' ' + hashOf( f ) );
});
