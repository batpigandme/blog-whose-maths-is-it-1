# spec

Backs the post's footnotes `[^split]` (how the specification splits the `Math` functions), `[^terms]` (the two terms), `[^lull]` (the count of `Math` functions per edition), and `[^es1]` (the 1st edition's wording).

Measured on macOS arm64, with [Python 3.15.2](https://www.python.org/downloads/release/python-3152/) and `pdftotext` from [poppler 26.11.0](https://gitlab.freedesktop.org/poppler/poppler/-/tags/poppler-26.11.0), against fixed editions of ECMA-262.

## What was run, and what it shows

Four Python scripts read ECMA-262 itself: the 17th edition (ES2026) as HTML, and the 1st, 2nd, 3rd, 5th, and 5.1 editions as PDFs (the 6th to 16th editions as HTML), each checked against a recorded sha256. `recount-split.py` sorted the 37 function properties of `Math` in the 17th edition by what each clause's own text says: 22 are implementation-approximated, 1 (`random`) is implementation-defined, and 14 are exact (`split.results.txt`). `count-math-functions.py` counted the `Math` function properties in every edition: 18 in the 1st to 5.1 editions, 35 in the 6th to 15th, 36 in the 16th, and 37 in the 17th (`math-function-counts.tsv`). `extract-terms.py` found the string "implementation-approximated" 0 times in the 11th edition and 139 times in the 12th (`terms.results.txt`). `extract-math-wording.py` located the passage that leaves functions open in the 1st edition, with "implementor", and in the 17th, with "implementer" (`math-wording.results.txt`). The sections below give the exact lines.

## Claim

From `[^split]`: counted from each function's own steps, in the 17th edition of ECMA-262 (ES2026), "22 functions return an implementation-approximated value, `random` is implementation-defined, and 14 are exact." `pow` is approximated through `Number::exponentiate`, which `**` also uses. `Math.sumPrecise` is at 21.3.2.34 and `Math.sqrt` is exact.

From the other footnotes: the term "implementation-approximated" first appears in the 12th edition (ES2021) and the 17th edition's 4.2 says "Some mathematical operations, such as Math.exp, are implementation-approximated." (`[^terms]`); `Math` has 18 function properties in the 1st to 5.1 editions, 35 in the 6th to 15th, 36 in the 16th, and 37 in the 17th, and the 1st edition's are at 15.8.2.1 to 15.8.2.18 with `atan2` at 15.8.2.5 and `random` at 15.8.2.14 (`[^lull]`, `[^es1]`); ten functions are left open in the 1st edition for the stated reason, spelled "implementor" there and "implementer" in the 17th (`[^es1]`).

## Tier

a: anywhere. Python 3 with only the standard library. The scripts that read PDFs (`count-math-functions.py`, `extract-math-wording.py`) also need poppler's `pdftotext` on PATH. macOS or Linux.

## Rerun

`pixi.toml` and `pixi.lock` pin the environment that produced the committed outputs: Python [3.15.2](https://www.python.org/downloads/release/python-3152/) and poppler [26.11.0](https://gitlab.freedesktop.org/poppler/poppler/-/tags/poppler-26.11.0) from conda-forge, for osx-arm64, linux-64, and linux-aarch64. From `spec/`, `pixi run python -I recount-split.py` runs a script inside that environment. The commands below use whatever `python3` and `pdftotext` are on the PATH.

```bash
# From the repository root. SPEC_CACHE_DIR is optional and defaults to a
# folder in the system temp directory; downloads are never kept in the repo.
export SPEC_CACHE_DIR="$HOME/.cache/whose-maths-spec"

python3 -I spec/recount-split.py          # the split; about 8 MB, a few seconds
python3 -I spec/extract-terms.py          # the two terms; about 22 MB
python3 -I spec/count-math-functions.py   # count per edition; about 85 MB
python3 -I spec/extract-math-wording.py   # the wording; shares the downloads above
```

The run that produced these outputs, from an empty cache, took about 40 seconds for all four; later runs reuse the cache. Each script checks every download's sha256 and stops with an error on a mismatch. `SPEC_OUT_DIR` redirects the outputs, which are otherwise written next to the scripts.

## The rule for the split

`recount-split.py` reads each clause "`Math.<name>`" in 21.3.2, from the HTML, and uses only the specification's text:

- Implementation-approximated: the clause's own text uses the term, or its steps call an abstract operation whose own text uses it. Only `pow` takes the second route.
- Implementation-defined: the clause's own text uses the term. Only `random` does.
- Exact: neither, in the clause or in any operation it calls.

"Own text" is the clause up to its first nested clause, so a clause that merely links to the Number type doesn't inherit anything from it. As a cross-check, the Note that opens 21.3.2 names the 23 functions whose behavior "is not precisely specified"; the script checks that list equals the approximated and implementation-defined sets together.

## Expected output

In `split.results.txt`:

```text
function properties of Math in 21.3.2: 37
implementation-approximated: 22
implementation-defined: 1
exact: 14
...
recount matches the post: yes
```

`split.tsv` has one row per function: its clause number, a link to its clause anchor, its category, where the deciding text is (`this clause, step 4`, or `Number::exponentiate (called at step 3), sentence` for `pow`), and that text. The 22 include `Math.pow`; the 14 exact functions are `abs`, `ceil`, `clz32`, `floor`, `fround`, `f16round`, `imul`, `max`, `min`, `round`, `sign`, `sqrt`, `sumPrecise`, and `trunc`.

`math-function-counts.tsv` has one row per edition; its `math_functions` column reads 18 for the 1st, 2nd, 3rd, 5th, and 5.1 editions, 35 for the 6th to the 15th, 36 for the 16th (`f16round` added), and 37 for the 17th (`sumPrecise` added). The 6th edition's 17 additions are in the `added` column of its row. `math-functions.tsv` lists every counted function by edition and clause; its 1st-edition rows run 15.8.2.1 `abs` to 15.8.2.18 `tan`, with `atan2` at 15.8.2.5 and `random` at 15.8.2.14.

`terms.results.txt` quotes the 4.2 example sentence and finds the string "implementation-approximated" 0 times in the 11th edition and 139 times in the 12th. `math-wording.results.txt` shows the same-library sentence with "implementor" in the 1st and 2nd editions and "implementer" from the 3rd, ten functions named from the 1st to the 5th edition, 11 in the 5.1 edition (`tan` is added to the list), and 23 in the 17th.

## Committed outputs

All were regenerated for this repository on 2026-11-19 on macOS 26.7.3, arm64, with Python 3.15.2 and poppler's `pdftotext` 26.11.0.

| File | What it is | Regenerated or captured |
| --- | --- | --- |
| `split.tsv` | Table of the 37 `Math` functions in the 17th edition, with category, clause link, and deciding text | regenerated |
| `split.results.txt` | The three counts, the lists, and the cross-checks | regenerated |
| `terms.results.txt` | Text of 4.2, 4.4.1, and 4.4.2, and where the term first appears | regenerated |
| `math-function-counts.tsv` | Count of `Math` function properties per edition, with additions | regenerated |
| `math-functions.tsv` | Every counted function by edition and clause | regenerated |
| `math-wording.results.txt` | The passage that leaves functions open, edition by edition | regenerated |

## Sources pinned

Every source is a fixed edition, so each is pinned by sha256, which the scripts check. The PDFs and HTML are fetched at run time and not committed.

| Edition | Source | sha256 |
| --- | --- | --- |
| 1st (1997) | `https://ecma-international.org/wp-content/uploads/ECMA-262_1st_edition_june_1997.pdf` | `cccbe1a1f1a653ddc864ab396987a4fba288acbdd06b1a4bab49fe61ff9a73fc` |
| 2nd (1998) | `.../ECMA-262_2nd_edition_august_1998.pdf` | `f037ad7b405d32c16e8b40bb970459d3e485419411a427f518b1732ac8a78121` |
| 3rd (1999) | `.../ECMA-262_3rd_edition_december_1999.pdf` | `752717984fd8f6daeccc4414d39998b01aa95683bbb023c64655d52c40d2fc47` |
| 5th (2009) | `.../ECMA-262_5th_edition_december_2009.pdf` | `d19ea217f1a70022fd5ca9bf9292f922d99558470dde6932aa4037a5df9faa7b` |
| 5.1 (2011) | `.../ECMA-262_5.1_edition_june_2011.pdf` | `ba56aac6044735047085f9766ad757519a8605ca43e011a696c0386316f587e4` |
| 6th to 17th | `https://262.ecma-international.org/<n>.0/` | listed per edition in `math-function-counts.tsv` and `count-math-functions.py` |
| 17th (2026) | `https://262.ecma-international.org/17.0/` | `5df49e088c2b5c7a3dfd4a330414b92897fb4535cb62fc5936cad101a6c2304a` |

## Scope

- **The pull request titles** in `[^lull]` (tc39/ecma262 [#1515](https://github.com/tc39/ecma262/pull/1515), [#1951](https://github.com/tc39/ecma262/pull/1951), [#2122](https://github.com/tc39/ecma262/pull/2122), [#2523](https://github.com/tc39/ecma262/pull/2523), [#3345](https://github.com/tc39/ecma262/pull/3345)) and the clause-by-clause diffs between consecutive editions were read by hand; no script here regenerates them.
- **The split is counted on the 17th edition.** The claim that `Math.sqrt` became exact in the 16th edition isn't checked, because the 16th edition's `sqrt` text isn't compared, and neither is the claim that `pow` was redefined on `Number::exponentiate` in the 11th edition (ES2020).
