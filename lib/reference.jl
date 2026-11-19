# reference.jl -- the correctly rounded answer for every case, from MPFR.
#
#   julia lib/reference.jl
#
# Environment (defaults):
#   CASES_DIR      case files from lib/gen-cases.js (<repo root>/.cache/cases)
#   REFERENCE_DIR  where to write the answers (<repo root>/.cache/reference)
#
# Reads <fn>.txt in CASES_DIR and writes the same file name in REFERENCE_DIR: the same inputs, then the
# correctly rounded binary64 result as 16 hex digits, or "-" where there is no
# reference (any input not finite, or MPFR returns NaN or raises a domain error).
#
# Each value is computed by MPFR at 256 bits of precision with round-to-nearest
# and then rounded once to binary64 with round-to-nearest (Float64(::BigFloat),
# which handles subnormals). The second rounding could misround only a value
# within 2^-256, relatively, of a midpoint between doubles; the hardest known
# cases for these functions at binary64 sit far further out than that.
#
# erf and gamma come straight from MPFR's mpfr_erf and mpfr_gamma (Base has no
# BigFloat erf or gamma, and SpecialFunctions is not needed for this). The rest
# are Base's BigFloat methods, which call MPFR. Math.fround is exactly
# specified, so its reference is Julia's round-to-nearest Float32 conversion.

setprecision( BigFloat, 256 )
const L = Base.MPFR.libmpfr
const RN = Base.MPFR.MPFRRoundNearest
erfb( x ) = ( z = BigFloat(); ccall( (:mpfr_erf, L), Int32, (Ref{BigFloat}, Ref{BigFloat}, Base.MPFR.MPFRRoundingMode), z, x, RN ); z )
gammab( x ) = ( z = BigFloat(); ccall( (:mpfr_gamma, L), Int32, (Ref{BigFloat}, Ref{BigFloat}, Base.MPFR.MPFRRoundingMode), z, x, RN ); z )

const UNARY = Dict(
	"erf" => erfb, "gamma" => gammab, "log1p" => log1p,
	"Math.exp" => exp, "Math.log" => log, "Math.sin" => sin, "Math.cos" => cos,
	"Math.tan" => tan, "Math.asin" => asin, "Math.acos" => acos, "Math.atan" => atan,
	"Math.sqrt" => sqrt, "Math.log2" => log2, "Math.log10" => log10
)

fromhex( h ) = reinterpret( Float64, parse( UInt64, h; base = 16 ) )
tohex( v::Float64 ) = string( reinterpret( UInt64, v ); base = 16, pad = 16 )

function ref( fn, x, y )
	if !isfinite( x ) || ( y !== nothing && !isfinite( y ) )
		return "-"
	end
	if fn == "Math.fround"
		return tohex( Float64( Float32( x ) ) )
	end
	r = try
		if fn == "Math.atan2"
			atan( BigFloat( y ), BigFloat( x ) )   # fixture fields x, y; value atan(y, x)
		elseif fn == "Math.pow"
			BigFloat( x ) ^ BigFloat( y )
		else
			UNARY[ fn ]( BigFloat( x ) )
		end
	catch e
		e isa DomainError || rethrow()
		return "-"
	end
	isnan( r ) && return "-"
	return tohex( Float64( r ) )
end

root = dirname( @__DIR__ )
casesdir = get( ENV, "CASES_DIR", joinpath( root, ".cache", "cases" ) )
refdir = get( ENV, "REFERENCE_DIR", joinpath( root, ".cache", "reference" ) )
mkpath( refdir )
for f in sort( filter( p -> endswith( p, ".txt" ), readdir( casesdir ) ) )
	fn = f[ 1:end-4 ]
	n = 0
	nref = 0
	open( joinpath( refdir, f ), "w" ) do io
		for line in eachline( joinpath( casesdir, f ) )
			p = split( line, ' ' )
			two = fn == "Math.atan2" || fn == "Math.pow"
			x = fromhex( p[ 2 ] )
			y = two ? fromhex( p[ 3 ] ) : nothing
			r = ref( fn, x, y )
			n += 1
			r == "-" || ( nref += 1 )
			println( io, two ? "$fn $(p[2]) $(p[3]) $r" : "$fn $(p[2]) $r" )
		end
	end
	println( rpad( fn, 12 ), lpad( n, 7 ), " cases, ", lpad( nref, 7 ), " with a reference" )
end
