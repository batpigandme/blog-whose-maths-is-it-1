# Engines, tools, and platforms

Everything the committed outputs ran on or read, with versions, platforms, and how each was obtained. Each output file's own header gives the same facts for that run, and each folder's README says which outputs were regenerated for this repository (2026-11-19) and which were captured earlier. "Unchecked" in the license column means the license of that exact build wasn't verified; the SPDX identifier is the project's.

Every version here links to a pinned source: a release tag, a commit, a versioned download, or a package page for that version. Where a tool has no such source (Apple clang, macOS, OrbStack, Safari), the version is plain text. Where a source is pinned by digest, the digest is written out.

## Platforms

| Platform | Used for |
| --- | --- |
| macOS 26.7.3, arm64 (Apple M1 Pro); Apple clang 21.0.0 | the regenerated d8, Node.js, MicroQuickJS, and V8 runs |
| OrbStack, aarch64 Linux VM on macOS; Ubuntu 24.04 container (`ubuntu:24.04@sha256:73b999393d07f2bf65a40373778a44dc9a6d54ad7718d29247d8ff9413c4d6a8`), aarch64 | the regenerated glibc and Linux runs on aarch64 |
| OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation; the same Ubuntu 24.04 image, x86_64 | the regenerated glibc and Linux runs on x86_64 |
| Claude Code Cloud, x86_64 VM (Intel Xeon), with FMA and AVX2; Ubuntu 24.04 | the captured x86_64 runs (`sin-demo/`, `fma-contraction/`, `v8-sources/`, `engine-families/`); the engine-families outputs also record glibc 2.39 ([Ubuntu package 2.39-0ubuntu8.9](https://launchpad.net/ubuntu/+source/glibc/2.39-0ubuntu8.9), in one output) and musl 1.2.4 ([Ubuntu package 1.2.4-2](https://launchpad.net/ubuntu/+source/musl/1.2.4-2)) on that host |
| macOS 26.6.x (Darwin 25.6.0 on 2026-11-03), arm64, Apple M1 Pro | the captured d8 run in `sin-demo/` |
| macOS, arm64 (OS version not recorded in the original output) | the captured `engine-families/` macOS run |

## Engines and runtimes

| Engine or runtime | Version or commit | Platform | How obtained | License | Folders |
| --- | --- | --- | --- | --- | --- |
| d8 (V8) | 13.6.233 ([`04fa9cb`](https://github.com/v8/v8/commit/04fa9cbe26525ab96ab3ff2a18b5d25e443e12fa)) | macOS arm64 | jsvu ([macOS arm64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-13.6.233.zip)) | BSD-3-Clause (unchecked for the jsvu binary) | `sin-demo/`, `v8-sources/`, `fma-contraction/` |
| d8 (V8) | 14.6.202 ([`e04c3a1`](https://github.com/v8/v8/commit/e04c3a1a2543bdbee7beac8846c9cbe8f657636f)) | macOS arm64; linux64 | jsvu ([macOS arm64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-14.6.202.zip)); V8's build bucket (`lib/fetch-d8.sh`; [linux64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-linux64-rel-14.6.202.zip)) | BSD-3-Clause (unchecked) | same |
| d8 (V8) | [15.4.8](https://github.com/v8/v8/tree/15.4.8) | macOS arm64; linux64 | V8's build bucket ([macOS arm64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-15.4.8.zip), [linux64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-linux64-rel-15.4.8.zip)) | BSD-3-Clause (unchecked) | `v8-sources/`, `fma-contraction/` |
| d8 (V8) | 15.8.32 ([`e5a1c63`](https://github.com/v8/v8/commit/e5a1c6353fce563774685e8b6d45262d57f0229b)) | macOS arm64; linux64 | jsvu; V8's build bucket ([macOS arm64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-15.8.32.zip), [linux64 build](https://storage.googleapis.com/chromium-v8/official/canary/v8-linux64-rel-15.8.32.zip)) | BSD-3-Clause (unchecked) | `sin-demo/`, `v8-sources/`, `fma-contraction/` |
| d8 (V8), bisection | every published build from [14.6.202](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-14.6.202.zip) to [15.4.8](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-15.4.8.zip); 34 probed on macOS (the published 14.x and 15.x builds are listed in [`versions-mac-arm64-14-15.txt`](v8-sources/versions-mac-arm64-14-15.txt) and [`versions-linux64-14-15.txt`](v8-sources/versions-linux64-14-15.txt)) | macOS arm64; linux64 | V8's build bucket, `v8-<platform>-rel-<version>.zip` | BSD-3-Clause (unchecked) | `v8-sources/` |
| Node.js | [24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0) ([`cdc1b38`](https://github.com/nodejs/node/commit/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae); V8 [13.6.233.17-node.51](https://github.com/nodejs/node/blob/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae/common.gypi#L44)) | macOS arm64 | nvm | MIT (unchecked) | `sin-demo/`, `v8-sources/` |
| Node.js | [24.22.3](https://github.com/nodejs/node/releases/tag/v24.22.3) ([`e63cab0`](https://github.com/nodejs/node/commit/e63cab040c09d43ceef8cb35508c40044614e906); V8 [13.6.233.17-node.63](https://github.com/nodejs/node/blob/e63cab040c09d43ceef8cb35508c40044614e906/common.gypi#L45)) | macOS arm64 | nvm | MIT (unchecked) | `sin-demo/` |
| Node.js | [26.13.1](https://github.com/nodejs/node/releases/tag/v26.13.1) ([`e9c2776`](https://github.com/nodejs/node/commit/e9c277643b0249c50f6e6de5413be8a88ea11b6a); V8 [14.6.202.34-node.40](https://github.com/nodejs/node/blob/e9c277643b0249c50f6e6de5413be8a88ea11b6a/common.gypi#L47)) | macOS arm64 | nvm | MIT (unchecked) | `sin-demo/`, `v8-sources/` |
| MicroQuickJS | [`6d4d7eb`](https://github.com/bellard/mquickjs/commit/6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9) | macOS arm64; OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation (Ubuntu 24.04) | built from the commit | MIT | `fma-contraction/` |

### Engines recorded only in the `engine-families/` outputs

The `engine-families/` outputs are captured, and they record only versions. How each was obtained isn't recorded in those outputs, except that the Linux QuickJS-ng, Hermes, and XS binaries came from jsvu. Each link below goes to the project's release tag, or to a versioned download, for the version the output names.

| Engine or runtime | Versions recorded | Pinned source |
| --- | --- | --- |
| Boa | 0.22 | [v0.22](https://github.com/boa-dev/boa/releases/tag/v0.22) |
| Duktape | 2.7.0 | [v2.7.0](https://github.com/svaarala/duktape/releases/tag/v2.7.0) |
| engine262 | no version recorded | the commit the post cites, [`d553e7b`](https://github.com/engine262/engine262/commit/d553e7b52501fbc47eae981c8d0fa7a5c26d0171) |
| GraalJS | 25.0.3 | [vm-25.0.3](https://github.com/oracle/graaljs/releases/tag/vm-25.0.3) |
| Hermes | 0.13.0 | [v0.13.0](https://github.com/meta/hermes/releases/tag/v0.13.0) |
| JavaScriptCore | builds 319418 and 324323; WebKitGTK 2.52.6 on Linux | [319418@main](https://commits.webkit.org/319418@main) and [324323@main](https://commits.webkit.org/324323@main); [webkitgtk-2.52.6.tar.xz](https://webkitgtk.org/releases/webkitgtk-2.52.6.tar.xz) |
| JerryScript | 3.0.0 | [v3.0.0](https://github.com/jerryscript-project/jerryscript/releases/tag/v3.0.0) |
| MicroQuickJS | no version recorded | [`6d4d7eb`](https://github.com/bellard/mquickjs/commit/6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9), the commit in the table above |
| Node.js | 22.22.1, 24.19.0, 26.7.0, and 26.12.0 | [v22.22.1](https://github.com/nodejs/node/releases/tag/v22.22.1), [v24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0), [v26.7.0](https://github.com/nodejs/node/releases/tag/v26.7.0), [v26.12.0](https://github.com/nodejs/node/releases/tag/v26.12.0) |
| QuickJS | 2021-03-27 | [quickjs-2021-03-27.tar.xz](https://bellard.org/quickjs/quickjs-2021-03-27.tar.xz) |
| QuickJS-ng | 0.17.0 | [v0.17.0](https://github.com/quickjs-ng/quickjs/releases/tag/v0.17.0) |
| SpiderMonkey shells | 115.10.0, 155.0b1, and 159.0b5 | [FIREFOX_115_10_0esr_RELEASE](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_115_10_0esr_RELEASE), [FIREFOX_155_0b1_RELEASE](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_155_0b1_RELEASE), [FIREFOX_159_0b5_RELEASE](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_159_0b5_RELEASE) |
| txiki.js | 26.6.0 | [v26.6.0](https://github.com/saghul/txiki.js/releases/tag/v26.6.0) |
| V8 (d8) | 13.6.233 to 15.8.32: 13.6.233, 14.1.146, 14.6.202, 15.4.8, and 15.8.32 | tags [13.6.233](https://github.com/v8/v8/tree/13.6.233), [14.1.146](https://github.com/v8/v8/tree/14.1.146), [14.6.202](https://github.com/v8/v8/tree/14.6.202), [15.4.8](https://github.com/v8/v8/tree/15.4.8), [15.8.32](https://github.com/v8/v8/tree/15.8.32); builds [14.1.146 for macOS arm64](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-14.1.146.zip) and [for linux64](https://storage.googleapis.com/chromium-v8/official/canary/v8-linux64-rel-14.1.146.zip), and the build links in the d8 rows above for the rest |
| Bare | 1.36.0 (V8 build) | [v1.36.0](https://github.com/holepunchto/bare/releases/tag/v1.36.0) |
| XS | 9.0.0 and 10.0.2 | Moddable releases [9.0.0](https://github.com/Moddable-OpenSource/moddable/releases/tag/9.0.0) and [10.0.2](https://github.com/Moddable-OpenSource/moddable/releases/tag/10.0.2) |
| musl, inside the Linux QuickJS-ng binary | 1.2.6, from the source path embedded in the binary | [v1.2.6](https://git.musl-libc.org/cgit/musl/tag/?h=v1.2.6) |

## Tools and libraries

| Tool or library | Version or commit | Platform | How obtained | License | Folders |
| --- | --- | --- | --- | --- | --- |
| Apple clang | 21.0.0 (clang-2100.3.34.2) | macOS arm64 | Xcode command-line tools | unchecked | `fma-contraction/`, `v8-sources/`, `sin-demo/` |
| GCC | [13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1)](https://launchpad.net/ubuntu/+source/gcc-13/13.3.0-6ubuntu2~24.04.1) | Ubuntu 24.04 containers | apt in the pinned image | GPL-3.0-or-later (unchecked) | `fma-contraction/`, `sin-demo/` |
| clang | [18.1.3](https://github.com/llvm/llvm-project/releases/tag/llvmorg-18.1.3) (Ubuntu) | Ubuntu 24.04 containers | apt in the pinned image | unchecked | `fma-contraction/` |
| glibc | 2.39 ([Ubuntu package 2.39-0ubuntu8.12](https://launchpad.net/ubuntu/+source/glibc/2.39-0ubuntu8.12); tag commit [`ef321e2`](https://github.com/bminor/glibc/commit/ef321e23c20eebc6d6fb4044425c00e6df27b05f)) | Ubuntu 24.04 containers | apt in the pinned image | LGPL-2.1-or-later (unchecked) | `sin-demo/` |
| glibc | [2.43](https://sourceware.org/git/?p=glibc.git;a=tag;h=refs/tags/glibc-2.43) ([`f762ccf`](https://github.com/bminor/glibc/commit/f762ccf84f122d1354f103a151cba8bde797d521)) | same containers | built from the tag at `sourceware.org/git/glibc.git` | LGPL-2.1-or-later (unchecked) | `sin-demo/` |
| glibc | [2.44](https://sourceware.org/git/?p=glibc.git;a=tag;h=refs/tags/glibc-2.44) ([`c3a3a98`](https://github.com/bminor/glibc/commit/c3a3a9808ad3ab4a3336836833f83288b672ccbf)) | same containers | built from the tag at `sourceware.org/git/glibc.git` | LGPL-2.1-or-later (unchecked) | `sin-demo/` |
| glibc source for the diff | [`4e21c20`](https://github.com/bminor/glibc/commit/4e21c2075193e406a92c0d1cb091a7c804fda4d9) | read only | the `bminor/glibc` mirror, at the pin | LGPL-2.1-or-later (per V8's `README.v8`) | `v8-sources/` |
| musl | [1.2.4-2 (Ubuntu package)](https://launchpad.net/ubuntu/+source/musl/1.2.4-2) | Claude Code Cloud, x86_64 VM | Ubuntu apt; a C program built with `musl-gcc -static` | MIT (unchecked) | `engine-families/` |
| LLVM libc (`atan`) | [`6fd5620`](https://chromium.googlesource.com/external/github.com/llvm/llvm-project/libc.git/+/6fd5620cc4fd3c55ee749e9bf71f52038431f76d) | macOS arm64; Ubuntu x86_64 and aarch64 containers | built from the commit, through Chromium's mirror of `llvm-project`'s `libc` | Apache-2.0 WITH LLVM-exception | `fma-contraction/` |
| V8 source (glibc copy, flags, `ieee754.cc`) | [`b0a55a7`](https://github.com/v8/v8/commit/b0a55a7dad7f536cce1f9aaddba89894c8533946) ([13.6.233.17](https://github.com/v8/v8/tree/13.6.233.17)) | read only; the glibc copy's `s_sin.c` and the rest compiled on macOS | raw GitHub files at the pin | BSD-3-Clause | `v8-sources/` |
| stdlib test fixtures | [`5506660`](https://github.com/stdlib-js/stdlib/commit/550666096f34c73f90f4bf86139935e4214fe421) | macOS arm64 | sparse git fetch | Apache-2.0 | `lib/`, `fma-contraction/` |
| `@stdlib/math-base-special-erf` | [0.2.6](https://www.npmjs.com/package/@stdlib/math-base-special-erf/v/0.2.6) | macOS arm64; container | npm | Apache-2.0 | `fma-contraction/` |
| `@stdlib/math-base-special-gamma` | [0.3.1](https://www.npmjs.com/package/@stdlib/math-base-special-gamma/v/0.3.1) | same | npm | Apache-2.0 | `fma-contraction/` |
| `@stdlib/math-base-special-log1p` | [0.2.4](https://www.npmjs.com/package/@stdlib/math-base-special-log1p/v/0.2.4) | same | npm | Apache-2.0 | `fma-contraction/` |
| esbuild | [0.25.10](https://www.npmjs.com/package/esbuild/v/0.25.10) | macOS arm64 | npm | MIT | `fma-contraction/` |
| Julia (with MPFR [4.2.2](https://www.mpfr.org/mpfr-4.2.2/)) | [1.13.3](https://github.com/JuliaLang/julia/releases/tag/v1.13.3) | macOS arm64 | juliaup [1.24.0](https://github.com/JuliaLang/juliaup/releases/tag/v1.24.0) | MIT (Julia); MPFR unchecked | `lib/`, `fma-contraction/` |
| Node.js (Ubuntu package, in the container) | [18.19.1](https://github.com/nodejs/node/releases/tag/v18.19.1) | Ubuntu 24.04 containers | apt | unchecked | `fma-contraction/` |
| Python (standard library only) | [3.15.2](https://github.com/python/cpython/releases/tag/v3.15.2) | macOS arm64 | Homebrew | PSF-2.0 | `spec/`, `sin-demo/` |
| poppler `pdftotext` | [26.11.0](https://poppler.freedesktop.org/poppler-26.11.0.tar.xz) | macOS arm64 | Homebrew | GPL-2.0-or-later | `spec/` |

## Added with the results-only folders

These come from captured or recorded results, not reruns. "Not recorded" means the original output or note doesn't say.

### Platforms

| Platform | Used for |
| --- | --- |
| macOS 26.7.3 (build 25G342), arm64 | the browser runs in `browsers/` |
| macOS (Darwin 25.6.0), arm64, Apple M1 Pro | the shell scan in `browsers/` |
| macOS 26.6.2, arm64, Apple M1 Pro; OrbStack 2.2.5; Ubuntu 24.04 containers (`ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852`) | the OrbStack runs in `plainly-wrong/`, and the macOS runs in `bindings/` |
| Claude Code Cloud, x86_64 VM (Intel Xeon, Ubuntu 24.04.5) | the Cloud runs in `sumprecise/`, `engine-families/scriptc/`, and the Cloud lines quoted in `plainly-wrong/` |

### Engines, runtimes, and bindings

| Name | Version or commit | Platform | How obtained | License | Folder |
| --- | --- | --- | --- | --- | --- |
| Chrome | [158.0.8127.37](https://chromium.googlesource.com/chromium/src/+/refs/tags/158.0.8127.37) (V8 [15.8.62.31](https://github.com/v8/v8/tree/15.8.62.31), revision [`b8c2be8`](https://github.com/chromium/chromium/commit/b8c2be851f62f6a394ec57955d7f31335d7cb6d4)) | macOS 26.7.3 arm64 | not recorded | unchecked | `browsers/` |
| Firefox | [160.0.1](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_160_0_1_RELEASE) (built from [`58fed86`](https://github.com/mozilla-firefox/firefox/commit/58fed86b1b6864ad71b83c910a879d6f1a6b678b)) | macOS 26.7.3 arm64 | not recorded | unchecked | `browsers/` |
| Safari | 27.2 (21625.2.8.18.4) | macOS 26.7.3 arm64 | not recorded | unchecked | `browsers/` |
| SpiderMonkey shell | [159.0b5](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_159_0b5_RELEASE) ([`34ac067`](https://github.com/mozilla-firefox/firefox/commit/34ac0671eb25f31f8c56ace36e1c413dd471eb8d)) | macOS arm64 | jsvu ([jsshell-mac.zip](https://archive.mozilla.org/pub/firefox/releases/159.0b5/jsshell/jsshell-mac.zip)) | unchecked | `browsers/` |
| Node.js | [22.23.5](https://github.com/nodejs/node/releases/tag/v22.23.5) ([`6055365`](https://github.com/nodejs/node/commit/60553651579ec33ca1aef9e1eedab2c3855f1f7e)) | Claude Code Cloud, x86_64 VM | image default | MIT (unchecked) | `sumprecise/` |
| Node.js | [26.7.0](https://github.com/nodejs/node/releases/tag/v26.7.0) ([`b4f23d3`](https://github.com/nodejs/node/commit/b4f23d3619c98bed09af93a21192f6080197a8c6); V8 [14.6.202.34-node.28](https://github.com/nodejs/node/blob/b4f23d3619c98bed09af93a21192f6080197a8c6/common.gypi#L45)) | Claude Code Cloud, x86_64 VM | preinstalled in the image | MIT (unchecked) | `sumprecise/` |
| Node.js | [27.0.0-alpha.0.1.1](https://github.com/nodejs/node/releases/tag/v27.0.0-alpha.0.1.1) ([`6c7c893`](https://github.com/nodejs/node/commit/6c7c89331d062a47d6fe3d16b3c00e4a3145826d); V8 [15.6.75.50-node.14](https://github.com/nodejs/node/blob/6c7c89331d062a47d6fe3d16b3c00e4a3145826d/common.gypi#L53)) | macOS arm64 | nvm | MIT (unchecked) | `sumprecise/` |
| Node.js | [24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0) and [24.22.2](https://github.com/nodejs/node/releases/tag/v24.22.2) (V8 [13.6.233.17-node.51](https://github.com/nodejs/node/blob/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae/common.gypi#L44) and [node.63](https://github.com/nodejs/node/blob/f7f273a9bb6445f6f7fb6349105e7532972045fb/common.gypi#L45)) | Claude Code Cloud, x86_64 VM; macOS arm64 | nvm; preinstalled in the image | MIT (unchecked) | `sumprecise/`, `engine-families/scriptc/`, `bindings/` |
| Deno | [2.9.8](https://github.com/denoland/deno/releases/tag/v2.9.8) | macOS arm64 | not recorded | unchecked | `sumprecise/` |
| Bun | [1.3.14](https://github.com/oven-sh/bun/releases/tag/bun-v1.3.14) (WebKit [`5488984`](https://github.com/oven-sh/WebKit/commit/5488984d20e0dbfe4be2c3ba8fb18eb81a5e0e8b)) | macOS arm64 | not recorded | unchecked | `sumprecise/` |
| scriptc | [0.4.7](https://www.npmjs.com/package/scriptc/v/0.4.7) (tag [`v0.4.7`](https://github.com/vercel-labs/scriptc/releases/tag/v0.4.7), commit [`6c60b0b`](https://github.com/vercel-labs/scriptc/commit/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff)) | Claude Code Cloud, x86_64 VM | npm; compiler binary from [`@scriptc/cli-linux-x64-gnu` 0.4.7](https://www.npmjs.com/package/@scriptc/cli-linux-x64-gnu/v/0.4.7), the version scriptc 0.4.7's `optionalDependencies` name | unchecked | `engine-families/scriptc/` |
| Rhino | 2.0.0-SNAPSHOT [`7386aa0`](https://github.com/mozilla/rhino/commit/7386aa037d9a8020e4e69cc0af11eb73fe59d09d); [1.9.2](https://github.com/mozilla/rhino/releases/tag/Rhino1_9_2_Release) [`b3d405f`](https://github.com/mozilla/rhino/commit/b3d405fe2ef4948929629b23d85ba7eef76a2c2a) | OrbStack arm64 and x86_64 under emulation; Claude Code Cloud (quoted) | [javascript-zoo 20260303 release](https://github.com/ivankra/javascript-zoo/releases/tag/20260303); Maven Central [`rhino-all-1.9.2.jar`](https://repo1.maven.org/maven2/org/mozilla/rhino-all/1.9.2/rhino-all-1.9.2.jar) | MPL-2.0 (unchecked) | `plainly-wrong/` |
| goja | [`622d100`](https://github.com/dop251/goja/commit/622d10077b6c154d9dc0897878aa1b4a674d7c9b) | OrbStack arm64 and x86_64 under emulation | `go install` with [go1.26.10](https://github.com/golang/go/releases/tag/go1.26.10) | MIT (unchecked) | `plainly-wrong/` |
| otto | [v0.5.1](https://github.com/robertkrimen/otto/releases/tag/v0.5.1) ([`43d0d58`](https://github.com/robertkrimen/otto/commit/43d0d581930e54a0daee9e3770b68e947a7f33fc)) | same | `go install` with [go1.24.7](https://github.com/golang/go/releases/tag/go1.24.7) | MIT (unchecked) | `plainly-wrong/` |
| Nova, Kiesel, Quanta, Porffor, Hermes | Nova [`d85a2f8`](https://github.com/trynova/nova/commit/d85a2f8d243441f4917f80b38e683d501aa62e72); Quanta [`767a49f`](https://github.com/solarbrowser/quanta/commit/767a49f40a7a974e081bd87840793cd188a135bf); Porffor [0.0.0-alpha.19](https://www.npmjs.com/package/porffor/v/0.0.0-alpha.19) ([`0c135ce`](https://github.com/CanadaHonk/porffor/commit/0c135ce2f36fdd3467d5a58daa92283810705a51)); Hermes [0.13.0](https://github.com/meta/hermes/releases/tag/v0.13.0) ([`4b3bf91`](https://github.com/meta/hermes/commit/4b3bf912cc0f705b51b71ce1a5b8bd79b93a451b)); Kiesel `20deb11f17569844c869b267d300d77cbc3414a1` (x86_64) and [`7a082e2af389ca9b8f4f08d563a016ede9c8d18a`](https://codeberg.org/kiesel-js/kiesel/commit/7a082e2af389ca9b8f4f08d563a016ede9c8d18a) (arm64), both as the release data in the setup output gives them | OrbStack arm64 and x86_64 under emulation | [javascript-zoo 20260303 release](https://github.com/ivankra/javascript-zoo/releases/tag/20260303) (Kiesel x86_64: [`kiesel.amd64.tar.zst`](https://github.com/ivankra/javascript-zoo/releases/download/20260303/kiesel.amd64.tar.zst)); npm; GitHub release tarball | unchecked | `plainly-wrong/` |
| v8go (V8 [9.0.257.18](https://github.com/v8/v8/tree/9.0.257.18)) | [`12b0374`](https://github.com/rogchap/v8go/commit/12b0374faffcc6a93eb284808ca1beab58259e72) | macOS 26.6.2 arm64 | `go get` | BSD-3-Clause | `bindings/` |
| v8go (V8 [10.9.194.9](https://github.com/v8/v8/tree/10.9.194.9) at runtime) | [v0.9.0](https://github.com/rogchap/v8go/releases/tag/v0.9.0) ([`0e40e6e`](https://github.com/rogchap/v8go/commit/0e40e6e5827ad897d25f915917d8206e9a8231db)) | macOS 26.6.2 arm64 | `go get rogchap.com/v8go@v0.9.0` | BSD-3-Clause | `bindings/` |
| PyMiniRacer (V8 [14.4.258.23](https://github.com/v8/v8/tree/14.4.258.23)) | [0.14.1](https://pypi.org/project/mini-racer/0.14.1/) ([`95b8988`](https://github.com/bpcreech/PyMiniRacer/commit/95b89887e74103a91747bca45a1e35ff0e1b81c3)) | macOS 26.6.2 arm64 | PyPI wheel, `pip install --no-deps` | ISC | `bindings/` |
| d8 (V8) | [9.0.257](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-9.0.257.zip), [10.9.194](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-10.9.194.zip), [14.4.258](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-14.4.258.zip), [14.6.202](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-14.6.202.zip) | macOS arm64 | jsvu | unchecked | `bindings/` |

### Tools and sources

| Tool or source | Version or commit | Platform | How obtained | License | Folder |
| --- | --- | --- | --- | --- | --- |
| Go | [go1.24.7](https://github.com/golang/go/releases/tag/go1.24.7), [go1.26.10](https://github.com/golang/go/releases/tag/go1.26.10) | OrbStack arm64 and x86_64 under emulation | conda-forge; `GOTOOLCHAIN=auto` for 1.26.10 | BSD-3-Clause (unchecked) | `plainly-wrong/` |
| OpenJDK | [25.0.2](https://github.com/openjdk/jdk25u/releases/tag/jdk-25.0.2-ga) and [21.0.10](https://github.com/openjdk/jdk21u/releases/tag/jdk-21.0.10-ga) | same | conda-forge | GPL-2.0-with-classpath-exception (unchecked) | `plainly-wrong/` |
| qemu-user | [8.2.2](https://github.com/qemu/qemu/releases/tag/v8.2.2) | OrbStack arm64 container | Ubuntu apt | GPL-2.0 (unchecked) | `plainly-wrong/` |
| Go and Python | [1.27.4](https://github.com/golang/go/releases/tag/go1.27.4) and [3.13.18](https://github.com/python/cpython/releases/tag/v3.13.18) | macOS arm64 | conda-forge, through pixi [0.84.2](https://github.com/prefix-dev/pixi/releases/tag/v0.84.2) | unchecked | `bindings/` |
| MDN browser-compat-data | [`9237d95`](https://github.com/mdn/browser-compat-data/commit/9237d95b44e0ed02a094c50a0277e228c81b236f), [`290cd74`](https://github.com/mdn/browser-compat-data/commit/290cd74dbb04d539bc252f4e8f44a723947f8f31), [`7171dca`](https://github.com/mdn/browser-compat-data/commit/7171dca74fea50d3fd88eca8e75b2636954a45b8) | read only | `gh api` | unchecked | `sumprecise/` |
| test262 | [`2e58f87`](https://github.com/tc39/test262/commit/2e58f87d8350ad51224617a041c6e041d52f8444) | read; run in the Cloud VM | pinned fetch | unchecked | `sumprecise/` |
| NumPy and Apple clang | NumPy [2.5.5](https://github.com/numpy/numpy/releases/tag/v2.5.5); Apple clang 21 | macOS arm64 | a recorded check; install route and clang patch version not recorded | unchecked | `reads/` |

## Specification editions

`spec/` fetches ECMA-262 editions 1 to 17 at run time from Ecma International and checks each file's sha256, which [`spec/README.md`](spec/README.md) records. Editions are fixed documents, so they are pinned by checksum, not by commit, and none is committed here.
