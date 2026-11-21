# plainly-wrong

> Captured results from earlier runs, not regenerated. This folder has no scripts.

Backs the post's section "Plainly wrong" and its footnotes `[^rhino]` and `[^go-log]`: Rhino's `asinh`, `acosh`, and `atanh`, fixed in 1.9.2, and Go's `log` of `5e-324` through goja and otto. It also holds the spare cases from the same runs.

Measured on Linux VMs in OrbStack (arm64, and an x86_64 container under emulation), with Claude Code Cloud's x86_64 VM results quoted from earlier runs.

What was run: on 3 November 2026, each case below is a one-line JavaScript program (or, for Go, a short Go program) run through the engine named in its column, inside an Ubuntu 24.04 container on a Mac's OrbStack VM, on each of the two platforms (arm64, and an x86_64 container under emulation). The printed answers sit beside the answers that [Node.js 24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0) printed for the same input. What the results show: Rhino's `asinh`, `acosh`, and `atanh` differ from Node.js's at the 2.0.0-snapshot build, and Rhino 1.9.2's agree with Node.js's apart from how `asinh( 5e-324 )` prints; Go's `log` of `5e-324` differs between x86_64 and arm64. Each table cell is a printed value, so the folder reads without running anything.

The post's other plainly wrong story, `Math.sin` on one huge argument, is in [`../sin-demo/`](../sin-demo/), and the `tan` pair is in [`../fma-contraction/`](../fma-contraction/).

## Claim

From the post, on Rhino:

> On the build the JavaScript engines zoo runs, a 2.0.0 snapshot at commit `7386aa0`, `Math.asinh(1e300)` returns `Infinity`: a textbook formula, overflowing. Someone reported it, and the fix shipped in Rhino 1.9.2, whose release notes say "Fix inconsistencies in the "Math" object by backporting algorithms from V8." Rhino 1.9.2 agrees with Node.js 24.19.0 on all eight inputs.

And from `[^rhino]`: the fault was measured on the build the engine set was tested on, and 1.9.2 was run on arm64 only, on 3 November 2026.

From the post, on Go:

> Go's `log` of the smallest positive double, `5e-324`, is wrong on x86_64 and right on arm64, and goja and otto give exactly Go's answers on both.

And from `[^go-log]`: `Math.log(5e-324)` is `-709.0895657128241` on x86_64 (Go's `amd64`) and `-744.4400719213812` on arm64, in goja, otto, and Go itself.

## Tier

c: results only.

## What the committed results show

Every cell below is copied from a line in a committed output, and the table says which. "Reference" is the line the same run printed for [Node.js 24.19.0](https://github.com/nodejs/node/releases/tag/v24.19.0) on the same input. A row is "wrong" when its answer differs from the reference; the reference is Node.js's answer, not a correctly rounded value computed here. The Claude Code Cloud rows use the Node.js line from the OrbStack runs, because no Node.js line from the cloud run is committed. Both OrbStack runs print the same Node.js answers.

### Rhino: `asinh`, `acosh`, and `atanh`

The input, one line, on a terminal:

```javascript
print( [ Math.asinh( 5e-324 ), Math.asinh( 1e-300 ), Math.asinh( 1e-10 ), Math.asinh( 1e300 ), Math.asinh( -0.5 ), Math.acosh( 1e300 ), Math.atanh( 1e-10 ), Math.atanh( 0.5 ) ].join( ' ' ) );
```

| Input | Node.js 24.19.0 | Rhino 7386aa0, Claude Code Cloud (x86_64 VM) and OrbStack (x86_64 container under emulation) | Rhino 7386aa0, OrbStack (arm64) | Rhino 1.9.2, OrbStack (arm64) |
| --- | --- | --- | --- | --- |
| `asinh( 5e-324 )` | `5e-324` | `0` | `0` | `4.9e-324` |
| `asinh( 1e-300 )` | `1e-300` | `0` | `0` | `1e-300` |
| `asinh( 1e-10 )` | `1e-10` | `1.000000082690371e-10` | `1.000000082690371e-10` | `1e-10` |
| `asinh( 1e300 )` | `691.4686750787736` | `Infinity` | `Infinity` | `691.4686750787736` |
| `asinh( -0.5 )` | `-0.48121182505960347` | `-0.48121182505960336` | `-0.48121182505960336` | `-0.48121182505960347` |
| `acosh( 1e300 )` | `691.4686750787736` | `Infinity` | `Infinity` | `691.4686750787736` |
| `atanh( 1e-10 )` | `1e-10` | `1.000000082640371e-10` | `1.000000082640371e-10` | `1e-10` |
| `atanh( 0.5 )` | `0.5493061443340548` | `0.5493061443340549` | `0.5493061443340548` | `0.5493061443340548` |

- **Sources.** The 7386aa0 columns: the cloud line is in `cloud-and-orbstack-comparison.results.txt` ("cloud:" under "Rhino 7386aa0"), the emulated x86_64 line in `orbstack-x86_64-emulated-probes.results.txt`, and the arm64 line in `orbstack-arm64-probes.results.txt`. The 1.9.2 column and the Node.js column on arm64: `orbstack-arm64-rhino-1.9.2.results.txt`.
- **JDK.** On both OrbStack hosts the same answers came back on OpenJDK 25.0.2 and 21.0.10.
- **What changed in 1.9.2.** At `7386aa0`, all eight answers differ from Node.js's on x86_64 and seven of eight on arm64. In 1.9.2 the overflows to `Infinity` and the `0` results are gone. The one row where the two 7386aa0 columns differ, `atanh( 0.5 )`, is a last-digit difference between the hosts.
- **The 7,820-case control.** In `orbstack-arm64-rhino-1.9.2.results.txt`, against the Node.js output of the earlier Claude Code Cloud run on the same cases, the 7386aa0 jar has 599 value differences, including `asinh`, `acosh`, and `atanh` at distances above 10^17 ULP, and 1.9.2 has 120, none in those three functions.
- **As printed, 1.9.2 matches Node.js on seven of the eight inputs.** On `asinh( 5e-324 )` it prints `4.9e-324` where Node.js prints `5e-324`. The control compares bits, and lists no `asinh` differences for 1.9.2.

### Go's `log` of `5e-324`

The input:

```javascript
console.log( [ Math.log( 5e-324 ), Math.log10( 5e-324 ), Math.log( 1e-310 ), Math.log2( 5e-324 ), Math.log( 2.2250738585072014e-308 ) ].join( ' ' ) );
```

The table shows the first value, `Math.log( 5e-324 )` (`math.Log( 5e-324 )` in Go itself). The files hold all five.

| Engine and version | Claude Code Cloud (x86_64 VM) | OrbStack (x86_64 container under emulation) | OrbStack (arm64) |
| --- | --- | --- | --- |
| goja `622d100`, built with go1.26.10 | `-709.0895657128241` | `-709.0895657128241` | `-744.4400719213812` |
| otto v0.5.1, built with go1.24.7 | `-709.0895657128241` | `-709.0895657128241` | `-744.4400719213812` |
| Go go1.24.7 and go1.26.10, `amd64` and `arm64` builds | `-709.0895657128241` (`amd64`; the Go version isn't named) | `-709.0895657128241` (`amd64`) | `-744.4400719213812` (`arm64`) |
| Go go1.24.7 and go1.26.10, `386` build | `-744.4400719213812` | `-744.4400719213812` | not built |
| Node.js 24.19.0 (reference) | not committed | `-744.4400719213812` | `-744.4400719213812` |

- **Sources.** The goja and otto lines are under "goja" and "otto" in `cloud-and-orbstack-comparison.results.txt` for the cloud, and in the two probes files for OrbStack. Go's own lines are under "Go itself" in the comparison file (cloud) and the `go-go1.24.7-*` and `go-go1.26.10-*` lines of the probes files.
- **Where the difference lives.** The arm64 probes file prints the build tags in Go's `src/math` for both versions: `log_asm.go: //go:build amd64 || s390x; log_stub.go: //go:build !amd64 && !s390x`, with the same `log_amd64.s` checksum (`5764160fdc45d72c`) in both.
- **The other four values.** `log10( 5e-324 )` and `log( 1e-310 )` also differ between x86_64 and arm64, in the same files. `log2( 5e-324 )` and `log( 2.2250738585072014e-308 )` print the same on both.

### The spares

Other cases from the same runs, each with its build and whether a newer release was run. Same reading rule as above.

| Engine | Build | Input | Answer | Reference (Node.js 24.19.0) | Newer release run? |
| --- | --- | --- | --- | --- | --- |
| Nova | `d85a2f8` (`latest-93-gd85a2f8d`), javascript-zoo 20260303 | `Math.atan2` on six inputs (the probe line is in the files) | `0 0 0 0 1.4711276743037347 0` | `-1.546676282474831 -0.7853981633974483 -1.1071487177940904 -1.5208379310729538 1.4711276743037347 -0.4636476090008061` | No. A commit build; no newer build run |
| Kiesel | `20deb11f1` (x86_64) and `7a082e2af` (arm64), javascript-zoo 20260303 | `Math.log1p( 1e-300 )`, `Math.expm1( 1e-300 )`, `Math.log1p( 1e-20 )`, `Math.expm1( 1e-20 )`, `Math.log1p( 5e-324 )`, `Math.expm1( 1e-10 )` | `0 0 0 0 0 1.000000082740371e-10` | `1e-300 1e-300 1e-20 1e-20 5e-324 1.00000000005e-10` | No. Commit builds |
| Kiesel | the same two builds | `toString( 16 )` on 2147483647, 2147483648, 2576980378, 4294967295, 4294967296, 255.5, -1, -255, -2147483647, -2147483648, -2147483649, 1073741824; then `(255).toString( 2 )`, the length of `(2576980378).toString( 2 )`, and `(2576980378).toString( 36 )` | `7fffffff 2147483648 2576980378 4294967295 4294967296 255.5 -1 -ff -7fffffff -2147483648 -2147483649 40000000 11111111 10 2576980378` | `7fffffff 80000000 9999999a ffffffff 100000000 ff.8 -1 -ff -7fffffff -80000000 -80000001 40000000 11111111 32 16m9msa` | No. Commit builds |
| Quanta | `767a49f`, javascript-zoo 20260303 | `new Float64Array( [ NaN ] )[ 0 ]` | `0` | `NaN` | No. A commit build |
| Quanta | the same | `String( 0.1 + 0.2 )` | `0.3` | `0.30000000000000004` | No |
| Porffor | `0.0.0-alpha.19` (`0c135ce`), from npm | `var UINT32_MAX = 4294967295;` then `console.log( UINT32_MAX );`, compiled with `porf native` | a compile error, `<stdin>:2993:14: error: expected identifier or '(' before numeric constant`; the same program with the variable renamed `UINT32_MAXX` compiles and prints `4294967295` | n/a (the renamed program's output is the reference) | Not checked |
| Hermes | 0.13.0, `hermes-cli-linux.tar.gz` | `hermes --version` | `Hermes release version: 0.12.0` | n/a | Not checked |

- **Quanta.** On OrbStack arm64 the binary stops at startup on any program (`Illegal instruction`, exit 132). `orbstack-arm64-quanta-qemu.results.txt` shows the instruction, `index z0.d, #8, x12`, and a CPU `Features` line with no `sve`. Through `qemu-aarch64` 8.2.2, and on the x86_64 runs, both probes print the same lines as the Claude Code Cloud run: the NaN probe's first line is `store NaN: read 0, words 0 0`, and the printing probe's first value is `0.3`.
- **Porffor.** Under x86_64 emulation the binary segfaults (exit 139), on `--help` too, so the two-line program has no x86_64 result here. The arm64 result is the one in the table. C generated on arm64 and compiled by the x86_64 container's compiler fails with the same errors at the same lines, and the stdlib bundle's first errors match the cloud's text and line numbers (`<stdin>:36867:7`).
- **Hermes.** The version line is the same on the emulated x86_64 container and on Claude Code Cloud. The release has an x86_64 Linux build only.

## Committed outputs

| File | What it is | Regenerated or captured | Date | Platform |
| --- | --- | --- | --- | --- |
| `results/orbstack-arm64-probes.results.txt` | Every probe on arm64, each run twice, with the Go build tags | captured, not rerun | 2026-11-03 | OrbStack, aarch64 Linux VM on macOS |
| `results/orbstack-x86_64-emulated-probes.results.txt` | The same probes on x86_64, including the Hermes version line and Porffor's segfaults | captured, not rerun | 2026-11-03 | OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation |
| `results/orbstack-arm64-rhino-1.9.2.results.txt` | Rhino 1.9.2 beside 7386aa0, with the jar's checksums | captured, not rerun | 2026-11-03 | OrbStack, aarch64 Linux VM on macOS |
| `results/orbstack-arm64-quanta-qemu.results.txt` | Why Quanta stops on arm64, and its two probes through `qemu-aarch64` | captured, not rerun | 2026-11-03 | OrbStack, aarch64 Linux VM on macOS |
| `results/cloud-and-orbstack-comparison.results.txt` | Each probe's Claude Code Cloud line beside the two OrbStack runs | captured, not rerun | 2026-11-03 (cloud lines from 2026-10-21 and 2026-11-02) | Claude Code Cloud, x86_64 VM; OrbStack as above |
| `results/orbstack-setup-arm64.results.txt` | How each arm64 binary was fetched, with its sha256 | captured, not rerun | 2026-11-03 | OrbStack, aarch64 Linux VM on macOS |
| `results/orbstack-setup-x86_64-emulated.results.txt` | The same for x86_64, plus Hermes | captured, not rerun | 2026-11-03 | OrbStack, aarch64 Linux VM on macOS, x86_64 container under emulation |
| `results/orbstack-host.results.txt` | The Mac, OrbStack, and the pinned toolchain versions | captured, not rerun | 2026-11-03 | macOS 26.6.2, arm64 (Apple M1 Pro) |

The OrbStack outputs are the second run of two (the first is not committed). Each file carries the standard header with a `# captured:` line, and its data lines are the original's, minus the sections named in its header and with paths, script names, and finding labels replaced. The raw per-probe outputs of the runs are not committed: the transcripts above quote the same lines.

## Sources pinned

| What | Pin |
| --- | --- |
| Rhino, the build that fails | [`7386aa037d9a8020e4e69cc0af11eb73fe59d09d`](https://github.com/mozilla/rhino/commit/7386aa037d9a8020e4e69cc0af11eb73fe59d09d), a 2.0.0 snapshot (jar manifest `2.0.0-SNAPSHOT`), the javascript-zoo jar with sha256 `9b216713807c5089159d1e3fad1fed0639168e81ee923ced4993b25eee2806f9` |
| Rhino 1.9.2 | [release `Rhino1_9_2_Release`](https://github.com/mozilla/rhino/releases/tag/Rhino1_9_2_Release), [`b3d405fe2ef4948929629b23d85ba7eef76a2c2a`](https://github.com/mozilla/rhino/commit/b3d405fe2ef4948929629b23d85ba7eef76a2c2a); [`rhino-all-1.9.2.jar`](https://repo1.maven.org/maven2/org/mozilla/rhino-all/1.9.2/rhino-all-1.9.2.jar) from Maven Central, sha256 `9b4fc23fdd7902beabd542099b6f590f05638dbbb054e9784f444982a6296493`, 1,952,141 bytes, with its published sha1 and md5 matched. The `.asc` signature was not checked |
| Rhino reports and fix | [issue 2520](https://github.com/mozilla/rhino/issues/2520) (`asinh`), [issue 2521](https://github.com/mozilla/rhino/issues/2521) (`acosh`), and [PR 2522](https://github.com/mozilla/rhino/pull/2522), merged on `master` as [`46515205678bc89daecd78f023224815aa85be7f`](https://github.com/mozilla/rhino/commit/46515205678bc89daecd78f023224815aa85be7f) |
| goja | [`622d10077b6c154d9dc0897878aa1b4a674d7c9b`](https://github.com/dop251/goja/commit/622d10077b6c154d9dc0897878aa1b4a674d7c9b), module version `v0.0.0-20261102140139-622d10077b6c`, which requires Go 1.26 |
| otto | [v0.5.1](https://github.com/robertkrimen/otto/releases/tag/v0.5.1), [`43d0d581930e54a0daee9e3770b68e947a7f33fc`](https://github.com/robertkrimen/otto/commit/43d0d581930e54a0daee9e3770b68e947a7f33fc); [module page](https://pkg.go.dev/github.com/robertkrimen/otto@v0.5.1) |
| Go | tags [go1.24.7](https://github.com/golang/go/tree/go1.24.7) and [go1.26.10](https://github.com/golang/go/tree/go1.26.10); [golang/go issue 56600](https://github.com/golang/go/issues/56600) and [CL 448216](https://go.dev/cl/448216), which the post says hadn't landed as of 18 November 2026 |
| Nova | [`d85a2f8d243441f4917f80b38e683d501aa62e72`](https://github.com/trynova/nova/commit/d85a2f8d243441f4917f80b38e683d501aa62e72); binary sha256 `38d2d8e191af6ce7633bc2c667baea7111392c3d4159d05a38193b770d6dd1e1` (arm64), `b9520c1a48820cf9881128ac642e8fb0c538980d8e23bc01b2400fcc1d99ac11` (x86_64) |
| Kiesel | `20deb11f17569844c869b267d300d77cbc3414a1` (x86_64, from the [`kiesel.amd64.tar.zst`](https://github.com/ivankra/javascript-zoo/releases/download/20260303/kiesel.amd64.tar.zst) release asset, sha256 `14f6b4bc8e685dffc86652bfaa50557fdf3adef3b74af94bddf998db5674485f`; Codeberg has no commit page for this revision) and [`7a082e2af389ca9b8f4f08d563a016ede9c8d18a`](https://codeberg.org/kiesel-js/kiesel/commit/7a082e2af389ca9b8f4f08d563a016ede9c8d18a) (arm64, sha256 `983e33623cd216022fc6658ed97b55a37501c4e7c850b40fdc42de7da6923ada`) |
| Quanta | [`767a49f40a7a974e081bd87840793cd188a135bf`](https://github.com/solarbrowser/quanta/commit/767a49f40a7a974e081bd87840793cd188a135bf); binary sha256 `ca29acd291703bae0fc6b11c978576544a016297b60b63479245e2d2b21f4753` (arm64), `ce1227d831e336317fcd3809721b56dc5646da93d29a352e98b2a16728968368` (x86_64) |
| Porffor | npm [`porffor@0.0.0-alpha.19`](https://www.npmjs.com/package/porffor/v/0.0.0-alpha.19), integrity `sha512-GLEMY3MhzUhboJ+UMNJAINaw6qGo6L33vEvBtdn5Q2OcbvC+lNcPm4dvOjQMlPVSQsy2cRpZ64AuBMCxLNaqFQ==`; [release `alpha-19`](https://github.com/CanadaHonk/porffor/releases/tag/alpha-19), [`0c135ce2f36fdd3467d5a58daa92283810705a51`](https://github.com/CanadaHonk/porffor/commit/0c135ce2f36fdd3467d5a58daa92283810705a51) |
| Hermes | [v0.13.0](https://github.com/meta/hermes/releases/tag/v0.13.0), [`4b3bf912cc0f705b51b71ce1a5b8bd79b93a451b`](https://github.com/meta/hermes/commit/4b3bf912cc0f705b51b71ce1a5b8bd79b93a451b); `hermes-cli-linux.tar.gz` sha256 `aead6eb0b8f563bb022354352eae32dad96c933330b6c1941b6db17674ca68ae` |
| javascript-zoo | release [20260303](https://github.com/ivankra/javascript-zoo/releases/tag/20260303), [`056b628e1ab0ba8d7fcd112023b0c7c2407461fa`](https://github.com/ivankra/javascript-zoo/commit/056b628e1ab0ba8d7fcd112023b0c7c2407461fa), the source of the Rhino, Nova, Kiesel, and Quanta binaries |
| Node.js 24.19.0 | [release `v24.19.0`](https://github.com/nodejs/node/releases/tag/v24.19.0), V8 [13.6.233.17](https://github.com/v8/v8/tree/13.6.233.17) (printed as `13.6.233.17-node.51`); the conda-forge builds that ran: [linux-64 `h50021de_1`](https://conda.anaconda.org/conda-forge/linux-64/nodejs-24.19.0-h50021de_1.conda) and [linux-aarch64 `hf4ab16c_1`](https://conda.anaconda.org/conda-forge/linux-aarch64/nodejs-24.19.0-hf4ab16c_1.conda) |
| OpenJDK 25.0.2 and 21.0.10 | the conda-forge builds that ran: 25.0.2 [linux-64 `h1602c4f_26`](https://conda.anaconda.org/conda-forge/linux-64/openjdk-25.0.2-h1602c4f_26.conda) and [linux-aarch64 `hd4191a3_26`](https://conda.anaconda.org/conda-forge/linux-aarch64/openjdk-25.0.2-hd4191a3_26.conda); 21.0.10 [linux-64 `h1602c4f_22`](https://conda.anaconda.org/conda-forge/linux-64/openjdk-21.0.10-h1602c4f_22.conda) and [linux-aarch64 `hd4191a3_22`](https://conda.anaconda.org/conda-forge/linux-aarch64/openjdk-21.0.10-hd4191a3_22.conda) |
| GCC 13.3.0 and Go 1.24.7 (the environment's) | the conda-forge builds that ran: GCC [linux-64 `h9576a4e_2`](https://conda.anaconda.org/conda-forge/linux-64/gcc-13.3.0-h9576a4e_2.conda) and [linux-aarch64 `h8a56e6e_2`](https://conda.anaconda.org/conda-forge/linux-aarch64/gcc-13.3.0-h8a56e6e_2.conda); Go [linux-64 `h282a287_0`](https://conda.anaconda.org/conda-forge/linux-64/go-1.24.7-h282a287_0.conda) and [linux-aarch64 `h569907c_0`](https://conda.anaconda.org/conda-forge/linux-aarch64/go-1.24.7-h569907c_0.conda). The go1.26.10 toolchain was fetched by the Go command (`GOTOOLCHAIN=auto`) when it built goja |
| pixi 0.83.0 | [release `v0.83.0`](https://github.com/prefix-dev/pixi/releases/tag/v0.83.0); it solved the conda-forge lock on the Mac and installed it in the containers |
| qemu-aarch64 8.2.2 | upstream tag [v8.2.2](https://github.com/qemu/qemu/tree/v8.2.2); the Ubuntu package that ran was [1:8.2.2+ds-0ubuntu1.18](https://launchpad.net/ubuntu/+source/qemu/1:8.2.2+ds-0ubuntu1.18) |
| glibc 2.39 | the Ubuntu package that ran, [2.39-0ubuntu8.9](https://launchpad.net/ubuntu/+source/glibc/2.39-0ubuntu8.9) |
| curl 8.23.0 and zstd 1.5.7 | tags [curl-8_23_0](https://github.com/curl/curl/releases/tag/curl-8_23_0) and [v1.5.7](https://github.com/meta/zstd/releases/tag/v1.5.7); the tools that fetched and unpacked the javascript-zoo archives |
| Docker 29.8.2 | client tag [v29.8.2](https://github.com/docker/cli/tree/v29.8.2) and engine tag [docker-v29.8.2](https://github.com/moby/moby/tree/docker-v29.8.2); `orbstack-host.results.txt` prints this version for both client and server |
| Container image | `ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852`, the multi-architecture digest the runs recorded; its [linux/arm64/v8 image](https://hub.docker.com/layers/library/ubuntu/24.04/images/sha256-19cad59657037cffa0ac9a48107019b768900ff1071140965827513ac866bd5e) (`sha256:19cad59657037cffa0ac9a48107019b768900ff1071140965827513ac866bd5e`) and [linux/amd64 image](https://hub.docker.com/layers/library/ubuntu/24.04/images/sha256-78d4744ead1f5b19b04d0df558ab182a5300903900755e515b2ca4d10eb2044d) (`sha256:78d4744ead1f5b19b04d0df558ab182a5300903900755e515b2ca4d10eb2044d`) |
| OrbStack 2.2.5, macOS 26.6.2 | named in plain text: there is no pinned source to link for either build (`orbstack-host.results.txt` records OrbStack's own commit, `bf842321f95fc3ca7cda3227bf0cd41cb188c471`) |

## Scope

- Rhino 1.9.2 ran on arm64 only, on 3 November 2026. No 1.9.2 run on x86_64 exists.
- The x86_64 container under emulation isn't an independent x86_64 machine: it runs on an aarch64 VM, and its CPU line reads `VirtualApple @ 2.50GHz`. The Claude Code Cloud lines are quoted from earlier runs, their raw outputs aren't committed, and the quoted lines don't name that run's Java or Go versions.
- Node.js 24.19.0 here is conda-forge's build. The Claude Code Cloud run's Node.js build is not in a committed output.
- Quanta's arm64 results come from software emulation (`qemu-aarch64`), for the two probes shown. The 7,820-case control wasn't run through it.
- Porffor's x86_64 binary doesn't run under the emulation, and Hermes 0.13.0 has no arm64 Linux build.
- Whether Go's fix has landed is the post's statement of 18 November 2026. No output here records it.
- No macOS or Windows runs of these engines are in this folder.
