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
| 1 | **Floats, heap and concurrency in the language** | in SPEC.md, the checker, the interpreter, the twins and the Python hand-back; lowered in Dafny, SPARK and Frama-C first, refused by name elsewhere until built | landed 2026-10-07 (T46-T48); the heap in all seven: Dafny and Frama-C natively (T50), the other five by copy-in/copy-out (T53), so swap_at, clamp_all and offset_all are proved in all seven; floats in SPARK (T49) and Frama-C (T51); floats elsewhere next |
| 2 | **An autonomy suite** (`t/autonomy/`) | 25 routines with real contracts: geofence, distance with a float error bound, heading wrap, PID step with saturation, rate limiter, 1-D Kalman update, moving average, 2-of-3 sensor voting, waypoint advance, time to collision, ring buffer, a parallel sensor pass. Each verified with its twin refuted in SPARK and Frama-C, and in all seven where the constructs are carried | 25 routines in `t/autonomy/` (T52), read from a clean clone: Frama-C 21, SPARK 20, Dafny 18, F* 17, Lean 15, Verus/Rocq 14; 13 in all seven. The spec audit (T54) found one spec to strengthen here, pid_step (which limit a saturated command takes); nearest_index's survivor is a tie, intended |
| 3 | **A public technical report** | the method (one spec, seven kernels, the twin rule) and its measurements: the matrix, AlgoVeri, the autonomy suite, and D8, the twin audit of public verified benchmarks | draft: `REPORT.md`; D8 is `t/audit.py` (T54), every one-edit mutant classed by execution, survivors proved in a kernel; first read: Dafny proves a wrong program against each of MutDafny's four weak DafnyBench specs |
| 4 | **Upstream fixes** | each kernel bug or limit the matrix finds, reported to that kernel's project with a minimal reproduction, linked here | three drafted in `internal/UPSTREAM-2026-10-07.md`, not filed |
| 5 | **One-command use** | a container with all seven kernels, `t verify` from a fresh machine in under five minutes, a two-minute quickstart | the CLI exists; a `Dockerfile` with all seven kernels, pinned by sha256, built and checked on a fresh CI runner (`.github/workflows/container.yml`); image publishing is the operator's call |
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
