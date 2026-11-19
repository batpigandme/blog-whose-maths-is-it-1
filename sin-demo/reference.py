#!/usr/bin/env python3
"""Correctly rounded sin of a float64, from integer arithmetic only.

Usage: python3 -I reference.py [INPUT_BITS_HEX ...]

Prints one line per input: "in=<bits> sin=<bits>", where <bits> is the
big-endian hex of the float64. The default input is 5c99c487f2337e3a
(1.1986535513718587e+138).

Standard library only. The input is exact, pi comes from Machin's formula at
PREC bits, the argument is reduced modulo 2*pi in fixed point, and sin comes
from its Taylor series in fixed point. PREC is far above what the input needs
(the input is about 2**458, so the reduction loses about 460 bits), and
Fraction's conversion to float rounds to nearest even, so the result is the
correctly rounded value, not a nearby one. This replaces an mpmath call (the
earlier checks used mpmath at 2,000 and 3,000 bits) so that nothing needs
installing; see README.md for how the two were compared.
"""
import struct
import sys
from fractions import Fraction

PREC = 1600
ONE = 1 << PREC


def arctan_inv(n):
    """arctan(1/n) in fixed point with PREC + 32 guard bits."""
    scale = 1 << (PREC + 32)
    term = scale // n
    total = term
    n2 = n * n
    k = 1
    sign = -1
    while term:
        term //= n2
        k += 2
        total += sign * (term // k)
        sign = -sign
    return total


def pi_fixed():
    # Machin: pi = 16 arctan(1/5) - 4 arctan(1/239)
    p = 16 * arctan_inv(5) - 4 * arctan_inv(239)
    return p >> 32


PI = pi_fixed()
TWO_PI = 2 * PI


def sin_fixed(r):
    """sin of a fixed-point r with |r| <= pi, by Taylor series."""
    r2 = (r * r) >> PREC
    term = r
    total = r
    k = 1
    while term:
        term = -((term * r2) >> PREC) // ((k + 1) * (k + 2))
        total += term
        k += 2
    return total


def bits_to_float(h):
    return struct.unpack('>d', bytes.fromhex(h.zfill(16)))[0]


def float_to_bits(x):
    return struct.pack('>d', x).hex()


def correctly_rounded_sin(x):
    if x != x or x in (float('inf'), float('-inf')):
        return float('nan')
    if x == 0:
        return x
    neg = x < 0
    m, e = abs(Fraction(x)).as_integer_ratio()
    # m / e is exact; as a fixed-point integer it is (m << PREC) // e, and e is
    # a power of two, so this is exact too while PREC >= log2(e).
    assert e & (e - 1) == 0 and (1 << PREC) % e == 0
    fixed = (m << PREC) // e
    r = fixed % TWO_PI
    if r > PI:
        r -= TWO_PI
    s = sin_fixed(r)
    y = float(Fraction(s, ONE))
    return -y if neg else y


def main(argv):
    inputs = argv[1:] or ['5c99c487f2337e3a']
    for h in inputs:
        x = bits_to_float(h)
        print('in=%s sin=%s' % (h.lower().zfill(16), float_to_bits(correctly_rounded_sin(x))))


if __name__ == '__main__':
    main(sys.argv)
