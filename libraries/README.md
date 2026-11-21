# libraries

> Captured results from earlier reads of GitHub's and npm's APIs, not regenerated. This folder has no scripts.

Backs the post's paragraph on the libraries of the lull and its footnotes `[^libs]` and `[^bigint-libs]`.

The outputs are API reads, taken on 2026-11-19 (npm downloads, stars, and last commits); they don't depend on an operating system.

## Claim

From the post: while `Math` gained no functions, libraries filled the gap. For statistics there was jStat and math.js; for numbers a double can't hold, decimal.js and several others, all picked as widely downloaded on npm. Some were built to be replaced: JSBI, from Google Chrome Labs, was a BigInt "polyfill" that "behaves exactly like the upcoming native BigInts," and BigInteger.js became "a thin wrapper over the native implementation" wherever an engine had one.

This folder holds the numbers behind "widely downloaded" and "where they are now":

- Each library's npm downloads for 2017, 2020, and 2023, with its stars, archived flag, last commit, and latest npm version.
- The two README passages the post quotes, JSBI's and BigInteger.js's.

## Tier

c: results only.

## What the committed results show

### Eleven libraries: downloads, stars, and last commits

From `library-downloads.results.txt`. Downloads are npm's calendar-year totals, 1 January to 31 December, read 19 November 2026. Stars, archive status, and last commit are for the default branch's HEAD on 19 November 2026.

| npm package | 2017 | 2020 | 2023 | Stars | Archived | Last commit |
| --- | --- | --- | --- | --- | --- | --- |
| jstat | 29,446 | 1,684,098 | 9,291,393 | 1,807 | no | 2022-12-28 |
| mathjs | 3,738,593 | 12,039,356 | 30,806,333 | 15,107 | no | 2026-11-17 |
| decimal.js | 4,286,292 | 118,104,020 | 802,294,389 | 7,273 | no | 2026-08-30 |
| simple-statistics | 371,570 | 2,854,098 | 5,870,371 | 3,530 | no | 2026-11-15 |
| ndarray | 2,274,088 | 10,616,826 | 20,816,295 | 1,247 | no | 2026-08-26 |
| numeric | 426,640 | 3,802,633 | 4,213,743 | 1,444 | no | 2012-12-20 |
| bn.js | 64,903,332 | 747,625,460 | 1,950,042,459 | 1,232 | no | 2026-07-09 |
| bignumber.js | 16,164,870 | 192,133,725 | 463,040,661 | 7,013 | no | 2026-08-31 |
| big.js | 65,765,963 | 626,484,992 | 1,026,382,435 | 5,202 | no | 2025-04-22 |
| jsbi | 0 | 7,405,040 | 58,446,476 | 963 | no | 2025-03-31 |
| big-integer (BigInteger.js) | 8,666,713 | 74,748,757 | 498,179,727 | 1,125 | no | 2024-02-02 |

The package names are npm's: the post's "Numeric Javascript" is `numeric`, and "BigInteger.js" is `big-integer`. The raw outputs behind each row are in `results/raw/`, one file per package, and the table in `library-downloads.results.txt` was checked against them. Each README's own description sentence, and the two quoted passages, are in the same file.

## Sources pinned

| What | Pinned to |
| --- | --- |
| jStat | [`jstat/jstat` @ `72f367f6dbd45c2d903053ee3f9981489912cad4`](https://github.com/jstat/jstat/tree/72f367f6dbd45c2d903053ee3f9981489912cad4) |
| math.js | [`josdejong/mathjs` @ `1847c3344a0a63ad4bd5b2f2b97e7f4f05f32566`](https://github.com/josdejong/mathjs/tree/1847c3344a0a63ad4bd5b2f2b97e7f4f05f32566) |
| bn.js | [`indutny/bn.js` @ `eb2e57c4e50a9b9a1f277a59ef446c13f564dddc`](https://github.com/indutny/bn.js/tree/eb2e57c4e50a9b9a1f277a59ef446c13f564dddc) |
| BigInteger.js | [`peterolson/BigInteger.js` @ `441f6bd73cef6a5029dd5600f17e3dd79eafeddb`](https://github.com/peterolson/BigInteger.js/tree/441f6bd73cef6a5029dd5600f17e3dd79eafeddb) |
| bignumber.js | [`MikeMcl/bignumber.js` @ `02109ca2749538d57551cdcc7e38585db111b4bb`](https://github.com/MikeMcl/bignumber.js/tree/02109ca2749538d57551cdcc7e38585db111b4bb) |
| big.js | [`MikeMcl/big.js` @ `cdbc06f1d5ae9be429b97f433ee884cf9ad28072`](https://github.com/MikeMcl/big.js/tree/cdbc06f1d5ae9be429b97f433ee884cf9ad28072) |
| decimal.js | [`MikeMcl/decimal.js` @ `b1d1e311eb272b16f5b2ca0e0d1f4c4fa8558edf`](https://github.com/MikeMcl/decimal.js/tree/b1d1e311eb272b16f5b2ca0e0d1f4c4fa8558edf) |
| JSBI | [`GoogleChromeLabs/jsbi` @ `5382367c7e3199858d36bb620977e1f90605bcb9`](https://github.com/GoogleChromeLabs/jsbi/tree/5382367c7e3199858d36bb620977e1f90605bcb9) |
| Numeric Javascript | [`sloisel/numeric` @ `656fa1254be540f428710738ca9c1539625777f1`](https://github.com/sloisel/numeric/tree/656fa1254be540f428710738ca9c1539625777f1) |
| ndarray | [`scijs/ndarray` @ `b735a1472293b0290817225506569866a07bfbf6`](https://github.com/scijs/ndarray/tree/b735a1472293b0290817225506569866a07bfbf6) |
| Simple Statistics | [`simple-statistics/simple-statistics` @ `551ad9eebea7daa85f145f2cf8fe5e70b847aeb4`](https://github.com/simple-statistics/simple-statistics/tree/551ad9eebea7daa85f145f2cf8fe5e70b847aeb4) |

Each of the eleven commits was the default branch's HEAD when read on 2026-11-19.

## Committed outputs

| File | What it is | Regenerated or captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/library-downloads.results.txt` | the table of eleven libraries' downloads, stars, archive status, last commits, and latest versions; each README's description; the JSBI and BigInteger.js passages | captured, not rerun | 2026-11-19 | GitHub and npm API reads; the machine isn't recorded |
| `results/raw/<package>.raw.txt` (11 files) | each library's raw output: repository description, stars, archived flag, default branch, HEAD SHA and date, and the three downloads responses and latest version from npm | captured, not rerun | 2026-11-19 | GitHub and npm API reads; the machine isn't recorded |

The two kinds of file are the original data with a header added.

## Scope

- The download counts include installs as another package's dependency, and how much of each count is that wasn't checked. bn.js's and big.js's 2023 counts, 1.95 billion and 1.03 billion, are far above the others, and the reason wasn't investigated.
- Star counts moved between an earlier read on 2026-11-17 and the committed one on 2026-11-19: math.js 15,106 and 15,107, bignumber.js 7,014 and 7,013, and Simple Statistics 3,529 and 3,530.
- A last commit isn't upkeep. [`josdejong/mathjs`](https://github.com/josdejong/mathjs/commit/1847c3344a0a63ad4bd5b2f2b97e7f4f05f32566) merged several commits on the day of the read, and stars are a count, not a verdict.
- The README copies the quoted sentences come from aren't kept in this folder.
- The outputs don't record the machine that made the API reads.
