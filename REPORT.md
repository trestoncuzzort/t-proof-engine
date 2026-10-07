# One specification, seven proof kernels

**A technical report on t: writing a routine once, proving it in Dafny, Verus, Lean 4, Rocq, F\*, SPARK and
Frama-C, and checking every specification with a refutation twin.**

Draft of 2026-10-07. Every number here is from a table regenerated from a clean clone of this repository
(`t/AGREEMENT.md`, `t/ALGOVERI.md`, `t/AUTONOMY.md`); the registration that predicted each one, before it ran, is in
`t/PREDICT-2026-10-06-t-expansion.md`.

## Abstract

A machine-checked proof is only as good as its specification, and a specification that cannot tell a correct program
from a wrong one proves nothing. t is a small language in which a routine and its contract are written once and then
lowered mechanically into seven independently built proof systems. A cell of the resulting table counts only if two
things hold. First, the kernel proves the real program. Second, it refutes the routine's **twin**, a one-edit mutant
chosen by a search for an input where the mutant breaks the contract, by accepting a certificate at that input. Over
114 tasks, 65 are proved with their twins refuted in all seven kernels. Each kernel refuses by name what it cannot
express, rather than weakening it. The language now carries the constructs embedded control code needs: in-place
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

**The matrix** (114 tasks; `t/AGREEMENT.md`, clean clone at 94fb961):

| kernel | proved, twin refuted | carried, not proved | refused by name |
|---|---|---|---|
| Dafny | 111 | 0 | 3 |
| Verus | 102 | 5 | 7 |
| Lean 4 | 89 | 4 | 21 |
| Rocq | 82 | 4 | 28 |
| F\* | 82 | 6 | 26 |
| SPARK | 78 | 6 | 30 |
| Frama-C | 69 | 3 | 42 |

- 65 of the 114 tasks are proved with the twin refuted in **all seven**.
- In Dafny, Lean and Frama-C every proved program's twin is refuted. In Verus, Rocq, F\* and SPARK, 2, 2, 2 and 1
  heap twins are not refuted yet: no certificate yet for a twin that differs only in the array, or a timeout.
- The heap reaches the five kernels without native arrays by copy-in/copy-out (PREDICT T53). With no aliasing,
  writing in place and copying back are the same program (Ada RM 6.2).

**AlgoVeri** (30 contracts lifted from the public benchmark; `t/ALGOVERI.md`): Dafny 30, Verus 9, F\* 5, SPARK 4,
Frama-C 2, Lean 1, Rocq 1. One contract is proved in all seven.

**The autonomy suite** (25 routines; `t/autonomy/`, `t/AUTONOMY.md`, clean clone at 94fb961), verified with the
twin refuted: Frama-C 21, SPARK 20, Dafny 18, F\* 17, Lean 15, Verus 14, Rocq 14. 13 of the 25 are in all seven.
What keeps the others out is measured, not guessed:
- nonlinear integer division (grid_cell, low_pass_step), which F\* alone proves;
- float rounding under a step budget (pid_step);
- floats, which five kernels refuse by name;
- the heap routines sample_push (ring-buffer `mod`) and saturate_all, proved in Dafny and Frama-C and not yet
  elsewhere.

**Solver change** (PREDICT T22): over 298 cells verified under the default solver, no second solver refuted a verified
program. Proof strength is solver-specific: under Z3, 31 of the 49 programs Alt-Ergo proves in Frama-C time out.

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
- **Z3 under SPARK** does not find the monotonicity of rounding: a rate limiter's `r >= prev - step`, for
  `r = prev + step`, times out. This is a measured limit, kept in the table.

## 6. Limitations

- **The lowerings are not verified.** A wrong lowering could prove the wrong theorem. Mitigations: seven independent
  lowerings must agree, the twin certificate must be refuted in the same lowering, and the matrix's
  "real verified, twin refuted" pairing makes a vacuous encoding visible. None of this is a proof of the lowerings.
- **The twin's value comes from t's interpreter.** A twin's certificate grounds the interpreter's computed value, and
  the kernel checks only that the contract fails there. The interpreter is a single Python implementation.
- **Twins are chosen by value difference within a bounded input domain.** A spec weak only outside that domain is not
  caught.
- **One machine, pinned versions.** Kernel versions are recorded in every table, and nothing is claimed beyond them.

## 7. Related work

`t/RELATED-WORK.md` reads 42 systems against their sources. No system found stacks more than two of t's pillars:
- one specification interlingua;
- lowered to several independently built kernels;
- graded by a table that requires a kernel-checked refutation of a witness-chosen twin;
- used as a reward for a model.

The closest, Federated Formal Verification (arXiv 2606.02019), discharges one TLA+ model's obligations across
heterogeneous backends behind kernel-agreement gates. It has no mutant, witness or refutation certificate, and
it cites obligations across kernels rather than lowering one program whole to each.

## 8. Reproduce

`t/RUN-ON-LINUX.md` installs the seven kernels. Then:

```
python3 t/cli.py verify t/tasks --jobs 3 --table AGREEMENT.md
python3 t/cli.py verify t/algoveri --jobs 2 --table ALGOVERI.md
python3 t/cli.py verify t/autonomy --jobs 3 --table AUTONOMY.md
```

The whole suite (`python3 -m pytest t`) runs without any kernel.
