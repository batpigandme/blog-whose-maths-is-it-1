# Engines, tools, and platforms

Everything the committed outputs ran on or read, with versions, platforms, and how each was obtained. Each output file's own header gives the same facts for that run, and each folder's README says which outputs were regenerated for this repository (2026-11-19) and which were captured earlier. "Unchecked" in the license column means the license of that exact build wasn't verified; the SPDX identifier is the project's.

## Platforms

| Platform | Used for |
| --- | --- |
| macOS 26.7.3, arm64 (Apple M1 Pro); Apple clang 21.0.0 | the regenerated d8, Node.js, MicroQuickJS, and V8 runs |
| OrbStack, aarch64 Linux VM on macOS; Ubuntu 24.04 container (`ubuntu:24.04@sha256:73b999393d07f2bf65a40373778a44dc9a6d54ad7718d29247d8ff9413c4d6a8`), aarch64 | the regenerated glibc and Linux runs on aarch64 |
| OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation; the same Ubuntu 24.04 image, x86_64 | the regenerated glibc and Linux runs on x86_64 |
| Claude Code Cloud, x86_64 VM (Intel Xeon), with FMA and AVX2; Ubuntu 24.04 | the captured x86_64 runs (`sin-demo/`, `fma-contraction/`, `v8-sources/`, `engine-families/`); the engine-families outputs also record glibc 2.39 and musl 1.2.4 on that host |
| macOS 26.6.x (Darwin 25.6.0 on 2026-11-03), arm64, Apple M1 Pro | the captured d8 run in `sin-demo/` |
| macOS, arm64 (OS version not recorded in the original output) | the captured `engine-families/` macOS run |

## Engines and runtimes

| Engine or runtime | Version or commit | Platform | How obtained | License | Folders |
| --- | --- | --- | --- | --- | --- |
| d8 (V8) | 13.6.233 (`04fa9cbe26525ab96ab3ff2a18b5d25e443e12fa`) | macOS arm64 | jsvu | BSD-3-Clause (unchecked for the jsvu binary) | `sin-demo/`, `v8-sources/`, `fma-contraction/` |
| d8 (V8) | 14.6.202 (`e04c3a1a2543bdbee7beac8846c9cbe8f657636f`) | macOS arm64; linux64 | jsvu; V8's build bucket (`lib/fetch-d8.sh`) | BSD-3-Clause (unchecked) | same |
| d8 (V8) | 15.4.8 | macOS arm64; linux64 | V8's build bucket | BSD-3-Clause (unchecked) | `v8-sources/`, `fma-contraction/` |
| d8 (V8) | 15.8.32 (`e5a1c6353fce563774685e8b6d45262d57f0229b`) | macOS arm64; linux64 | jsvu; V8's build bucket | BSD-3-Clause (unchecked) | `sin-demo/`, `v8-sources/`, `fma-contraction/` |
| d8 (V8), bisection | every published build from 14.6.202 to 15.4.8; 34 probed on macOS | macOS arm64; linux64 | V8's build bucket | BSD-3-Clause (unchecked) | `v8-sources/` |
| Node.js | 24.19.0 (`cdc1b38d40cb567b7ad0b39c86addf830a0af0ae`; V8 13.6.233.17-node.51) | macOS arm64 | nvm | MIT (unchecked) | `sin-demo/`, `v8-sources/` |
| Node.js | 24.22.3 (`e63cab040c09d43ceef8cb35508c40044614e906`; V8 13.6.233.17-node.63) | macOS arm64 | nvm | MIT (unchecked) | `sin-demo/` |
| Node.js | 26.13.1 (`e9c277643b0249c50f6e6de5413be8a88ea11b6a`; V8 14.6.202.34-node.40) | macOS arm64 | nvm | MIT (unchecked) | `sin-demo/`, `v8-sources/` |
| MicroQuickJS | `6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9` | macOS arm64; OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation (Ubuntu 24.04) | built from the commit | MIT | `fma-contraction/` |

The `engine-families/` outputs are captured, and they record only versions: Boa 0.22, Duktape 2.7.0, engine262, GraalJS 25.0.3, Hermes 0.13.0, JavaScriptCore builds 319418 and 324323 (and WebKitGTK 2.52.6 on Linux), JerryScript 3.0.0, MicroQuickJS, Node.js 22.22.1, 24.19.0, 26.7.0, and 26.12.0, QuickJS 2021-03-27, QuickJS-ng 0.17.0, SpiderMonkey shells 115.10.0, 155.0b1, and 159.0b5, txiki.js 26.6.0, V8 13.6.233 to 15.8.32, Bare 1.36.0, and XS 9.0.0 and 10.0.2. How each was obtained isn't recorded in those outputs, except that the Linux QuickJS-ng, Hermes, and XS binaries came from jsvu.

## Tools and libraries

| Tool or library | Version or commit | Platform | How obtained | License | Folders |
| --- | --- | --- | --- | --- | --- |
| Apple clang | 21.0.0 (clang-2100.3.34.2) | macOS arm64 | Xcode command-line tools | unchecked | `fma-contraction/`, `v8-sources/`, `sin-demo/` |
| GCC | 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1) | Ubuntu 24.04 containers | apt in the pinned image | GPL-3.0-or-later (unchecked) | `fma-contraction/`, `sin-demo/` |
| clang | 18.1.3 (Ubuntu) | Ubuntu 24.04 containers | apt in the pinned image | unchecked | `fma-contraction/` |
| glibc | 2.39 (Ubuntu package 2.39-0ubuntu8.12; tag commit `ef321e23c20eebc6d6fb4044425c00e6df27b05f`) | Ubuntu 24.04 containers | apt in the pinned image | LGPL-2.1-or-later (unchecked) | `sin-demo/` |
| glibc | 2.43 (`f762ccf84f122d1354f103a151cba8bde797d521`) | same containers | built from the tag at `sourceware.org/git/glibc.git` | LGPL-2.1-or-later (unchecked) | `sin-demo/` |
| glibc | 2.44 (`c3a3a9808ad3ab4a3336836833f83288b672ccbf`) | same containers | built from the tag at `sourceware.org/git/glibc.git` | LGPL-2.1-or-later (unchecked) | `sin-demo/` |
| glibc source for the diff | `4e21c2075193e406a92c0d1cb091a7c804fda4d9` | read only | the `bminor/glibc` mirror, at the pin | LGPL-2.1-or-later (per V8's `README.v8`) | `v8-sources/` |
| LLVM libc (`atan`) | `6fd5620cc4fd3c55ee749e9bf71f52038431f76d` | macOS arm64; Ubuntu x86_64 and aarch64 containers | built from the commit, through Chromium's mirror of `llvm-project`'s `libc` | Apache-2.0 WITH LLVM-exception | `fma-contraction/` |
| V8 source (glibc copy, flags, `ieee754.cc`) | `b0a55a7dad7f536cce1f9aaddba89894c8533946` (13.6.233.17) | read only; the glibc copy's `s_sin.c` and the rest compiled on macOS | raw GitHub files at the pin | BSD-3-Clause | `v8-sources/` |
| stdlib test fixtures | `550666096f34c73f90f4bf86139935e4214fe421` | macOS arm64 | sparse git fetch | Apache-2.0 | `lib/`, `fma-contraction/` |
| `@stdlib/math-base-special-erf` | 0.2.6 | macOS arm64; container | npm | Apache-2.0 | `fma-contraction/` |
| `@stdlib/math-base-special-gamma` | 0.3.1 | same | npm | Apache-2.0 | `fma-contraction/` |
| `@stdlib/math-base-special-log1p` | 0.2.4 | same | npm | Apache-2.0 | `fma-contraction/` |
| esbuild | 0.25.10 | macOS arm64 | npm | MIT | `fma-contraction/` |
| Julia (with MPFR 4.2.2) | 1.13.3 | macOS arm64 | juliaup 1.24.0 | MIT (Julia); MPFR unchecked | `lib/`, `fma-contraction/` |
| Node.js (Ubuntu package, in the container) | 18.19.1 | Ubuntu 24.04 containers | apt | unchecked | `fma-contraction/` |
| Python (standard library only) | 3.15.2 | macOS arm64 | Homebrew | PSF-2.0 | `spec/`, `sin-demo/` |
| poppler `pdftotext` | 26.11.0 | macOS arm64 | Homebrew | GPL-2.0-or-later | `spec/` |

## Added with the results-only folders

These come from captured or recorded results, not reruns. "Not recorded" means the original output or note doesn't say.

### Platforms

| Platform | Used for |
| --- | --- |
| macOS 26.7.3 (build 25G342), arm64 | the browser runs in `browsers/` |
| macOS (Darwin 25.6.0), arm64, Apple M1 Pro | the shell scan in `browsers/` |
| macOS 26.6.2, arm64, Apple M1 Pro; OrbStack 2.2.5 | the OrbStack runs in `plainly-wrong/`, and the macOS runs in `bindings/` |
| Claude Code Cloud, x86_64 VM (Intel Xeon, Ubuntu 24.04.5) | the Cloud runs in `sumprecise/`, `engine-families/scriptc/`, and the Cloud lines quoted in `plainly-wrong/` |

### Engines, runtimes, and bindings

| Name | Version or commit | Platform | How obtained | License | Folder |
| --- | --- | --- | --- | --- | --- |
| Chrome | 158.0.8127.37 (V8 15.8.62.31, revision `b8c2be851f62f6a394ec57955d7f31335d7cb6d4`) | macOS 26.7.3 arm64 | not recorded | unchecked | `browsers/` |
| Firefox | 160.0.1 (built from `58fed86b1b6864ad71b83c910a879d6f1a6b678b`) | macOS 26.7.3 arm64 | not recorded | unchecked | `browsers/` |
| Safari | 27.2 (21625.2.8.18.4) | macOS 26.7.3 arm64 | not recorded | unchecked | `browsers/` |
| SpiderMonkey shell | 159.0b5 (`34ac0671eb25f31f8c56ace36e1c413dd471eb8d`) | macOS arm64 | jsvu | unchecked | `browsers/` |
| Node.js | 22.23.5 (`60553651579ec33ca1aef9e1eedab2c3855f1f7e`) | Claude Code Cloud, x86_64 VM | image default | MIT (unchecked) | `sumprecise/` |
| Node.js | 26.7.0 (`b4f23d3619c98bed09af93a21192f6080197a8c6`; V8 14.6.202.34-node.28) | Claude Code Cloud, x86_64 VM | preinstalled in the image | MIT (unchecked) | `sumprecise/` |
| Node.js | 27.0.0-alpha.0.1.1 (`6c7c89331d062a47d6fe3d16b3c00e4a3145826d`; V8 15.6.75.50-node.14) | macOS arm64 | nvm | MIT (unchecked) | `sumprecise/` |
| Node.js | 24.19.0 and 24.22.2 (V8 13.6.233.17-node.51 and node.63) | Claude Code Cloud, x86_64 VM; macOS arm64 | nvm; preinstalled in the image | MIT (unchecked) | `sumprecise/`, `engine-families/scriptc/`, `bindings/` |
| Deno | 2.9.8 | macOS arm64 | not recorded | unchecked | `sumprecise/` |
| Bun | 1.3.14 (WebKit `5488984d20e0dbfe4be2c3ba8fb18eb81a5e0e8b`) | macOS arm64 | not recorded | unchecked | `sumprecise/` |
| scriptc | 0.4.7 (`6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff`) | Claude Code Cloud, x86_64 VM | npm; compiler binary from `@scriptc/cli-linux-x64-gnu` | unchecked | `engine-families/scriptc/` |
| Rhino | 2.0.0-SNAPSHOT `7386aa037d9a8020e4e69cc0af11eb73fe59d09d`; 1.9.2 `b3d405fe2ef4948929629b23d85ba7eef76a2c2a` | OrbStack arm64 and x86_64 under emulation; Claude Code Cloud (quoted) | javascript-zoo 20260303 release; Maven Central `rhino-all-1.9.2.jar` | MPL-2.0 (unchecked) | `plainly-wrong/` |
| goja | `622d10077b6c154d9dc0897878aa1b4a674d7c9b` | OrbStack arm64 and x86_64 under emulation | `go install` with go1.26.10 | MIT (unchecked) | `plainly-wrong/` |
| otto | v0.5.1 (`43d0d581930e54a0daee9e3770b68e947a7f33fc`) | same | `go install` with go1.24.7 | MIT (unchecked) | `plainly-wrong/` |
| Nova, Kiesel, Quanta, Porffor, Hermes | Nova `d85a2f8d243441f4917f80b38e683d501aa62e72`; Quanta `767a49f40a7a974e081bd87840793cd188a135bf`; Porffor 0.0.0-alpha.19 `0c135ce2f36fdd3467d5a58daa92283810705a51`; Hermes 0.13.0 `4b3bf912cc0f705b51b71ce1a5b8bd79b93a451b`; Kiesel SHAs in the setup output | OrbStack arm64 and x86_64 under emulation | javascript-zoo 20260303 release; npm; GitHub release tarball | unchecked | `plainly-wrong/` |
| v8go (V8 9.0.257.18) | `12b0374faffcc6a93eb284808ca1beab58259e72` | macOS 26.6.2 arm64 | `go get` | BSD-3-Clause | `bindings/` |
| v8go (V8 10.9.194.9 at runtime) | v0.9.0 (`0e40e6e5827ad897d25f915917d8206e9a8231db`) | macOS 26.6.2 arm64 | `go get rogchap.com/v8go@v0.9.0` | BSD-3-Clause | `bindings/` |
| PyMiniRacer (V8 14.4.258.23) | 0.14.1 (`95b89887e74103a91747bca45a1e35ff0e1b81c3`) | macOS 26.6.2 arm64 | PyPI wheel, `pip install --no-deps` | ISC | `bindings/` |
| d8 (V8) | 9.0.257, 10.9.194, 14.4.258, 14.6.202 | macOS arm64 | jsvu | unchecked | `bindings/` |

### Tools and sources

| Tool or source | Version or commit | Platform | How obtained | License | Folder |
| --- | --- | --- | --- | --- | --- |
| Go | go1.24.7, go1.26.10 | OrbStack arm64 and x86_64 under emulation | conda-forge; `GOTOOLCHAIN=auto` for 1.26.10 | BSD-3-Clause (unchecked) | `plainly-wrong/` |
| OpenJDK | 25.0.2 and 21.0.10 | same | conda-forge | GPL-2.0-with-classpath-exception (unchecked) | `plainly-wrong/` |
| qemu-user | 8.2.2 | OrbStack arm64 container | Ubuntu apt | GPL-2.0 (unchecked) | `plainly-wrong/` |
| Go and Python | 1.27.4 and 3.13.18 | macOS arm64 | conda-forge, through pixi 0.84.2 | unchecked | `bindings/` |
| MDN browser-compat-data | `9237d95b44e0ed02a094c50a0277e228c81b236f`, `290cd74dbb04d539bc252f4e8f44a723947f8f31`, `7171dca74fea50d3fd88eca8e75b2636954a45b8` | read only | `gh api` | unchecked | `sumprecise/` |
| test262 | `2e58f87d8350ad51224617a041c6e041d52f8444` | read; run in the Cloud VM | pinned fetch | unchecked | `sumprecise/` |
| NumPy and Apple clang | NumPy 2.5.5; Apple clang 21 | macOS arm64 | a recorded check; install route and clang patch version not recorded | unchecked | `reads/` |

## Specification editions

`spec/` fetches ECMA-262 editions 1 to 17 at run time from Ecma International and checks each file's sha256, which `spec/README.md` records. Editions are fixed documents, so they are pinned by checksum, not by commit, and none is committed here.
