#!/usr/bin/env node
/**
* bisect.js -- narrow, for each Math function, the V8 release build where its
* results change, between two published d8 builds.
*
*   node v8-sources/bisect.js
*   FUNCS="tan log" node v8-sources/bisect.js
*   PLATFORM=linux64 node v8-sources/bisect.js
*
* The candidates are the d8 release builds published in the bucket
* chromium-v8 (official/canary/v8-<platform>-rel-<version>.zip), in version
* order, which is V8's main-line order (v8-sources/list-versions.sh). Each
* build is downloaded by lib/fetch-d8.sh, run on v8-sources/math-probe.js, and
* removed again unless it is an endpoint or KEEP is set. The probe evaluates 88
* inputs, 8 per function, where d8 14.6.202 and d8 15.4.8 give different bits,
* and classifies each function in a build as "old" (all 8 have 14.6.202's
* bits), "new" (all 8 have 15.4.8's bits), or mixed. One probe run classifies
* every function, so the builds are probed once and each function's bisection
* reads the same results.
*
* A function's endpoints must classify differently; a midpoint that is neither
* class stops that function's bisection, which would mean the change is not a
* single step. A build that fails to download or run is stepped over. Every
* boundary build is probed twice more at the end.
*
* Environment (defaults):
*   PLATFORM   mac-arm64, mac64 or linux64 (this machine's)
*   LO, HI     the endpoints (14.6.202 and 15.4.8)
*   VERSIONS   the version list (v8-sources/versions-<PLATFORM>-14-15.txt;
*              regenerate with list-versions.sh)
*   FUNCS      space-separated functions (acos asin atan atan2 cos exp log
*              log10 log2 sin tan)
*   KEEP       if set, keep every downloaded build under .cache/d8
*   OUT        output file (v8-sources/results/bisect-<PLATFORM>.txt)
*
* Needs node, curl and unzip, and network access. Downloads about 19 MB per
* probed build; the committed macOS run probed 34 distinct builds, plus the
* endpoints and the rechecks. Takes several minutes.
*/
'use strict';

var fs = require( 'fs' );
var os = require( 'os' );
var path = require( 'path' );
var cp = require( 'child_process' );

var ROOT = path.join( __dirname, '..' );
var CACHE = process.env.CACHE_DIR || path.join( ROOT, '.cache' );
var PLATFORM = process.env.PLATFORM || ( { 'darwin-arm64': 'mac-arm64', 'darwin-x64': 'mac64', 'linux-x64': 'linux64' } )[ os.platform() + '-' + os.arch() ];
var LO = process.env.LO || '14.6.202';
var HI = process.env.HI || '15.4.8';
var VERSIONS = process.env.VERSIONS || path.join( __dirname, 'versions-' + PLATFORM + '-14-15.txt' );
var FUNCS = ( process.env.FUNCS || 'acos asin atan atan2 cos exp log log10 log2 sin tan' ).split( ' ' );
var KEEP = !!process.env.KEEP;
var OUT = process.env.OUT || path.join( __dirname, 'results', 'bisect-' + PLATFORM + '.txt' );
var PROBE = path.join( __dirname, 'math-probe.js' );

var V = fs.readFileSync( VERSIONS, 'utf8' ).split( '\n' ).filter( Boolean );
var lines = [];
function log( s ) {
	lines.push( s );
	console.log( s );
}
function idx( v ) {
	return V.indexOf( v );
}
var cache = {};
var ends = {};
ends[ LO ] = true;
ends[ HI ] = true;

// Download (if needed), run the probe, and return { fn: class }; null if the
// build can't be had or run.
function probe( v, fresh ) {
	if ( cache[ v ] && !fresh ) {
		return cache[ v ];
	}
	var d8;
	var dir;
	var out;
	var res = null;
	try {
		d8 = cp.execFileSync( path.join( ROOT, 'lib', 'fetch-d8.sh' ), [ v, PLATFORM ], { encoding: 'utf8', stdio: [ 'ignore', 'pipe', 'ignore' ], env: Object.assign( {}, process.env, { CACHE_DIR: CACHE } ) } ).trim();
		dir = path.dirname( d8 );
		out = cp.execFileSync( d8, [ PROBE ], { encoding: 'utf8', timeout: 120000, stdio: [ 'ignore', 'pipe', 'ignore' ] } ).trim().split( '\n' ).pop();
		var m = /^math old\/new\/other \d+\/\d+\/\d+ {2}(.*)$/.exec( out );
		if ( m ) {
			res = {};
			m[ 1 ].split( ', ' ).forEach( function ( kv ) {
				var p = kv.split( ' ' );
				res[ p[ 0 ] ] = ( p[ 1 ] === '8/0/0' ) ? 'old' : ( p[ 1 ] === '0/8/0' ) ? 'new' : 'mixed[' + p[ 1 ] + ']';
			});
		}
	} catch ( e ) {
		res = null;
	}
	if ( dir && !KEEP && !ends[ v ] ) {
		fs.rmSync( dir, { recursive: true, force: true } );
	}
	cache[ v ] = res;
	return res;
}
function cls( v, fn ) {
	var r = probe( v );
	return r && r[ fn ] ? r[ fn ] : 'error';
}

log( '# engine:   d8 release builds ' + LO + ' to ' + HI + ' (' + ( idx( HI ) - idx( LO ) - 1 ) + ' builds between), published ' + PLATFORM + ' builds, one probe of 88 inputs per build' );
var osName = os.platform() + ' ' + os.release();
try {
	if ( os.platform() === 'darwin' ) {
		osName = 'macOS ' + cp.execFileSync( 'sw_vers', [ '-productVersion' ], { encoding: 'utf8' } ).trim();
	} else if ( fs.existsSync( '/etc/os-release' ) ) {
		osName = ( /^PRETTY_NAME="?([^"\n]*)"?/m.exec( fs.readFileSync( '/etc/os-release', 'utf8' ) ) || [ 0, osName ] )[ 1 ];
	}
} catch ( e ) {
	// keep the generic name
}
log( '# platform: ' + osName + ', ' + os.arch() + ', ' + os.cpus()[ 0 ].model );
log( '# obtained: https://storage.googleapis.com/chromium-v8/official/canary/ (lib/fetch-d8.sh); version list ' + path.basename( VERSIONS ) );
log( '# date:     ' + new Date().toISOString().replace( /\.\d+Z$/, 'Z' ) );
log( '# script:   v8-sources/bisect.js' );
log( '' );

var results = {};
var boundary = {};
if ( idx( LO ) < 0 || idx( HI ) <= idx( LO ) ) {
	throw new Error( 'endpoints not in the list or out of order' );
}
FUNCS.forEach( function ( fn ) {
	var lo = idx( LO );
	var hi = idx( HI );
	var clo = cls( LO, fn );
	var chi = cls( HI, fn );
	log( '######## ' + fn );
	log( 'endpoint ' + LO + ': ' + clo );
	log( 'endpoint ' + HI + ': ' + chi );
	if ( clo === chi ) {
		log( 'endpoints classify the same; nothing to bisect' );
		return;
	}
	while ( hi - lo > 1 ) {
		var mid = Math.floor( ( lo + hi ) / 2 );
		var c = cls( V[ mid ], fn );
		var off = 1;
		while ( c === 'error' && mid + off < hi ) {
			log( 'tested ' + V[ mid ] + ': error (not downloadable or no output); trying ' + V[ mid + off ] );
			mid = mid + off;
			c = cls( V[ mid ], fn );
		}
		log( 'tested ' + V[ mid ] + ': ' + c );
		if ( c === clo ) {
			lo = mid;
		} else if ( c === chi ) {
			hi = mid;
		} else {
			log( 'STOP: ' + V[ mid ] + ' is neither endpoint\'s class (' + c + '); the change is not a single step here' );
			return;
		}
	}
	log( 'RESULT ' + fn + ': ' + V[ lo ] + ' is ' + clo + ', ' + V[ hi ] + ' is ' + chi + ', adjacent in the published list' );
	results[ fn ] = [ V[ lo ], clo, V[ hi ], chi ];
	boundary[ V[ lo ] ] = boundary[ V[ hi ] ] = true;
});

log( '' );
log( '######## boundary builds probed again, twice each (fresh download and run)' );
Object.keys( boundary ).sort().forEach( function ( v ) {
	[ 1, 2 ].forEach( function ( r ) {
		var p = probe( v, true );
		log( 'recheck ' + v + ' run ' + r + ': ' + ( p ? FUNCS.filter( function ( f ) { return results[ f ] && ( results[ f ][ 0 ] === v || results[ f ][ 2 ] === v ); } ).map( function ( f ) { return f + ' ' + p[ f ]; } ).join( ', ' ) : 'error' ) );
	});
});
log( '' );
log( '######## summary: the window each function changes in, as published builds' );
FUNCS.forEach( function ( fn ) {
	if ( results[ fn ] ) {
		log( fn.padEnd( 7 ) + ' ' + results[ fn ][ 0 ] + ' (' + results[ fn ][ 1 ] + ') -> ' + results[ fn ][ 2 ] + ' (' + results[ fn ][ 3 ] + ')' );
	}
});
fs.mkdirSync( path.dirname( OUT ), { recursive: true } );
fs.writeFileSync( OUT, lines.join( '\n' ) + '\n' );
