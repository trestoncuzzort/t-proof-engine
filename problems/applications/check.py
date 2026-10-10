#!/usr/bin/env python3
"""Compile every application and compare independent Python answers on finite inputs.

Proofs are a separate `t/cli.py verify` run. This tests the executable lowering,
including boundary inputs outside the twin search domain. Oracles use Python's
math, bisect, itertools and sequence operations, and NumPy's documented unequal
partition rule: https://numpy.org/doc/stable/reference/generated/numpy.array_split.html.
"""
from __future__ import annotations

import argparse
import bisect
import calendar
import hashlib
import itertools
import json
import math
import random
import sys
import tempfile
from fractions import Fraction
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(ROOT / "t"))
import judge
import surface
from check_wf import check_wf


def scenarios():
    rng = random.Random(7410)
    small = list(range(101))
    huge = [2**31 - 1, 2**31, 2**63 - 1, 2**64, 10**100]
    ns = small + huge
    positive = list(range(1, 20)) + [2**31 - 1, 2**63, 10**50]
    seqs = [list(s) for size in range(5) for s in itertools.product((-2, 0, 3), repeat=size)]
    seqs += [[rng.randint(-1000, 1000) for _ in range(rng.randrange(51))] for _ in range(100)]

    yield "sum_squares", [(n,) for n in small], lambda n: sum(k*k for k in range(1, n+1))
    yield "sum_odds", [(n,) for n in small], lambda n: sum(range(1, 2*n, 2))
    yield "arithmetic_series", list(itertools.product(range(31), (-11, 0, 9), (-7, 0, 5))), \
        lambda n, a, d: sum(a + k*d for k in range(n))
    yield "geometric_series", list(itertools.product(range(26), (-3, -1, 0, 1, 2, 7))), \
        lambda n, base: sum(base**k for k in range(n))
    yield "integer_sqrt", [(n,) for n in ns + [k*k+d for k in (11, 100, 2**32, 10**50) for d in (-1, 0, 1)]], math.isqrt
    yield "triangular_inverse", [(n,) for n in ns], lambda n: (math.isqrt(8*n+1)-1)//2
    yield "choose_two", [(n,) for n in small], lambda n: math.comb(n, 2)
    signed = sorted(set(ns + [-n for n in ns]))
    yield "quotient_remainder", list(itertools.product(signed, positive)), lambda n, d: list(divmod(n, d))
    residues = [(a, b, m) for m in range(1, 18) for a in range(m) for b in range(m)]
    residues += [(m-1, m-1, m) for m in huge]
    yield "modular_add", residues, lambda a, b, m: (a+b) % m
    yield "modular_multiply", list(itertools.product((-100, -3, 0, 1, 15, 10**50), range(16), (1, 2, 7, 19))), \
        lambda a, b, m: a*b % m
    search = [(sorted(s), x) for s in seqs for x in (-1001, -2, 0, 1, 3, 1001)]
    yield "bisect_left", search, bisect.bisect_left
    yield "bisect_right", search, bisect.bisect_right
    yield "prefix_sums", [(s,) for s in seqs], lambda s: list(itertools.accumulate(s, initial=0))
    yield "argmin_first", [(s,) for s in seqs if s], lambda s: min(range(len(s)), key=s.__getitem__)
    yield "run_count", [(s,) for s in seqs], lambda s: len(list(itertools.groupby(s)))
    yield "horner", [(s, x) for s in seqs for x in (-3, 0, 1, 2)], \
        lambda s, x: sum(a * x**i for i, a in enumerate(reversed(s)))
    yield "ceil_div", list(itertools.product(signed, positive)), lambda n, d: math.ceil(Fraction(n, d))
    yield "align_up", list(itertools.product(ns, positive)), lambda n, k: math.ceil(Fraction(n, k))*k

    batches = [(n, b, i) for n in range(1, 41) for b in range(1, 10) for i in range(math.ceil(n/b))]
    def batch_bounds(n, b, i):
        chunk = list(itertools.batched(range(n), b))[i]
        return [chunk[0], chunk[-1]+1]
    yield "batch_bounds", batches, batch_bounds

    def shard_bounds(n, workers, rank):
        sizes = [0]*workers
        for index in range(n):
            sizes[index % workers] += 1
        return [sum(sizes[:rank]), sum(sizes[:rank+1])]
    yield "shard_bounds", [(n, w, r) for n in range(61) for w in range(1, 13) for r in range(w)], shard_bounds
    yield "flatten2", [(r, c, rows, cols) for rows in range(1, 9) for cols in range(1, 9)
                       for r in range(rows) for c in range(cols)], \
        lambda r, c, rows, cols: list(itertools.product(range(rows), range(cols))).index((r, c))
    yield "unflatten2", [(i, rows, cols) for rows in range(1, 9) for cols in range(1, 9)
                         for i in range(rows*cols)], \
        lambda i, rows, cols: list(list(itertools.product(range(rows), range(cols)))[i])
    bounds = small + [2**30-1, 2**30, 2**31-2, 2**31-1]
    yield "midpoint", [(lo, hi) for lo in bounds for hi in bounds if lo <= hi], lambda lo, hi: (lo+hi)//2
    limited = [(a, b, limit) for limit in range(16) for a in range(limit+1) for b in range(limit+1)]
    limited += [(a, b, limit) for limit in huge for a in (0, 1, limit-1, limit) for b in (0, 1, limit-1, limit)]
    yield "checked_add", limited, lambda a, b, limit: a+b <= limit
    yield "saturating_add", limited, lambda a, b, limit: min(a+b, limit)
    buf = list(itertools.product(range(16), repeat=3)) + list(itertools.product([0, 1, *huge], repeat=3))
    yield "buffer_range", buf, lambda offset, length, capacity: offset+length <= capacity
    yield "window_count", list(itertools.product(range(61), range(1, 20))), \
        lambda n, block: sum(i+block < n for i in range(n))
    yield "resume_position", list(itertools.product(ns, positive)), lambda n, e: list(divmod(n, e))

    def normalize(i, n):
        try:
            return list(range(n))[i]
        except IndexError:
            return -1
    yield "normalize_index", [(i, n) for n in range(41) for i in range(-n-2, n+3)], normalize
    yield "full_batches", list(itertools.product(range(101), range(1, 33))), \
        lambda n, b: sum(len(chunk) == b for chunk in itertools.batched(range(n), b))
    ranges = list(itertools.product(range(-12, 13, 3), range(-12, 13, 3), range(1, 10)))
    yield "range_length", ranges, lambda start, stop, step: len(range(start, stop, step))
    digits = [(n,) for n in ns if n > 0] + [(10**k+d,) for k in range(1, 101) for d in (-1, 0, 1)]
    yield "decimal_digits", digits, lambda n: len(str(n))

    # Bezout coefficients need not be unique. Compare their defining equation and
    # gcd with an independent library, rather than choose a second Euclid loop.
    yield "extended_gcd", list(itertools.product(range(31), repeat=2)) + [(2**100+1, 2**70+3)], \
        lambda a, b: math.gcd(a, b)
    yield "peasant_multiply", list(itertools.product(signed, ns)), lambda x, y: x*y
    yield "binary_power", list(itertools.product(range(-8, 9), range(41))), pow
    yield "max_subarray", [(s,) for s in seqs if s], \
        lambda s: max(sum(s[i:j]) for i in range(len(s)) for j in range(i+1, len(s)+1))
    yield "count_inversions", [(s,) for s in seqs], \
        lambda s: sum(s[i] > s[j] for i in range(len(s)) for j in range(i+1, len(s)))
    yield "leap_year", [(y,) for y in range(-400, 2401)], calendar.isleap
    intervals = [(a, b, c, d) for a in range(-4, 5) for b in range(a, 6)
                 for c in range(-4, 5) for d in range(c, 6)]
    def intersection(a, b, c, d):
        common = sorted(set(range(a, b)) & set(range(c, d)))
        return [common[0], common[-1]+1] if common else [max(a, c)]*2
    yield "interval_intersection", intervals, intersection
    yield "rolling_context", [(s, c) for s in seqs for c in (1, 2, 3, 8, 50)], lambda s, c: s[-c:]


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--task", help="check just this task")
    parser.add_argument("--json", type=Path, help="write complete counts and first failures")
    args = parser.parse_args()
    if not judge.DAFNY:
        parser.error("Dafny is required; see t/RUN-ON-LINUX.md")
    suites = list(scenarios())
    registered = {name for name, _, _ in suites}
    present = {p.stem for p in HERE.glob("*.t")}
    if registered != present:
        parser.error(f"oracle/task mismatch: missing oracles={present-registered}, missing tasks={registered-present}")
    if args.task and args.task not in registered:
        parser.error(f"unknown task {args.task!r}")
    results = []
    for name, cases, oracle in suites:
        if args.task and name != args.task:
            continue
        row = {"task": name, "cases": len(cases), "passed": 0, "failures": []}
        path = HERE / f"{name}.t"
        row["source_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
        try:
            with tempfile.TemporaryDirectory(prefix="t-application-") as work:
                task = surface.parse_file(path)
                errors = check_wf(task)
                if errors:
                    raise ValueError("; ".join(str(e) for e in errors))
                call = judge.compile_task(task, Path(work))
                for values in cases:
                    want = oracle(*values)
                    got = call(values)
                    ok = got == want
                    if name == "extended_gcd":
                        ok = (isinstance(got, list) and len(got) == 3 and got[0] == want
                              and values[0]*got[1] + values[1]*got[2] == want)
                    if ok:
                        row["passed"] += 1
                    elif len(row["failures"]) < 5:
                        row["failures"].append({"input": values, "got": got, "expected": want})
        except (Exception, SystemExit) as exc:
            # Keep failed tasks in the report; a later task still gets its run.
            row["error"] = str(exc)
        row["status"] = "pass" if row["passed"] == row["cases"] and "error" not in row else "fail"
        results.append(row)
        print(f"{name}: {row['status'].upper()} {row['passed']}/{row['cases']}", flush=True)
    report = {"kind": "finite differential tests, not formal proofs", "seed": 7410,
              "python": sys.version.split()[0], "results": results,
              "passed": sum(r["passed"] for r in results), "cases": sum(r["cases"] for r in results)}
    if args.json:
        args.json.write_text(json.dumps(report, indent=2) + "\n")
    print(f"{report['passed']}/{report['cases']} cases match; {len(results)} tasks")
    return 0 if all(r["status"] == "pass" for r in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
