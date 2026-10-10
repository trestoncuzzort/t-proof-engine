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

## Read (2026-10-10, on the lab)

The comparison-only desugar (step 4) was prototyped and measured before committing: a `tshape.floats_to_real_if_safe`
that rewrites a float task to real only when every op is a comparison, a boolean connective, equality or selection
(the whitelist is conservative — any arithmetic or value-producing float op keeps it abstaining), wired into the five
non-native kernels ahead of `abstain_on_floats`. It was run on `px4_constrain_f` (float params, ops `< <= > == and
implies`) across all seven kernels on the lab.

The rewrite fired correctly (params → real, `has_float` false). It did **not** close the gap, for a different reason
in each kernel, and every failure was an honest refusal — no twin was wrongly accepted, so nothing was unsound:

- **verus:** lowering error on the real-rewritten task (its real lowering did not accept this shape).
- **lean, rocq:** still abstain — the real version is caught by the next guard (`abstain_unless_carried`); their carried
  set does not cover this real comparison/selection shape.
- **dafny, fstar:** prove the real task but the solver gives up on the twin without a countermodel, so the cell is a
  refusal, not agreement.
- **spark, framac** (unchanged, native floats): count as before.

So the desugar shortcut adds zero agreements and turns clean abstains into tried-and-failed cells; it was reverted.
**This empirically confirms the plan above:** closing the gap is not a rewrite but real per-kernel float support —
Flocq binary64 for Rocq first, and the real-lowering/carried-set gaps in Lean, F\* and Verus addressed in their own
lowerings — with Dafny/Verus staying abstained on anything that rounds. The negative result is the measurement that
tells the next run to invest in the Rocq/Flocq lowering rather than a generic float→real desugar.

## Read 2 (2026-10-10, demonstrated on the lab)

The Rocq-via-Flocq route is no longer only predicted: it is compiled and proved. `coq-flocq 4.2.2` was installed into
the lab's default opam switch against Rocq 9.2 (user-level, no sudo). Two infra gaps had to be closed first, both
without root: the switch lacked `gmp.h` (only a gnatprove-bundled `libgmp` runtime existed), so GMP 6.3.0 was built
from source into `~/.local` — which in turn needed `m4`, taken from `~/.local/t-proof-deps/usr/bin/m4`; `conf-gmp`
and `zarith` then rebuilt against it, with the Rocq stack recompiled. After the install, `dawnr doctor` still reports
7 of 7 provers and Rocq runs under the pipeline's normal environment — no regression.

The proof-of-concept `t/flight/evidence/constrain_flocq_poc.v` states PX4's `math::constrain` at IEEE-754 binary64
(`Binary.binary_float 53 1024`), with the float order as Flocq's `Bcompare 53 1024`, and proves the three clamp
properties (below/above/within) with `coqc` exit 0. The proof is a direct case analysis — which is the point: for a
comparison-only task the body and the specification share the same float order, so the t program provably meets its t
specification, and the twin rule then does its job. This confirms step 1 is reachable and cheap for the comparison
subset.

What remains (and is the real work): teach dawnr's Rocq *generator* (`t/lower_rocq.py`) to emit this shape for any
comparison-only float task and its twin, carry `float` in Rocq's set, and discharge over Flocq — then widen past
comparisons toward the arithmetic tasks, where the Flocq rounding lemmas are needed and the proof stops being a case
split. The POC fixes the API and the environment so that work starts from a compiling base rather than a blank one.

## Read 3 (2026-10-10): both hard pieces solved via Rocq primitive floats

The generator blockers were (a) the real-side proof, (b) the twin *refutation*, (c) concrete float witnesses. Rocq's
`Stdlib.Floats` primitive floats dissolve (b) and (c): `t/flight/evidence/constrain_primfloat_poc.v` (coqc exit 0)
proves the three `constrain` clamp properties (real, definitional) AND refutes a low-branch mutant at the measured
witness `(0,1,2)` by `vm_compute; reflexivity` on `(... =? 1) = false`. Native float literals, native computable
order (`<?`,`=?`), and `vm_compute` are exactly what the generator needs to emit and what dawnr's witness-routed
refutation already expects.

Tradeoff for the owner to weigh: primitive floats rest on the `Floats` library's FPU axioms (visible in
`Print Assumptions`), whereas the Flocq `binary_float` POC (Read 2) is axiom-free but has hard literals/refutation.
Both are now demonstrated to compile and prove; the choice is a soundness-vs-effort call. Either way the generator
work for the comparison-only subset is no longer open-ended: emit function + real theorem (definitional proof) +
twin + `vm_compute` refutation at the routed witness, gated on the comparison-only check `tshape` already computes.

## Read 4 (2026-10-10): comparison-only subsection real-side PROVEN, axiom-free

Scoping floats-elsewhere into subsections (operator's steer) made the tractable part obvious, and it is now done and
machine-checked. `t/flight/evidence/constrain_flocq_full.v` (coqc exit 0) proves the FULL PX4 `math::constrain`
contract -- the bounds clause `lo <= r <= hi` AND all three implication clauses -- in Rocq via Flocq, **axiom-free**
and **generic over any IEEE format** (`prec`, `emax`, so binary32 and binary64 at once), under finiteness
hypotheses (Floats v1 is finite-only).

The key is Flocq's `Bltb_correct`/`Bleb_correct`/`Beqb_correct`: for finite floats each comparison boolean equals the
corresponding real-comparison boolean, so the whole contract reduces to real arithmetic and `lra` closes it. Crucially
the proof is a SINGLE uniform tactic (destruct the body's two comparisons; rewrite every finite-float comparison to
its real form; case-split the real bools; `lra`), which is the same for any comparison-only float task -- exactly what
a generator needs to emit. This corrects Read 2-3's "multi-week" estimate for this subsection: the real side is a
~30-line generic proof, not a formalization program.

Remaining for the subsection to land in `lower_rocq.py`: (1) emit, for a comparison-only float task, the Flocq
preamble + `Definition` (the body) + the contract `Theorem` (from the ensures, with finiteness hypotheses) + this
uniform proof; (2) the twin side -- either a concrete-witness Flocq disproof or the primitive-float `vm_compute`
route (Read 3); (3) carry `float` in Rocq's set behind the comparison-only gate. Arithmetic-float tasks remain a
separate, later subsection (they need Flocq rounding lemmas, not this reduction).

## Read 5 (2026-10-10): emitter wired + validated through the pipeline; blocker is adapter conformance

The comparison-only Flocq lowering was emitted from the task AST and wired into `lower_rocq.py` behind a
comparison-only-float gate (`_float_cmp_ok`/`_float_cmp_lower`), then run through `t/cli.py verify` on the lab for
`px4_constrain_f`. Result: `rocq` reads **VACUOUS** on both real and twin ("accepted, but for the wrong reason;
never a win") -- the adapter (`t/verifiers/rocq.py`) rejected it. The standalone proof is unchanged and still
`coqc`-clean (Read 4); what fails is the ADAPTER'S AUDIT PROTOCOL, which the ad-hoc emitted artifact does not satisfy:
the vacuity smoke (`_vacuity_smoke` replaces the goal with False and refuses if the hypotheses prove it), the coqchk
local-assumption re-check, the theorem-name scan, and -- for the twin -- the single REFUTED door, a declared
`t_refutation_certificate` proving the spec false at the measured witness. The emitter change was reverted.

So the subsection's remaining work is now precisely located and is NOT the proof: it is making the emitted artifact
conform to the rocq adapter's audit, i.e. structuring the theorem so the vacuity smoke passes (hypotheses provably
satisfiable; likely the `Section`/`prec`/`emax`/finiteness framing confuses the probe's top-split), keeping the unit
coqchk-clean, and emitting a witness-grounded refutation certificate for the twin instead of a failing contract
proof. That is engine-adapter-specific work (how the standard Z/lia lowering already satisfies these audits), to be
done against `t/verifiers/rocq.py`'s protocol -- the math (Read 4) is settled.

## Read 6 (2026-10-10): CORRECTION -- the reduce-to-reals proof is classical, not axiom-free

Read 4 called the Flocq proof axiom-free. That was wrong, and the adapter caught it. `Print Assumptions
constrain_spec` lists `Classical_Prop.classic` and `ClassicalDedekindReals.sig_forall_dec/sig_not_dec`: reducing
finite-float order to real order and closing with `lra` goes through Coq's classical real numbers, so the proof
assumes classical logic + the axiomatic reals. The rocq adapter's positive-check-1 closedness audit
(`Print Assumptions` per theorem; "Axioms:" present or not "Closed under the global context" for every obligation)
demotes exactly this to VACUOUS -- that is the door that fired when the lowering was wired in (Read 5), not the
vacuity smoke.

This sharpens the real blocker: the engine requires constructive, axiom-free kernel proofs, and the B2R/`Rcompare`/
`lra` route cannot give one. An axiom-free comparison-only float lowering must reason at Flocq's spec-float (SF)
level -- `SFcompare`/`SFltb`/`SFleb` over the integer sign/mantissa/exponent representation, which is constructive --
and prove the clamp order facts (reflexivity, the `<?`=false ⟹ `<=?` relation, and the precondition) from the SF
total order WITHOUT touching `R`. That is a genuinely harder proof than the reals shortcut, and PrimFloat is no help
(its `vm_compute` route assumes the FPU axioms). So for this subsection the axiom-free requirement, not the algebra,
is the hard part -- the opposite of Read 4's optimism, and the honest statement of what remains.

## Read 7 (2026-10-10): axiom-free IS reachable at the spec-float level (reflexivity proven Closed)

Read 6 said the axiom-free requirement was the hard wall. It is a wall only for the reals shortcut; the spec-float
route goes straight through it. `t/flight/evidence/bleb_refl_axfree.v`: `Bleb x x = true` for finite `x`, proved by
unfolding `Bleb`/`SFleb`/`SFcompare`, `destruct`ing the `binary_float` constructors (non-finite cases `discriminate`),
reducing the mantissa/exponent comparisons with `Z.compare_refl`/`Pos.compare_refl`, and splitting the sign. `Print
Assumptions bleb_refl` reports **"Closed under the global context"** -- no `R`, no `Classical_Prop.classic`, no
`ClassicalDedekindReals`. This is exactly the audit the rocq adapter demands (positive-check-1), and it passes.

So the comparison-only subsection is reachable axiom-free. The building block is done; the rest is the same kind of
constructive SF reasoning: `Bltb x x = false` (as reflexivity), the order relation `Bltb a b = false -> Bleb b a =
true` for finite `a b` (via `Bcompare_swap`, which is constructive, plus a three-way case on the compare), and then
the clamp bounds reassembled from these instead of `lra`. All `Closed under the global context`, all passing the
closedness audit. The generator then emits this shape (Read 5's wiring) and a witness-grounded `t_refutation_certificate`
for the twin at concrete spec-float values. Laborious, but no longer uncertain: the axiom-free comparison-only float
lowering is a finite stack of constructive SF lemmas, not a reals reduction and not a multi-week unknown.

## Read 8 (2026-10-10): axiom-free bounds clause PROVEN Closed -- the hard clause is done

The clause Read 2-4 feared most -- the universally-quantified `lo <= r <= hi` -- is now proved axiom-free.
`t/flight/evidence/constrain_bounds_axfree.v` (coqc, `Print Assumptions constrain_bounds` = "Closed under the global
context") derives it at the spec-float level from three small reusable lemmas, all Closed:
- `bleb_refl`  : `Bleb x x = true` for finite x (unfold SFcompare; `Z.compare_refl`/`Pos.compare_refl`; split sign).
- `cmp_some`   : finite x,y => `SFcompare (B2SF x) (B2SF y) <> None` (so the unordered/NaN case is excluded).
- `le_not_lt`  : finite a,b => `Bltb a b = false -> Bleb b a = true` (via `Bcompare_swap`, which is `Bcompare = SFcompare`,
  plus `cmp_some` to kill None). NB `SFleb` maps None->false, so finiteness is load-bearing here.

The bounds proof is then an 8-line case split using `bleb_refl`, `le_not_lt`, and the precondition -- no `lra`, no `R`.
This is the proof shape the generator emits, and it passes the rocq adapter's closedness audit (the door that
rejected the reals version in Read 5/6). Remaining for the full contract: `Beqb` reflexivity (like `bleb_refl`) for the
implication clauses, `le_not_gt` (`Bleb a b = true -> Bltb b a = false`) for the "within" clause, and one small order
chain (`lo<=hi` and `hi<v` => `Bltb v lo = false`) for the "above" clause -- all the same constructive SF style.
Then the generator emits this shape and a spec-float refutation certificate for the twin.

## Read 9 (2026-10-10): 3 of 4 contract clauses axiom-free and Closed; only "above" (transitivity) left

`t/flight/evidence/constrain_spec3_axfree.v` (`Print Assumptions constrain_spec3` = "Closed under the global
context") proves the bounds clause, the "within" clause (`lo<=v<=hi -> r==v`) and the "below" clause (`v<lo -> r==lo`)
of PX4 `constrain`, all axiom-free at the spec-float level. The lemma kit is small and all-Closed: `cmp_some`,
`bleb_refl`, `beqb_refl`, `le_not_lt`, `le_not_gt` -- the last two both one `Bcompare_swap` rewrite plus a three-way
case, since `Bcompare = SFcompare` makes the swap a spec-float fact.

The only remaining clause is "above" (`v>hi -> r==hi`): it needs `lo<=hi` and `hi<v` to force `Bltb v lo = false`,
i.e. `le_lt_trans` (`Bleb a b -> Bltb b c -> Bltb a c`) then `lt_asym` (`Bltb a c -> Bltb c a = false`). `lt_asym` is
another swap one-liner, but `le_lt_trans` is SFcompare TRANSITIVITY, which Flocq proves only through `B2R`/`Rlt_trans`
(the classical-axiom route, grep: every `*_trans` in BinarySingleNaN goes via `R`). An axiom-free proof must establish
the spec-float order is transitive by constructive case analysis on the sign/exponent/mantissa layout -- the one
genuinely intricate lemma in this subsection. With it, the full `constrain` contract is axiom-free and Closed, the
generator emits this shape, and the twin gets a spec-float refutation certificate. Everything up to that single
transitivity lemma is done and committed.
