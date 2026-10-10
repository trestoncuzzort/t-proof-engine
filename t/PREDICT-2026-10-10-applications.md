# T74: applications beyond the UVa batch

Registered 2026-10-10 before application runs. Base: 9422625. The request is to
apply t to useful mathematical and repository problems. This machine has Dafny
4.11.0 and Lean 4.33.1; the other five columns are not claimed.

## Prior work and scope

Read ENGINE.md, SPEC.md, SYNTAX.md, T73 and the research landscape before writing.
The existing suites already cover sums, Fibonacci, gcd, basic search, full-array
reversal and PX4. This batch adds independent contracts and executable comparisons
for more arithmetic, binary search boundaries, prefix scans, indexing and data
batching. Reuse the existing lowerings, twin ladder and certificate adapters.

Sources: Python's [bisect contracts](https://docs.python.org/3/library/bisect.html),
[itertools](https://docs.python.org/3/library/itertools.html),
[importlib](https://docs.python.org/3/library/importlib.html#importing-a-source-file-directly),
NumPy's [unequal partition rule](https://numpy.org/doc/stable/reference/generated/numpy.array_split.html),
[Dafny induction](https://dafny.org/dafny/OnlineTutorial/Lemmas.html), and
locallm at e81b5e456c5f1da6de2f70f7954dbc3de283e795 (`train_factorial.py`,
`token_shards.py`). Mathematical integer contracts do not prove machine arithmetic
or floating-point sampling. A restatement of repository arithmetic does not prove
the surrounding repository.

## Predictions and falsifiers

1. Attempt at least 32 distinct application tasks. Each remains in the report,
   including refusals and timeouts. At least 25 will be verified / refuted in
   Dafny, at least 12 in both Dafny and Lean. A proof alone never counts.
2. Compile each application's Dafny lowering and compare it with an independently
   written Python oracle on boundary, exhaustive small and seeded larger inputs.
   Zero disagreements is the bar. These comparisons are finite tests, not proofs.
3. Probe `judge.compile_task` twice in one process, including two different bodies
   with the same task name. Prediction: the import cache reuses the first module.
   Repair only after a failing regression; both callables must remain independent.
4. Probe locallm's actual batch generator with fewer examples than batch_size.
   Prediction: it yields no batch, while main retries epochs without advancing
   step. State its actual epoch-count expression in t and refute it at n=1,b=2.
   A fix must reject invalid/insufficient batches before model construction, keep
   full batches and deterministic order unchanged, and have a regression witness.
5. Save a reproducible runner, source identities, partial kernel table and test
   results. Re-run the application matrix from a clean local clone. Preserve the
   established seven-kernel tables and their README totals.

The 32 planned tasks: sum_squares, sum_odds, arithmetic_series, geometric_series,
integer_sqrt, triangular_inverse, choose_two, quotient_remainder, modular_add,
modular_multiply, bisect_left, bisect_right, prefix_sums, argmin_first, run_count,
horner, ceil_div, align_up, batch_bounds, shard_bounds, flatten2, unflatten2,
midpoint, checked_add, buffer_range, saturating_add, window_count, resume_position,
normalize_index, full_batches, range_length, decimal_digits.

## Read

First development pass: Dafny 27/32, Lean 14/32, both 13/32. The uncounted tasks
remain in the suite. The executable run exposed a second judge defect before
comparison: Dafny doubles underscores in Python identifiers. A failing regression
now pins that lookup too. Source: Dafny 4.11.0's PythonCodeGenerator.cs.

The remaining runs and final clean-clone read are pending.

Before a second batch: add eight applications (40 total): extended_gcd,
peasant_multiply, binary_power, max_subarray, count_inversions, leap_year,
interval_intersection and rolling_context. Prediction: at least six count in
Dafny. max_subarray states the standard Kadane recurrence; exhaustive subarray
enumeration tests that modelling step. Sources: the Euclidean invariant in
SPEC.md, [Python calendar](https://docs.python.org/3/library/calendar.html),
and locallm's plain_generate.py context suffix. Existing integer_exponential
uses linear multiplication; binary_power tests a different logarithmic algorithm.
