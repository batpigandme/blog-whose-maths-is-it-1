#!/usr/bin/env bash
#
# compare.sh -- compare result columns from several builds, function by
# function, by the hash of each result column.
#
#   ./fma-contraction/compare.sh RESULTS_DIR LABEL [LABEL...]
#   ./fma-contraction/compare.sh .cache/results mac-default mac-nocontract linux-x86_64
#
# RESULTS_DIR/<label>/<fn>.txt hold each build's results (lib/run-cases.sh).
# Prints one line per function with each build's hash, then, for the first
# pair of labels, on how many functions they have the same bits and which
# functions differ; the first label is the baseline of the table. Needs node. macOS or Linux.

set -euo pipefail
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DIR="${1:?usage: compare.sh RESULTS_DIR LABEL [LABEL...]}"; shift
LABELS=( "$@" )

node - "$ROOT/lib/colhash.js" "$DIR" "${LABELS[@]}" <<'JS'
var cp = require( 'child_process' );
var args = process.argv.slice( 2 );
var script = args[ 0 ], dir = args[ 1 ], labels = args.slice( 2 );
var table = {};
var fns = null;
labels.forEach( function ( l ) {
	var out = cp.execFileSync( 'node', [ script, dir + '/' + l ], { encoding: 'utf8' } ).trim().split( '\n' );
	table[ l ] = {};
	out.forEach( function ( line ) {
		var p = line.split( ' ' );
		table[ l ][ p[ 0 ] ] = p[ 1 ];
	});
	fns = fns || Object.keys( table[ l ] );
});
function pad( s, n ) { s = String( s ); while ( s.length < n ) { s += ' '; } return s; }
console.log( pad( 'function', 13 ) + labels.map( function ( l ) { return pad( l, 40 ); } ).join( '' ) );
fns.forEach( function ( f ) {
	var base = table[ labels[ 0 ] ][ f ];
	console.log( pad( f, 13 ) + labels.map( function ( l, i ) {
		var h = table[ l ][ f ];
		return pad( h + ( i === 0 ? '' : ( h === base ? ' =' : ' !=' ) + ' ' + labels[ 0 ] ), 40 );
	}).join( '' ) );
});
console.log();
labels.forEach( function ( a, i ) {
	labels.slice( i + 1 ).forEach( function ( b ) {
		var diff = fns.filter( function ( f ) { return table[ a ][ f ] !== table[ b ][ f ]; } );
		console.log( a + ' and ' + b + ': same bits on ' + ( fns.length - diff.length ) + ' of ' + fns.length + ' functions' +
			( diff.length ? '; differ on ' + diff.map( function ( f ) { return f.replace( 'Math.', '' ); } ).join( ', ' ) : '' ) );
	});
});
JS
