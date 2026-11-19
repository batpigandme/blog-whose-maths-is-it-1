# tan-mpfr.jl -- the correctly rounded Math.tan of 0xc0322052fd59ea32, from MPFR.
#
#   julia fma-contraction/tan-mpfr.jl
#
# Julia's BigFloat is MPFR. tan is computed at 256 bits with round-to-nearest
# and then rounded once to binary64, as lib/reference.jl does for every case.
setprecision( BigFloat, 256 )
x = reinterpret( Float64, 0xc0322052fd59ea32 )
r = Float64( tan( BigFloat( x ) ) )
println( "Math.tan c0322052fd59ea32 ", string( reinterpret( UInt64, r ); base = 16, pad = 16 ) )
println( "# Julia ", VERSION, ", MPFR ", Base.MPFR.version() )
