# Advent of Code 2015 in ABAP

Solutions for all 25 days of [Advent of Code 2015](https://adventofcode.com/2015), with ABAP Unit tests, puzzle inputs, and runners for SAP and local Node.js execution.

## SAP

Import the repository into your chosen package using abapGit. The starting folder is `src/`; the `std/` dictionary definitions are local transpilation stubs and are excluded from the SAP import.

Run an individual `ZCL_A2015_DD` class through `IF_OO_ADT_CLASSRUN`, or run `ZCL_A2015_RUN_ALL` to execute every day and print a timing summary. Puzzle inputs are W3MI objects named `Z2015_DD.TXT`.

The local lint configuration targets ABAP 7.55 syntax. Actual SAP execution results are listed below.

## Local Node.js execution

Tested with Node.js 24. Install Git and Node.js, then:

```sh
git clone https://github.com/bizhuka/adventofcode-2015-abap.git
cd adventofcode-2015-abap
npm ci
npm run verify
npm start
```

On Windows, use `npm.cmd` if PowerShell blocks `npm.ps1`.

`npm run verify` runs ABAP linting, transpilation, ABAP Unit tests, and JavaScript tests for the local hashing implementation. Generated files are written to `output/` and are not committed.

The menu offers `0` for `ZCL_A2015_RUN_ALL`, `1`–`25` for individual days, and `-` to stop. You can also select a class directly:

```sh
npm start -- 6
npm start -- ZCL_A2015_25
npm start -- 0
```

All puzzle calculations use ABAP except Day 4's explicitly scoped local MD5 mining helper. Its `sy-saprl = 'OPEN'` branch uses `runtime/day04.mjs`; SAP uses `CL_ABAP_MESSAGE_DIGEST`. No other solution uses this runtime check.

The build reapplies a focused `open-abap-core` patch to `calculate_hash_for_char`, hashing UTF-8 directly while retaining full digest outputs. The dependency is pinned to the tested commit and installed from its HTTPS archive; `.npmrc` permits this direct archive dependency on npm 12. W3MI support comes from `open-abap-core`.

## Repository layout

| Path | Contents |
| --- | --- |
| `src/` | ABAP solutions, base class, SAP runner, ABAP Unit tests, abapGit metadata, and W3MI puzzle inputs |
| `std/` | SAP dictionary definitions needed by local transpilation |
| `runtime/` | Day 4's local MD5 helper and JavaScript hash tests |
| `scripts/` | Build, dependency patch, test discovery, and local menu runner |
| `abaplint.json` | ABAP lint configuration |
| `abap_transpile.json` | Local transpilation configuration |

## Execution timings

These are the SAP and Node.js run-all results supplied by the author. Each duration includes class creation, input loading, initialization, and both puzzle parts. Each table is sorted from slowest to fastest; an empty error column means no error was reported.

These are individual runs on different environments, not controlled cross-platform benchmarks. Day 4 uses the local MD5 helper in the Node.js run.

### SAP results

| Class | Elapsed seconds | Status | Error |
| --- | ---: | --- | --- |
| `ZCL_A2015_20` | 42.187671 | OK | |
| `ZCL_A2015_04` | 13.795157 | OK | |
| `ZCL_A2015_10` | 9.857314 | OK | |
| `ZCL_A2015_11` | 7.520101 | OK | |
| `ZCL_A2015_18` | 3.672307 | OK | |
| `ZCL_A2015_06` | 0.842712 | OK | |
| `ZCL_A2015_09` | 0.670848 | OK | |
| `ZCL_A2015_13` | 0.61339 | OK | |
| `ZCL_A2015_15` | 0.562958 | OK | |
| `ZCL_A2015_19` | 0.403791 | OK | |
| `ZCL_A2015_17` | 0.375173 | OK | |
| `ZCL_A2015_01` | 0.19444 | OK | |
| `ZCL_A2015_12` | 0.18091 | OK | |
| `ZCL_A2015_22` | 0.154236 | OK | |
| `ZCL_A2015_03` | 0.144493 | OK | |
| `ZCL_A2015_14` | 0.143671 | OK | |
| `ZCL_A2015_21` | 0.142065 | OK | |
| `ZCL_A2015_05` | 0.134987 | OK | |
| `ZCL_A2015_07` | 0.110243 | OK | |
| `ZCL_A2015_23` | 0.104904 | OK | |
| `ZCL_A2015_24` | 0.104066 | OK | |
| `ZCL_A2015_16` | 0.10259 | OK | |
| `ZCL_A2015_08` | 0.096355 | OK | |
| `ZCL_A2015_25` | 0.091371 | OK | |
| `ZCL_A2015_02` | 0.087512 | OK | |

### Node.js results

| Class | Elapsed seconds | Status | Error |
| --- | ---: | --- | --- |
| `ZCL_A2015_20` | 61.0849242 | OK | |
| `ZCL_A2015_10` | 5.660317100000001 | OK | |
| `ZCL_A2015_11` | 5.4973877999999985 | OK | |
| `ZCL_A2015_18` | 5.349580300000001 | OK | |
| `ZCL_A2015_06` | 2.0329126 | OK | |
| `ZCL_A2015_22` | 1.4727741000000096 | OK | |
| `ZCL_A2015_15` | 1.1757903000000005 | OK | |
| `ZCL_A2015_09` | 0.6263687 | OK | |
| `ZCL_A2015_04` | 0.6082747999999997 | OK | |
| `ZCL_A2015_13` | 0.5441054999999978 | OK | |
| `ZCL_A2015_19` | 0.5191906999999992 | OK | |
| `ZCL_A2015_17` | 0.20615850000000135 | OK | |
| `ZCL_A2015_03` | 0.17444669999999995 | OK | |
| `ZCL_A2015_14` | 0.08720470000000205 | OK | |
| `ZCL_A2015_12` | 0.07707319999999891 | OK | |
| `ZCL_A2015_07` | 0.06413879999999972 | OK | |
| `ZCL_A2015_24` | 0.048562099999995556 | OK | |
| `ZCL_A2015_02` | 0.02497440000000006 | OK | |
| `ZCL_A2015_01` | 0.021572000000000115 | OK | |
| `ZCL_A2015_05` | 0.016255299999999806 | OK | |
| `ZCL_A2015_16` | 0.014543399999998655 | OK | |
| `ZCL_A2015_21` | 0.013325400000001536 | OK | |
| `ZCL_A2015_23` | 0.013204299999997601 | OK | |
| `ZCL_A2015_08` | 0.009766900000000533 | OK | |
| `ZCL_A2015_25` | 0.006099400000006426 | OK | |
