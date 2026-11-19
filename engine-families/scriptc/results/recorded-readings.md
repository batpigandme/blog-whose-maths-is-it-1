# Recorded readings: scriptc's source and its release run

Two readings, not runs. Nothing here was regenerated, and the CI logs in the second reading have expired, so it can't be rechecked against them.

## Source reading, at scriptc 0.4.7

- **Pinned source:** [`vercel-labs/scriptc` at `6c60b0b`](https://github.com/vercel-labs/scriptc/tree/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff), the commit of tag [`v0.4.7`](https://github.com/vercel-labs/scriptc/releases/tag/v0.4.7), which is also npm `scriptc@0.4.7`. Read on 2026-11-02, before the run in this folder.
- **Reading:** the runtime has its own C port of V8's `src/base/ieee754.cc`, as Node.js v24.22.0 bundles it (V8 13.6.233.17), compiled into the runtime as functions named `scr_ieee754_<function>` (for example `scr_ieee754_sin`). `Math.pow` alone goes to the platform's `pow`, through `scr_math_pow`.
- **Where, in the pinned tree:**
  - [`packages/runtime/src/scr_ieee754.c`](https://github.com/vercel-labs/scriptc/blob/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff/packages/runtime/src/scr_ieee754.c#L16-L27), lines 16 to 27, the port's own account of what it is a port of; `scr_ieee754_sin` is at line 2467.
  - [`packages/runtime/vendor/README.md`](https://github.com/vercel-labs/scriptc/blob/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff/packages/runtime/vendor/README.md#L19-L24), lines 19 to 24.
  - [`packages/runtime/src/scr_lib.c`](https://github.com/vercel-labs/scriptc/blob/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff/packages/runtime/src/scr_lib.c#L7188), `scr_math_pow` at line 7188.
- **The npm package:** its copies of those three files are byte-identical to the tag's.
- **What the binary shows:** the compiled typed control defines the `scr_ieee754_*` functions and `scr_math_pow`, and its only import from the C library's `libm` is `pow` (`scriptc-binary-links.results.txt`).
- **Later check, 2026-11-18:** at scriptc's `main`, [`8c03f35`](https://github.com/vercel-labs/scriptc/commit/8c03f356a560cb0dedab5fdecbde715df42b36ff) (whose newest release was v0.4.14, of 2026-11-15), the vendored V8 tree has the same git tree SHA, `89cb896a4f`, and `scr_ieee754.c` differs by one comment line, naming Node.js v24.22.1 where the 0.4.7 file names v24.22.0.

## Release run, read from the CI logs

- **Pinned source:** [run 41153019462](https://github.com/vercel-labs/scriptc/actions/runs/41153019462) of `release.yml`, event `push`, created 2026-10-31 00:58:46 UTC, conclusion success, for commit `6c60b0b`. The GitHub release v0.4.7 targets that commit and was published 2026-10-31 05:03:48 UTC. The run is on its third attempt; the build jobs ran from 00:59 to 03:13, and the third attempt re-ran "Publish to npm" at 04:29.
- **Read on 2026-11-18** with `gh run view 41153019462 -R vercel-labs/scriptc --log`, 18 days after the run; the logs have since expired, which is why this is a recorded reading.
- **No reuse of an earlier run's builds:** the `check-release` job logged "Local version: 0.4.7" and "Release needs publishing or completion", and never logged "Reusing native builds from run …", the line the workflow's script prints when it reuses an earlier run's builds. The jobs that run only when `reuse_artifacts != 'true'` (the profile job and every native build) ran.
- **Built from source in CI:** the log has one "built @scriptc/runtime-<platform>@0.4.7" line per platform, for example "built @scriptc/runtime-darwin-arm64@0.4.7: 7 flavors, 5 vendor archives", from the job "Build native package (darwin-arm64)". Those jobs check out the run's commit. At that commit, `packages/runtime/src/scr_ieee754.c` is blob `798bcbcbcc5a0536150b3640e84b89475fe5cc74` (`gh api 'repos/vercel-labs/scriptc/contents/packages/runtime/src/scr_ieee754.c?ref=6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff' --jq .sha`), and [`runtime-pack-matrix.mjs`](https://github.com/vercel-labs/scriptc/blob/6c60b0bcbfc6edd34ce5c1cdb588d42bdb7171ff/packages/runtime-pack-common/runtime-pack-matrix.mjs) line 58 lists `"scr_ieee754.c"` among the units compiled into the pack.
- **Published from that run's builds:** the "Publish to npm" job's `download-artifact` step logs "Fetching artifact list for workflow run 41153019462" and downloads the `native-*` artifacts, including `native-darwin-arm64` (sha256 `a4a049f9…a431` as logged), and the same job's file listing includes `dist/lib/runtime-sources/src/scr_ieee754.c`.

## Scope

- The release-run reading supports "built from source by its release workflow". The build log doesn't print a compile line for `scr_ieee754.c` by name, so that the port was compiled into the pack rests on its being in the pack's source list at that commit.
- The run's native artifacts have expired, so the published tarballs' bytes weren't compared with the logged digests, and nothing was rebuilt.
- The run in this folder used the compiler binary and runtime pack from the npm package `scriptc@0.4.7`; it didn't build them from the pinned source.
- The source reading is of one version, 0.4.7. The later check is of one commit, and it compares the vendored tree and one file; it isn't a rerun.
