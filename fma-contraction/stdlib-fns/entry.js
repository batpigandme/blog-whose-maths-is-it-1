// entry.js -- the three functions lib/driver.js looks for, bundled by
// ../build-stdlib-fns.sh into one ES5 script that defines the globals
// erf, gamma and log1p.
module.exports = {
	erf: require( '@stdlib/math-base-special-erf' ),
	gamma: require( '@stdlib/math-base-special-gamma' ),
	log1p: require( '@stdlib/math-base-special-log1p' )
};
