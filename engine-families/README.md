# engine-families

> Captured results from earlier runs, not regenerated. This folder has no scripts.

Backs the post's section "The families" and its footnotes `[^c-library]`, `[^scriptc]`, `[^go-log]`, `[^strictmath]`, and `[^rust]`, and Figure 4, "Many engines, a handful of sources."

The outputs were measured on macOS arm64, and on Linux x86_64 in a Claude Code Cloud VM.

## What was run

Three runs on 2026-10-22 produced the three output files. On a Mac (arm64), 25 binaries ran 17 functions: each is an engine, runtime, or build at a version listed under [Sources pinned](#sources-pinned), or `macos-libm-c`, a C program calling the system's maths library. Each result was compared with MPFR references (`macos-all-engines.results.txt`). On an x86_64 Linux VM in Claude Code Cloud (Ubuntu 24.04, glibc 2.39), the result bits of the same engines' Linux builds were attributed by hash to glibc, to the macOS binary of the same name, or to neither (`linux-attribution.results.txt`). On the same VM, the C libraries that jsvu's Linux binaries link were read, and QuickJS-ng's and Hermes's Linux binaries were compared with a C program built against musl (`linux-binaries-and-musl.results.txt`). The tables under "What the committed results show" are counted from those three files, by the rule stated above each.

## Claim

From the post: many engines draw on somebody else's code, and sorted by whose, they fall into a few families. Engines that call the same library get the same answers from it, so one bug shows up in all of them, and one upstream fix fixes all of them.

- **The platform's C library.** On macOS, several engines match the system's C library bit for bit on every `Math` function; on Linux, the same engines give glibc's bits instead, or musl's for a QuickJS-ng build linked against it. So one engine, at one version, can answer differently depending on the operating system under it.
- **fdlibm and its ports.** V8's own code is an fdlibm port, and so is most of SpiderMonkey's. A port is a copy, so a fix upstream doesn't reach it by itself.
- **The language the engine is written in.** goja and otto call Go's `math`; Rhino and GraalJS build on Java's `Math`; Boa uses Rust's `f64` methods, and underneath, its bits are the C library's.

## Tier

c: results only.

## What the committed results show

Both tables below are counted from the committed outputs, by one rule each, so they can be checked against those files.

### On macOS, against the system's C library

From `macos-all-engines.results.txt`: for each `Math` function the output lists the engines whose results are identical, and one of those groups contains `macos-libm-c`, a C program calling the system's maths library. An engine "matches" a function when it is in that group. The count is over the 14 rows named `Math.<name>` in the output (`acos`, `asin`, `atan`, `atan2`, `cos`, `exp`, `fround`, `log`, `log10`, `log2`, `pow`, `sin`, `sqrt`, `tan`). The output has three more rows (`erf`, `gamma`, and `log1p`, written without the `Math.` prefix), which this table leaves out.

| Engine and version | Matches macOS's C library on | Differs on |
| --- | --- | --- |
| Boa 0.22 | 14 of 14 | none |
| Hermes 0.13.0 | 14 of 14 | none |
| JerryScript 3.0.0 | 14 of 14 | none |
| QuickJS-ng 0.17.0 | 14 of 14 | none |
| Duktape 2.7.0 | 13 of 14 | `fround` |
| JavaScriptCore, builds 319418 and 324323 | 13 of 14 | `pow` |
| SpiderMonkey shell 155.0b1 and 159.0b5 | 5 of 14 | `acos`, `asin`, `atan`, `atan2`, `exp`, `log`, `log10`, `log2`, `pow` |
| MicroQuickJS (`mqjs`, and its soft-float build) | 3 of 14 | `acos`, `asin`, `atan`, `atan2`, `cos`, `exp`, `log`, `log2`, `pow`, `sin`, `tan` |
| V8 15.4.8 and 15.8.32 (d8) | 3 of 14 | the same eleven as `mqjs` |
| XS 9.0.0 and 10.0.2 | 3 of 14 | `acos`, `asin`, `atan`, `atan2`, `cos`, `exp`, `log`, `log10`, `pow`, `sin`, `tan` |
| V8 13.6.233, 14.1.146, and 14.6.202 (d8) | 2 of 14 | all but `fround` and `sqrt` |
| Node.js 22.22.1, 24.19.0, 26.7.0, and 26.12.0 | 2 of 14 | all but `fround` and `sqrt` |
| Bare 1.36.0 (V8 build) | 2 of 14 | all but `fround` and `sqrt` |
| engine262 | 2 of 14 | all but `fround` and `sqrt` |

`fround` and `sqrt`, which are exactly specified, match macOS's C library for every engine in the table except Duktape on `fround`.

### On Linux (Claude Code Cloud, x86_64 VM), against glibc 2.39

From `linux-attribution.results.txt`: each cell says whether an engine's Linux result bits are glibc's (`G`), are the same as the macOS binary of the same name (`S`), or are neither (`-`); `.` means there was no macOS binary of that name to compare with. The table counts the output's 12 columns (`acos`, `asin`, `atan`, `atan2`, `cos`, `exp`, `log`, `log10`, `log2`, `pow`, `sin`, `tan`); `fround` and `sqrt` are left out of that output because they are exactly specified.

| Engine and version | glibc's bits | Same as the macOS binary | Neither |
| --- | --- | --- | --- |
| Boa 0.22, Duktape 2.7.0, JerryScript 3.0.0, QuickJS 2021-03-27, txiki.js 26.6.0 | 12 of 12 | 0 | 0 |
| JavaScriptCore build 324323 | 11 of 12 | 0 | 1 (`pow`) |
| JavaScriptCore, WebKitGTK 2.52.6 | 11 of 11 compared | 0 | `pow` not compared |
| Hermes 0.13.0 (static binary) | 6 of 12 (`cos`, `exp`, `log`, `log10`, `pow`, `sin`) | 0 | 6 |
| SpiderMonkey shell 159.0b5 | 3 of 12 (`cos`, `sin`, `tan`) | 8 | 1 (`pow`) |
| V8 13.6.233, 14.1.146, and 14.6.202 (d8) | 0 | 11 | 1 (`pow`) |
| V8 15.4.8 and 15.8.32 (d8) | 0 | 10 | 2 (`atan`, `pow`) |
| QuickJS-ng 0.17.0 (static binary) | 1 (`log`) | 0 | 11 |
| XS 10.0.2 | 1 (`log2`) | 0 | 11 |
| Node.js 24.19.0 and 26.7.0 | 0 | 1 (`log2`) | 11 |
| engine262 | 0 | 1 (`log2`) | 11 |
| MicroQuickJS (`mqjs`, and its soft-float build) | 0 | 3 (`log`, `log10`, `log2`) | 9 |

QuickJS-ng's Linux binary is statically linked, and the C library inside it is [musl 1.2.6](https://git.musl-libc.org/cgit/musl/tag/?h=v1.2.6), by the source path embedded in the binary. `linux-binaries-and-musl.results.txt` shows a C program built against Ubuntu's [musl 1.2.4](https://launchpad.net/ubuntu/+source/musl/1.2.4-2) (package 1.2.4-2) giving the same bits as that binary on all 12 functions, and Hermes's static Linux binary matching musl on only `log` and `log2`. That's the "mix" the post describes.

## The other families

The post's other claims in "The families" rest on results held in other folders of this repository, with the pinned source each reads.

| Family | Engines, at the commits the post cites | Claim, in the post's words | In this folder |
| --- | --- | --- | --- |
| The language's maths: Go | goja [`622d100`](https://github.com/dop251/goja/commit/622d10077b6c154d9dc0897878aa1b4a674d7c9b), otto [`43d0d58`](https://github.com/robertkrimen/otto/commit/43d0d581930e54a0daee9e3770b68e947a7f33fc), on Go [1.24.7](https://github.com/golang/go/releases/tag/go1.24.7) and [1.26.10](https://github.com/golang/go/releases/tag/go1.26.10) | Go's `log` of `5e-324` is wrong on x86_64 and right on arm64, and goja and otto give exactly Go's answers on both | [`plainly-wrong/`](../plainly-wrong/) |
| The language's maths: Java | Rhino, GraalJS | `java.lang.Math` is "not defined to return the bit-for-bit same results" | [`reads/java-math.md`](../reads/java-math.md) |
| The language's maths: Rust | Boa 0.22 | Boa's bits are the C library's (see the tables above) | the tables above |
| The engine's own code | MicroQuickJS [`6d4d7eb`](https://github.com/bellard/mquickjs/commit/6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9), its `libm.c`; Elk [`71a86fa`](https://github.com/cesanta/elk/commit/71a86fa2fef146696be9ae66715bf3f91d0a5f2c), with no `Math` object | MicroQuickJS ships its own maths library; Elk has none | the MicroQuickJS rows above |
| A port of V8's code | scriptc [`4af5844`](https://github.com/vercel-labs/scriptc/commit/4af5844f522b2762716226114262fd7dd86c8e65); the run and source reading are of v0.4.7, [`6c60b0b`](https://github.com/vercel-labs/scriptc/commit/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff) | its `Math` matches Node.js [24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0)'s bit for bit on all 7,820 cases tested, with `pow` going to the platform's | [`scriptc/`](scriptc/README.md) |
| Borrowed from the host | engine262 [`d553e7b`](https://github.com/engine262/engine262/commit/d553e7b52501fbc47eae981c8d0fa7a5c26d0171) | its maths matches the engine running it, inferred from its bits | the engine262 rows above |

## Committed outputs

| File | What it is | Regenerated or captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `macos-all-engines.results.txt` | 25 binaries by 17 functions against MPFR, with groups of identical output | captured, not rerun | 2026-10-22 | a Mac (arm64); the OS version isn't in the original output |
| `linux-attribution.results.txt` | the same engines' Linux results attributed by hash to glibc, the macOS binary, or neither | captured, not rerun | 2026-10-22 | Claude Code Cloud, x86_64 VM; glibc 2.39 |
| `linux-binaries-and-musl.results.txt` | what jsvu's Linux binaries link, and QuickJS-ng and Hermes against musl | captured, not rerun | 2026-10-22 | Claude Code Cloud, x86_64 VM; glibc 2.39 and musl 1.2.4 |

The three files are the original outputs with a header added. Their table bodies are unedited, apart from the one excerpt noted in the last file's header.

## Sources pinned

Each version the outputs record, with the release tag or versioned download for it. The outputs don't say which download each binary came from, so each link is to the project's source for that version. [`ENGINES.md`](../ENGINES.md) lists the same links.

| Engine, runtime, or library | Versions recorded | Pinned source |
| --- | --- | --- |
| Boa | 0.22 | [v0.22](https://github.com/boa-dev/boa/releases/tag/v0.22) |
| Duktape | 2.7.0 | [v2.7.0](https://github.com/svaarala/duktape/releases/tag/v2.7.0) |
| engine262 | no version recorded | the commit the post cites, [`d553e7b`](https://github.com/engine262/engine262/commit/d553e7b52501fbc47eae981c8d0fa7a5c26d0171) |
| GraalJS | 25.0.3 | [vm-25.0.3](https://github.com/oracle/graaljs/releases/tag/vm-25.0.3) |
| Hermes | 0.13.0 | [v0.13.0](https://github.com/meta/hermes/releases/tag/v0.13.0) |
| JavaScriptCore | builds 319418 and 324323; WebKitGTK 2.52.6 | [319418@main](https://commits.webkit.org/319418@main), [324323@main](https://commits.webkit.org/324323@main); [webkitgtk-2.52.6.tar.xz](https://webkitgtk.org/releases/webkitgtk-2.52.6.tar.xz) |
| JerryScript | 3.0.0 | [v3.0.0](https://github.com/jerryscript-project/jerryscript/releases/tag/v3.0.0) |
| MicroQuickJS | no version recorded | [`6d4d7eb`](https://github.com/bellard/mquickjs/commit/6d4d7eb6b99011d5aab6e88a9b99e8fd4d86c6e9), the commit the post cites |
| Node.js | 22.22.1, 24.19.0, 26.7.0, and 26.12.0 | [v22.22.1](https://github.com/nodejs/node/releases/tag/v22.22.1), [v24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0), [v26.7.0](https://github.com/nodejs/node/releases/tag/v26.7.0), [v26.12.0](https://github.com/nodejs/node/releases/tag/v26.12.0) |
| QuickJS | 2021-03-27 | [quickjs-2021-03-27.tar.xz](https://bellard.org/quickjs/quickjs-2021-03-27.tar.xz) |
| QuickJS-ng | 0.17.0 | [v0.17.0](https://github.com/quickjs-ng/quickjs/releases/tag/v0.17.0) |
| SpiderMonkey shells | 115.10.0, 155.0b1, and 159.0b5 | [FIREFOX_115_10_0esr_RELEASE](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_115_10_0esr_RELEASE), [FIREFOX_155_0b1_RELEASE](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_155_0b1_RELEASE), [FIREFOX_159_0b5_RELEASE](https://github.com/mozilla-firefox/firefox/releases/tag/FIREFOX_159_0b5_RELEASE) |
| txiki.js | 26.6.0 | [v26.6.0](https://github.com/saghul/txiki.js/releases/tag/v26.6.0) |
| V8 (d8) | 13.6.233, 14.1.146, 14.6.202, 15.4.8, and 15.8.32 | tags [13.6.233](https://github.com/v8/v8/tree/13.6.233), [14.1.146](https://github.com/v8/v8/tree/14.1.146), [14.6.202](https://github.com/v8/v8/tree/14.6.202), [15.4.8](https://github.com/v8/v8/tree/15.4.8), [15.8.32](https://github.com/v8/v8/tree/15.8.32); the d8 builds are `v8-<platform>-rel-<version>.zip` in V8's build bucket, for example [15.8.32 for macOS arm64](https://storage.googleapis.com/chromium-v8/official/canary/v8-mac-arm64-rel-15.8.32.zip) and [for linux64](https://storage.googleapis.com/chromium-v8/official/canary/v8-linux64-rel-15.8.32.zip) |
| Bare | 1.36.0 (V8 build) | [v1.36.0](https://github.com/holepunchto/bare/releases/tag/v1.36.0) |
| XS | 9.0.0 and 10.0.2 | Moddable releases [9.0.0](https://github.com/Moddable-OpenSource/moddable/releases/tag/9.0.0) and [10.0.2](https://github.com/Moddable-OpenSource/moddable/releases/tag/10.0.2) |
| glibc | 2.39 (Ubuntu 24.04; package 2.39-0ubuntu8.9 in `linux-binaries-and-musl.results.txt`) | [Ubuntu package 2.39-0ubuntu8.9](https://launchpad.net/ubuntu/+source/glibc/2.39-0ubuntu8.9) |
| musl | 1.2.4 (Ubuntu package 1.2.4-2), and 1.2.6 inside QuickJS-ng's binary | [Ubuntu package 1.2.4-2](https://launchpad.net/ubuntu/+source/musl/1.2.4-2); [v1.2.6](https://git.musl-libc.org/cgit/musl/tag/?h=v1.2.6) |

## Scope

- The macOS output doesn't record the macOS version, or how each of the 25 binaries was obtained.
- Windows isn't covered: no Windows build was run.
