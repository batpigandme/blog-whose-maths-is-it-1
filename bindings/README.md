# bindings

> **Results only for now: scripts and reruns to follow.** Everything here is copied from earlier runs and not regenerated, apart from one table of hashes computed from those runs' outputs. Nothing in this folder can be rerun yet.

Backs the post's section "The binding" and its footnote `[^bindings]`, including the table "Copy, V8, and its `sin` of the bug's input."

The outputs were measured on macOS arm64, on one Mac.

## Claim

From the post: a binding embeds an engine in another language's programs, and it brings that engine's maths with it, not the language's.

- [v8go](https://github.com/rogchap/v8go) runs JavaScript from Go on V8, and its `Math` is V8's, bit for bit: it matches d8, V8's own command-line shell, at the same V8 on every probe.
- A binding keeps the V8 it was built with. [PyMiniRacer](https://github.com/bpcreech/PyMiniRacer) 0.14.1, for Python, carries V8 14.4 with the trig flag on, and gives the 1,063-ULP `sin` from [Chromium bug 511271840](https://issues.chromium.org/issues/511271840). With `--no-use-libm-trig-functions` it gives the correct one.
- v8go's latest release, v0.9.0, carries V8 10.9, older than the glibc copy of `sin` and `cos` that V8 vendored in 11.0, and gives the correct `sin`. So the newer binding has the worse `sin`.

## Tier

c: results only, for now. The full folder will be tier b: it needs a Mac, Go and Python with a C and C++ compiler (Apple clang), and jsvu's d8 builds at three V8 versions.

## What the committed results show

The tables are counted from the committed outputs, by the rules stated under each.

### Which V8 each binding carries

Read at runtime from the binding itself, and from its build metadata, in the "build metadata" sections of `mac-bindings-run3.results.txt` and `mac-bindings-run4.results.txt`.

| Binding | V8 at runtime | V8 its build metadata names |
| --- | --- | --- |
| v8go at commit `12b0374` | 9.0.257.18 (`v8go.Version()`) | 9.0.257.18 (`deps/v8_version`) |
| v8go v0.9.0, the latest release | 10.9.194.9 (`v8go.Version()`) | 11.1.277.13 (`deps/v8_version`) |
| PyMiniRacer 0.14.1 | 14.4.258.23 (`MiniRacer().v8_version`) | not recorded; the library holds the one version string, 14.4.258.23 |

v8go v0.9.0's metadata names 11.1.277.13, but the prebuilt `libv8.a` it ships carries the string `10.9.194.9-v8go` on all four platforms (darwin arm64 and x86_64, Linux arm64 and x86_64), and `v8go.Version()` returns that. This folder uses the runtime value. Neither v8go version has the vendored trig code: the build's `deps/build.py` has no GN argument naming `libm` or trig (0), `libv8.a` has no string naming `use_libm_trig` (0), and d8 9.0.257 and 10.9.194 list no `--use-libm-trig-functions` flag in `--help` (0 lines each). PyMiniRacer's library carries the flag's help text, `use libm trig functions`, and d8 14.4.258's `--help` lists the flag (2 lines, default on).

### The bug's input through each copy

`Math.sin(1.1986535513718587e+138)`, from the "probe sin" sections. Each row's result is the bits of the double, as 16 hex digits.

| Row | V8 | Result bits | Result |
| --- | --- | --- | --- |
| v8go at `12b0374` | 9.0.257.18 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| d8 9.0.257 | 9.0.257 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| v8go v0.9.0 (run 4) | 10.9.194.9 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| d8 10.9.194 (run 4) | 10.9.194 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| PyMiniRacer 0.14.1, trig flag on (default) | 14.4.258.23 | `3cbb779ceaa3bc42` | `3.811845021115429e-16` |
| d8 14.4.258, trig flag on (default) | 14.4.258 | `3cbb779ceaa3bc42` | `3.811845021115429e-16` |
| PyMiniRacer 0.14.1, `--no-use-libm-trig-functions` | 14.4.258.23 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| d8 14.4.258, `--no-use-libm-trig-functions` | 14.4.258 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| Node.js 26.13.1 | 14.6.202.34-node.40 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |
| Node.js 24.19.0 | 13.6.233.17-node.51 | `3cbb779ceaa3c069` | `3.811845021115953e-16` |

The two bit patterns differ by `0x427`, which is 1,063 as a count of doubles. The post's "1,063 ULP low" is that difference, and its "correct" is `3cbb779ceaa3c069`.

### Bit for bit against d8

For each binding, the run file's comparison lines list the probes whose output is identical to d8's at the build named in the row. There are six probes: `sin`, the bug's input; `na`, six `atan2` values; `ke`, `log1p` and `expm1` values; `ra`, `asinh`, `acosh`, and `atanh` values; `gl`, `log`, `log10`, and `log2` of subnormals and the smallest normal; and `control`, 7,820 cases over `Math`'s functions. A probe is identical when its output text is the same, and for `control`, when the hash of the 7,820 lines is the same. Every probe ran twice on every row, and every repeat matched.

| Binding row | Compared with | Probes identical | Differing | Run |
| --- | --- | --- | --- | --- |
| v8go at `12b0374` | d8 9.0.257 | 6 of 6 | none | run 3 |
| v8go v0.9.0 | d8 10.9.194 | 6 of 6 | none | run 4 |
| PyMiniRacer 0.14.1, trig flag on | d8 14.4.258 | 6 of 6 | none | runs 3 and 4 |
| PyMiniRacer 0.14.1, flag off | d8 14.4.258, flag off | 6 of 6 | none | runs 3 and 4 |

The `control` output is identical in more places than the pairs in the table. The four rows at V8 9.0 and 10.9 (v8go at `12b0374`, d8 9.0.257, v8go v0.9.0, and d8 10.9.194) give one output, byte for byte, and PyMiniRacer and d8 14.4.258 give another, with the flag on and with it off. `control-output-sha256.results.txt` lists the hash of every row's output. The "digest" in the run files is the first 16 hex digits of that hash.

d8 14.6.202, the V8 in Node.js 26.13.1, gives the same `control` output as d8 14.4.258 and PyMiniRacer (digest `6837870d4acd9392`), and with the flag off the same as d8 14.4.258 with it off. This is in `mac-d8-14.6.202-supplement.results.txt`.

### Against Node.js 26.13.1

Counted by the run files' `unrun-math-compare.js` lines, with Node.js 26.13.1 as the reference, over the 7,820 `control` cases. "Differ" counts values that differ, each by 1 ULP in every row; "NaN payload only" counts cases where both give NaN with different payload bits.

| Row | Bit-identical | NaN payload only | Values differ |
| --- | --- | --- | --- |
| v8go at `12b0374`, and v8go v0.9.0 | 7,703 | 57 | 60 (`pow` 48, `tan` 5, `asin` 3, and `sin`, `acos`, `atanh`, and `log10` 1 each) |
| PyMiniRacer 0.14.1, trig flag on | 7,790 | 0 | 30 (`cos` 10, `sin` 9, `tan` 5, `asin` 3, and `acos`, `atanh`, and `log10` 1 each) |
| PyMiniRacer 0.14.1, flag off | 7,808 | 0 | 12 |
| Node.js 24.19.0 | 7,763 | 57 | 0 |

d8 9.0.257, d8 10.9.194, and d8 14.4.258 (flag on) give the same counts as their bindings' rows, so the differences from Node.js follow the V8 build, not the embedding. For the flag-off row, the supplement's d8 14.6.202 with the flag off, against the same reference, also has 12 values differing.

## Sources pinned

| What | Pinned to |
| --- | --- |
| v8go, the commit run | [`12b0374faffcc6a93eb284808ca1beab58259e72`](https://github.com/rogchap/v8go/commit/12b0374faffcc6a93eb284808ca1beab58259e72), 2021-11-17, a pull request commit on no branch or tag (read with `gh api` on 2026-11-17: it diverges from v0.7.0 by 7 commits ahead and 1 behind), run as Go module `rogchap.com/v8go v0.6.1-0.20211117174756-12b0374faffc` |
| v8go v0.9.0 | tag commit [`0e40e6e5827ad897d25f915917d8206e9a8231db`](https://github.com/rogchap/v8go/commit/0e40e6e5827ad897d25f915917d8206e9a8231db), 2023-03-20; `deps/darwin_arm64/libv8.a` is 55,859,440 bytes, SHA-256 prefix `0109276cbf192519` |
| v8go's last V8 commit, which sets the metadata to 11.1.277.13 | [`be4ff5ecead3461733ef5b9e1268faac4cfe3185`](https://github.com/rogchap/v8go/commit/be4ff5ecead3461733ef5b9e1268faac4cfe3185), 2023-03-20 |
| v8go's last change to the prebuilt `libv8.a`, 10.9.194.9 | [`02e1763d01762e1397996f5543d11bf051403a83`](https://github.com/rogchap/v8go/commit/02e1763d01762e1397996f5543d11bf051403a83), 2023-01-30 |
| PyMiniRacer 0.14.1 | tag commit [`95b89887e74103a91747bca45a1e35ff0e1b81c3`](https://github.com/bpcreech/PyMiniRacer/commit/95b89887e74103a91747bca45a1e35ff0e1b81c3), 2026-02-01; wheel `mini_racer-0.14.1-py3-none-macosx_11_0_arm64.whl`, SHA-256 `56cc6965a1665a50d8d613bc43aa83b4cec6b1f09acc69dc4c2845dacb201463`, matched against PyPI's |
| V8's vendored glibc `sin` and `cos` | [`4588fe544f78784f5d3a8861886cd4d73f20ab1e`](https://github.com/v8/v8/commit/4588fe544f78784f5d3a8861886cd4d73f20ab1e), 2022-11-30 |
| d8 9.0.257, 10.9.194, 14.4.258, and 14.6.202 | jsvu builds; SHA-256 prefixes `e630152758822a90`, `07749d6f15bf44c3`, `9fbb1a2caa0cc738`, and `fb9af3ddddfed69b` |
| Node.js 24.19.0 and 26.13.1 | nvm builds; SHA-256 prefixes `27db838bb204ef7c` and `266dec4dce3a6cdc` |

## Committed outputs

| File | What it is | Regenerated or captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/mac-bindings-run3.results.txt` | v8go at `12b0374` and PyMiniRacer 0.14.1 against d8 9.0.257 and 14.4.258 and Node.js 24.19.0 and 26.13.1: build metadata, five probes, the control's hashes, and the comparisons | captured, not rerun | 2026-11-17 | macOS arm64 (26.6.2, Apple M1 Pro) |
| `results/mac-bindings-run4.results.txt` | the same, with v8go v0.9.0 and d8 10.9.194 in place of the first pair | captured, not rerun | 2026-11-17 | macOS arm64 (26.6.2, Apple M1 Pro) |
| `results/mac-d8-14.6.202-supplement.results.txt` | d8 14.6.202 against Node.js 26.13.1 and against d8 14.4.258 | captured, not rerun | 2026-11-17 | macOS arm64 (26.6.2, Apple M1 Pro) |
| `results/control-v8-9.0-and-10.9.results.txt` | the 7,820-case `Math` control output of v8go and d8 at V8 9.0 and 10.9 | captured, not rerun | 2026-11-17 | macOS arm64 (26.6.2, Apple M1 Pro) |
| `results/control-v8-14.4.results.txt` | the same control output for PyMiniRacer and d8 at V8 14.4, flag on | captured, not rerun | 2026-11-17 | macOS arm64 (26.6.2, Apple M1 Pro) |
| `results/control-v8-14.4-trig-flag-off.results.txt` | the same, flag off | captured, not rerun | 2026-11-17 | macOS arm64 (26.6.2, Apple M1 Pro) |
| `results/control-output-sha256.results.txt` | the SHA-256 of every row's control output, both repeats, in runs 3 and 4 | computed for this repository from the runs' outputs, not a rerun | 2026-11-19 | the hashes are of macOS arm64 outputs |

The run files are the original outputs with a header added and the scratch and home directories replaced by `<scratch>` and `~`. Each `control-*` file is a header, then the original output's lines unedited: dropping the lines that begin with `#` gives the output the hashes are of.

## What the full folder will hold

- The driver script, which records every version and build fact, builds the Go harness, runs every probe twice on every row, and compares; the Go harness for v8go and the Python harness for PyMiniRacer, which pass V8 flags through when given.
- The probe files and the case generator for the 7,820-case control, with a checksum of the generator's output, not the case file.
- The install steps: jsvu for the d8 builds, nvm for Node.js, `go get` of v8go at the commit and at v0.9.0, and `pip` for the PyMiniRacer wheel with its SHA-256 checked.
- The raw outputs of every row and repeat, not only the three distinct control outputs, as the full set of both runs' files.
- Runs on Linux, where both bindings ship their own builds.

## Scope

- Everything was measured on macOS arm64, on one Mac: macOS 26.6.2, Apple M1 Pro, with Go 1.27.4 and Python 3.13.18 from conda-forge and Apple clang 21.0.0 compiling v8go's C++. v8go's `darwin_arm64` `libv8.a` and the `macosx_11_0_arm64` PyMiniRacer wheel are the builds that ran. The Linux and Windows builds weren't run.
- These are the latest PyMiniRacer release, 0.14.1, and two v8go versions, the commit and v0.9.0. v8go v0.7.0 and v0.8.0, and other PyMiniRacer versions, weren't run, and no other binding was.
- "Matches d8" means matching d8 at the same build number. A d8 from jsvu is at the build, such as 9.0.257, and each binding is at a patch level on that build's branch, such as `.18`. The outputs match, and the binaries differ.
- The outputs contain no reference computation. "Correct" is the bug's correctly rounded value, `3.811845021115953e-16`, as the post gives it; the run compares bits between engines and builds.
- The 1-ULP differences from Node.js weren't checked against a reference, and the compiler and flags behind them weren't compared.
- PyMiniRacer's default V8 flags are `--single-threaded`, and its `__about__.py` says version 0.14.0 inside the 0.14.1 wheel; neither touches V8.
- Two earlier runs of the same driver aren't kept. The first ran the `print` one-liners on Node.js unchanged, so two probes threw a `ReferenceError` there, and it counted NaN payloads as ULP distances. The second fixed the first problem and kept the second, and it recorded d8 14.4.258's `control` output differing from its own repeat in 22 lines, where `asin` and `acos` out of domain returned a NaN with payload `7ff4000000000000` once and `7ffc000000000000` the other time. In the runs kept here, every d8 and binding repeat matched.
