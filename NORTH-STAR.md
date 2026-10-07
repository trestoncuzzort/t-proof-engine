# North star

Set 2026-10-07. Everything else in this repository is a step toward this, and each step names which target it moves.

## Write it once, prove it everywhere it ships

A safety-critical routine is written once, in t. It is proved in the toolchains industry certifies with (SPARK and
Frama-C, which DO-178C and ISO 26262 projects use, and Dafny) and in the research kernels (Verus, Lean 4, Rocq,
F*). Every specification is checked by a refutation twin, so a spec that cannot tell right code from wrong code is
caught. The proof of the method is real autonomy code: navigation, control and scheduling routines, with floating
point, in-place arrays and concurrency, because that is where a wrong answer moves a vehicle.

## Targets, with where each stands

| # | target | measure | state (2026-10-07) |
|---|---|---|---|
| 1 | **Floats, heap and concurrency in the language** | in SPEC.md, the checker, the interpreter, the twins and the Python hand-back; lowered in Dafny, SPARK and Frama-C first, refused by name elsewhere until built | landed 2026-10-07 (T46-T48); the heap in all seven: Dafny and Frama-C natively (T50), the other five by copy-in/copy-out (T53), so swap_at, clamp_all and offset_all are proved in all seven (66 of 114 in all seven after T55's stronger specs, T57's heap-twin certificates and T65's frame fix); floats in SPARK (T49) and Frama-C (T51); floats elsewhere next |
| 2 | **An autonomy suite** (`t/autonomy/`) | 25 routines with real contracts: geofence, distance with a float error bound, heading wrap, PID step with saturation, rate limiter, 1-D Kalman update, moving average, 2-of-3 sensor voting, waypoint advance, time to collision, ring buffer, a parallel sensor pass. Each verified with its twin refuted in SPARK and Frama-C, and in all seven where the constructs are carried | real flight code: 27 PX4-Autopilot functions restated statement by statement in `t/flight/` (T67-T69: mathlib, Hysteresis, the obstacle-map bin index, the MAVLink Ringbuffer), 18 verified with the twin refuted in all seven kernels, 25 agreeing with PX4's own compiled C++ on every point compared and AlphaFilter once its binary32 `alpha` is applied, 18 shipping for every int32 input; nine lowering gaps found by real code and fixed (T68, T69); one PX4 defect found by the method (collision prevention's bin index goes negative for a field of view nothing range-checks, T68); 25 routines in `t/autonomy/` (T52), read from a clean clone: Frama-C 21, SPARK 20, Dafny 18, F* 18, Lean/Verus/Rocq 15; 14 in all seven. The spec audit (T54) found one spec to strengthen here, pid_step (which limit a saturated command takes); nearest_index's survivor is a tie, intended |
| 3 | **A public technical report** | the method (one spec, seven kernels, the twin rule) and its measurements: the matrix, AlgoVeri, the autonomy suite, and D8, the twin audit of public verified benchmarks | draft: `REPORT.md`; D8 read (T54, clean clone): over 316 Dafny-verified DafnyBench programs, Dafny proves a second one-edit program against the same contract in 44, 23 of them gaps by hand reading, MutDafny's four among them; six corpora in Dafny, Verus, Lean and Frama-C (T56, T59): 72 gaps across five public benchmarks, each with a kernel proof of the wrong program; ACSL by Example and vericoding Lean none; R1/R2 (T61): 25 of the 72 repaired with a kernel proof, printed as source patches in `t/repairs/` |
| 4 | **Upstream fixes** | each kernel bug or limit the matrix finds, reported to that kernel's project with a minimal reproduction, linked here | eight drafted in `internal/UPSTREAM-2026-10-07.md` (kernels, two benchmarks, Why3, and PX4's obstacle-map index), none filed |
| 5 | **One-command use** | a container with all seven kernels, `t verify` from a fresh machine in under five minutes, a two-minute quickstart | `QUICKSTART.md` (one routine, seven proofs, an audit of its spec); a `Dockerfile` with all seven kernels, pinned by sha256, built and checked on a fresh CI runner (`.github/workflows/container.yml`): 28 of 28 smoke cells verified/refuted in all seven kernels in 115 s, a 10 GB image built in about 25 minutes; image publishing is the operator's call; `t build` (T62) compiles the proven C and Dafny and runs them against the interpreter, 9,961 runs, no lowering bug, every C disagreement integer width; the proof at the width that ships (`t ship`, T63): 63 routines for every int32 input (two by inferred loop bounds, T64), 12 within a proved envelope |
| 6 | **A model that writes t** | dawnr drafts the t for a routine from a plain requirement; only what the kernels prove is kept | the gate exists (dawnr) |

## Order

1. Heap (in-place arrays), then concurrency (built on it), then floats: the language first, so the suite can be
   written in it.
2. The autonomy suite, routine by routine, each landing with its matrix row.
3. The container and quickstart, so anyone can rerun every number.
4. The report, once the suite has its rows, with D8 measured by the kernels.
5. Upstream reports as the matrix finds them, from now on.

The language rule stands throughout: a construct a kernel cannot express is refused by name, never weakened, and no
number is published that a clean clone does not reproduce.
