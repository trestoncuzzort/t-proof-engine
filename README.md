# t-proof-engine

**t** is a small specification language. A task is written once in t: a typed signature, preconditions,
postconditions and a short body. It is then lowered mechanically into **seven proof systems**: Dafny, Verus,
SPARK, Frama-C, Lean 4, Rocq and F\*. t proves nothing itself and is trusted for nothing. Every verdict comes from
a kernel. The seven are independent front ends over four distinct proof engines, not seven independent solvers:
- Z3, behind Dafny (through Boogie), Verus, F*, and SPARK as this engine runs it (`--prover=z3`);
- Alt-Ergo, behind Frama-C's WP;
- the Lean kernel;
- the Rocq kernel, whose compiled proofs `coqchk` re-checks independently.

**Solver change, measured** (PREDICT T22's read, 2026-10-07): the SMT-backed legs were re-run under a second solver.
SPARK ran under CVC5 and Alt-Ergo, Frama-C under Z3 and CVC5, and Dafny under CVC5 through Boogie.
- Over 298 cells that verify under the default solver, no second solver refuted a verified program.
- A second solver re-verifies all 56 of SPARK's counted programs, 86 of Dafny's 88 and 33 of Frama-C's 49. The
  other 16 in Frama-C rest on Alt-Ergo alone.
- Proof strength is solver-specific: under Z3, 31 of the 49 Frama-C programs that Alt-Ergo proves time out.
- Dafny's twin side cannot be measured under CVC5: Boogie's model converter crashes on CVC5's real-valued models.
- Verus and F\* run on Z3 alone.

Each task is also paired with a deliberately broken **twin**, one edit away from the real program, and a concrete
input at which the twin breaks the specification. A kernel's cell counts only when the kernel proves the real
program **and** refutes the twin by accepting a certificate at that input. A specification that cannot tell the two
apart is vacuous and is refused. When a lowering cannot express a construct, that kernel refuses it by name and
never weakens it.

## Where it stands

Measured from a clean clone of this repository on 2026-10-07 over the 114 committed tasks
([t/AGREEMENT.md](t/AGREEMENT.md)):

| kernel | proved, twin refuted | carried, not proved | refused by name |
|---|---|---|---|
| Dafny | 111 | 0 | 3 |
| Verus | 99 | 1 | 14 |
| Rocq | 79 | 0 | 35 |
| Lean 4 | 84 | 2 | 28 |
| F\* | 79 | 2 | 33 |
| SPARK | 73 | 4 | 37 |
| Frama-C | 62 | 1 | 51 |

- In every kernel, the twin of every proved program is refuted (100%).
- 62 of the 114 tasks are proved, with the twin refuted, in all seven kernels.
- Datatypes with fields (records and non-recursive sums, PREDICT T23) and recursive datatypes (trees, T25) are proved
  in Dafny, Verus, Lean, Rocq and F* (T34, T35); SPARK and Frama-C carry the non-recursive ones (T36, T37), so
  color_code, shape_area, manhattan and rect_area are verified with the twin refuted in all seven. A quantifier over a seq's elements is stated in
  all seven, over a set's in Dafny, Verus and Lean (T26, T30). Finite sets are carried in Lean too, on core Std's
  extensional tree set (T29). Frama-C gives a seq local its own caller-provided buffer (T31). A datatype field may be
  a seq in Rocq, F* and SPARK too (T42), and Rocq proves loops over a datatype state (T41). Early exits (`break`,
  `continue`, `while true`) are proved in all seven through one rewrite (T44), F* and SPARK carry filtered
  comprehensions (T45), and Frama-C flattens a datatype with a seq field into parameters (T43).
- Since 2026-10-07 the language has a heap (arrays written in place, `modifies`, `old`; T46), parallel loops whose
  race freedom is checked by rule (T47) and IEEE floats (T48). Dafny proves the seven heap and parallel tasks, SPARK
  the float tasks on `Long_Float` (T49). The direction they serve is in [NORTH-STAR.md](NORTH-STAR.md).
- Most refusals are of constructs added to the language on 2026-10-06, which the other kernels are being taught
  now.
- [t/ALGOVERI.md](t/ALGOVERI.md): 30 of AlgoVeri's contracts in seven kernels, regenerated from a clean clone for
  T38: five of the BST family and three of the left-leaning red-black tree's, over recursive datatypes and
  set-ranged quantifiers. Dafny verifies all 30 with the twin refuted; Verus 9, F* 5, SPARK 4, Frama-C 2, Rocq 1,
  Lean 1. integer_exponential is the first AlgoVeri
  contract verified with the twin refuted in all seven (T28). T15 and T17 repaired 11 of T13's 13 malformed cells; the
  other two are named in T13's read.

The registrations and reads behind these numbers are in
[t/PREDICT-2026-10-06-t-expansion.md](t/PREDICT-2026-10-06-t-expansion.md). Each change states, before it runs,
the count that would falsify it.

## What the language has

- **Values:** integers, booleans, exact rationals, sequences (literals, concatenation, slices, stepped slices),
  nested sequences, pairs, strings as code-point sequences with a string library, finite sets, maps and datatypes.
- **Code:** loops with invariants and `decreases`, `for` loops, early exits, recursion with termination, methods,
  lemmas, comprehensions and higher-order calls (`fold`, `sort_by`, `max_by`, `min_by`).
- **Library:** `min`, `max`, `abs`, `gcd`, `pow`, `isqrt`, `sum`, `sort` and `rev`, with membership and
  `any`/`all` reductions.
- **Not in the language:** heap, floats and concurrency.

[t/SYNTAX.md](t/SYNTAX.md) gives the grammar with one example per construct. [t/SPEC.md](t/SPEC.md) gives the
semantics and the decisions behind them, and [t/TUTORIAL.md](t/TUTORIAL.md) teaches the language from zero.

## Quick start

The engine is standard-library Python (3.10 or later). Each kernel is installed separately:
[t/RUN-ON-LINUX.md](t/RUN-ON-LINUX.md), [t/RUN-ON-MACOS.md](t/RUN-ON-MACOS.md),
[t/RUN-ON-WINDOWS.md](t/RUN-ON-WINDOWS.md).

    python3 t/cli.py check  t/tasks/clamp.t                  # well-formedness diagnostics
    python3 t/cli.py lower  t/tasks/clamp.t --kernel lean    # the Lean source t lowers to
    python3 t/cli.py twin   t/tasks/clamp.t                  # the twin's operator and witness
    python3 t/cli.py verify t/tasks/clamp.t                  # every kernel that is installed
    python3 t/cli.py verify t/tasks --jobs 3 --table AGREEMENT.md   # the whole matrix

A kernel that is not installed is reported absent, not passed. With fewer than two kernels present, `verify`
refuses to give a verdict (`T_MIN_KERNELS` sets the floor).

Tests use the standard library and pytest. Tests that need a kernel binary skip by name when it is absent:

    cd t && python3 -m pytest -q

## Map

| path | what |
|---|---|
| `t/cli.py` | one command: parse, check, format, lower, verify, twin, explain |
| `t/surface.py`, `t/check_wf.py`, `t/interp.py` | the parser and printer, the well-formedness checker, the reference interpreter |
| `t/lower_*.py`, `t/verifiers/` | the seven lowerings and the adapters that run each kernel and read its verdict |
| `t/harness.py`, `t/run_par.py` | twins, witnesses, certificates, and the parallel matrix runner |
| `t/tasks/`, `t/twins/` | the committed tasks, and 426 real/twin pairs over 213 verified programs |
| `t/malformed/` | programs every checker must reject, each with its expected error |
| `t/lsp.py`, `t/editors/` | a language server and an editor extension |
| `t/AGREEMENT.md`, `t/CONFORMANCE.md` | the matrix of record, and the conformance suite (programs with a known expected verdict, run in every kernel) |
| `internal/RESEARCH-2026-10-06-*.md` | the landscape of related systems, and what it decided |

## Relation to dawnr

[dawnr](https://github.com/trestoncuzzort/dawnr) is an offline assistant that uses t as its proof tool. dawnr
grew this engine under its own `t/` directory, so the engine's history before this repository was split out is
kept here as it was: the commits that touched the engine, filtered from dawnr's history. Engine changes now land
here first. dawnr carries a pinned copy and records which commit of this repository it carries.

## License

[Research Use License](LICENSE). You may use it for research and education without asking. Commercial use needs
written permission first ([NOTICE](NOTICE)). Third-party material keeps its own license. That covers the seven
verifiers, which are not part of this repository, and `t/third_party/codex_seatbelt/` (Apache License 2.0).
