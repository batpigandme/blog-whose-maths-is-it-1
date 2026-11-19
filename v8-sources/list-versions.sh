#!/usr/bin/env bash
#
# list-versions.sh -- the V8 14.x and 15.x release builds published for a
# platform, in version order.
#
#   ./v8-sources/list-versions.sh [PLATFORM] > v8-sources/versions-mac-arm64-14-15.txt
#
# PLATFORM is mac-arm64, mac64 or linux64 (default: this machine's). Lists the
# objects named official/canary/v8-<platform>-rel-<version>.zip in the public
# bucket chromium-v8 through its JSON API, one version per line, sorted by
# major, minor and build number, which is V8's main-line order. Needs curl and
# node. Any OS.

set -euo pipefail
if [ -n "${1:-}" ]; then
	PLATFORM="$1"
else
	case "$( uname -s )-$( uname -m )" in
		Darwin-arm64 ) PLATFORM=mac-arm64 ;;
		Darwin-x86_64 ) PLATFORM=mac64 ;;
		Linux-x86_64 ) PLATFORM=linux64 ;;
		* ) echo "name a platform" >&2; exit 2 ;;
	esac
fi
node - "$PLATFORM" <<'JS'
var https = require( 'https' );
var platform = process.argv[ 2 ];
var versions = [];
function get( url ) {
	return new Promise( function ( resolve, reject ) {
		https.get( url, function ( res ) {
			var b = '';
			res.on( 'data', function ( d ) { b += d; } );
			res.on( 'end', function () { resolve( JSON.parse( b ) ); } );
		}).on( 'error', reject );
	});
}
async function main() {
	var major;
	for ( major of [ 14, 15 ] ) {
		var token = '';
		do {
			var url = 'https://storage.googleapis.com/storage/v1/b/chromium-v8/o?fields=items(name),nextPageToken&maxResults=1000' +
				'&prefix=' + encodeURIComponent( 'official/canary/v8-' + platform + '-rel-' + major + '.' ) +
				( token ? '&pageToken=' + encodeURIComponent( token ) : '' );
			var r = await get( url );
			( r.items || [] ).forEach( function ( o ) {
				var m = /-rel-(\d+\.\d+\.\d+)\.zip$/.exec( o.name );
				if ( m ) {
					versions.push( m[ 1 ] );
				}
			});
			token = r.nextPageToken;
		} while ( token );
	}
	versions.sort( function ( a, b ) {
		var x = a.split( '.' ).map( Number ), y = b.split( '.' ).map( Number );
		return ( x[ 0 ] - y[ 0 ] ) || ( x[ 1 ] - y[ 1 ] ) || ( x[ 2 ] - y[ 2 ] );
	});
	console.log( versions.join( '\n' ) );
}
main();
JS
