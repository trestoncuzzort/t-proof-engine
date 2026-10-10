# Floats elsewhere: what the next gate actually costs, per kernel

Registered 2026-10-10 after a prior-art survey and before any lowering change. This is a design/prediction, not a
measured result: nothing here has been run. NORTH-STAR target 1 reads "floats in SPARK (T49) and Frama-C (T51);
floats elsewhere next." SPEC.md "Floats (v1)" (PREDICT T48) is IEEE-754 binary64, round-to-nearest-even, defined
only when finite, never mixing with int or real. The other five kernels `tshape.abstain_on_floats` by name.

The question this answers before any code is written: for each remaining kernel, is there a *faithful* way to lower
Floats (v1), or would lowering it be a false verdict? The answer is not the same for all five, and for two of them
the honest answer is to keep abstaining.

## Why floats are in SPARK and Frama-C first

Both have a native, IEEE-754-faithful float model that the toolchain reasons about directly: GNATprove supports
IEEE floats (and fixed-point) in SPARK, and Frama-C/WP has an IEEE-754-conformant floating-point abstraction that
keeps the properties real-number reasoning silently loses, such as the non-associativity of addition
([frama-c.com/u3cat/wp1.html](https://frama-c.com/u3cat/wp1.html)). That faithfulness is the reason they went first,
not alphabetical luck.

## Per-kernel prior art (what to build on, not hand-roll)

| kernel | faithful IEEE-754 route today | verdict |
|---|---|---|
| **Rocq** | **Flocq** — `Flocq.IEEE754.Binary` / `BinarySingleNaN`, rounding mode `mode_NE` (nearest, ties to even). CompCert's binary64 (`compcert.lib.Floats`) is built on it and proves bit-level properties. | **tractable and faithful** — the one real next kernel |
| **Lean 4** | **FloatSpec** (a Flocq port to Lean+Mathlib: rounding, ulp, error bounds, IEEE encodings) is the closest, but it is in development with ~270 `sorry` placeholders. The built-in `Float` is IEEE binary64 operationally but the logic treats it as an opaque `Float.Model`, not a proof target. | **blocked on library maturity** |
| **F\*** | No faithful derived binary64 library found; the available `IEEE754.fst` (Z3's) is *axiomatic* — the arithmetic is assumed, not proved from a bit representation. | **blocked**; an axiomatic model would be assumptions, not proof |
| **Dafny** | No IEEE float type. Modeling floats as Dafny `real` is explicitly *unsound* for IEEE: it ignores underflow, NaN, signed zero, infinities and non-associativity (DafnyMPI uses `real` and says so; the Java-verification case study records a tool proving the false `0.0 == 1.0` this way). | **keep abstaining** — a `real` lowering is a false verdict |
| **Verus** | Same as Dafny: no faithful IEEE model; `real`/rational abstraction loses the same properties. | **keep abstaining** |

Sources: Flocq (gitlab.inria.fr/flocq/flocq; `IEEE754.Binary`, `mode_NE`); CompCert `compcert.lib.Floats` on Flocq;
FloatSpec (reservoir.lean-lang.org/@Beneficial-AI-Foundation/FloatSpec); Lean reference, Float = IEEE binary64 /
`Float.Model` (lean-lang.org/doc/reference .../Floating-Point-Numbers); DafnyMPI (arXiv:2512.18842) on `real`-as-float
being imprecise; "Correct Approximation of IEEE 754 FP for Program Verification" (arXiv:1903.06119) on real-abstraction
unsoundness and a tool proving `0.0 == 1.0`; Frama-C WP IEEE abstraction (frama-c.com/u3cat/wp1.html).

## The honest plan

1. **Rocq via Flocq is the next faithful kernel.** Lower a Floats (v1) `float` to Flocq's binary64, each arithmetic
   op to the corresponding `B*` operation under `mode_NE`, `sqrt` to `Bsqrt`, `real(f)` to `B2R`, and carry the
   finiteness side-condition SPEC.md already requires as a `is_finite` hypothesis. This is build-on-Flocq, not a new
   float theory.
2. **Dafny and Verus keep abstaining.** A `real` lowering is not a conservative approximation here; it certifies
   programs IEEE semantics would refute. "An honest refusal beats a false verdict" (AGENTS.md rule 2) decides this:
   the correct lowering for these two is the one already shipped — abstain by name — until a faithful model exists.
3. **Lean and F\* stay abstaining** until FloatSpec closes its `sorry`s (Lean) or a derived (not axiomatic) F\* binary64
   library exists. Track FloatSpec rather than forking it.
4. **Safe cross-kernel increment available now, no rounding involved.** The comparison-only float tasks —
   `px4_constrain`/`constrain_f`, `px4_min`, `px4_max`, `px4_sign*`, `px4_is_in_range` — return one of their inputs
   unchanged; they contain no arithmetic, so no IEEE rounding occurs. On finite, non-NaN floats (which Floats (v1)
   already restricts to), IEEE ordered comparison equals real-order comparison, so these lower *faithfully* in any
   kernel with an ordered real/float carrier — including Lean, Rocq and F\* — without a rounding model. This turns a
   specific, provably-safe subset of the abstains into verified cells while the full Flocq route is built.

## Predictions (to check on the run that implements step 1 or step 4)

1. **Step 4, comparison-only:** lowering `constrain`/`min`/`max`/`sign`/`is_in_range` as ordered comparisons on a
   real/float carrier verifies the real task and refutes its twin in every kernel it is added to, and moves no cell of
   the existing 114-task matrix. If any such task needs an arithmetic op after all, it is out of this subset and stays
   abstaining.
2. **Step 1, Rocq/Flocq:** the three existing float tasks (sat_scale, deadband, rate_limit) lower to Flocq `mode_NE`
   binary64; sat_scale and deadband verify with twin refuted; rate_limit may time out exactly as it does in SPARK
   (its ensures needs monotonicity of rounding), which is reported as timeout, not forced.
3. **No regression:** no lowering of the 104 pre-float matrix tasks changes bytes; the SPARK and Frama-C float cells
   do not move; Dafny/Verus/Lean/F\* keep abstaining on any task carrying arithmetic floats.

## Validation plan

Add the lowering behind the same `has_float` gate `tshape.abstain_on_floats` reads, so a kernel only stops abstaining
for the subset it can prove. Run `t/cli.py verify t/flight` and the float unit tests (`test_floats.py`) on the lab
with all seven kernels before and after, and regenerate the matrix from a clean clone. Engine changes land here
first, then sync to dawnr. Do not claim a binary32 result: Floats (v1) is binary64 by definition and binary32 flight
correspondence remains the separately-deferred item.
