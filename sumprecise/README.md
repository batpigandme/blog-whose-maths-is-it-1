# sumprecise

> **Results only for now: scripts and reruns to follow.** Everything here is copied from earlier runs, or recorded from reads of them, and not regenerated. Nothing in this folder can be rerun yet.

Backs the post's sentence "As of November 2026, no stable Node.js release has it on by default" and its footnote `[^sumprecise-node]`, which says that Node.js 26.13.1 "has no `sumPrecise` without a flag," that Node.js 26.7.0 "has it behind `--js-sum-precise`," and that the Node.js 27 alpha "has it unflagged."

The outputs were measured on macOS arm64, and on Linux x86_64 in a Claude Code Cloud VM.

## Claim

From the post's footnote: Node.js 26.13.1, the newest stable release, carries V8 14.6.202.34 and has no `sumPrecise` without a flag (run 18 November 2026); Node.js 26.7.0 has it behind `--js-sum-precise` (run 17 November 2026); and the Node.js 27 alpha, 27.0.0-alpha.0.1.1, has it unflagged, run on 18 November 2026.

The folder also holds two records that back the body sentence about stable releases: Node.js 24.19.0 and 22.23.5 reject the flag, and MDN's browser-compat-data lists Node.js as `false` for `sumPrecise` at `9237d95b`.

## Tier

c: results only, for now. The full folder will be tier b: it needs the Node.js versions above (nvm installs them on macOS or Linux) and, for the test262 part, a fetch of test262 at a pinned commit.

## What the committed results show

One row for each Node.js version that appears in a committed output, five in all. A cell reads from the line a run printed: `typeof Math.sumPrecise` without a flag, and the result of starting `node` with `--js-sum-precise` with it.

| Node.js | V8 (`process.versions.v8`) | Platform | Date | No flag | With `--js-sum-precise` |
| --- | --- | --- | --- | --- | --- |
| 22.23.5 | 12.4.254.21-node.57 | Claude Code Cloud, x86_64 VM | 2026-11-17 | `undefined` | rejected: `node: bad option: --js-sum-precise`, exit 9 |
| 24.19.0 | 13.6.233.17-node.51 | Claude Code Cloud, x86_64 VM | 2026-11-17 | `undefined` | rejected: `node24: bad option: --js-sum-precise`, exit 9 |
| 26.7.0 | 14.6.202.34-node.28 | Claude Code Cloud, x86_64 VM | 2026-11-17 | `undefined` | `function`; `--v8-options` lists the flag with `default: --no-js-sum-precise` |
| 26.13.1 | 14.6.202.34-node.40 | macOS arm64 | 2026-11-18 | `undefined` | has it: the five-input probe below ran with the flag |
| 27.0.0-alpha.0.1.1 | 15.6.75.50-node.14 | macOS arm64 | 2026-11-18 | `function` | not needed |

By that rule: one of the five has it without a flag (the alpha), two have it behind the flag (26.7.0 and 26.13.1), and two reject the flag (22.23.5 and 24.19.0).

On Node.js 26.7.0 with the flag, the run went further, in `results/node-flag-run-cloud-x86_64.results.txt`:

- test262's ten `Math.sumPrecise` files, each run twice, sloppy and strict: `node26+flag pass 20 fail 0 of 20`.
- A hand-check of 35 cases against values worked out from the specification: `hand-check: 35 of 35 as specified`.
- As a negative control, the same test262 runner on Node.js 24.19.0, which has no `Math.sumPrecise`, passes 0 of 20.

The same file shows the flag's name in Node.js 26.7.0's own help: `--js-sum-precise (enable "Math.sumPrecise")`.

### The five-input probe

A separate result, in `results/five-input-probe.results.txt`: on 2026-11-18 on macOS arm64, five inputs went through the `Math.sumPrecise` each of four runtimes has (the Node.js 27 alpha, Node.js 26.13.1 with `--js-sum-precise`, Deno 2.9.8, and Bun 1.3.14). Both Node.js rows, and Deno's, give `-1` for `[-1]` and `-1.7976931348623157e+308` for `[-Number.MAX_VALUE]`, and all four give `1e-323` for `[5e-324, 5e-324]`. Bun 1.3.14 gives `-1.0000000000000002` and `-Infinity` for the first two. The file records the table as it was written down.

### MDN's record

`results/mdn-bcd-math-json.results.txt` records the `Math.sumPrecise` entry in MDN's browser-compat-data at [`9237d95b`](https://github.com/mdn/browser-compat-data/blob/9237d95b44e0ed02a094c50a0277e228c81b236f/javascript/builtins/Math.json): Chrome and Edge 147, Firefox 137, Safari 26.2, Deno 2.7.8, and Bun 1.2.18 carry a version, and `nodejs` is `false`. The same entries are recorded at the two other commits listed in that file.

## Sources pinned

| What | Pin |
| --- | --- |
| Node.js 22.23.5 | tag `v22.23.5`, [`60553651579ec33ca1aef9e1eedab2c3855f1f7e`](https://github.com/nodejs/node/commit/60553651579ec33ca1aef9e1eedab2c3855f1f7e) |
| Node.js 24.19.0 | tag `v24.19.0`, [`cdc1b38d40cb567b7ad0b39c86addf830a0af0ae`](https://github.com/nodejs/node/commit/cdc1b38d40cb567b7ad0b39c86addf830a0af0ae) |
| Node.js 26.7.0 | tag `v26.7.0`, [`b4f23d3619c98bed09af93a21192f6080197a8c6`](https://github.com/nodejs/node/commit/b4f23d3619c98bed09af93a21192f6080197a8c6) |
| Node.js 26.13.1 | tag `v26.13.1`, [`e9c277643b0249c50f6e6de5413be8a88ea11b6a`](https://github.com/nodejs/node/commit/e9c277643b0249c50f6e6de5413be8a88ea11b6a); its [`deps/v8/include/v8-version.h`](https://github.com/nodejs/node/blob/e9c277643b0249c50f6e6de5413be8a88ea11b6a/deps/v8/include/v8-version.h) is the footnote's V8 14.6.202.34 |
| Node.js 27.0.0-alpha.0.1.1 | tag `v27.0.0-alpha.0.1.1`, [`6c7c89331d062a47d6fe3d16b3c00e4a3145826d`](https://github.com/nodejs/node/commit/6c7c89331d062a47d6fe3d16b3c00e4a3145826d); its [`deps/v8/include/v8-version.h`](https://github.com/nodejs/node/blob/6c7c89331d062a47d6fe3d16b3c00e4a3145826d/deps/v8/include/v8-version.h); [release page](https://github.com/nodejs/node/releases/tag/v27.0.0-alpha.0.1.1), [Node.js's post for it](https://nodejs.org/en/blog/release/v27.0.0-alpha.0.1.1), [archived](https://archive.is/6X3Ed) |
| MDN browser-compat-data | [`9237d95b44e0ed02a094c50a0277e228c81b236f`](https://github.com/mdn/browser-compat-data/commit/9237d95b44e0ed02a094c50a0277e228c81b236f); and `290cd74dbb04d539bc252f4e8f44a723947f8f31`, `7171dca74fea50d3fd88eca8e75b2636954a45b8` for the other two reads |
| test262 | [`2e58f87d8350ad51224617a041c6e041d52f8444`](https://github.com/tc39/test262/tree/2e58f87d8350ad51224617a041c6e041d52f8444/test/built-ins/Math/sumPrecise), `test/built-ins/Math/sumPrecise`, ten files |

The five Node.js tag lookups were resolved to commits with the GitHub API on 2026-11-19. The Node.js binaries' own checksums weren't recorded.

## Committed outputs

| File | What it is | Captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/node-flag-run-cloud-x86_64.results.txt` | the Node.js rows of a 19-binary run: versions, presence, the flag searches, test262 with the flag, the negative control, and the hand-check | captured, not rerun | 2026-11-17 | Claude Code Cloud, x86_64 VM; Ubuntu 24.04.5 LTS |
| `results/node-26.13.1-and-27-alpha-macos.results.txt` | `typeof Math.sumPrecise` on Node.js 26.13.1 and the 27 alpha, four spot values on the alpha, and the alpha's release record | recorded from a written sentence, not rerun | 2026-11-18 | macOS arm64 |
| `results/five-input-probe.results.txt` | five inputs through four runtimes' `Math.sumPrecise` | recorded from a written table, not rerun | 2026-11-18 | macOS arm64 |
| `results/mdn-bcd-math-json.results.txt` | the `sumPrecise` entry in MDN's browser-compat-data at the pinned commits | recorded values from reads, not refetched | 2026-11-17 and 2026-11-18 | not a run |

The Cloud file is the original transcript's Node.js lines with a header added and paths stripped. The other three are written from records, so their values are the recorded ones and their layout is new.

## What the full folder will hold

- The run script and the script that adds the flag rows, with their header output, and the test262 runner, which fetches test262 at the pinned commit.
- The hand-check script and its oracle, which computes the expected values independently.
- A rerun of the Node.js 22, 24, 26, and 27 alpha checks on macOS arm64 and in Claude Code Cloud, with the alpha's run as a transcript in place of the sentence.
- The `Math.json` entry extracted at the pinned commit.

## Scope

- Five Node.js versions were checked. The post's sentence about every stable release rests on MDN's `false` for Node.js and on the V8 versions the release lines carry; no run covers each release.
- The Cloud run is one x86_64 VM on 2026-11-17, and the macOS results are one Mac on 2026-11-18. Node.js 26.7.0 and 26.13.1 carry the same V8 version, 14.6.202.34, with different Node.js patch suffixes.
- The Node.js 27 alpha and Node.js 26.13.1 results are recorded values with no transcript. The alpha is an alpha, and GitHub does not flag its release as a prerelease, which is why the post says "stable."
- The five-input probe was run once, and its Bun and Deno rows are not a check on Node.js.
- MDN's file is recorded as values at pinned commits. Its text isn't kept here.
