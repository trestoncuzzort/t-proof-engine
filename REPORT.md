# One specification, seven proof kernels

**A technical report on t: writing a routine once, proving it in Dafny, Verus, Lean 4, Rocq, F\*, SPARK and
Frama-C, and checking every specification with a refutation twin.**

Draft of 2026-10-07. Every number here is from a table regenerated from a clean clone of this repository
(`t/AGREEMENT.md`, `t/ALGOVERI.md`, `t/AUTONOMY.md` and the `t/AUDIT-*.md` tables). The registration that predicted
each one, before it ran, is in `t/PREDICT-2026-10-06-t-expansion.md`.

## Abstract

A machine-checked proof is only as good as its specification, and a specification that cannot tell a correct program
from a wrong one proves nothing. t is a small language in which a routine and its contract are written once and then
lowered mechanically into seven independently built proof systems. A cell of the resulting table counts only if two
things hold. First, the kernel proves the real program. Second, it refutes the routine's **twin**, a one-edit mutant
chosen by a search for an input where the mutant breaks the contract, by accepting a certificate at that input. Over
114 tasks, 65 are proved with their twins refuted in all seven kernels. A specification audit runs every one-edit
mutant by execution and has the kernel prove the ones the spec cannot tell apart. Over 316 Dafny-verified DafnyBench
programs, Dafny also proves a different, one-edit program against the same contract in 44; read by hand, 23 of those
are gaps in the specification. Across five public benchmark corpora in Dafny, Verus and Lean, 72 such gaps are found,
each with a kernel proof of the wrong program, and 25 of them are repaired mechanically, each repaired contract
kernel-proved for the program as written. Each kernel refuses by name what it cannot express, rather than
weakening it. The language now carries the constructs embedded control code needs: in-place
arrays, parallel loops whose race freedom is checked by rule, and IEEE-754 doubles. A suite of 25 autonomy routines
is checked the same way.

## 1. The problem

Three failures recur in verified-software benchmarks and in machine-generated proofs:
- **A vacuous or decorative specification.** `ensures true`, or a postcondition any program meets, is proved by every
  kernel and says nothing.
- **A proof that leans on one tool's quirks.** A proof can depend on a solver heuristic, a trigger choice or an
  encoding artifact, and other tools disagree with it silently.
- **An encoding gap.** A construct a backend cannot express gets approximated, and the approximation is proved
  instead of the program.

t addresses each one structurally rather than by review.

## 2. The method

- **One source, seven lowerings.** A task (typed signature, `requires`, `ensures`, body, loop invariants and
  `decreases`) is lowered by a separate, mechanical backend per kernel. t proves nothing and is trusted for nothing.
  The seven front ends sit on four distinct proof engines: Z3, Alt-Ergo, the Lean kernel and the Rocq kernel.
- **The twin rule.** A one-edit mutation ladder runs over the body (negate a condition, flip a comparison, shift a
  constant by one, swap a variable, collapse a branch, drop a guard or an early exit). The first mutant that an
  interpreter run finds disagreeing with the real program, at an input where it also breaks the `ensures`, is the
  twin. A kernel's cell counts as **verified/refuted** only when the kernel proves the real program and accepts a
  ground certificate that the twin violates the contract at that input. A specification no twin can break is reported
  as such.
- **Refusal by name.** A construct a kernel's lowering does not carry raises a named refusal (`abstain`). It is never
  approximated. The refusals are a census of what each kernel lacks.
- **Registration before measurement.** Every change states, before it runs, which cells it predicts will move. The
  table is installed only from a clean clone, with nothing else running, and the read says whether each bar held.
- **Byte identity.** Every change compares every lowering of every task, real and twin, in all seven kernels,
  before and after. A change that moves a cell it did not predict is caught before any kernel runs.

## 3. What the language carries

Integers, booleans, exact rationals, sequences (slices, comprehensions), nested sequences, pairs and tuples, finite
sets, maps, datatypes (records, sums, recursion), strings as code-point sequences with a library, loops with
invariants, early exits, recursion, methods and lemmas. Since 2026-10-07 it also carries:
- **Heap (v1):** an array parameter written in place under `modifies`, with `old(...)` and no aliasing. By Ada RM 6.2,
  writing in place then equals copying in and out.
- **Concurrency (v1):** `parallel for`, whose iterations may touch only their own element. The checker enforces this,
  so every schedule computes what the sequential loop computes, and the interpreter runs a second schedule to show
  it.
- **Floats (v1):** IEEE-754 binary64, rounded to nearest even and defined only when finite, the semantics SPARK
  states. `real(f)` measures a float against exact arithmetic.

## 4. Results

**The matrix** (114 tasks; `t/AGREEMENT.md`, clean clone at 07311fa):

| kernel | proved, twin refuted | carried, not proved | refused by name |
|---|---|---|---|
| Dafny | 111 | 0 | 3 |
| Verus | 104 | 3 | 7 |
| Lean 4 | 88 | 4 | 22 |
| Rocq | 83 | 3 | 28 |
| F\* | 84 | 4 | 26 |
| SPARK | 79 | 5 | 30 |
| Frama-C | 70 | 2 | 42 |

- 65 of the 114 tasks are proved with the twin refuted in **all seven**.
- In six kernels every proved program's twin is refuted. The one exception is SPARK's relu_all, whose twin times
  out.
- The heap reaches the five kernels without native arrays by copy-in/copy-out (PREDICT T53). With no aliasing,
  writing in place and copying back are the same program (Ada RM 6.2).

**AlgoVeri** (30 contracts lifted from the public benchmark; `t/ALGOVERI.md`): Dafny 30, Verus 9, F\* 5, SPARK 4,
Frama-C 2, Lean 1, Rocq 1. One contract is proved in all seven.

**The autonomy suite** (25 routines; `t/autonomy/`, `t/AUTONOMY.md`, clean clone at f4d5570), verified with the
twin refuted: Frama-C 21, SPARK 20, Dafny 18, F\* 18, Lean 15, Verus 15, Rocq 15. 14 of the 25 are in all seven.
What keeps the others out is measured, not guessed:
- nonlinear integer division (grid_cell, low_pass_step), which F\* alone proves;
- pid_step's two rounded products and a sum, a timeout in SPARK and Frama-C at every step budget tried;
- floats, which five kernels refuse by name;
- the heap routines sample_push (ring-buffer `mod`) and saturate_all, proved in Dafny and Frama-C and not yet
  elsewhere.

**Solver change** (PREDICT T22): over 298 cells verified under the default solver, no second solver refuted a verified
program. Proof strength is solver-specific: under Z3, 31 of the 49 programs Alt-Ergo proves in Frama-C time out.

**D8: auditing public specifications** (PREDICT T54; `t/audit.py`, `t/AUDIT-DAFNYBENCH.md`, clean clone at 62fa15e).
The twin rule asks one question of a spec: does it refute one wrong program? The audit asks a wider one: of every
one-edit mutant of the body, which change what the routine computes, and does the spec catch each of them? The
interpreter classes every mutant over the task's bounded domain. A **survivor** computes a different result at a
ground input and meets the `ensures` at every domain point. Dafny then verifies the real body and the first
survivors. A survivor Dafny proves is a second, different program with a proof against the same contract.

Over the 326 DafnyBench tasks t can state (`t/dafnybench/`, a selection biased toward simple programs):

| measure | count |
|---|---|
| tasks audited | 320 |
| real body verified by Dafny | 316 |
| mutants: killed / same / diverge / survive | 6,829 / 896 / 1,002 / 418 |
| tasks with a survivor | 53 |
| tasks whose verified real body has a survivor **Dafny also proves** | 44 |

The 44 were read by hand (`t/dafnybench/CLASSIFIED.md`):
- 23 are gaps:
  - three `max` routines whose contract (`c >= a && c >= b`) admits a value above both;
  - a Euclidean division with no bound on the remainder;
  - a median of three that admits a non-median;
  - a contract that an `==>` precedence slip makes a tautology;
  - the four weak specs MutDafny's authors found by hand.
- 3 are `ensures true`.
- 3 are test cases.
- 15 are intended latitude, mostly ties among maxima.

MutDafny (arXiv 2511.15403) ran 118,458 Dafny-verified mutants of 794 programs, 30,459 of them alive, and triaged a
sample by hand: 157 of 284 alive mutants were equivalent to the original. The audit removes that step:
- equivalence is decided by running the mutants, so no kernel time or reading goes to the 896 mutants that compute
  the same thing;
- every survivor comes with the input where it differs;
- a survivor is a fact about the postcondition alone, independent of the loop invariants.

The cost is the bounded domain: a difference outside it is not seen.

The same audit, in the kernel each source was verified in (PREDICT T56 and T59; clean clones at 5e3abec and 9c7b147):

| corpus | kernel | audited | mutants killed | specs with a survivor | real verified | survivor proved too | gaps by hand |
|---|---|---|---|---|---|---|---|
| DafnyBench (what t states) | Dafny | 320 | 94.2% | 53 | 316 | 44 | 23, and 3 `ensures true` |
| vericoding, Dafny track | Dafny | 488 | 94.8% | 54 | 425 | 39 | 31, and 1 tautology |
| vericoding, Verus track | Verus | 63 | 96.8% | 20 | 55 | 14 | 13 |
| vericoding, Lean track | Lean | 16 | 100% | 0 | 12 | 0 | 0 |
| HumanEval-Dafny | Dafny | 45 | 93.5% | 6 | 39 | 5 | 5 |
| ACSL by Example | Frama-C | 16 | 100% | 0 | 13 | 0 | 0 |

Across the five benchmark corpora, 102 tasks have a kernel-proved one-edit wrong program. By hand reading, 72 of them
are gaps in the specification. 25 are repaired with a proof (below).

Specification quality tracks the source:
- ACSL by Example, an expert-written library, kills every mutant, including on ties: `max_element` names the
  first maximum.
- In vericoding's Verus track, a task counts as solved when the kernel verifies a program against its specification.
  13 of the 55 verified tasks are also solved by a one-edit wrong program (`t/vericoding/CLASSIFIED.md`). In its
  Dafny track, 31 of 425 are (`t/vericoding/CLASSIFIED-DAFNY.md`).
  - The APPS-derived specifications state only that the output is well formed, and two are met by a constant.
  - The NumPy-derived ones state mostly the output's length.
- The vericoding paper estimates by hand that about 9% of its specifications are too weak. The audit gives a
  mechanical lower bound with a proof for each case.

Run on t's own suites, the audit found seven of its own specs too weak, each of which passes the twin rule:
- count_pos_for, evens, filter_pos and index_map;
- rate_limit, where the direction of a limited step is unstated;
- pid_step, where the limit a saturated command takes is unstated;
- tree_insert, where the search-tree order is unstated.

All seven were rewritten to pin their results down (PREDICT T55, T60; tree_insert now states the bounded search-tree
order). Each kills every behaviour-changing mutant, and the suite's audit reads 1,578 of 1,578 killed. The stronger filter_pos costs Frama-C one cell: WP has no frame fact for a
recursive logic function over memory, and the loop invariant steps out. The stronger tree_insert costs Rocq and Lean
one cell each. A stronger contract is harder to prove, and the matrix now counts the harder one.

**Repair: from a measured gap to a proved contract** (PREDICT T61; `t/repair.py`, `t/REPAIR-*.md`, `t/repairs/`).
A gap the audit measures can be repaired mechanically:
- **Candidates:** clauses from a grammar over the task's own vocabulary (result-to-parameter relations, membership,
  extremes and their attainment, bounds, the converse of a subset-only postcondition), plus Daikon-style fits read off
  the real program's values on the domain.
- **Filter:** each clause must hold for the real program at every domain point.
- **Cover:** the fewest clauses that kill every survivor.
- **Check:** the repaired task is audited again, then proved in the kernel. Where the old loop invariants cannot
  carry the stronger contract, invariants are inferred the same way from the loop-head states the interpreter
  observes, and proved with it.

25 of the 72 benchmark gaps are repaired with a kernel proof:
- the converse that MutDafny's authors proposed by hand for three subset-only specs, with the loop invariant that
  carries it;
- `0 <= r < b` for a Euclidean division;
- `z == (x == y)` for the precedence slip;
- attainment for a maximum difference, with the running extremes attained in the scanned prefix as invariants.

Each repair is printed as source lines in the kernel's language. Most of the rest cannot be repaired from their own
vocabulary: the APPS- and NumPy-derived specifications never define the function the task computes. The repair
refuses a solution that never reads its inputs. 13 of vericoding's 509 Dafny solutions and 8 of its 63 Verus ones are
such programs, including a recorded Verus solution that returns `'R'` for every input.

**Shipping: the proven lowerings compiled and run** (PREDICT T62; `t/build.py`, `t/BUILD-*.md`). A kernel proves a
lowering. A backend and a toolchain then make it a program, and neither is verified. Each proven lowering is
compiled with its kernel's ordinary toolchain (the Frama-C C with gcc, the Dafny with its Python backend), run on
domain points, and compared with t's interpreter. Over 9,961 compiled runs of the task and autonomy suites:
- No result betrays a lowering bug, and Dafny's Python builds agree on every point.
- Every C disagreement is integer width. WP's model, pinned on purpose because t's integers are unbounded, treats
  `int` as a mathematical integer, and the shipped C uses 32 bits.
  - 29 routines differ only at inputs beyond int32.
  - 3 overflow an intermediate inside int32 inputs: `(r + 1) * (r + 1)` in an integer square root,
    `2 * decel * dist` in a stopping-distance check, `prev + max_step` in a throttle limiter.
  - All of them agree at 64 bits up to values beyond 2^63.

  A proof of the routine is not a proof of the shipped binary until the proof is done at the width that ships.

**The proof at the width that ships** (PREDICT T63; `t/ship.py`, `t/SHIP-*.md`). Each C lowering is proved again under
WP's machine-integer model with runtime-error guards, so every signed operation owes a no-overflow proof. Where an
overflow is reachable at full width, the largest ±2^k input bound under which everything proves is the routine's
proved operating envelope:
- 63 routines ship for every 32-bit input. Two of them are held by loop bounds (`0 <= c <= i <= len(s)`). The bounds
  were inferred from observed loop states, pruned by Houdini, and proved (T64).
- 12 ship within an envelope:
  - abs within ±2^30, its `-x` overflowing at INT_MIN;
  - a throttle limiter within ±2^29;
  - a cross-track sign test and a stopping-distance check within ±2^14.
- 19 have no envelope found. That is not proof of unsafety:
  - an overflow inside a library helper outside the task's loops;
  - a contract already open (the frame gap);
  - non-linear division the prover does not decide.

## 5. What the kernels taught

Each item below was found by a measured disagreement and fixed in a lowering, and each is in SPEC.md with its date.
- **Lean's `grind`** normalizes `(0 : Int).toNat` to `0` before E-matching, so a lemma stated at an Int index never
  fired at a literal index. The fix states the lemma at a Nat index as well.
- **Rocq's `congruence`** needs a hypothesis and its negation to be one syntactic term, so seq equalities are written
  in one canonical orientation.
- **Verus's** recursive comprehension over the whole source needs subrange extensionality at every step. A loop over
  a prefix gets two broadcast lemmas: one step of the prefix, and the full-length prefix equals the whole.
- **Frama-C's** smoke test flags the dead code after a `while (1)` left only by `return`, so the rewrite drops it.
- **Dafny's** array axioms trigger on `a[i]` and `a.Length`, not on the sequence view `a[..][i]`. In-place reverse
  timed out until elements were read on the array itself.
- **Float goals need a larger step budget, and one needs more than budget.** A rate limiter timed out at the
  integer budget in SPARK and Frama-C and proves at ten times it; programs over doubles now get 100 times
  (PREDICT T58). In Frama-C the per-goal wall then became the binding limit under load and was made a backstop
  (T58b). The PI controller step, two rounded products and a sum, still times out at every budget, the non-linear
  case the SPARK User's Guide names as a prover limitation.

## 6. Limitations

- **The lowerings are not verified.** A wrong lowering could prove the wrong theorem. Mitigations:
  - seven independent lowerings must agree;
  - the twin certificate must be refuted in the same lowering;
  - the matrix's "real verified, twin refuted" pairing makes a vacuous encoding visible;
  - the C and Dafny lowerings are compiled and run against the interpreter (T62: 9,961 runs, no lowering bug found).

  None of this is a proof of the lowerings.
- **The twin's value comes from t's interpreter.** A twin's certificate grounds the interpreter's computed value, and
  the kernel checks only that the contract fails there. The interpreter is a single Python implementation.
- **Twins are chosen by value difference within a bounded input domain.** A spec weak only outside that domain is not
  caught.
- **One machine, pinned versions.** Kernel versions are recorded in every table, and nothing is claimed beyond them.
  The `Dockerfile` pins the same versions by sha256, and CI builds it on a fresh machine.
- **The audit's limits.**
  - A difference outside the bounded domain is not seen.
  - Telling a gap from intended latitude is a reading of the routine's purpose. Every reading is published beside
    its proof (`CLASSIFIED*.md`) so it can be disputed.
  - The lifted corpora are the programs t can state, a selection biased toward integers, sequences and loops, so
    the counts describe those programs, not each benchmark whole.

## 7. Related work

`t/RELATED-WORK.md` reads 42 systems against their sources. No system found stacks more than two of t's pillars:
- one specification interlingua;
- lowered to several independently built kernels;
- graded by a table that requires a kernel-checked refutation of a witness-chosen twin;
- used as a reward for a model.

The closest, Federated Formal Verification (arXiv 2606.02019), discharges one TLA+ model's obligations across
heterogeneous backends behind kernel-agreement gates. It has no mutant, witness or refutation certificate, and
it cites obligations across kernels rather than lowering one program whole to each.

Mutation analysis of specifications is older than this work:
- MutDafny (arXiv 2511.15403) mutates Dafny implementations and reads a verified mutant as a possible weak spec.
- IronSpec mutates the specifications themselves.
- Endres et al. (2024) score postconditions by how many mutants of an implementation they reject.

The audit here differs in two ways. It decides equivalence by execution before any kernel runs. It also states each
survivor at a witness input and confirms it with a kernel proof.

## 8. Reproduce

`t/RUN-ON-LINUX.md` installs the seven kernels. Then:

```
python3 t/cli.py verify t/tasks --jobs 3 --table AGREEMENT.md
python3 t/cli.py verify t/algoveri --jobs 2 --table ALGOVERI.md
python3 t/cli.py verify t/autonomy --jobs 3 --table AUTONOMY.md
python3 t/cli.py audit  t/dafnybench --kernel dafny --jobs 4 --table AUDIT-DAFNYBENCH.md
```

Or, with nothing installed but Docker: `docker build -t t-proof-engine .` and see `QUICKSTART.md`.

The whole suite (`python3 -m pytest t`) runs without any kernel.
