# Zoom out, 2026-10-07: what the engine is now, what the landscape says, and what it decides

Written 2026-10-07 01:32Z, after the depth programme of 2026-10-06/07 (T9-T21) and a fresh landscape survey
(`internal/RESEARCH-2026-10-07-landscape-survey.md`: every competitor number there was read on a fetched page and
re-checked against raw text). This note supersedes the ordering in `internal/RESEARCH-2026-10-06-landscape.md`
where the two disagree, and corrects four of its claims.

## 1. Where the engine stands (measured)

| measure | 2026-10-06 21:20Z | 2026-10-07 01:20Z |
|---|---|---|
| repository | `t/` inside dawnr | its own repository, t-proof-engine, with its history |
| committed tasks | 84 | 88 |
| verified with the twin refuted in all seven kernels | 36 | 47 (48 if T21's matrix reads as registered) |
| per kernel | Dafny 84, Verus 76, F* 53, SPARK 50, Rocq 43, Lean 40, Frama-C 36 | Dafny 88, Verus 80, Rocq 62, Lean 61, F* 58, SPARK 55, Frama-C 49 |
| twin refuted where the real is verified | 100% in every kernel | 100% in every kernel |
| AlgoVeri contracts stated in t | 0 | 21 of the 22 stateable; Dafny 21, Verus 6, F* 5, SPARK 3, Frama-C 2, Rocq 1, Lean 0 |
| MALFORMED cells on AlgoVeri | n/a | 13 found, 11 repaired (T15, T17), 2 named and open |

What moved the numbers was depth, as the 10-06 note decided. Two things carried it: the library, in Lean, Rocq
and Frama-C; and comprehension maps, in every kernel. Each landing was registered before its run, and each was
read cell by cell against a whole-column re-run. AlgoVeri was the first outside benchmark the lowerings had met,
and it found six defect classes that none of the 88 tasks reach.

## 2. What the landscape says (read on 2026-10-07)

1. **The twin is no longer unique.** SWE-Proof ships a "pre-fix twin" per task that must fail to verify, in three
   backends, with a mutation-kill check. SpecSyn and MutDafny score specs by refuted mutants. What stays
   distinct in t:
   - the twin is one mechanical edit away, with a measured witness;
   - REFUTED means the kernel accepted a certificate at that witness, never a bare verifier failure;
   - the same twin is refuted in all seven legs.
2. **Multi-verifier benchmarks.** VerifyThisBench covers seven tools, but its tasks differ per tool. Aligned
   benchmarks stop at three verifiers (AlgoVeri, Vericoding, SWE-Proof). t's claim, one statement checked in
   seven, holds for aligned contracts and should be worded that way.
3. **The seven kernels are not seven independent solvers.** Dafny (through Boogie) and Verus both default to Z3.
   SPARK runs on Why3 with CVC5 and Z3, and Frama-C's WP on Alt-Ergo and others. Lean and Rocq are
   kernel-checked, and Lean documents independent re-checkers (comparator with nanoda, lean4checker). "Seven
   independent kernels" overstates it. The accurate wording is "seven independent front ends over four proof
   engines", counted against this engine's own adapters (corrected 01:45Z from "five"):
   - Z3 behind Dafny, Verus, F*, and SPARK as pinned here (`--prover=z3`);
   - Alt-Ergo behind Frama-C;
   - the Lean kernel;
   - the Rocq kernel, re-checked by `coqchk` in the adapter already.

   **Measured 02:12Z (PREDICT T22's read).** The SMT-backed legs were re-run under a second solver: SPARK under
   CVC5 and Alt-Ergo, Frama-C under Z3 and CVC5, and Dafny under CVC5.
   - Over 298 cells that verify under the default, no second solver refuted a verified real.
   - A second solver re-verifies SPARK 56 of 56, Dafny 86 of 88 and Frama-C 33 of 49.
   - Proof strength is solver-specific: Frama-C under Z3 keeps 18 of 49.
   - Dafny's twin side under CVC5 is unmeasurable: Boogie's model converter crashes on a Real value.
4. **Lean is no longer the weak leg for agents.** CLEVER went from 1/161 to 98.1%, and Aristotle resolves 96.8% of
   VERINA. It is still the weak leg for one-shot writing and on AlgoVeri (7.8% direct). In t, Lean carries 10 of
   the 21 AlgoVeri contracts and verifies none, and it co-blocks 20 of them.
5. **Defective specs are common, and nobody grades them by cross-kernel refutation.** LeetProof finds 8.5% of
   VERINA's and 11.2% of CLEVER's specs defective, Vericoding about 9% too weak, and Aristotle 23 false VERINA
   statements.
6. **Agents bypass weak checks.** In 49,280 SPARK obligations, agents used `pragma Assume`, then `SPARK_Mode => Off`.
   An unstaged agent plus a verifier "proves 98% of both the correct and the known-buggy programs". This is the
   failure t's no-assume rules and its twin exist to stop.
7. **Competitors lead** on scale and real code (500 real issues, 849 Verus tasks, 12,504 specs), language reach
   (heaps, Rust), agentic proof search, foundational trust (a verified Dafny VCG in HOL4), and shipping code.

## 3. Corrections to the 10-06 note

- "None pairs each proof with a refuted mutant": SWE-Proof does, on three backends (item 1 above).
- "No system targets more than three verifiers": true only for aligned tasks; VerifyThisBench uses seven.
- "Lean is the weak leg on every multi-verifier benchmark": true for one-shot writing, not for agents.
- AxDafny "paper only": its paper names a repository that returned 404 on 2026-10-07.

The engine's README states none of the four, so it needs no change. Its "seven independent proof systems" wording
is corrected by item 3.

## 4. Decisions, in order

Each is its own registration, measured before it is claimed.

1. **D6, a common-mode audit (low effort). DONE for SPARK, Frama-C and Dafny (T22's read); Lean's independent re-check is still owed.** Re-run the SMT-backed legs under a second solver: SPARK under its
   bundled CVC5 and Alt-Ergo (the adapter pins Z3), Dafny through Boogie's CVC5, and Frama-C's WP under Z3 or
   CVC5 through Why3. Replay the Lean cells through an independent checker. Rocq's cells are already re-checked
   by `coqchk`. The table this produces is agreement under solver change, which answers item 3 with a measurement
   instead of wording. Verus and F* run on Z3 alone and are reported as such.
2. **D7, Lean loops through `mvcgen` (a one-task probe first).** Lean co-blocks 20 of 21 AlgoVeri contracts, and
   `t/lower_lean.py` drives every loop proof through `grind` alone. Lean's own tutorial pairs `mvcgen` (loop
   invariants supplied, which t's loops always carry) with `grind` for the rest. Bar for the probe:
   `integer_exponential`, the AlgoVeri task Lean alone keeps from six-kernel agreement, verifies with the twin
   refuted.
3. **The near misses on the 88 (low effort each).** Three tasks are one kernel short of all seven: `palindrome`
   (Frama-C: a `rev` local needs a workspace buffer; the patch is written and shelved), `odd_positions` (Lean: an
   index sum `grind` does not reorder) and `swap_rows` (Frama-C: a nested-seq return). `double_all` is a Frama-C
   timeout. With `largest` (T21), these are the cheapest all-seven gains left.
4. **G9, datatypes with fields (high effort, high value).** Records and non-recursive sums first, then recursive
   ones. 37 of AlgoVeri's 55 unstated contracts need them. The v1 AST already carries `ctor` arguments and `match`
   binders, and `check_wf`'s `ctor-fields-not-v1` rule is the gate to lift. Waves: Dafny, Verus, Lean; then Rocq,
   F*; then SPARK, Frama-C; then recursion.
5. **D8, a twin audit of public benchmark specs (medium-high effort, the most distinctive result available).**
   Lift what t can state from Vericoding's Dafny sources (which include VERINA, CLEVER and DafnyBench). For each
   spec, publish whether its twins are refuted in every kernel: a kernel-checked weak-spec count. No published
   work grades spec strength this way, and the defect rates above say there is something to find.
6. **D9, DafnyComp's chained programs (medium).** Lift 30 of the 300. Models fall from over 58% to 3.69% verified
   when functions compose, and t's methods, lemmas and per-function twins give a compositional agreement table.
7. **Proposed, not started: a model writing t against AlgoVeri's per-language baselines.** This is the real test
   of "write once, verify seven", and the twin would replace the LLM judge that cost direct Dafny about 15
   points. It needs a model budget and the operator's go-ahead: on 2026-10-06 the operator paused assistant,
   training and speed work until t is done.
8. **Later: one foundational column.** Lower to Velvet or Strata Core, so one leg's verification conditions have
   Lean semantics. Both are pre-1.0 with breaking changes announced, so this follows 1-6.

## 5. What this note does not change

The rules: refusal by name, never a weakened spec; a prediction before every run; the twin rule; tables installed
only from a clean clone. The landscape changes what is claimed and what comes first, not how anything is measured.

## 6. Addendum, 2026-10-07 04:04Z: after G9-G12

Measured since this note was written (each registered in `t/PREDICT-2026-10-06-t-expansion.md`, read from a clean
clone):

| measure | 01:20Z | 04:03Z |
|---|---|---|
| committed tasks | 88 | 101 |
| all seven | 48 | 49 |
| per kernel | Dafny 88, Verus 80, Rocq 62, Lean 61, F* 59, SPARK 56, Frama-C 49 | Dafny 101, Verus 93, Lean 74, Rocq 63, F* 60, SPARK 57, Frama-C 50 |
| AlgoVeri programs | 21 | 27 (the table of 22 installed by T24; 27 registered in T27) |
| solver independence | worded ("four engines") | measured (T22): no verified real refuted under a second solver, over 298 cells |

**What landed:**
- **G9:** datatypes with fields (records, options).
- **G10:** recursive datatypes (trees).
- **G11:** quantifiers over a set's or a seq's elements. The seq form is desugared to indices, so all seven kernels
  state it.
- **G12:** AlgoVeri's BST family begins, from search and insert to the three rotations.

Each was registered with hand probes, and each left every earlier lowering byte for byte unchanged. Datatypes and
set ranges are stated in Dafny, Verus and Lean (sets: Dafny and Verus). The other four refuse them by name.

**What the landscape says now.** Item 4 of section 2 still stands: Lean is strong for agents and weak in t, and t's
Lean column verifies none of AlgoVeri's programs. That is now the largest single gap on the outside benchmark: 0 of
27, against Dafny's 27 and Verus's 9 registered. The BST family cannot reach Lean at all until Lean carries finite
sets. Core Lean has no finite-set type without Mathlib, which this column does not import.

**Decisions, in order:**
1. **Read T27:** the matrix of 101 unchanged, and the AlgoVeri table of 27.
2. **Lean on AlgoVeri.** D7 (`mvcgen` for loops) as its one-task probe, then finite sets in Lean, as a list with set
   semantics plus the lemmas grind needs. That unlocks the set tasks and the BST family there.
3. **Verus's `res.val` shape.** The three rotations are blocked in Verus only by a definedness obligation that
   Dafny's extensional set equality discharges. An extensional `=~=` bridge in the well-definedness lemma is the
   candidate, measured first.
4. **The BST family's rest:** delete, which needs min-extraction helpers, splay and lca, the last restated over
   `view(root)`.
5. **Datatypes in Rocq and F*:** 13 committed datatype tasks move two columns, and F* has a set library.
6. **D8**, the twin audit of public benchmark specs, stays the most distinctive result. It needs the lifter pointed
   at Vericoding's Dafny sources.

## 7. Addendum, 2026-10-07 07:05Z: datatypes in all seven, and what it leaves

**Measured since section 6:**

| | section 6 (T27) | now |
|---|---|---|
| matrix tasks | 101 | 104 |
| proved with the twin refuted in all seven | 49 | 57 (clean27's matrix; its AlgoVeri half re-run) |
| kernels carrying datatypes | 3 (Dafny, Verus, Lean) | 7 (Rocq, F*, SPARK, Frama-C since T34-T37) |
| AlgoVeri all seven | 0 | 1 (integer_exponential, T28) |

**What landed:**
- **Lean:**
  - finite sets on core Std's `ExtTreeSet` (T29) and set-ranged quantifiers (T30);
  - the sign bridge for a product inside a lemma's definitions (T28);
  - a map's element at a Nat index (T32).
- **Frama-C:** seq locals as caller-provided buffers, and `rev` (T31).
- **Rocq:** one orientation for a seq equality (T33).
- **Datatypes:**
  - Rocq: `Inductive`, structural `Fixpoint`s proved by induction (T34);
  - F*: inductive types, refined field reads, `decreases` by subterm (T35);
  - SPARK: discriminated records (T36);
  - Frama-C: tagged structs by value (T37).
- **Three tasks:** rev_equal, doubled_head and set_first.

**What the landscape says now.** Decision 5 of section 6 is done and went further. Every kernel now carries
non-recursive datatypes, and four of the 12 datatype tasks are verified/refuted in all seven. The rest are short of
all seven on two named shapes:
- **Recursive datatypes** in SPARK and Frama-C (pointers);
- **Seq fields** (bag_size, checked_tail) everywhere but Dafny, Verus and Lean.

The largest outside gap is unchanged in kind. AlgoVeri's BST family stops at the set-ranged quantifier in Rocq, F*,
SPARK and Frama-C, and at the proofs in Lean.

**Decisions, in order:**
1. **Read T35-T38 from clean-clone runs with nothing beside them.**
   - clean26 showed a kernel timeout under concurrent load.
   - clean27's AlgoVeri half was OOM-killed at 8 GB, so that half now runs alone at 2 jobs under 11 GB.
2. **More of AlgoVeri, now that every kernel carries datatypes** (T38 begins it: the left-leaning red-black tree's
   rotations and colour flip).
   - Next: `llrbt_insert` and `llrbt_delete`, then the BST rest. `bst_delete` needs a `remove_min` method, since the
     contract's `v >= 0` does not hold of a subtree's minimum. Then `lca`.
   - Segment trees need a map view.
   - Tries need a sequence of datatypes, which t's sequences do not hold yet: a named language gap.
3. **The four single-kernel near misses:**
   - odd_positions in Lean (T39, flat slice reads in comprehension bodies);
   - swap_rows, grid_row_sums and double_all in Frama-C.
4. **Set-ranged quantifiers in Rocq and F*.** Both carry sets and now datatypes, so all_pos_set and the
   BST/red-black statements could lower there.
5. **Seq fields in datatypes:** bag_size and checked_tail, everywhere but Dafny, Verus and Lean. Datatype returns
   and locals in Frama-C.
6. **The standing items:**
   - Verus's `res.val` hint;
   - D7 (`mvcgen`);
   - D8, the twin audit of public specs, still the most distinctive result. The lifting infrastructure (dawnr's
     `lift_*.py`, `run_par.py`, the DafnyBench and Vericoding coverage reports) is in place.

**D8 scoping, measured at 07:33Z (no kernels).** The twin ladder alone was run over dawnr's 326 lifted DafnyBench and
Clover tasks (the lab-rescue copy), 20 s each:

| ladder outcome | tasks |
|---|---|
| a mutant whose behaviour the spec falsifies at a measured witness | 317 |
| `requires` unsatisfiable in the bounded domain | 4 |
| no witness | 1 |
| no operator | 1 |
| timeout | 3 |

The one "no witness" case, UpWhileNotEqual (`ensures i == n`), is a strong spec: its mutants either agree or fail to
terminate, and the ladder does not count non-termination as a witness. So "no witness" is not a weak-spec signal;
kernel-checked "decorative" cells are the measure. The 785-lift table already shows them where the source's own
contract is `ensures true` (abs and max in dafny-training's session1).

A D8 result worth publishing therefore needs two things:
- wider lifting: more of the 785, and Vericoding's Dafny sources;
- the kernels' verdicts, not the ladder's.

That is a lab-scale run, not a desktop one.

## 8. Zoom out, 2026-10-07 18:30Z: after the heap, the audit and the container

**Where the engine stands (measured, clean clones).**
- Seven kernels over 114 tasks: 65 in all seven; every proved program's twin is refuted in six kernels.
- The language has a heap (all seven), parallel loops, and IEEE doubles (SPARK, Frama-C).
- The autonomy suite: 14 of 25 in all seven.
- The specification audit (D8):
  - 72 kernel-proved specification gaps across five public benchmarks;
  - none in ACSL by Example or vericoding's Lean track;
  - none left in t's own task suite.
- The container builds on a fresh machine with all seven kernels.

**What the landscape says now** (sections 2, 6 and 7, and this round's reading, receipts 0139ee2dd35d, ceb1bc69583b,
dc2c168fbaca):
1. **Measuring weak specs is crowded:**
   - by mutants: MutDafny, SpecSyn, SWE-Proof's mutation-kill;
   - by hand or LLM-as-judge: vericoding, LeetProof, Aristotle;
   - by behavioural adequacy: Spec-Harness, POSTCONDBENCH, NL2Contract.

   D8 already beats them where they stop: equivalent mutants are set aside by execution, and each survivor is
   proved. But a better measurement is a small step.
2. **Nobody repairs a spec with a proof.**
   - SpecFuzzer and Daikon infer assertions that pass tests; nothing is verified.
   - LLM contract inference (NL2Contract, SpecGen, AutoSpec) is checked by a verifier for consistency, never for
     killing the wrong programs a weak spec lets through.
   - The vericoding paper keeps weak specs deliberately, as "different tasks".

   A repaired spec that is (a) proved for the real program in a kernel, (b) shown to kill every mutant the old one
   let through, and (c) proved with whatever loop invariants it needs, does not exist in the landscape.
3. **Competitors still lead on scale and shipping** (section 2, item 7):
   - VERINA, CLEVER and VerusBench are not yet lifted;
   - no competitor ships proved executable code from one source to several languages, and t has three executable
     lowerings already (C through Frama-C, Ada through SPARK, Rust through Verus).

**Decisions, in order (the programme after T60):**
1. **R1, `t repair`: proved specification repair.**
   - For each survivor the audit measures, candidate clauses come from a grammar over the task's own vocabulary:
     - result-to-parameter equalities and disjunctions;
     - membership in a sequence parameter;
     - the converse of a subset-only postcondition, built from the spec's own predicates;
     - length relations;
     - extremal quantifier templates;
     - equality to a spec function the task already defines.
   - The interpreter keeps the clauses that hold for the real program on the whole domain, and a greedy cover picks
     the fewest that kill every survivor.
   - The repaired task is re-audited (zero survivors) and proved in the kernel.
   - Where the old loop invariants cannot carry the stronger postcondition, R1b strengthens them from the same
     grammar over the loop-head states the interpreter observes, each candidate kept only if it holds at every
     observed state, the kernel then proving them.
2. **R2:** apply R1 to the 72 benchmark gaps and publish the repairs as upstream-ready patches (filing stays the
   operator's call).
3. **R3:** lift VERINA and CLEVER (Lean) and VerusBench (Verus), and audit them, so D8 covers the benchmarks the agent
   race is measured on.
4. **R4, `t build`:** the executable lowerings as a library: proved C, Ada and Rust for a routine, each compiled and
   checked against the interpreter on the domain. "Prove it everywhere it ships" becomes literal.
5. **Kernel gaps named in reads:**
   - Rocq's induction over changing parameters;
   - Lean's structurally recursive tasks with `requires`;
   - ring-buffer `mod` in Verus, Lean, Rocq and F*;
   - Frama-C's frame fact for recursive logic functions.

**State of the programme, 2026-10-07 19:40Z** (each measured from a clean clone, PREDICT T61-T65):

| item | what landed | measured |
|---|---|---|
| R1 + R2 | `cli.py repair`: grammar + Daikon-style fits, survivor cover, R1b loop invariants, kernel proof, source patches | 25 of 72 benchmark gaps repaired with a proof; 21 input-blind vericoding solutions found |
| R4 | `cli.py build`: proven C (gcc) and Dafny (Python) executables against the interpreter | 9,961 runs, no lowering bug; every C disagreement is int width |
| R4b | `cli.py ship`: the C proved again at machine width (WP Typed + RTE), with a proved operating envelope | 61 routines for every int32 input, 12 within an envelope |
| R4c | loop bounds inferred from observed states, pruned by Houdini, for the width proof | 63 for every int32 input |
| R5 | Frama-C's frame gap closed by reading read-only inputs at `Pre` | filter_pos back in all seven (clean40 reading) |
| R3 | not started: needs dawnr's Lean and Verus lifters to cover more than 66 of vericoding's 2,334 Verus specs | |

Next, in order: the Rocq and Lean recursion items of R5, which restore tree_insert in both; the ring-buffer `mod`;
then R3's lifters.
