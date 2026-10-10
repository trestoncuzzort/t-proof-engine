#!/usr/bin/env python3
"""Compare t's contracts with pinned locallm source and installed NumPy.

Only the named functions/expressions are executed. This is finite evidence about
those slices, not verification of training, tensor operations or the repositories.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import random
import subprocess
import sys
import tempfile
from pathlib import Path
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1] / "t"))
import judge
import surface

LOCALLM_BASE = "e81b5e456c5f1da6de2f70f7954dbc3de283e795"


def pinned(repo, path):
    return subprocess.check_output(["git", "-C", str(repo), "show", f"{LOCALLM_BASE}:{path}"], text=True)


def definitions(source, names):
    nodes = [n for n in ast.parse(source).body if isinstance(n, (ast.FunctionDef, ast.ClassDef)) and n.name in names]
    env = {"random": random}
    exec(compile(ast.Module(body=nodes, type_ignores=[]), "<selected-repository-definitions>", "exec"), env)
    return env


def expression(node, env):
    return eval(compile(ast.Expression(body=node), "<repository-expression>", "eval"), env)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--locallm", type=Path, required=True, help="checkout containing the pinned base and the batch fix")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    import numpy as np

    old = pinned(args.locallm, "train_factorial.py")
    fixed = (args.locallm / "train_factorial.py").read_text()
    shards = pinned(args.locallm, "token_shards.py")
    plain = pinned(args.locallm, "plain_generate.py")
    old_env = definitions(old, {"batches"})
    fixed_env = definitions(fixed, {"batches", "batches_per_epoch"})
    concat = definitions(shards, {"_Concat"})["_Concat"]
    main_node = next(n for n in ast.parse(old).body if isinstance(n, ast.FunctionDef) and n.name == "main")
    count_expr = next(n.value for n in ast.walk(main_node) if isinstance(n, ast.Assign)
                      and any(isinstance(t, ast.Name) and t.id == "per_epoch" for t in n.targets))
    batch_node = next(n for n in ast.walk(ast.parse(shards)) if isinstance(n, ast.FunctionDef) and n.name == "get_batch")
    avail_expr = next(n.value for n in ast.walk(batch_node) if isinstance(n, ast.Assign)
                      and isinstance(n.value, ast.ListComp)
                      and any(isinstance(t, ast.Name) and t.id == "avail" for t in n.targets))
    weights_expr = next(n.value.args[0] for n in ast.walk(batch_node) if isinstance(n, ast.Assign)
                        and any(isinstance(t, ast.Name) and t.id == "weights" for t in n.targets))
    produce = next(n for n in ast.walk(ast.parse(plain)) if isinstance(n, ast.FunctionDef) and n.name == "_produce")
    suffix_expr = next(n.iter for n in ast.walk(produce) if isinstance(n, ast.For)
                       and isinstance(n.iter, ast.Subscript) and isinstance(n.iter.value, ast.Name)
                       and n.iter.value.id == "ids")

    counts = {"full_batches": 0, "rejected_empty_epochs": 0, "resume_position": 0,
              "normalize_index": 0, "window_count": 0, "rolling_context": 0, "numpy_shard_bounds": 0}
    with tempfile.TemporaryDirectory(prefix="t-repository-applications-") as tmp:
        calls = {}
        for name in ("full_batches", "resume_position", "normalize_index", "window_count", "rolling_context", "shard_bounds"):
            work = Path(tmp) / name
            work.mkdir()
            calls[name] = judge.compile_task(surface.parse_file(HERE / f"{name}.t"), work)
        for n in range(65):
            examples = list(range(n))
            for b in range(1, 17):
                old_batches = list(old_env["batches"](examples, batch_size=b, seed=7, epoch=3))
                proved_count = calls["full_batches"]((n, b))
                assert proved_count == len(old_batches), (n, b)
                counts["full_batches"] += 1
                claimed = expression(count_expr, {"examples": examples, "args": SimpleNamespace(batch_size=b)})
                if n < b:
                    assert claimed == 1 and proved_count == 0
                    try:
                        list(fixed_env["batches"](examples, batch_size=b, seed=7, epoch=3))
                    except ValueError as exc:
                        assert "full batch" in str(exc)
                        counts["rejected_empty_epochs"] += 1
                    else:
                        raise AssertionError(f"fixed generator accepted n={n}, b={b}")
                else:
                    assert claimed == proved_count == fixed_env["batches_per_epoch"](n, b)
                    assert old_batches == list(fixed_env["batches"](examples, batch_size=b, seed=7, epoch=3))
                    for completed in (0, 1, proved_count-1, proved_count, proved_count+1, 10**20):
                        assert calls["resume_position"]((completed, proved_count)) == list(divmod(completed, proved_count))
                        counts["resume_position"] += 1
        for lengths in ((0,), (1,), (2, 3), (1, 0, 3), (0, 0, 4), (4, 1, 2, 3)):
            parts, total = [], 0
            for length in lengths:
                parts.append(list(range(total, total+length)))
                total += length
            for offset in range(total+1):
                view = concat(parts, offset=offset)
                for i in range(-len(view)-2, len(view)+3):
                    normalized = calls["normalize_index"]((i, len(view)))
                    try:
                        part, j = view._locate(i)
                    except IndexError:
                        assert normalized == -1
                    else:
                        assert normalized >= 0 and part[j] == normalized+offset
                    counts["normalize_index"] += 1
        for n in range(65):
            for block in range(1, 20):
                avail = expression(avail_expr, {"self": SimpleNamespace(train_lengths=[n]), "block_size": block})
                weight = expression(weights_expr, {"avail": avail})[0]
                assert calls["window_count"]((n, block)) == weight
                counts["window_count"] += 1
            for capacity in (1, 2, 8, 32, 64):
                ids = list(range(n))
                actual = expression(suffix_expr, {"ids": ids, "self": SimpleNamespace(block_size=capacity)})
                assert calls["rolling_context"]((ids, capacity)) == actual
                counts["rolling_context"] += 1
            for workers in range(1, 13):
                split = np.array_split(np.arange(n), workers)
                start = 0
                for rank, part in enumerate(split):
                    stop = start + len(part)
                    assert calls["shard_bounds"]((n, workers, rank)) == [start, stop]
                    counts["numpy_shard_bounds"] += 1
                    start = stop
                assert start == n

    sources = {name: hashlib.sha256(text.encode()).hexdigest() for name, text in
               (("original_train_factorial.py", old), ("fixed_train_factorial.py", fixed),
                ("token_shards.py", shards), ("plain_generate.py", plain))}
    result = {"kind": "finite comparisons against repository code, not whole-repository proofs",
              "locallm_base": LOCALLM_BASE, "numpy": np.__version__, "source_sha256": sources,
              "counts": counts, "all_passed": True,
              "original_finding": {"examples": 1, "batch_size": 2, "claimed_batches": 1, "actual_batches": 0}}
    args.json.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
