# scriptc

> Captured results from earlier runs and readings, not regenerated. This folder has no scripts.

Backs the post's footnote `[^scriptc]`, and the sentence in "The families" that says scriptc, "the last post's compiler with no engine at run time, carries a C port of V8's maths code, and its `Math` matches Node.js 24.19.0's bit for bit on all 7,820 cases tested: no engine, and still V8's answers."

The run was measured on Linux x86_64 in a Claude Code Cloud VM.

## What was run

On 2026-11-02, on an x86_64 Linux VM in Claude Code Cloud (Ubuntu 24.04, [glibc 2.39](https://github.com/bminor/glibc/releases/tag/glibc-2.39)), scriptc [0.4.7](https://www.npmjs.com/package/scriptc/v/0.4.7), installed from npm, compiled a typed `Math` control program of 7,820 cases across 24 functions to a native executable, linked by [clang 18.1.3](https://github.com/llvm/llvm-project/releases/tag/llvmorg-18.1.3) (Ubuntu). Node.js [v24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0) ran the same cases, and the two outputs have the same bits on all 7,820. A second Node.js, [v24.22.2](https://github.com/nodejs/node/releases/tag/v24.22.2), gives the same digest. The folder also records a reading of scriptc's source at that version and of the log of its release run, which are readings, not runs.

## Claim

scriptc [`4af5844`](https://github.com/vercel-labs/scriptc/commit/4af5844f522b2762716226114262fd7dd86c8e65) is a compiler with no engine at run time. It carries its own C port of V8's maths code, as Node.js [v24.22.0](https://github.com/nodejs/node/releases/tag/v24.22.0) bundles it, and its `Math` matches Node.js 24.19.0's bit for bit on all 7,820 cases tested. `Math.pow` alone goes to the platform's `pow`. "V8" here means Node.js's build of it, not d8's; d8's results weren't part of this comparison.

The source reading and the run are of scriptc 0.4.7, tag `v0.4.7`, commit [`6c60b0b`](https://github.com/vercel-labs/scriptc/commit/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff), which is the version the footnote cites. The post's families table links `4af5844` for the project; nothing in this folder reads the port at that commit.

## Tier

c: results only.

## What the committed results show

- **The case set.** `scriptc-typed-control-output.results.txt` has one line per case, 7,820 in all, and then the program's own count line, `cases 7820`. By function name: 21 one-argument functions at 320 cases each (`acos`, `acosh`, `asin`, `asinh`, `atan`, `atanh`, `cbrt`, `cos`, `cosh`, `exp`, `expm1`, `fround`, `log`, `log10`, `log1p`, `log2`, `sin`, `sinh`, `sqrt`, `tan`, `tanh`), `atan2` and `hypot` at 300 each, and `pow` at 500: 6,720 + 600 + 500 = 7,820. A line carries the function, then the bits of each argument and of the result, in hex.
- **The match.** In `scriptc-vs-node.results.txt`, the row `scriptc+typed` and the row `node24-ref` (Node.js [v24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0), V8 [13.6.233.17-node.51](https://github.com/nodejs/node/blob/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae/common.gypi#L44)) have the same bits digest, `0429ac9a4a2f1efb`, and the comparison reads "compared 7820, bit-identical 7820, NaN payload only 0, value differs 0, unmatched lines 0". The two output files in `results/` have identical data lines (the same sha256, in each header).
- **A second Node.js.** The same file records Node.js [v24.22.2](https://github.com/nodejs/node/releases/tag/v24.22.2) (V8 [13.6.233.17-node.63](https://github.com/nodejs/node/blob/f7f273a9bb6445f6f7fb6349105e7532972045fb/common.gypi#L45)), the Node.js line the port names, giving the same digest on the control, "byte-identical" to both the v24.19.0 output and scriptc's.
- **Where the bits come from.** `scriptc-binary-links.results.txt` shows the compiled executable defining `scr_ieee754_*` functions and `scr_math_pow`, and importing one function from the C library's `libm`, `pow`. In `scriptc-vs-node.results.txt`, both scriptc and Node.js differ from glibc 2.39's own functions on 542 of the control's 7,821 output lines, so the match with Node.js isn't a match with glibc.
- **The source and the build.** `results/recorded-readings.md` records the source reading at `6c60b0b` (the port's files, and `pow`'s routing) and a read of the release run's CI logs.

## Committed outputs

| File | What it is | Regenerated or captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/scriptc-typed-control-output.results.txt` | 7,820 `Math` cases run through scriptc's compiled typed control | captured, not rerun | 2026-11-02 | Claude Code Cloud, x86_64 VM; glibc 2.39 |
| `results/node-v24.19.0-control-output.results.txt` | the same cases through Node.js v24.19.0 | captured, not rerun | 2026-11-02 | Claude Code Cloud, x86_64 VM; glibc 2.39 |
| `results/scriptc-vs-node.results.txt` | digests, the bit-for-bit comparison, the glibc cross-check, and the Node.js v24.22.2 check | captured, not rerun | 2026-11-02 | Claude Code Cloud, x86_64 VM; glibc 2.39 |
| `results/scriptc-binary-links.results.txt` | what the compiled executable defines and imports | captured, not rerun | 2026-11-02 | Claude Code Cloud, x86_64 VM; glibc 2.39 |
| `results/scriptc-untyped-control-compile-error.results.txt` | scriptc's compile error on the control as first written | captured, not rerun | 2026-11-02 | Claude Code Cloud, x86_64 VM; glibc 2.39 |
| `results/recorded-readings.md` | the source reading at `6c60b0b` and the release run's CI logs | recorded readings, not runs | 2026-11-02 and 2026-11-18 | not applicable |

The five `.results.txt` files are the original outputs with a header added, or lines selected from them, as each header says. The data lines are unedited.

## Sources pinned

| What | Pinned to |
| --- | --- |
| scriptc source and release | [`6c60b0b`](https://github.com/vercel-labs/scriptc/commit/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff), tag [`v0.4.7`](https://github.com/vercel-labs/scriptc/releases/tag/v0.4.7) |
| The port | [`packages/runtime/src/scr_ieee754.c` at `6c60b0b`](https://github.com/vercel-labs/scriptc/blob/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff/packages/runtime/src/scr_ieee754.c), git blob `798bcbcbcc5a0536150b3640e84b89475fe5cc74` |
| The release run | [run 41153019462](https://github.com/vercel-labs/scriptc/actions/runs/41153019462), expired logs |
| The project at the commit the post's table links | [`4af5844`](https://github.com/vercel-labs/scriptc/commit/4af5844f522b2762716226114262fd7dd86c8e65) |
| Node.js reference | [v24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0), commit [`cdc1b38`](https://github.com/nodejs/node/commit/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae), V8 [13.6.233.17-node.51](https://github.com/nodejs/node/blob/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae/common.gypi#L44) (nvm); no binary hash is committed |
| The second Node.js | [v24.22.2](https://github.com/nodejs/node/releases/tag/v24.22.2), commit [`f7f273a`](https://github.com/nodejs/node/commit/f7f273a9bb6445f6f7fb6349105e7532972045fb), V8 [13.6.233.17-node.63](https://github.com/nodejs/node/blob/f7f273a9bb6445f6f7fb6349105e7532972045fb/common.gypi#L45) (nvm); it also ran `npm install` of scriptc |
| The Node.js the port names | [v24.22.0](https://github.com/nodejs/node/releases/tag/v24.22.0), and, in the later check, [v24.22.1](https://github.com/nodejs/node/releases/tag/v24.22.1); both named in comments in `scr_ieee754.c`, neither run |
| V8, the source of the port | [13.6.233.17](https://github.com/v8/v8/tree/13.6.233.17), commit [`b0a55a7`](https://github.com/v8/v8/commit/b0a55a7dad7f536cce1f9aaddba89894c8533946), whose [`src/base/ieee754.cc`](https://github.com/v8/v8/blob/b0a55a7dad7f536cce1f9aaddba89894c8533946/src/base/ieee754.cc) is the file the port is of |
| The npm package | [`scriptc@0.4.7`](https://www.npmjs.com/package/scriptc/v/0.4.7), and the compiler binary's package, [`@scriptc/cli-linux-x64-gnu` 0.4.7](https://www.npmjs.com/package/@scriptc/cli-linux-x64-gnu/v/0.4.7), the version `scriptc@0.4.7`'s `optionalDependencies` name |
| C compiler and C library | [clang 18.1.3](https://github.com/llvm/llvm-project/releases/tag/llvmorg-18.1.3) (Ubuntu) and [glibc 2.39](https://github.com/bminor/glibc/releases/tag/glibc-2.39) (Ubuntu 24.04), as the headers record them |

## Scope

- This is one build: scriptc 0.4.7, on Linux x86_64, with glibc 2.39. Nothing here covers another version, another operating system, or another architecture.
- The run used a typed variant of the control. scriptc's compiler rejected the original, which keeps rows of mixed type in one array, with the error `SC0001` (`scriptc-untyped-control-compile-error.results.txt`); the typed variant splits each table into arrays of one type. On Node.js, the typed variant's output is byte-identical to the original's (sha256 prefix `38ff3e5e7738d8c3`, in `scriptc-vs-node.results.txt`).
- The 7,820 cases are the control's own, across 24 `Math` functions. The match says nothing about the `Math` functions the control doesn't call.
- `Math.pow` goes to the platform's `pow`, glibc 2.39's here, which V8's `Math.pow` also calls; the match on `pow`'s 500 cases is a match with Node.js's build running on the same C library.
- "V8" means Node.js's build of it. d8, V8's own shell, wasn't run in this comparison.
- The comparison is of results: the port is read from source, and the pack that ran was installed from npm. The release run's logs show the pack was built from source in CI at `6c60b0b`, with no compile line for the port by name, and the logs have expired (`results/recorded-readings.md`).
- The Node.js binaries aren't hashed in these outputs, and the original run's machine isn't recorded beyond the platform label.
