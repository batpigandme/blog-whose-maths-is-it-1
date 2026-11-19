# sin-demo: `Math.sin` on one huge argument

Backs the post's opening demo and two footnotes: `[^sin-check]` (d8, Node.js, glibc, and Chrome 158 on `Math.sin( 1.1986535513718587e+138 )`), `[^versions]` (two Node.js patch releases, and the V8 in Node.js 26.13.1).

Measured on macOS arm64 (Apple M1 Pro), and on Linux VMs in OrbStack (an aarch64 Linux VM on a Mac) and in Claude Code Cloud (an x86_64 VM). The scripts run on any Docker host.

## Claim

> On a Mac (macOS on arm64), d8, V8's own command-line shell, at 13.6.233 and 14.6.202, returns `3.811845021115429e-16`. The correctly rounded answer is `3.811845021115953e-16`, and the first is 1,063 ULP below it. Bit for bit, it's what glibc 2.39's own `sin` gives for that input. Node.js 24.19.0 (V8 13.6), on the same Mac, gives the correctly rounded answer, and so does d8 15.8.32. So does Chrome 158 (V8 15.8).

And, in the footnotes: d8's default value is a glibc bug with huge arguments, fixed in glibc 2.44 ([bug 34376](https://sourceware.org/bugzilla/show_bug.cgi?id=34376)); Node.js 24.19.0 and 24.22.3 both carry V8 13.6.233.17, differing only in the suffix `-node.51` against `-node.63`, and "give the same `Math` answers on every case tested."

The input is the float64 with bits `5c99c487f2337e3a`, `1.1986535513718587e+138`, from [Chromium bug 511271840](https://issues.chromium.org/issues/511271840). The correctly rounded `sin` is `3cbb779ceaa3c069`; the d8 and glibc value is `3cbb779ceaa3bc42`; the two differ by 1,063 in their bit patterns, which is 1,063 ULP.

## Tier

*b: needs a Mac or particular binaries.*

- `d8.sh`: macOS or Linux, with jsvu's d8 builds 13.6.233, 14.6.202, and 15.8.32 and nvm's Node.js 24.19.0.
- `glibc.sh`: any host with Docker. The regenerated runs used OrbStack on an Apple silicon Mac, with arm64 containers and, under emulation, x86_64 containers.
- `versions.sh`: macOS or Linux, with nvm's Node.js 24.19.0, 24.22.3, and 26.13.1, and curl.
- `reference.py`: Python 3, standard library only, anywhere.

## Rerun

Each script takes its paths from environment variables (documented at the top of each file) and prints to the terminal; set `OUT=<file>` to write the same text to a file too.

```bash
python3 -I reference.py 5c99c487f2337e3a        # the correctly rounded value, about a second
./d8.sh                                         # a few seconds
./versions.sh                                   # a few seconds
./glibc.sh                                      # about 3 minutes the first time on an M1 Pro (two glibc builds), about 30 seconds after
PLATFORM=linux/amd64 ./glibc.sh                 # x86_64 containers, under emulation on a Mac: about 30 minutes the first time
```

`d8.sh` needs the d8 builds from [jsvu](https://github.com/GoogleChromeLabs/jsvu) (`JSVU_HOME`, default `~/.jsvu`) and Node.js from nvm (`NVM_DIR`, default `~/.nvm`). `glibc.sh` needs network access for apt and for `git clone` of glibc, and keeps the glibc builds in a Docker volume named `glibc-sin-demo-build-<arch>` so reruns are fast; remove it with `docker volume rm` when done.

`reference.py` computes the correctly rounded `sin` with integers only (Machin's formula for pi at 1,600 bits, argument reduction in fixed point, Taylor series), so nothing needs installing. The earlier checks used mpmath at 2,000 and 3,000 bits; mpmath wasn't importable under `python3 -I` on this Mac, so `reference.py` stands in for it. It was checked against two values from those mpmath runs (`3cbb779ceaa3c069` for the input above, `bc56ec67bcf77522` for the bug report's own example `6414c96c11134d36`) and against an independent 80-digit `decimal` computation on 300 random inputs.

## Expected output

### d8 and Node.js (`d8.sh`; the post's `[^sin-check]`)

From [`outputs/d8-mac-arm64-regenerated-20261119.txt`](outputs/d8-mac-arm64-regenerated-20261119.txt). Each configuration ran twice; the repeats matched.

| Engine | Default | With `--no-use-libm-trig-functions` |
|---|---|---|
| d8 13.6.233 | `3cbb779ceaa3bc42`, 1,063 ULP from correct | `3cbb779ceaa3c069`, correct |
| d8 14.6.202 | `3cbb779ceaa3bc42`, 1,063 ULP from correct | `3cbb779ceaa3c069`, correct |
| d8 15.8.32 | `3cbb779ceaa3c069`, correct | the build doesn't list the flag; its runs print an unknown-flag warning and give the default value |
| Node.js 24.19.0 (V8 13.6.233.17-node.51) | `3cbb779ceaa3c069`, correct | not applicable |

The post's `3.811845021115429e-16` is the `sin` line of the 13.6.233 and 14.6.202 default runs, and `3.811845021115953e-16` the line of every other run. The last table of the output gives the distances in ULP: `1063` from the correct value for the four default runs of 13.6.233 and 14.6.202, `0` for the rest.

### glibc (`glibc.sh`; the post's `[^sin-check]`)

From [`outputs/glibc-linux-arm64-regenerated-20261119.txt`](outputs/glibc-linux-arm64-regenerated-20261119.txt), [`outputs/glibc-linux-x86_64-emulated-regenerated-20261119.txt`](outputs/glibc-linux-x86_64-emulated-regenerated-20261119.txt), and (captured, from a Claude Code Cloud x86_64 VM with FMA and AVX2) [`outputs/glibc-linux-x86_64-captured-20261118.txt`](outputs/glibc-linux-x86_64-captured-20261118.txt). `sin-check.c` calls the C library's `sin` on the input's bits; the output prints the bits it returned, and where the loader found `sin`.

| glibc | OrbStack, aarch64 Linux VM on macOS | OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation | Claude Code Cloud, x86_64 VM, with FMA and AVX2 (captured) |
|---|---|---|---|
| 2.39, Ubuntu 24.04's package `2.39-0ubuntu8.12` | `3cbb779ceaa3bc42` | `3cbb779ceaa3bc42` | `3cbb779ceaa3bc42` |
| 2.43, built from its tag | `3cbb779ceaa3bc42` | `3cbb779ceaa3bc42` | `3cbb779ceaa3bc42` |
| 2.44, built from its tag | `3cbb779ceaa3c069` | `3cbb779ceaa3c069` | `3cbb779ceaa3c069` |

So 2.39's value is the one d8 gives by default (1,063 ULP below the correct `3cbb779ceaa3c069`), 2.43 gives the same wrong bits, and 2.44 gives the correct ones. Each file also runs the bug report's own example, `6414c96c11134d36`: 2.39 and 2.43 give `bc56ec67bcf5e379`, 2.44 gives the correctly rounded `bc56ec67bcf77522`, in all three files.

On x86_64, glibc picks one of several `sin` variants when the program starts (`__sin_fma`, `__sin_avx`, `__sin_sse2`). The captured run, on a CPU with FMA and AVX2, ran the first of those by default and the other two under `GLIBC_TUNABLES`, and all three agreed. In the OrbStack x86_64 container under emulation, the SSE2 variant ran for every setting: `sin_at` is the same offset for every tunable setting, and in the 2.43 and 2.44 builds it is `0x65b00` and `0x67460`, which `nm` in the same file names as `__sin_sse2`. So the emulated file shows one variant, and the captured file shows three. The aarch64 file doesn't run the tunable settings; it prints one `sin_at` offset per build.

### Node.js patch releases (`versions.sh`; the post's `[^versions]`)

From [`outputs/versions-mac-arm64-regenerated-20261119.txt`](outputs/versions-mac-arm64-regenerated-20261119.txt).

| Node.js | `process.versions.v8` | `math-control.js` sha256 (7,821 lines) | `sin` bits |
|---|---|---|---|
| 24.19.0 | `13.6.233.17-node.51` | `40c986c4…ca4e2b96` | `3cbb779ceaa3c069` |
| 24.22.3 | `13.6.233.17-node.63` | `40c986c4…ca4e2b96` | `3cbb779ceaa3c069` |
| 26.13.1 | `14.6.202.34-node.40` | `606a3ac0…f208e7`, a different V8, not compared | `3cbb779ceaa3c069` |

The script compares 24.19.0 and 24.22.3 with `cmp` and prints `identical` for both the control and the `sin` probe: "the two gave identical bits on every case tested" means these 7,820 `Math` calls (the `cases` line of the control, which is 7,821 lines counting that line) and the one `sin` input, and nothing wider. Part 2 of the output reads the V8 version and the `-node.N` suffix from each release's own `deps/v8/include/v8-version.h` and `common.gypi` at its release commit: `13.6.233.17` with `-node.51`, `13.6.233.17` with `-node.63`, and `14.6.202.34` with `-node.40`. The comment in `common.gypi` that the post quotes, "Increment by one for each non-official patch applied to deps/v8", is at [v24.19.0](https://github.com/nodejs/node/blob/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae/common.gypi#L42-L44) and [v24.22.3](https://github.com/nodejs/node/blob/e63cab040c09d43ceef8cb35508c40044614e906/common.gypi#L43-L45).

## Chrome 158 (part of `[^sin-check]`)

These scripts don't drive browsers, so Chrome has no output file. The post reports one run, made by hand, in Chrome 158.0.8127.37 (V8 15.8.62.31), arm64, on macOS 26.7.3, on 18 November 2026. To repeat it, paste this into the console:

```javascript
Math.sin( 1.1986535513718587e+138 );
```

The post's answer is the correctly rounded `3.811845021115953e-16`. To see the bits, paste this adaptation of the post's footnote snippet for the other examples (it prints `3cbb779ceaa3c069` in Node.js 24.19.0; it hasn't been run in a browser here):

```javascript
f=new Float64Array(1),u=new BigUint64Array(f.buffer),(f[0]=Math.sin(1.1986535513718587e+138),u[0].toString(16))
```

Chrome Stable moves every few weeks, so a different Chrome may carry a different V8; `chrome://version` reports which. The post's claim is for 15.8.62.31, on that day.

## Committed outputs

| File | What it is | Regenerated or captured | Date | Platform |
|---|---|---|---|---|
| [`outputs/d8-mac-arm64-regenerated-20261119.txt`](outputs/d8-mac-arm64-regenerated-20261119.txt) | `d8.sh`: d8 13.6.233, 14.6.202, 15.8.32 (default and flag off, twice each) and Node.js 24.19.0, with distances in ULP | regenerated for this repo | 2026-11-19 | macOS 26.7.3, arm64, Apple M1 Pro |
| [`outputs/d8-mac-arm64-captured-20261103.txt`](outputs/d8-mac-arm64-captured-20261103.txt) | The same comparison from the earlier run the post's `[^sin-check]` cites, with a different script version and output format | captured, not rerun | 2026-11-03 | macOS (Darwin 25.6.0), arm64, Apple M1 Pro |
| [`outputs/glibc-linux-arm64-regenerated-20261119.txt`](outputs/glibc-linux-arm64-regenerated-20261119.txt) | `glibc.sh`: glibc 2.39, 2.43, 2.44 | regenerated for this repo | 2026-11-19 | OrbStack, aarch64 Linux VM on macOS; Ubuntu 24.04.5 container, aarch64 |
| [`outputs/glibc-linux-x86_64-emulated-regenerated-20261119.txt`](outputs/glibc-linux-x86_64-emulated-regenerated-20261119.txt) | `PLATFORM=linux/amd64 glibc.sh`: the same, under x86_64 emulation | regenerated for this repo | 2026-11-19 | OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation; Ubuntu 24.04.5 |
| [`outputs/glibc-linux-x86_64-captured-20261118.txt`](outputs/glibc-linux-x86_64-captured-20261118.txt) | glibc 2.39, 2.43, 2.44 on x86_64 with FMA and AVX2, including all three `sin` variants, and the bug report's example | captured, not rerun | 2026-11-18 | Claude Code Cloud, x86_64 VM; Ubuntu 24.04 |
| [`outputs/versions-mac-arm64-regenerated-20261119.txt`](outputs/versions-mac-arm64-regenerated-20261119.txt) | `versions.sh`: Node.js 24.19.0, 24.22.3, 26.13.1 | regenerated for this repo | 2026-11-19 | macOS 26.7.3, arm64, Apple M1 Pro |

The captured files are copies of earlier outputs with paths and host names stripped; their first lines say so. The earlier d8 run was done twice, and the first copy printed an error in place of each d8 version line (d8 has no `--version` flag); the second is the one kept, and its `sin` lines match the first's.

### Where this rerun differs from the earlier ones

- **The operating system moved.** The d8 run of 2026-11-03 was on Darwin 25.6.0; this one is on macOS 26.7.3. The d8 and Node.js binaries are the same: the SHA-256 prefixes of d8 13.6.233 (`6b91f615cd9b0c12`), d8 14.6.202 (`fb9af3ddddfed69b`), and Node.js 24.19.0 (`27db838bb204ef7c`) match the earlier file's, and every `sin` bit pattern matches.
- **d8 15.8.32 now runs with the flag too.** The earlier run left it out because `--help` doesn't list the flag. This run passes it anyway: d8 prints `Warning: unknown flag --no-use-libm-trig-functions.` and runs the default build, giving the correct value. That's two more lines in the table, not a different result. The 15.8.32 binary's hash wasn't recorded earlier; it is in the next section.
- **The correct value is computed, not copied.** The earlier runs took it from mpmath; `reference.py` computes it here and gives the same bits for both inputs.
- **The Linux runs use a different route to glibc.** The earlier x86_64 run built 2.43 and 2.44 from the tags in a Claude Code Cloud x86_64 VM. These builds are in Ubuntu 24.04 containers in OrbStack, from the same two commits, and give the same results; the x86_64 container runs under emulation and runs a different `sin` variant (see above).

## Sources pinned

| What | Pin |
|---|---|
| d8 13.6.233 | `v8/v8` tag [13.6.233](https://github.com/v8/v8/commit/04fa9cbe26525ab96ab3ff2a18b5d25e443e12fa), commit `04fa9cbe26525ab96ab3ff2a18b5d25e443e12fa`; jsvu's binary, sha256 `6b91f615cd9b0c126a77e6cc73885c813b171249f403d180f93132d78ad80cce` |
| d8 14.6.202 | tag [14.6.202](https://github.com/v8/v8/commit/e04c3a1a2543bdbee7beac8846c9cbe8f657636f), commit `e04c3a1a2543bdbee7beac8846c9cbe8f657636f`; binary sha256 `fb9af3ddddfed69b4b57540d64469a7b338863b6f89a10e4413907c6f29e0ca3` |
| d8 15.8.32 | tag [15.8.32](https://github.com/v8/v8/commit/e5a1c6353fce563774685e8b6d45262d57f0229b), commit `e5a1c6353fce563774685e8b6d45262d57f0229b`; binary sha256 `a59f1e33fd8f51636901c31c760e5a40e3b8f784320ff40aba9c6877b5436e10` |
| Node.js 24.19.0 | commit [`cdc1b38d40cb567b7ad0b39c86addf830a0af0ae`](https://github.com/nodejs/node/commit/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae); nvm's binary, sha256 `27db838bb204ef7c21df2931f5656e4c8fb32e6e947f363a402b49714d32b5b1` |
| Node.js 24.22.3 | commit [`e63cab040c09d43ceef8cb35508c40044614e906`](https://github.com/nodejs/node/commit/e63cab040c09d43ceef8cb35508c40044614e906); binary sha256 `ba7073582822078d8c90bca3facacc46690bc5366fab4b815aeef9148cd6e854` |
| Node.js 26.13.1 | commit [`e9c277643b0249c50f6e6de5413be8a88ea11b6a`](https://github.com/nodejs/node/commit/e9c277643b0249c50f6e6de5413be8a88ea11b6a); binary sha256 `266dec4dce3a6cdcf5cdc38722a00cf5ae6a12cc51068d2a227655bbb75751ec` |
| Node.js files read by `versions.sh` | `deps/v8/include/v8-version.h` at 24.19.0 and 24.22.3: `7a945b92…d47802` (the same bytes); at 26.13.1: `ce7ce832…b5ba3`. `common.gypi`: `83a690f0…b871` (24.19.0), `3c4090d3…61b2` (24.22.3), `d8048c8c…3454` (26.13.1). The script checks the full hashes, which are in it, and stops if one differs |
| glibc 2.39 (the Ubuntu package) | `libc6 2.39-0ubuntu8.12`, installed by apt in the image below; the same version as the captured run. The upstream tag [`glibc-2.39`](https://github.com/bminor/glibc/commit/ef321e23c20eebc6d6fb4044425c00e6df27b05f) is commit `ef321e23c20eebc6d6fb4044425c00e6df27b05f` (the package carries Ubuntu's patches, so the tag is the nearest upstream point, not what ran) |
| glibc 2.43 | tag `glibc-2.43` (tag object `5d3654a1b7dccb7959df975ab26868612dbcd24e`), commit `f762ccf84f122d1354f103a151cba8bde797d521`, from `https://sourceware.org/git/glibc.git`; the script checks the clone against it |
| glibc 2.44 | tag `glibc-2.44` (tag object `6c33941ff7188ac0813314f249a402a84b1a9d36`), commit `c3a3a9808ad3ab4a3336836833f83288b672ccbf`, same source and check |
| Docker base image | `ubuntu:24.04@sha256:73b999393d07f2bf65a40373778a44dc9a6d54ad7718d29247d8ff9413c4d6a8` (the multi-platform index); its arm64 manifest is `sha256:c92376659a7f14cc1f51615d73c9f4b7d8e18d59f370e02b4ed683ab4485c66c` and its amd64 manifest `sha256:77eb101c607d6e3d4f5ad0c8a02c2136c689b98aba1f359e6502ba517e5c57ec`. The packages apt adds (gcc 13.3.0, the system glibc) are whatever Ubuntu's archive serves on the day |
| glibc 2.43 and 2.44 build flags | `configure --prefix=/opt/glibc-<version> --disable-werror --disable-nscd --disable-mathvec`, then `make`; the probe is compiled once, against Ubuntu's glibc 2.39 headers, and run under each build's `testrun.sh` |

The GitHub mirror `bminor/glibc` has the `glibc-2.39` tag but, on 2026-11-19, no `glibc-2.43` or `glibc-2.44` tag, so those two commits come from `git ls-remote https://sourceware.org/git/glibc.git` (annotated tags dereferenced).

## Scope

- **x86_64 with FMA and AVX2 is captured, not rerun.** The captured run came from a Claude Code Cloud x86_64 VM, with an earlier version of `glibc.sh`; the file's `sin_at` paths now say `/build/` where its original said a scratch directory.
- **x86_64 emulation reaches one `sin` variant.** The OrbStack x86_64 container under emulation reaches only the SSE2 variant of glibc's `sin`, and its CPU flags show `fma` and no `avx2`, so the results for the FMA and AVX variants come from the Claude Code Cloud run.
- **Chrome 158 is a note, not a committed output.** It was run once in a browser console, by hand, on 2026-11-18; see the Chrome section above.
- **The results cover `sin` on this input and one control.** They say nothing about 2.44 on other inputs, or about `cos`, `tan`, or other huge arguments.
- **The fix commit isn't built on its own.** The runs compare the 2.43 and 2.44 release tags, which differ in much more than the change for [bug 34376](https://sourceware.org/bugzilla/show_bug.cgi?id=34376). The attribution to that bug comes from the control input being the bug report's own example.
- **d8's vendored copy isn't compared with glibc's source here.** Identical bits from d8 by default and from glibc 2.39 make a shared algorithm the likely explanation; the two `s_sin.c` files weren't compared in this folder.
