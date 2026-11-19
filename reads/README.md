# reads

> **Results only for now: scripts and reruns to follow.** Everything here is a recorded quotation or reading, copied from earlier notes and not regenerated. Nothing in this folder is a run, and nothing can be rerun yet.

Backs the post's footnotes `[^js10]`, `[^java-math]`, and `[^numpy]`: three claims that rest on a reading of a published document or of one check, rather than on a run.

The readings were taken from documents, and the one check was made on macOS arm64.

## Claim

From the post:

- JavaScript 1.0 shipped in March 1996 with 17 functions on `Math`; `Math.random` was "available only on Unix platforms," and the number-parsing functions behaved differently "depending upon host operating system" (`[^js10]`).
- Rhino and GraalJS build on Java's `Math`, which is "not defined to return the bit-for-bit same results" (`[^java-math]`).
- NumPy's `np.longdouble` is whatever the C compiler's `long double` is, which on Apple's clang for arm64 is a plain `double` (`[^numpy]`).

## Tier

c: results only, for now. The full folder will be tier a for `numpy-longdouble.md`, whose check becomes a script that runs anywhere NumPy is installed; the other two stay readings of documents.

## Committed outputs

| Footnote | File | What it records | Kind | Date | Platform |
| --- | --- | --- | --- | --- | --- |
| `[^js10]` | [`js10.md`](js10.md) | Figure 8 of Wirfs-Brock and Eich's history: its title, 17 `Math` functions and 8 constants, and its footnotes 1 and 2 | recorded reading | 2026-11-18 | not applicable |
| `[^java-math]` | [`java-math.md`](java-math.md) | `java.lang.Math`'s statements about bit-for-bit results and about calling `StrictMath` | recorded quotation | 2026-11-16 | not applicable |
| `[^numpy]` | [`numpy-longdouble.md`](numpy-longdouble.md) | NumPy 2.5.5's `np.finfo(np.longdouble)` reporting float64's parameters, with `sizeof(long double)` 8, on macOS arm64 with Apple clang | recorded one-line check | 2026-11-18 | macOS arm64 |

The counts in `js10.md` (17 functions, 8 constants) come from the lists it prints, which can be counted against the figure by anyone with the paper.

## What the full folder will hold

- `numpy-longdouble.md`'s check as a rerunnable script, with a header naming the NumPy version, the compiler, and the platform, and its output.
- The page of each document read at a pinned copy where one exists, with a hash for any file that can't be pinned to a commit.

## Scope

- Each file is a reading taken once, on the date it gives. Documents can change, and none of the three is committed as a copy.
- The NumPy check is one Mac, one compiler version, and one NumPy version; no Intel Mac, Windows, or Linux machine was checked.
- The `java.lang.Math` documentation isn't pinned to a commit, and which code runs on a given Java virtual machine isn't checked.
