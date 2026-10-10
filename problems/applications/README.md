# Applications: mathematics, algorithms and repository code

**40 tasks proved in Dafny, 18 also in Lean; every counted cell refutes its broken
twin.** Measured from a clean checkout of 9ccd6cc on 2026-10-10, with three repeats
per side and no flaked cell. [The matrix](RESULTS.md) includes all 80 attempted
cells. Lean leaves 22 unproved or timed out. Five other kernels were not run.

The compiled programs pass **82,880 independent oracle cases**, plus **13,562
repository comparisons and rejection checks** against locallm and NumPy. These
finite tests are separate from the proofs. T74's registration and read are in
[`t/PREDICT-2026-10-10-applications.md`](../../t/PREDICT-2026-10-10-applications.md).
The original UVa and seven-kernel engine tables retain their own measured scope.

Receipts: [manifest and source hashes](evidence/manifest.json),
[kernel verdicts](evidence/verdicts.json), [execution](evidence/execution.json),
[repository comparisons](evidence/repositories.json),
[original defect refutation](evidence/locallm-refutation.json), and
[lowered-source hashes](evidence/LOWERINGS.sha256). The engine's judge/build
regressions pass 12 tests. The locallm fix is local commit 3ec301f; its trainer
suite passes 10 tests and 3 subtests.

## What the suite does

| Task | Contract and use |
|---|---|
| [sum_squares](sum_squares.t) | Sum the first n squares; prove the cubic closed form. |
| [sum_odds](sum_odds.t) | Sum the first n odd numbers; prove n squared. |
| [arithmetic_series](arithmetic_series.t) | Signed arithmetic progression; prove its closed form. |
| [geometric_series](geometric_series.t) | Finite geometric sum, including bases 0, 1 and negative integers. |
| [integer_sqrt](integer_sqrt.t) | Binary search for the unique nonnegative integer between consecutive squares. |
| [triangular_inverse](triangular_inverse.t) | Largest triangular number no greater than n; allocation and diagonal indexing. |
| [choose_two](choose_two.t) | Count unordered pairs by adding each new element's partners. |
| [quotient_remainder](quotient_remainder.t) | Euclidean decomposition, including negative numerators. |
| [modular_add](modular_add.t) | Add two residues using a subtraction guard. |
| [modular_multiply](modular_multiply.t) | Repeated residue addition; prove congruence and canonical range. |
| [decimal_digits](decimal_digits.t) | Decimal length characterized by consecutive powers of ten. |
| [extended_gcd](extended_gcd.t) | Euclid's recursive gcd definition plus the Bezout equation, including zero arguments. |
| [peasant_multiply](peasant_multiply.t) | Multiplication by halving and doubling; logarithmic in the nonnegative multiplier. |
| [binary_power](binary_power.t) | Repeated squaring, proved against recursive exponentiation. |
| [bisect_left](bisect_left.t) | First insertion boundary: every earlier value is smaller. |
| [bisect_right](bisect_right.t) | Last insertion boundary: every later value is greater. |
| [prefix_sums](prefix_sums.t) | Exclusive prefix sums; adjacent differences recover the input. |
| [argmin_first](argmin_first.t) | Minimum index with the first occurrence winning ties. |
| [run_count](run_count.t) | Count maximal adjacent runs, including an empty sequence. |
| [horner](horner.t) | Polynomial evaluation by Horner's recurrence. |
| [max_subarray](max_subarray.t) | Kadane's recurrence for a nonempty maximum-sum subarray. |
| [count_inversions](count_inversions.t) | Count index pairs whose values are out of order. |
| [ceil_div](ceil_div.t) | Integer ceiling division characterized by tight inequalities. |
| [align_up](align_up.t) | Least multiple of k at or above n; padding and allocation. |
| [batch_bounds](batch_bounds.t) | A nonempty batch's half-open interval, including a short final batch. |
| [shard_bounds](shard_bounds.t) | Balanced partitions following NumPy's array_split convention. |
| [flatten2](flatten2.t) | Row-major flattening with bounds and inverse-coordinate equations. |
| [unflatten2](unflatten2.t) | Recover row and column; prove the round trip and bounds. |
| [midpoint](midpoint.t) | Midpoint without adding both input bounds; int32 operating envelope stated. |
| [checked_add](checked_add.t) | Decide whether a sum fits using subtraction. |
| [buffer_range](buffer_range.t) | Decide whether a half-open buffer access fits using subtraction. |
| [saturating_add](saturating_add.t) | Addition clamped to a caller-supplied nonnegative limit. |
| [window_count](window_count.t) | Number of block+1 token windows that fit in a shard. |
| [resume_position](resume_position.t) | Epoch and within-epoch offset uniquely reconstruct completed updates. |
| [normalize_index](normalize_index.t) | Python-style negative indices, with -1 representing rejection. |
| [full_batches](full_batches.t) | Number of complete batches; positive exactly when a batch fits. |
| [range_length](range_length.t) | Length of a positive-step half-open range. |
| [leap_year](leap_year.t) | Proleptic Gregorian leap-year predicate, including nonpositive years. |
| [interval_intersection](interval_intersection.t) | Canonical half-open intersection, including disjoint and empty intervals. |
| [rolling_context](rolling_context.t) | Keep a context suffix with exact length and element correspondence. |

## Run the applications

Python 3.12 or newer; Dafny 4.11.0 and Lean 4.33.1 as in
[RUN-ON-LINUX](../../t/RUN-ON-LINUX.md). Point `T_LEAN_BIN` at Lean if it is
outside the documented discovery paths. Commands run from the repository root:

```sh
python3 t/cli.py verify problems/applications --kernels dafny,lean --jobs 2 --flake 3 \
  --out /tmp/t-applications --table /tmp/t-applications.md
python3 problems/applications/check.py --json /tmp/t-application-execution.json
python3 -m unittest discover -s t -p test_judge.py -v
```

The matrix exits 1 when any selected cell fails to count. Read its individual
cells; that exit is not a refutation of every task. `check.py` compiles each
Dafny lowering and compares it with independent math, bisect, calendar and
itertools oracles on small exhaustive, boundary and seeded inputs. It refuses an
oracle/task mismatch and keeps failed tasks in its JSON report. Translation uses
`--no-verify`; this executable comparison does not mint a proof verdict.

## Repository applications

`compare_repositories.py` reads locallm at commit
`e81b5e456c5f1da6de2f70f7954dbc3de283e795` and the checkout's fixed trainer.
It executes the selected original functions or expressions, without importing
training or running a model. It compares batch counts, resume positions, shard
window availability, negative indexing and context suffixes. It also checks all
partition endpoints against the installed NumPy implementation.

```sh
python3 problems/applications/compare_repositories.py --locallm ../locallm \
  --json /tmp/t-repository-comparisons.json
python3 t/refute_at.py problems/applications/findings/locallm_epoch_count.t \
  --at '{"n": 1, "b": 2}' --kernels dafny,lean --json
```

The first command requires NumPy and the batch fix in the locallm checkout.
The second refutes the original epoch-count expression with a kernel-accepted
certificate. With one example and batch size two, the generator produces no
batch but `max(n // b, 1)` claims one. The trainer catches StopIteration,
increments the epoch and retries without incrementing its update counter.
The [patch](findings/locallm-empty-batches.patch) validates positive batch size
and sufficient examples before model construction and on direct generator use.
Valid full batches keep their existing ordering and drop-last behavior.

The application run also repaired two defects in `t/judge.py`: cached imports
could run a previous task's code, and underscored task names did not match
Dafny's Python name escaping. [test_judge.py](../../t/test_judge.py) pins both,
including recursion, sequences and restoration of the caller's import state.

## Scope and sources

The kernels prove t's stated contracts over mathematical integers. Generated
Python, the translator, input/output glue and repository-to-t correspondence are
tested, not proved. No result certifies an entire repository. In particular,
window_count proves integer window availability, not floating-point random
sampling, and the buffer/arithmetic tasks do not establish C overflow semantics.

max_subarray proves the standard Kadane recurrence; its equivalence to a maximum
over all subarrays is tested here by exhaustive enumeration on the chosen inputs,
not proved as a separate theorem. extended_gcd proves its recursive Euclidean
definition and the Bezout equation; executable checks compare the result with
`math.gcd`. Horner, geometric_series, run_count and count_inversions also use
recursive definitions, with independent power-sum, grouping or pair-enumeration
oracles. The catalog names each contract. Runtimes and complexity bounds are not
kernel-checked.

Sources read before implementation: Python's
[bisect](https://docs.python.org/3/library/bisect.html),
[itertools](https://docs.python.org/3/library/itertools.html),
[calendar](https://docs.python.org/3/library/calendar.html),
[importlib](https://docs.python.org/3/library/importlib.html),
NumPy's [array_split](https://numpy.org/doc/stable/reference/generated/numpy.array_split.html),
Dafny's [division lemmas](https://github.com/dafny-lang/dafny/blob/v4.11.0/Source/DafnyStandardLibraries/src/Std/Arithmetic/DivMod.dfy)
and [Python backend](https://github.com/dafny-lang/dafny/blob/v4.11.0/Source/DafnyCore/Backends/Python/PythonCodeGenerator.cs),
the existing [UVa division proof](../uva/p11526.t), and
[locallm](https://github.com/trestoncuzzort/locallm/tree/e81b5e456c5f1da6de2f70f7954dbc3de283e795).
