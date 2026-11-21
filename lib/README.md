# Shared helpers

Small scripts that more than one folder uses. They produce no results of their own: the 392,083 test cases they generate, the engines they run, and the results are in the folders that call them. Each one's header says what it needs and which environment variables it reads. Everything runs on macOS or Linux, and nothing is committed that a script can fetch at a pinned commit.

| File | What it does |
| --- | --- |
| `fetch-stdlib-fixtures.sh` | Sparse checkout of stdlib's maths test fixtures at stdlib commit [`550666096f34c73f90f4bf86139935e4214fe421`](https://github.com/stdlib-js/stdlib/commit/550666096f34c73f90f4bf86139935e4214fe421), into `.cache/` |
| `gen-cases.js` | Turns those fixtures into 392,083 test cases (`<fn> <x hex> [<y hex>] <expected hex>`), and with `--check` compares the result with `cases.sha256` |
| `cases.sha256` | SHA-256 of each generated case file; the case files are about 15 MB and are not committed |
| `driver.js` | One ES5 script that evaluates a case string with `Math` (and `erf`, `gamma`, `log1p` when defined) and prints raw bits; runs on MicroQuickJS, d8, and Node.js |
| `run-cases.sh` | Runs the cases through any engine, in chunks, and keeps one result file per function |
| `colhash.js` | Hash of a result column: two runs have the same hash exactly when every case has the same bits |
| `platform.c` | The same cases through the C library's `<math.h>`, as one more column |
| `reference.jl` | The correctly rounded answer for every case, from MPFR through Julia; the committed checksums were matched with [Julia 1.13.3](https://github.com/JuliaLang/julia/releases/tag/v1.13.3) (see `fma-contraction/README.md`) |
| `reference.sha256` | SHA-256 of each file `reference.jl` writes |
| `fetch-d8.sh` | Downloads a published d8 build from V8's build bucket (`https://storage.googleapis.com/chromium-v8/official/canary/v8-<platform>-rel-<version>.zip`), without installing anything; the versions used are linked in `v8-sources/README.md` and `fma-contraction/README.md` |
| `header.sh` | The metadata header every committed output starts with; `PLATFORM_LABEL` names the environment and is printed first on the platform line |
