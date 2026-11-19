# One library, two compilers

Backs the `tan` pair in `[^mquickjs]`, the mechanism in `[^contract]`, and V8's `atan` in `[^atan]`, in "Whose maths is it?".

## Claim

> MicroQuickJS, the engine for embedded systems from the last post, carries its own maths library, `libm.c`. Built from the same commit by GCC on Linux x86_64 and by Apple clang on macOS arm64, it gives different answers on nine `Math` functions.
>
> Apple clang, by default, turns `a * b + c` into a *fused multiply-add* (FMA) ... GCC, building for baseline x86_64, has no FMA instruction to fuse into. Build MicroQuickJS on the Mac with fusing turned off, and it gives the Linux answers on all 17 functions tested.
>
> From 15.4, d8's `atan` differs between Linux and macOS, by the same mechanism.

The `tan` input is `0xc0322052fd59ea32`; the answers are `3fec40c1bc40f28e` (macOS), `3fec40c1bc40f28c` (Linux), and `3fec40c1bc40f28d`, the correctly rounded value, from MPFR. V8 15.4 and later call LLVM libc's `atan`, which uses fused multiply-adds on arm64 and not on baseline x86_64.

## Tier

*b: needs a Mac, plus Docker for the Linux half.* macOS arm64 with Apple clang, GNU make, `objdump` (Apple's ships with the command-line tools), Node.js with npm, git, curl, and unzip. Docker (OrbStack or Docker Desktop) runs the Ubuntu 24.04 containers. Julia 1.13 is optional: it supplies the correctly rounded `tan` value through MPFR, and `lib/reference.jl` for the full reference, and without it the output says its MPFR value is captured.

## Rerun

From the repository root. Each script fetches what it needs at pinned commits into `.cache/` (ignored by git), and writes its output to `fma-contraction/results/`.

```bash
./fma-contraction/run-contract-mac.sh      # MicroQuickJS twice, all 392,083 cases: about 2 minutes
./fma-contraction/run-contract-linux.sh    # Ubuntu 24.04 x86_64, GCC 13.3.0 (emulated on an arm64 Mac): about 6 minutes
./fma-contraction/compare-all.sh           # the three builds side by side
./fma-contraction/tan-pair.sh              # the three answers for the tan input, with MPFR
./fma-contraction/run-atan-mac.sh          # LLVM libc's atan, and d8 14.6.202, 15.4.8, 15.8.32
./fma-contraction/run-atan-linux.sh        # the same in x86_64 and arm64 containers
```

The first run also fetches stdlib's test fixtures (about 45 MB, sparse, at a pinned commit) and generates the 392,083 test cases from them with `lib/gen-cases.js`. The case files are about 15 MB, so they are not committed; `lib/cases.sha256` has the SHA-256 of each one, and the scripts stop if a regenerated file differs. The post prints one case, the `tan` input, which is line 4222 of `Math.tan.txt`.

The correctly rounded reference for every case (not needed for the comparisons here) is `julia lib/reference.jl`, which takes a few seconds; `lib/reference.sha256` has the SHA-256 of each output file, and a run in this repository matched all 17.

## Expected output

- **The `tan` pair**, `results/tan-pair.txt`:

  ```text
  3fec40c1bc40f28e  +1 ulp    macOS arm64, Apple clang 21.0.0, default (fused)
  3fec40c1bc40f28c  -1 ulp    macOS arm64, Apple clang 21.0.0, -ffp-contract=off
  3fec40c1bc40f28c  -1 ulp    Ubuntu 24.04 x86_64, GCC 13.3.0, default
  3fec40c1bc40f28d  exact     correctly rounded (MPFR)
  ```

- **Fused instructions**, `results/contract-mac-arm64.txt`: `fused multiply-add instructions in libm.o: 68` for the default build and `0` with `-ffp-contract=off`; no other object file of either build has any. In `results/contract-linux-x86_64.txt`, GCC's build has `0`, with GCC's own default shown as `-ffp-contract=fast`.
- **Nine functions, 17 tested**, `results/compare.txt`: `mac-default and linux-x86_64: same bits on 8 of 17 functions; differ on acos, asin, atan, atan2, cos, exp, pow, sin, tan`, and `mac-nocontract and linux-x86_64: same bits on 17 of 17 functions`. "Same bits" means the hash of the result column is the same, so every case has the same answer. The 17 are 14 `Math` functions (`acos`, `asin`, `atan`, `atan2`, `cos`, `exp`, `fround`, `log`, `log10`, `log2`, `pow`, `sin`, `sqrt`, `tan`) and `erf`, `gamma`, and `log1p` from stdlib's published packages, which are plain JavaScript and never reach the C library.
- **V8's `atan`**, `results/atan-mac-arm64.txt` and `results/atan-linux-x86_64.txt`: V8 15.4.8's `src/base/ieee754.cc` line 164 calls `LIBC_NAMESPACE::shared::atan`. On the 6,498 `atan` cases, d8 15.4.8 and 15.8.32 have hash `dfeb183ada38` on macOS arm64 and `bc5fda2988f9` on Linux x86_64. LLVM libc's `atan`, built at the revision V8 vendors, gives `dfeb183ada38` with 20 fused instructions (arm64, and x86_64 with `-mavx2 -mfma`) and `bc5fda2988f9` with none (baseline x86_64, or arm64 with the fused path and contraction off). d8 14.6.202, before the move, gives `7b3415650fcd` on both.

## Committed outputs

| File | What it is | Status | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/contract-mac-arm64.txt` | MicroQuickJS built default and with `-ffp-contract=off`; fused counts; the `tan` input; a hash per function | regenerated for this repository | 2026-11-19 | macOS 26.7.3, arm64, Apple M1 Pro, Apple clang 21.0.0 |
| `results/contract-linux-x86_64.txt` | The same on Ubuntu 24.04, GCC 13.3.0 | regenerated for this repository | 2026-11-19 | container, linux/amd64, emulated on the machine above |
| `results/compare.txt` | The three builds' hashes side by side; the emulated run against the captured real x86_64 hashes | regenerated for this repository | 2026-11-19 | assembled on the macOS machine |
| `results/tan-pair.txt` | The `tan` answers, with MPFR | regenerated for this repository | 2026-11-19 | assembled on the macOS machine; MPFR 4.2.2 through Julia 1.13.3 |
| `results/atan-mac-arm64.txt` | LLVM libc's `atan` four ways, and d8 14.6.202, 15.4.8, 15.8.32, on macOS | regenerated for this repository | 2026-11-19 | macOS 26.7.3, arm64, Apple M1 Pro |
| `results/atan-linux-x86_64.txt` | The same library built without and with `-mavx2 -mfma`, and the published Linux d8 builds | regenerated for this repository | 2026-11-19 | container, linux/amd64, emulated |
| `results/atan-linux-aarch64.txt` | The same library on arm64 Linux, with and without the fused path | regenerated for this repository | 2026-11-19 | container, linux/arm64, native |
| `results/captured-linux-x86_64-2026-10-22.txt` | The 17 hashes, and a clang `-mfma` build, from an earlier run on a real x86_64 machine | captured earlier, not rerun | 2026-10-22 | Ubuntu 24.04.5, x86_64, Intel Xeon 2.80 GHz; paths stripped |
| `lib/cases.sha256`, `lib/reference.sha256` | SHA-256 of the generated case files and of MPFR's reference answers | regenerated for this repository | 2026-11-19 | macOS arm64; Julia 1.13.3 |

**Where this rerun differs from the earlier one.** Nothing in the results. All 17 hashes of the macOS builds, and of the Linux build, equal the earlier run's, as do the 68 and 0 fused instructions, the three `atan` hashes, and the MPFR reference files. What changed is the setup: macOS is 26.7.3 (it was 26.6.2), the Linux half ran in an emulated x86_64 container rather than on a real x86_64 machine (the equal hashes are the check that the emulation reproduces it), `erf`, `gamma`, and `log1p` come from stdlib's published npm packages rather than a checkout of the repository, and the clang that builds LLVM libc's `atan` in the x86_64 container is Ubuntu's 18.1.3 rather than Debian's 16.0.6.

## Sources pinned

| What | Pin |
| --- | --- |
| [MicroQuickJS](https://github.com/bellard/mquickjs) (MIT) | commit `6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9` (2026-09-26) |
| [stdlib](https://github.com/stdlib-js/stdlib) test fixtures (Apache-2.0) | commit `550666096f34c73f90f4bf86139935e4214fe421`; the fixtures it holds last changed in June 2025 |
| LLVM libc, from [Chromium's mirror of llvm-project's `libc`](https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libc.git) (Apache-2.0 with LLVM exceptions) | commit `6fd5620cc4fd3c55ee749e9bf71f52038431f76d`, the revision in V8 15.4.8's `DEPS` |
| [V8](https://github.com/v8/v8) 15.4.8 (BSD-3-Clause), read for `DEPS`, `src/base/ieee754.cc`, and `third_party/llvm-libc/BUILD.gn` | commit `332c967a18581b884d6d684005bd02d84bf970ac` |
| d8 14.6.202, 15.4.8, 15.8.32 | published builds from `storage.googleapis.com/chromium-v8/official/canary/v8-<platform>-rel-<version>.zip`; each atan output prints the first 16 hex digits of the SHA-256 of the `d8` binary it ran |
| `erf`, `gamma`, `log1p` | `@stdlib/math-base-special-erf@0.2.6`, `-gamma@0.3.1`, `-log1p@0.2.4`, and `esbuild@0.25.10`, with every dependency pinned in `stdlib-fns/package-lock.json` |
| Ubuntu 24.04 container image | `ubuntu@sha256:73b999393d07f2bf65a40373778a44dc9a6d54ad7718d29247d8ff9413c4d6a8` (linux/amd64 digest as recorded in each output); `gcc`, `make`, `clang`, and `nodejs` from its apt archive, whose versions each output prints |

## Not yet public

- **A run on a real x86_64 machine.** The Linux half here ran under emulation. GCC for baseline x86_64 emits only SSE2 double arithmetic, and the hashes equal the earlier run's on real hardware (`results/captured-linux-x86_64-2026-10-22.txt`), but that run is captured, not repeated.
- **MicroQuickJS built with clang `-mfma -ffp-contract=on` on x86_64** (the same source with fusing turned on, which gives the macOS bits on all 17 functions): only the captured table, not rerun. The emulated container reports `fma` but not `avx2` in its CPU flags, though the `-mavx2 -mfma` build of LLVM libc's `atan` ran there (`results/atan-linux-x86_64.txt`), so it might run; the result would still come from an emulator, which is a weaker claim than the real-hardware table.
- **Accuracy against MPFR for every case, per build.** `lib/reference.jl` and its checksums are here; the per-build exact, one-ulp, and worse counts are not, because the post doesn't state them.
- **d8 15.x on Linux arm64.** V8 doesn't publish one in the bucket the scripts use, so the arm64 Linux column is LLVM libc's `atan` built natively, not d8.
