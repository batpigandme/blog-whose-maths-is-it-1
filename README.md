# Whose maths is it?

> Source code for the blog post ["Whose maths is it?"][post].

The post asks where JavaScript's `Math` functions come from, and why the same engine can answer differently on different builds and machines. This repository holds the code, data, and outputs behind its claims, one folder per claim, so you can check them or rerun them. The results were measured on macOS arm64, and on Linux VMs in Claude Code Cloud (x86_64) and OrbStack (aarch64, on a Mac).

## How to use this repository

Every footnote or section in the post that defers to the repository is listed in the index below, with a folder, a tier, and a status.

**Tiers** say what a rerun needs:

- **a: anywhere.** Node.js or Python on any operating system; some also need `pdftotext` or network access to fetch a specification edition.
- **b: needs a Mac or particular binaries.** The answer depends on the build, so the evidence is machine specific: d8 builds from [jsvu](https://github.com/GoogleChromeLabs/jsvu) or V8's build bucket, nvm's Node.js releases, Apple clang, or Docker for the Linux halves. Each folder's README says which.
- **c: results only.** Committed outputs and pinned quotations or links; nothing to rerun.

**Status** is one of:

- **published**: the folder is here, with its script and committed output.
- **results only**: the folder holds recorded observations or readings, such as browser console runs and quotations, and no script is planned for them.
- **results only for now**: the folder holds captured results, labeled as such, and the scripts and reruns are added after publication.
- **link only**: the footnote's pinned link is the evidence; nothing is kept here.

**Committed outputs** are labeled in each folder's README as *regenerated* (the script in the folder produced it, on the date and machine in its header) or *captured* (copied from an earlier run, with machine paths stripped, not rerun). Every output starts with a header naming the engine, platform, how the engine was obtained, the date, and the script. [`ENGINES.md`](./ENGINES.md) collects the engines, tools, and platforms in one table.

Local runs vary by operating system, compiler, and CPU. That's part of the post's argument, so two machines giving different bits isn't a bug in a script. No Docker image is shipped; the Linux halves run in containers you build yourself, on any Docker host.

## Index

| Post section or footnote | What it backs | Folder | Tier | Status |
| --- | --- | --- | --- | --- |
| Plainly wrong | each story's builds, inputs, outputs, and script | [`plainly-wrong/`](./plainly-wrong/) | b | results only for now |
| The families | which engines draw on which library | [`engine-families/`](./engine-families/) | c for now (b later) | results only for now: a stub of captured results |
| `[^browsers]` | the shell scan, and the three browser runs on `sin`, `cos`, `tan` | [`browsers/`](./browsers/) | c (b for the shell scan) | results only for the browser runs; the shell scan's scripts are added after publication |
| `[^js10]` | the figure's 17 `Math` functions and 8 constants | [`reads/`](./reads/) | c | results only: a recorded reading |
| `[^es1]` | the 1st edition's 18 functions by clause; the 3rd edition's "implementer" | [`spec/`](./spec/) | a | published |
| `[^terms]` | §4.2's example, "implementation-approximated" | [`spec/`](./spec/) | a | published |
| `[^split]` | the 22 / 1 / 14 split of the 37 `Math` functions | [`spec/`](./spec/) | a | published |
| `[^sumprecise-node]` | `sumPrecise` support by Node.js version | [`sumprecise/`](./sumprecise/) | b | results only for now |
| `[^lull]` | the count of `Math` functions per edition | [`spec/`](./spec/) | a | published |
| `[^libs]` | npm downloads, stars, and archive status for the libraries the post names | [`libraries/`](./libraries/) | a | results only for now |
| `[^mquickjs]` | MicroQuickJS's `tan` pair, and nine functions that differ between macOS and Linux | [`fma-contraction/`](./fma-contraction/) | b | published |
| `[^atan]` | V8's LLVM `atan` and the fused multiply-add probe | [`fma-contraction/`](./fma-contraction/) | b | published |
| `[^contract]` | the contraction probe: 68 fused instructions with contraction on, none with it off | [`fma-contraction/`](./fma-contraction/) | b | published |
| `[^sin-check]` | the 1,063-ULP `sin` through d8, Node.js, glibc, and Chrome | [`sin-demo/`](./sin-demo/) | b | published; the Chrome run is a README note |
| `[^versions]` | the Node.js patch-release comparison; Node.js 26.13.1's V8 | [`sin-demo/`](./sin-demo/) | b | published |
| `[^v8]` | V8's glibc copy, `pow`, and the build switch | [`v8-sources/`](./v8-sources/) | b | published |
| `[^v8-move]` | `tan`'s move to LLVM's libm; the per-family bisection of d8 builds | [`v8-sources/`](./v8-sources/) | b | published |
| `[^rhino]` | Rhino's `asinh`, `acosh`, and `atanh` across hosts and versions | [`plainly-wrong/`](./plainly-wrong/) | b | results only for now |
| `[^c-library]` | per-engine, per-platform runs against the C library | [`engine-families/`](./engine-families/) | c for now (b later) | results only for now: a stub of captured results |
| `[^scriptc]` | scriptc's cases and run | [`engine-families/scriptc/`](./engine-families/scriptc/) | b | results only for now |
| `[^go-log]` | Go's `log` of `5e-324` on x86_64 and arm64 | [`plainly-wrong/`](./plainly-wrong/) | b | results only for now |
| `[^java-math]` | `java.lang.Math` and `StrictMath` | [`reads/`](./reads/) | c | results only: a recorded reading |
| `[^bindings]` | v8go and PyMiniRacer against d8 at the same V8 | [`bindings/`](./bindings/) | b | results only for now |
| `[^firefox]` | where SpiderMonkey reads its preference | | c | link only |
| `[^numpy]` | NumPy's `np.finfo(np.longdouble)` on a Mac | [`reads/`](./reads/) | a | results only for now: a recorded check; its script is added after publication |

## Layout

```text
README.md             this index
ENGINES.md            the engines, tools, and platforms used, with versions and how they were obtained
spec/                 how the specification splits the Math functions, and its edition counts
sin-demo/             Math.sin on one huge argument, through d8, Node.js, and glibc
v8-sources/           where V8's maths comes from, by version
fma-contraction/      MicroQuickJS's and V8's maths library, with and without fused multiply-add
engine-families/      which library each engine's maths matches, and scriptc (results only for now)
plainly-wrong/        Rhino, Go's log, and the other cases the post calls plainly wrong (results only for now)
browsers/             Chrome, Firefox, and Safari on one Mac as recorded, and the shell scan (results only)
sumprecise/           Math.sumPrecise support by Node.js version (results only for now)
libraries/            npm downloads and repository status for the libraries the post names (results only for now)
bindings/             v8go and PyMiniRacer against d8 at the same V8 (results only for now)
reads/                recorded readings: the HOPL figure, java.lang.Math, NumPy (results only)
lib/                  helpers more than one folder uses: the case generator, drivers, checksums
```

Each folder has its own README: the claim it backs, its tier, how to rerun it, the expected output, the committed outputs, the sources pinned to commits or checksums, and its scope. Third-party code isn't copied here; scripts fetch it at a pinned commit into an ignored `.cache/` folder, and generated inputs ship as the generator plus a checksum of its output.

## License

See [LICENSE][license].

## Copyright

Copyright © 2026. The Stdlib [Authors][stdlib-authors].

[post]: `TODO: put blog post link here`

[stdlib-authors]: https://github.com/stdlib-js/stdlib/graphs/contributors

[license]: ./LICENSE
