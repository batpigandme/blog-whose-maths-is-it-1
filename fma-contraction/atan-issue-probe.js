// atan-issue-probe.js -- Math.atan of one input, printed as input bits and
// result bits.
//
//   d8 fma-contraction/atan-issue-probe.js
//
// The input is 0x40600e99e0bbf8d4 (about 128.46), the one reported in
// https://github.com/llvm/llvm-project/issues/197072, where LLVM libc's atan
// is one unit in the last place off. d8 14.6.202 and earlier give
// 3ff9021897ae0934; d8 15.4 and later, which call LLVM libc, give
// 3ff9021897ae0933.
var f = new Float64Array( 1 );
var u = new Uint32Array( f.buffer );
function hex( x ) {
	f[ 0 ] = x;
	return ( '00000000' + u[ 1 ].toString( 16 ) ).slice( -8 ) + ( '00000000' + u[ 0 ].toString( 16 ) ).slice( -8 );
}
u[ 1 ] = 0x40600e99;
u[ 0 ] = 0xe0bbf8d4;
var x = f[ 0 ];
print( hex( x ) + ' ' + hex( Math.atan( x ) ) );
