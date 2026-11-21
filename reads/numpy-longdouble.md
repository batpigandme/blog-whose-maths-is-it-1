# numpy-longdouble

Backs the post's footnote `[^numpy]`, on the sentence "NumPy's `np.longdouble` is whatever the C compiler's `long double` is: 80 bits on most x86 machines, but a plain `double` with Microsoft's compiler and with Apple's clang on arm64."

A recorded reading of one check, not a run. Nothing here was regenerated.

## Claim

On a Mac with Apple clang on arm64, `long double` is the same as `double`, so NumPy's `np.longdouble` has float64's parameters there.

## Tier

c: results only for both halves: the NumPy half and the Apple clang half are each recorded here, and the Apple clang result depends on the compiler.

## The recorded reading

**Checked:** 2026-11-18, on macOS arm64 (the OS version wasn't recorded).

| What | Recorded |
| --- | --- |
| Compiler | Apple clang 21 (the patch version wasn't recorded for this check) |
| `sizeof(long double)` | 8 |
| `LDBL_MANT_DIG` | 53 |
| NumPy | 2.5.5 |
| `np.finfo(np.longdouble)` | reports float64's parameters |

**The post's sentence:** "Apple's clang on arm64 was checked on 18 November 2026: `sizeof(long double)` is 8."

**The documents the footnote cites, for the other platforms:**

- NumPy's [`basics.types.rst`, "Extended precision," at `f7fdace6`](https://github.com/numpy/numpy/blob/f7fdace610a999f8babe4d3be21e1ed855aaf478/doc/source/user/basics.types.rst#extended-precision), read 2026-11-18: x86 hardware has 80-bit precision, "most C compilers provide this as their `long double` type", and Microsoft's compiler, "standard for Windows builds", makes it "identical to `double`".
- Quansight Labs, ["Numpy QuadDType: Quadruple Precision for Everyone"](https://labs.quansight.org/blog/numpy-quaddtype-blog), 30 September 2024, which says "Windows & macOS: 64-bit", matching the arm64 result.

**Platform:** macOS arm64, Apple clang 21.

## Scope

- This is one Mac, one compiler version, and one NumPy version. The recorded reading is a one-line check, and no script or transcript of it is committed.
- No Intel Mac was checked. By the NumPy documentation's rule for x86, one would be expected to differ; that isn't recorded here as a result.
- Windows and Microsoft's compiler weren't run; that row rests on NumPy's documentation.
- `np.finfo(np.longdouble)`'s individual fields (precision, epsilon, and the rest) weren't recorded, only that it reports float64's parameters.
