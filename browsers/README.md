# browsers

> Recorded results from browser consoles, plus captured outputs from a scan of the same functions in two shells. The browser runs are complete as recorded: browser, version, OS and architecture, date, snippet, and output bits. To compare, paste the snippet below into your own browser's console. The scan's scripts are added after publication.

Backs the post's opening, where `Math.tan( 7 )` gives three answers in Chrome, Firefox, and Safari on one Mac, and its footnote `[^browsers]`: "Run on 18 November 2026, once in each browser's console, on one Mac with macOS 26.7.3, all three running as arm64."

The browser runs were measured on macOS arm64. The shell scan the inputs came from was measured on macOS arm64.

## Claim

From the post: same machine, same input, three answers, different in the last digit. The three bit patterns are `3febe2e6e13eea79` (Chrome 158.0.8127.37, V8 15.8.62.31), `3febe2e6e13eea78` (Firefox 160.0.1), and `3febe2e6e13eea7a` (Safari 27.2, 21625.2.8.18.4), three neighboring doubles. The footnote's snippet prints those bits for four inputs, `tan(4)`, `tan(7)`, `sin(18)`, and `cos(29)`, and this folder records all four.

The post attributes the three answers to three libraries: LLVM's for Chrome, fdlibm for Firefox, and macOS's C library for Safari. What this folder holds for that attribution is a match of bits, described below, and Firefox's source at the commit it was built from.

## Tier

c: results only for the browser runs. The shell scan will be tier b: it needs a Mac and jsvu builds of d8 and the SpiderMonkey shell.

## What the committed results show

### The three browsers

One run in each browser's console, on 2026-11-18, of the snippet below. Each cell is the bits the snippet printed, with the decimal the bits stand for (converted from the bits, not printed by the browsers). A reader's browser will give different bits.

```js
f=new Float64Array(1),u=new BigUint64Array(f.buffer),[Math.tan(4),Math.tan(7),Math.sin(18),Math.cos(29)].map(x=>(f[0]=x,u[0].toString(16)))
```

| Browser | Version | OS and architecture | Date | `tan(4)` | `tan(7)` | `sin(18)` | `cos(29)` |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Chrome | 158.0.8127.37 (V8 15.8.62.31) | macOS 26.7.3, arm64 | 2026-11-18 | `3ff2866f9be4de13` (1.1578212823495775) | `3febe2e6e13eea79` (0.8714479827243188) | `bfe8081668131e26` (-0.750987246771676) | `bfe7f01658314e47` (-0.7480575296890003) |
| Firefox | 160.0.1 | macOS 26.7.3, arm64 | 2026-11-18 | `3ff2866f9be4de14` (1.1578212823495777) | `3febe2e6e13eea78` (0.8714479827243187) | `bfe8081668131e27` (-0.7509872467716762) | `bfe7f01658314e48` (-0.7480575296890004) |
| Safari | 27.2 (21625.2.8.18.4) | macOS 26.7.3, arm64 | 2026-11-18 | `3ff2866f9be4de13` (1.1578212823495775) | `3febe2e6e13eea7a` (0.8714479827243189) | `bfe8081668131e27` (-0.7509872467716762) | `bfe7f01658314e48` (-0.7480575296890004) |

The rule for counting answers: for each input, the number of distinct bit patterns across the three browsers, read from `results/browser-runs.results.txt`. `tan(7)` has three. The other three inputs have two each: Chrome and Safari agree on `tan(4)`, and Firefox and Safari agree on `sin(18)` and `cos(29)`.

### The shell scan the four inputs came from

From the three `shell-scan-*.results.txt` files: for each of 6,300 inputs, the raw bits of `Math.sin`, `Math.cos`, and `Math.tan` in three configurations of two shells.

| Configuration | What it stands for |
| --- | --- |
| d8 (V8) 15.8.32, no flags | V8 as Chrome 158 ships it, to the extent that 15.8.32 and 15.8.62.31 agree |
| SpiderMonkey shell 159.0b5 with `--use-fdlibm-for-sin-cos-tan` | the fdlibm path Firefox takes by default outside Windows |
| SpiderMonkey shell 159.0b5, no flags | the shell's own default, which calls the platform's C library |

The rule for counting: a result differs when the d8 bits and the fdlibm-path bits for that function and input are unequal, counted line by line over the two files. The count is 656 of 18,900 results (6,300 inputs times three functions):

| Function | Inputs where d8 and the fdlibm path differ |
| --- | --- |
| `sin` | 201 |
| `cos` | 214 |
| `tan` | 241 |

`shell-scan-scored.results.txt` has one row for each of those 656 results (its 656 rows follow its header), scored in ULPs from the correctly rounded value. In all 656 rows, both results are within 1 ULP of it. The largest distance in the d8 column is 0.500, and the largest in the fdlibm column is 0.716. That is a measurement over these 6,300 inputs.

The four inputs, from their rows in `shell-scan-scored.results.txt`:

| Input | d8 15.8.32 | SpiderMonkey, fdlibm path | SpiderMonkey, default | ULPs from correct, d8 and fdlibm path |
| --- | --- | --- | --- | --- |
| `Math.tan(4)` | `3ff2866f9be4de13` | `3ff2866f9be4de14` | `3ff2866f9be4de13` | 0.441 and 0.559 |
| `Math.tan(7)` | `3febe2e6e13eea79` | `3febe2e6e13eea78` | `3febe2e6e13eea7a` | 0.406 and 0.594 |
| `Math.sin(18)` | `bfe8081668131e26` | `bfe8081668131e27` | `bfe8081668131e27` | 0.452 and 0.548 |
| `Math.cos(29)` | `bfe7f01658314e47` | `bfe7f01658314e48` | `bfe7f01658314e48` | 0.465 and 0.535 |

### Browsers against the shells

Comparing the two tables, cell by cell, over the four inputs:

- Chrome's four answers equal d8 15.8.32's.
- Firefox's four answers equal the SpiderMonkey fdlibm path's.
- Safari's four answers equal the SpiderMonkey shell's default, which is macOS's C library.

Safari's `tan(7)` is not scored in `shell-scan-scored.results.txt`, which scores the d8 and fdlibm columns. By arithmetic from that row, the two scored answers are neighboring doubles on either side of the correct value, at 0.406 and 0.594 ULP, so `3febe2e6e13eea7a`, the next double above d8's, is 1.406 ULP from it. Safari's other three answers each equal a scored column, so each is within 1 ULP.

## Sources pinned

| What | Pin |
| --- | --- |
| Firefox 160.0.1's build | [`58fed86b1b6864ad71b83c910a879d6f1a6b678b`](https://github.com/mozilla-firefox/firefox/commit/58fed86b1b6864ad71b83c910a879d6f1a6b678b), the "Built from" revision in the browser's `about:buildconfig` (Mercurial changeset `b1145b0710192f716be5f59f5b2dfeed650d5294`); committed 2026-11-16 13:04 UTC, and both tags `FIREFOX_160_0_1_BUILD1` and `FIREFOX_160_0_1_RELEASE` point at it |
| Firefox's preference at that commit | [`modules/libpref/init/StaticPrefList.yaml`, lines 10562 to 10567](https://github.com/mozilla-firefox/firefox/blob/58fed86b1b6864ad71b83c910a879d6f1a6b678b/modules/libpref/init/StaticPrefList.yaml#L10562-L10567): `javascript.options.use_fdlibm_for_sin_cos_tan` is `false` on Windows and `true` otherwise |
| Firefox's use of the preference | [`js/src/builtin/Math.cpp`, lines 57 to 63](https://github.com/mozilla-firefox/firefox/blob/58fed86b1b6864ad71b83c910a879d6f1a6b678b/js/src/builtin/Math.cpp#L57-L63): the fdlibm path is taken when the preference is set or the realm has `alwaysUseFdlibm` |
| SpiderMonkey 159.0b5 | [`34ac0671eb25f31f8c56ace36e1c413dd471eb8d`](https://github.com/mozilla-firefox/firefox/commit/34ac0671eb25f31f8c56ace36e1c413dd471eb8d), the commit the tags `FIREFOX_159_0b5_BUILD1` and `FIREFOX_159_0b5_RELEASE` point at; the shell's `sin`, `cos`, and `tan` call `fdlibm_*` when that preference is set, and the shell's own default is `false` |
| Chrome 158.0.8127.37 | revision `b8c2be851f62f6a394ec57955d7f31335d7cb6d4`, as `chrome://version` printed it |
| d8 15.8.32 and the SpiderMonkey shell 159.0b5 | installed with [jsvu](https://github.com/GoogleChromeLabs/jsvu); the binaries' checksums weren't recorded |

The Firefox 160.0.1 source lines and tag lookup were read with the GitHub API on 2026-11-18. The commit hashes, and the 159.0b5 tag lookup, were resolved with it on 2026-11-19.

## Committed outputs

| File | What it is | Captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/browser-runs.results.txt` | the snippet, the three browsers' output arrays, and each browser's version and architecture checks | recorded from consoles, not rerun | 2026-11-18 | macOS 26.7.3, arm64 |
| `results/shell-scan-v8-15.8.32.results.txt` | bits of `sin`, `cos`, and `tan` for 6,300 inputs, d8 15.8.32 | captured, not rerun | 2026-11-18 | macOS (Darwin 25.6.0), arm64, Apple M1 Pro |
| `results/shell-scan-spidermonkey-159.0b5-fdlibm.results.txt` | the same, SpiderMonkey shell 159.0b5 with `--use-fdlibm-for-sin-cos-tan` | captured, not rerun | 2026-11-18 | same |
| `results/shell-scan-spidermonkey-159.0b5-default.results.txt` | the same, SpiderMonkey shell 159.0b5, no flags | captured, not rerun | 2026-11-18 | same |
| `results/shell-scan-scored.results.txt` | the 656 differing results, scored in ULPs from the correctly rounded value | captured, not rerun | 2026-11-18 | same |

The four shell-scan files are the original outputs with a header added. Their data lines are unedited.

## What the shell scan will add

- The scan script, the scoring script, and the snippet file, with the install steps for d8 and the SpiderMonkey shell through jsvu, and each file's header produced by the script.
- A rerun of the shell scan, with its result beside the captured one.

## Scope

- Each browser result is one console run on one Mac on 2026-11-18, recorded as values. A reader's browser will give different bits.
- The browsers were given four inputs. The shell scan covers 6,300 inputs, in two shells, and no browser was run on them.
- Chrome 158 carries V8 15.8.62.31, and the scan's d8 is 15.8.32. Chrome's four answers equal d8's, and nobody compared the two builds' `Math` sources.
- The JavaScriptCore version inside Safari 27.2 wasn't read. Safari's answers equal the SpiderMonkey shell's default on four inputs, which is a match of bits and doesn't trace Safari's code to macOS's C library.
- The Firefox run shows Firefox's answers equal the shell's fdlibm path on four inputs. The preference is read from source at the build's commit, and the page's realm was not inspected.
- The scan records its host as Darwin 25.6.0 and an Apple M1 Pro, and the browser runs record macOS 26.7.3 and no CPU; the original outputs don't say whether it was the same Mac.
- Firefox on Windows takes a different path by its preference, as the post says; no Windows run was made.
- Whether all three answers are allowed rests on the specification's wording for implementation-approximated functions, which [`spec/`](../spec/) holds; no bound is checked in this folder.
