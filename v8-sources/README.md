# Where V8's maths comes from

Backs `[^v8]` and `[^v8-move]` in "Whose maths is it?": V8's four sources for `Math`, and when each moved.

Measured on macOS arm64 (Apple M1 Pro), and on Linux VMs in Claude Code Cloud (x86_64) and OrbStack (an x86_64 container under emulation). The Linux script runs on any Docker host.

## What was run, and what it shows

`check.sh` compiled V8's copy of glibc's `sin` and `cos` (from V8 13.6.233.17, built with Apple clang 21.0.0 once with floating-point contraction off and once on) and ran case files generated from stdlib's test fixtures through the copy, through d8 [13.6.233](https://github.com/v8/v8/commit/04fa9cbe26525ab96ab3ff2a18b5d25e443e12fa), [14.6.202](https://github.com/v8/v8/commit/e04c3a1a2543bdbee7beac8846c9cbe8f657636f), and [15.8.32](https://github.com/v8/v8/commit/e5a1c6353fce563774685e8b6d45262d57f0229b), through Node.js [24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0) and [26.13.1](https://github.com/nodejs/node/releases/tag/v26.13.1), and through macOS's C library: 23,995 cases each for `sin` and `cos`, 69,633 for `pow`. On both functions, d8's default in 13.6.233 and 14.6.202 equals the copy built with contraction off on all 23,995 cases. On `pow`, every engine matches macOS's `pow` on all but 2 of 69,633 cases.

`sources.sh` read the pinned V8 and glibc source lines and commit metadata through GitHub, and `glibc-diff.sh` compared V8's copy with glibc file by file: two files are identical, three differ in 2 to 4 lines, and `s_sin.c` differs in 30. `bisect.js` probed published d8 builds from 14.6.202 to 15.4.8 with 88 inputs per build, once per function family, and found each family changing between two adjacent published builds, all in V8 15.0 (the lines are quoted under "Expected output"). The same bisection on linux64 builds, and an earlier one, agree.

## Claim

> V8 is the clearest case, because by default it draws its `Math` from four places, and they've changed with its version. Its own code, for most functions ... A copy of glibc's code, for `sin` and `cos`, from V8 11.0 (late 2022) until 15.0 ... They're glibc's code apart from build glue, and d8's default `sin` and `cos` match them on every case tested. LLVM's maths library, from 15.0, in May 2026, for most functions, one family per commit ... The platform's C library, for `pow`, by a flag that's on by default. `pow` was never V8's own code, so 15.0 had nothing to move.

In the footnotes: the glibc copy is `third_party/glibc` (README at 13.6.233.17), switched in commit `4588fe544f78784f5d3a8861886cd4d73f20ab1e` (30 November 2022, V8 11.0), reverted, and relanded (`7519793`, 2 December 2022). d8 13.6.233's and 14.6.202's default `sin` and `cos` match glibc's source, compiled on the Mac, on all 23,995 cases of each. `pow` calls the platform's `std::pow` after two shortcuts, and d8 13.6.233, 14.6.202, and 15.8.32 and Node.js 24.19.0 and 26.13.1 match macOS's `pow` on all but two of 69,633 cases, both `x ** 2`. V8's build sets `v8_use_libm_trig_functions = is_clang`. `tan` moved to LLVM's libm in `cc1a6fc` (11 May 2026, "[math] Implement Math.tan() using LLVM's libm"), and a per-family bisection of published d8 builds shows each family moving in a single step in V8 15.0.

## Tier

*b: needs a Mac and particular binaries* for the measurements: macOS arm64 with `clang` and `objdump`, Node.js 24.19.0 and 26.13.1 installed with nvm (the script reads `$NVM_DIR`, default `$HOME/.nvm`), curl, unzip, and Node.js. `sources.sh` and `glibc-diff.sh` need curl, Node.js, and diff, so they run anywhere (*a*). The bisection result is *c* as a published result, and the rerun needs a Mac or Linux machine with curl, unzip, and Node.js, and takes several minutes. d8 comes from V8's public build bucket, not from jsvu, and no `Math` result depends on how it was installed.

## Rerun

Set `PLATFORM_LABEL` to name the environment the run happens in; it is printed first on the output's platform line. The committed Linux outputs use "Claude Code Cloud, x86_64 VM", "OrbStack, aarch64 Linux VM on macOS", and "OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation".

From the repository root. Run `node lib/gen-cases.js` once first, after `./lib/fetch-stdlib-fixtures.sh`, to generate the case files into `.cache/cases/` (see `lib/gen-cases.js`; the fixtures are fetched at a pinned commit and `lib/cases.sha256` checks the result).

```bash
./lib/fetch-stdlib-fixtures.sh && node lib/gen-cases.js --check   # the case files, checked against lib/cases.sha256
./v8-sources/check.sh          # sin, cos, pow against V8's glibc copy and the platform: about 30 seconds
./v8-sources/sources.sh        # the source lines and commits the footnotes cite
./v8-sources/glibc-diff.sh     # V8's copy against glibc, file by file
node v8-sources/bisect.js      # which published build each function changes in: several minutes, about 40 builds of about 19 MB each downloaded (34 distinct builds were probed in the committed macOS run, plus the endpoints and the rechecks)
./v8-sources/run-bisect-linux.sh   # the same on linux64 builds, in a container
```

`sources.sh` calls GitHub's REST API about a dozen times without authentication, under its limit of 60 requests an hour; set `GITHUB_TOKEN` to raise it.

## Expected output

- **`sin` and `cos`**, `results/math-sources-mac-arm64.txt`, Part 1. V8's copy is compiled with `-ffp-contract=off` (0 fused instructions), and d8's default column equals it: `sin-d8-13.6.233-default-1 vs sin-copy-contract-off 0 of 23995 differ`, and the same line for 14.6.202, and for `cos` (also `0 of 23995`). Built with contraction on (73 fused instructions) the copy differs from d8 on 12 `sin` and 28 `cos` cases. With the trig flag turned off, d8 stops matching the copy, differing on 784 `sin` and 804 `cos` cases; Node.js 24.19.0 and 26.13.1 differ from the copy on 766 and 810 (Part 3 shows they reject `--no-use-libm-trig-functions` as a bad option); d8 15.8.32, after the copy's removal, differs on 32 and 58. Every d8 column was run twice, and the repeats matched.
- **`pow`**, Part 2: `pow-d8-13.6.233-default-1 vs pow-platform-libm 2 of 69633 differ`, the same for d8 14.6.202 and 15.8.32 and for both Node.js builds. The section after Part 2 lists the two inputs for each, the same two, both with `y` equal to 2, where V8 computes `x ** 2` as `x * x` and the two results differ in the last hex digit by one. With `--no-use-std-math-pow`, d8 13.6.233 differs from the platform on 4,383 cases and d8 15.8.32 on 118.
- **Source lines**, `results/sources.txt`: `Revision: 4e21c2075193e406a92c0d1cb091a7c804fda4d9` and "a handful of files that are forked from glibc" in `README.v8`; `v8_use_libm_trig_functions = is_clang` at `gni/v8.gni` line 169; both flags defaulting to `true`; `return std::pow(x, y);` after the `y == 2` and `y == 0.5` shortcuts; commit titles and dates for `4588fe5` (30 November 2022; `include/v8-version.h` reads major 11, minor 0), its revert `ea18ee8ff8…` (1 December), the reland `7519793…` (committer date 2 December), `cc1a6fc…` ("[math] Implement Math.tan() using LLVM's libm", 11 May 2026), and `8787f08…` ("Remove ability to call glibc sin/cos", committer date 6 July 2026; its author date is 18 May).
- **The copy against glibc**, `results/glibc-diff.txt`: `mydefs.h` and `usncs.h` identical; `branred.c`, `branred.h`, and `sincostab.c` differ in 2 to 4 lines of includes; `s_sin.c` in 30 lines, which are includes, the two function names, and removed side effects (the rounding-mode guard, `errno`, and the underflow check); `dla.h` cut down; `endian.h` and `trig.h` V8's own.
- **The bisection**, `results/bisect-mac-arm64.txt`, last section: `log`, `log10`, `log2` change between 15.0.45 and 15.0.46; `tan` between 15.0.48 and 15.0.49 (the linux64 builds skip those two numbers, so `results/bisect-linux64.txt` has 15.0.47 to 15.0.50); `acos`, `asin` between 15.0.104 and 15.0.105; `cos`, `sin` between 15.0.114 and 15.0.115; `exp` between 15.0.117 and 15.0.118; `atan`, `atan2` between 15.0.199 and 15.0.200. Each boundary build was probed twice more, fresh, with the same class each time. No function's bisection hit a build that was neither endpoint's class, so each change is a single step in the published list of 1,200 builds between the endpoints; the bisection tests only the builds it lands on, so a change that reverted and came back between two probes would not show.

## Committed outputs

| File | What it is | Status | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/math-sources-mac-arm64.txt` | d8 13.6.233, 14.6.202, 15.8.32 and Node.js 24.19.0, 26.13.1 on `sin`, `cos`, `pow` against V8's glibc copy and the platform's library; the Node.js flag check | regenerated for this repository | 2026-11-19 | macOS 26.7.3, arm64, Apple M1 Pro, Apple clang 21.0.0 |
| `results/sources.txt` | Pinned source lines and commit metadata read from GitHub | regenerated for this repository | 2026-11-19 | any (curl and Node.js) |
| `results/glibc-diff.txt` | V8's copy against glibc at the named revision | regenerated for this repository | 2026-11-19 | any (curl and diff) |
| `results/bisect-mac-arm64.txt` | Per-function bisection of published macOS arm64 d8 builds, 14.6.202 to 15.4.8 | regenerated for this repository | 2026-11-19 | macOS 26.7.3, arm64, Apple M1 Pro |
| `results/bisect-linux64.txt` | The same on published linux64 builds, in a container | regenerated for this repository | 2026-11-19 | OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation; Ubuntu 24.04, linux/amd64 |
| `results/captured-bisect-linux64-2026-10-23.txt` | The earlier per-function bisection on linux64 builds, as far as its summary | captured earlier, not rerun | 2026-10-23 | Claude Code Cloud, x86_64 VM; Intel Xeon 2.10 GHz; host name stripped |
| `math-cases.txt`, `math-probe.js` | The 88 probe inputs (8 per function where d8 14.6.202 and 15.4.8 differ on Linux), and the d8 script generated from them | captured earlier (the inputs); regenerated (the script, byte for byte from the inputs) | 2026-10-23 | the inputs come from Linux x86_64 result columns |
| `versions-mac-arm64-14-15.txt`, `versions-linux64-14-15.txt` | The 14.x and 15.x builds published in the bucket for each platform | regenerated for this repository | 2026-11-19 | any (curl and Node.js) |

**Where this rerun differs from the earlier one.** The `sin`, `cos`, and `pow` results are identical to the earlier run's: every hash and count above equals it, including 0 of 23,995 for the copy against d8. The bisection of the linux64 builds gives the earlier windows for every function, `tan` included (15.0.47 to 15.0.50). The macOS bisection gives the same windows except for `tan`, whose window there is 15.0.48 to 15.0.49, because those two builds exist for macOS and not for Linux; both windows contain the same commit, `cc1a6fc`. The macOS version is 26.7.3 (it was 26.6.2), and d8 now comes from the bucket directly instead of through jsvu; the binaries' SHA-256 values equal the earlier ones.

## Sources pinned

| What | Pin |
| --- | --- |
| [V8](https://github.com/v8/v8) 13.6.233.17 (BSD-3-Clause), for `third_party/glibc`, `gni/v8.gni`, `src/flags/flag-definitions.h`, `src/numbers/ieee754.cc`, `src/base/ieee754.cc` | tag 13.6.233.17, commit [`b0a55a7dad7f536cce1f9aaddba89894c8533946`](https://github.com/v8/v8/commit/b0a55a7dad7f536cce1f9aaddba89894c8533946); the nine glibc-copy files' SHA-256 values are in `glibc-files.sha256`, and `check.sh` stops if one differs |
| [glibc](https://github.com/bminor/glibc) (LGPL-2.1-or-later), `sysdeps/ieee754/dbl-64/` | commit [`4e21c2075193e406a92c0d1cb091a7c804fda4d9`](https://github.com/bminor/glibc/commit/4e21c2075193e406a92c0d1cb091a7c804fda4d9), the revision in V8's `README.v8` |
| V8 commits | [`4588fe544f78784f5d3a8861886cd4d73f20ab1e`](https://github.com/v8/v8/commit/4588fe544f78784f5d3a8861886cd4d73f20ab1e), [`ea18ee8ff8ecf50ef09593551eed40c9e554fabc`](https://github.com/v8/v8/commit/ea18ee8ff8ecf50ef09593551eed40c9e554fabc), [`7519793938af3bb5e74594a45da10bc04bd33f20`](https://github.com/v8/v8/commit/7519793938af3bb5e74594a45da10bc04bd33f20), [`cc1a6fcbdabbe4c912948bebe29371c084eade33`](https://github.com/v8/v8/commit/cc1a6fcbdabbe4c912948bebe29371c084eade33), [`8787f0842a158b0be8de8b4ae9b1d2f89a40d8ab`](https://github.com/v8/v8/commit/8787f0842a158b0be8de8b4ae9b1d2f89a40d8ab), read through GitHub's API by SHA |
| d8 13.6.233, 14.6.202, 15.8.32, and the builds the bisection probes | published builds, `storage.googleapis.com/chromium-v8/official/canary/v8-<platform>-rel-<version>.zip`: [13.6.233](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-13.6.233.zip), [14.6.202](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-14.6.202.zip), and [15.8.32](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-15.8.32.zip) for macOS arm64, and the bisection's other endpoint [15.4.8](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-15.4.8.zip); the probed versions are listed in `versions-mac-arm64-14-15.txt` and `versions-linux64-14-15.txt`. The V8 source for the three named builds is at the tags' commits, [13.6.233](https://github.com/v8/v8/commit/04fa9cbe26525ab96ab3ff2a18b5d25e443e12fa), [14.6.202](https://github.com/v8/v8/commit/e04c3a1a2543bdbee7beac8846c9cbe8f657636f), and [15.8.32](https://github.com/v8/v8/commit/e5a1c6353fce563774685e8b6d45262d57f0229b). `check.sh` prints the first 16 hex digits of each binary's SHA-256 (`6b91f615cd9b0c12`, `fb9af3ddddfed69b`, `a59f1e33fd8f5163`) |
| Node.js [24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0), [26.13.1](https://github.com/nodejs/node/releases/tag/v26.13.1) | nvm installs; `check.sh` prints the first 16 hex digits of each binary's SHA-256 (`27db838bb204ef7c`, `266dec4dce3a6cdc`) and its V8 version (`13.6.233.17-node.51`, `14.6.202.34-node.40`) |
| [stdlib](https://github.com/stdlib-js/stdlib) test fixtures (Apache-2.0) | commit [`550666096f34c73f90f4bf86139935e4214fe421`](https://github.com/stdlib-js/stdlib/commit/550666096f34c73f90f4bf86139935e4214fe421), through `lib/fetch-stdlib-fixtures.sh` |

## Scope

- **Chromium's own build of V8, and Chrome, aren't run.** The post says that by the same build configuration a clang build of Chrome would have had the glibc `sin` before 15.0, and that no older Chrome was run.
- **Node.js's gyp files aren't read.** The footnote says they don't mention `v8_use_libm_trig_functions` at v24.19.0. This repository shows the consequence: the flag is a bad option, and the copy's results don't match.
- **The tracking bug's text** ([issue 510499297](https://issues.chromium.org/issues/510499297)) isn't fetched, and the commit messages that cite it aren't reproduced.
- **The bisection covers 14.6.202 to 15.4.8** and the functions the earlier run bisected; it doesn't cover `tanh`, `sinh`, and `cosh` in 15.9.
- **The accuracy figures in V8's commit messages** (for example the maximum errors of the old and new `sin`) aren't reproduced; the commit hashes are pinned for a reader who wants them.
