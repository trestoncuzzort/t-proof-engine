#!/usr/bin/env python3
"""t/flight/px4_diff.py: PX4's own code against its t transcription, on every domain point.

Each task in this directory restates one PX4 function (README.md names the file, line and instantiation). This harness
fetches PX4's headers at the pinned commit, compiles PX4's own function in a C++ program that calls it on every input
in the task's bounded domain (at most POINTS), and compares each result with t's interpreter running the t task. A
match says the t program computes what PX4 computes there, so what the kernels prove about the t program is about
PX4's function on those inputs. A mismatch is reported with its input.

Integer templates are instantiated at int64_t (the domain reaches beyond int32). The float ones are instantiated at
double, t's binary64; PX4 flies most of them at float. The slew-rate and alpha-filter wrappers pass `dt` and `alpha`
through `float`, as PX4's own signatures do. The specialised `negate<int16_t>` is called at int16_t. Built with
`-ffp-contract=off`, so each double operation rounds once, as t's semantics says.

  python3 t/flight/px4_diff.py [--table PX4-DIFF.md]
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))

import harness  # noqa: E402
import interp  # noqa: E402
import tasks_io  # noqa: E402

PX4_COMMIT = "dd804e4b9c490aed051bb36f8d3fca1ee137be2a"
POINTS = 400
CACHE = HERE.parent / "out" / "px4" / PX4_COMMIT
HEADERS = ["src/lib/mathlib/mathlib.h", "src/lib/mathlib/math/Functions.hpp", "src/lib/mathlib/math/Limits.hpp",
           "src/lib/mathlib/math/SearchMin.hpp", "src/lib/mathlib/math/TrajMath.hpp",
           "src/lib/mathlib/math/Utilities.hpp", "src/lib/mathlib/math/filter/AlphaFilter.hpp",
           "src/lib/slew_rate/SlewRate.hpp"]
MATRIX = ["AxisAngle", "Dcm", "Dcm2", "Dual", "Euler", "LeastSquaresSolver", "Matrix", "PseudoInverse", "Quaternion",
          "Scalar", "Slice", "SparseVector", "SquareMatrix", "Vector", "Vector2", "Vector3", "Vector4", "filter",
          "helper_functions", "integration", "math"]
STUB = ("// Stand-in for PX4's platform header: only the names the math headers use.\n#pragma once\n#include <cmath>\n"
        "#define PX4_ISFINITE(x) std::isfinite(x)\n#define M_TWOPI_F 6.28318530717958647692f\n")

# task -> (C++ expression calling PX4 on the parameters, result kind)
CALLS = {
    "px4_constrain": ("math::constrain<int64_t>(val, min_val, max_val)", "int"),
    "px4_min": ("math::min<int64_t>(a, b)", "int"),
    "px4_max": ("math::max<int64_t>(a, b)", "int"),
    "px4_min3": ("math::min<int64_t>(a, b, c)", "int"),
    "px4_max3": ("math::max<int64_t>(a, b, c)", "int"),
    "px4_is_in_range": ("math::isInRange<int64_t>(val, min_val, max_val)", "bool"),
    "px4_sign_no_zero": ("math::signNoZero<int64_t>(val)", "int"),
    "px4_sign": ("matrix::sign<int64_t>(val)", "int"),
    "px4_sign_from_bool": ("math::signFromBool(positive)", "int"),
    "px4_sq": ("math::sq<int64_t>(val)", "int"),
    "px4_negate_i16": ("math::negate<int16_t>((int16_t)value)", "int"),
    "px4_wrap_int": ("matrix::wrap<int64_t>(x, low, high)", "int"),
    "px4_constrain_f": ("math::constrain<double>(val, min_val, max_val)", "float"),
    "px4_lerp": ("math::lerp<double>(a, b, s)", "float"),
    "px4_interpolate": ("math::interpolate<double>(value, x_low, x_high, y_low, y_high)", "float"),
    "px4_slew_update": ("[&]{ SlewRate<double> sr(value); sr.setSlewRate(slew_rate); "
                        "return sr.update(new_value, (float)dt); }()", "float"),
    "px4_alpha_update": ("[&]{ AlphaFilter<double> f; f.setAlpha((float)alpha); f.reset(state); "
                         "return f.update(sample); }()", "float"),
}
# parameters PX4's own signature narrows to binary32 (`float`) before use, though the template is at double
NARROWED = {"px4_alpha_update": ["alpha"], "px4_slew_update": ["dt"]}

NOT_DIFFED = {"px4_interp_index": "the index is internal to interpolateNXY, which returns only the interpolated value"}


def fetch_px4() -> Path:
    """PX4's headers at the pinned commit, cached; the platform header replaced by STUB."""
    root = CACHE
    files = HEADERS + [f"src/lib/matrix/matrix/{m}.hpp" for m in MATRIX] + ["LICENSE"]
    for f in files:
        dst = root / f
        if not dst.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            url = f"https://raw.githubusercontent.com/PX4/PX4-Autopilot/{PX4_COMMIT}/{f}"
            with urllib.request.urlopen(url, timeout=60) as r:
                dst.write_bytes(r.read())
    stub = root / "stub" / "px4_platform_common" / "defines.h"
    stub.parent.mkdir(parents=True, exist_ok=True)
    stub.write_text(STUB)
    return root


def _cpp_lit(v, ty) -> str:
    if ty == "bool":
        return "true" if v else "false"
    if ty == "float":
        return f"{float(v).hex()}"
    return f"INT64_C({int(v)})"


def program(task: dict, ref) -> tuple[str, list, list]:
    expr, kind = CALLS[task["name"]]
    pts = ref.points[:POINTS]
    lines, expect, inputs = [], [], []
    for env0, real in pts:
        decl = " ".join(f"{'double' if p['type'] == 'float' else ('bool' if p['type'] == 'bool' else 'int64_t')} "
                        f"{p['name']} = {_cpp_lit(env0[p['name']], p['type'])};" for p in task["params"])
        if kind == "float":
            show = f'printf("%a\\n", (double)({expr}));'
            expect.append(float(real).hex())
        else:
            show = f'printf("%lld\\n", (long long)({expr}));'
            expect.append(str(int(real)))
        lines.append(f"  {{ {decl} {show} }}")
        inputs.append({k: interp._j(v) for k, v in env0.items()})
    src = ("#include <cinttypes>\n#include <cstdio>\n#include <mathlib/mathlib.h>\n#include <matrix/math.hpp>\n"
           "#include <slew_rate/SlewRate.hpp>\n#include <mathlib/math/filter/AlphaFilter.hpp>\n"
           "int main() {\n" + "\n".join(lines) + "\n  return 0;\n}\n")
    return src, expect, inputs


def diff_task(path: Path, px4: Path) -> dict:
    task = tasks_io.load_task(str(path))
    name = task["name"]
    if name in NOT_DIFFED:
        return {"name": name, "status": f"not diffed: {NOT_DIFFED[name]}"}
    harness._set_ctx(task)
    ref = interp.Reference(task)
    src, expect, inputs = program(task, ref)
    with tempfile.TemporaryDirectory(prefix="t-px4-") as d:
        cpp, exe = Path(d) / "p.cpp", Path(d) / "p"
        cpp.write_text(src)
        p = subprocess.run(["g++", "-std=c++17", "-O1", "-ffp-contract=off", "-w", f"-I{px4}/src/lib",
                            f"-I{px4}/src/lib/matrix", f"-I{px4}/stub", str(cpp), "-o", str(exe)],
                           capture_output=True, text=True, timeout=300)
        if p.returncode != 0:
            return {"name": name, "status": "compile error: " + (p.stderr.strip().splitlines() or ["?"])[0][:200]}
        out = subprocess.run([str(exe)], capture_output=True, text=True, timeout=60).stdout.splitlines()
    norm = (lambda s: float.fromhex(s).hex()) if CALLS[name][1] == "float" else (lambda s: s.strip())
    got = [norm(x) for x in out]
    bad = [i for i, (e, g) in enumerate(zip(expect, got)) if e != g]
    res = {"name": name, "points": len(expect), "px4_call": CALLS[name][0]}
    if bad and len(got) == len(expect) and task["name"] in NARROWED:
        # every difference explained by PX4's float narrowing: rerun t's interpreter with those parameters rounded to
        # binary32 (as PX4's signature does) at each differing point
        import struct
        funs = interp.funs_of(task, task["body"])
        explained = 0
        for i in bad:
            env0 = dict(ref.points[i][0])
            for n in NARROWED[task["name"]]:
                env0[n] = struct.unpack("f", struct.pack("f", env0[n]))[0]
            env = ref._start(env0)
            interp.exec_body(task["body"], env, funs, interp.St())
            if float(env[ref.ret]).hex() == got[i]:
                explained += 1
        if explained == len(bad):
            res.update(status=f"agrees once PX4's float narrowing of {', '.join(NARROWED[task['name']])} is applied",
                       narrowed_points=len(bad))
            return res
    if len(got) != len(expect) or bad:
        i = bad[0] if bad else len(got)
        res.update(status="DIFFERS", first={"input": inputs[i] if i < len(inputs) else None,
                                             "t": expect[i] if i < len(expect) else None,
                                             "px4": got[i] if i < len(got) else None}, differing=len(bad))
    else:
        res["status"] = "agrees"
    return res


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="px4_diff.py", description=__doc__.split("\n\n")[0])
    ap.add_argument("--table", metavar="PATH")
    args = ap.parse_args(argv)
    px4 = fetch_px4()
    results = [diff_task(p, px4) for p in sorted(HERE.glob("*.t"))]
    for r in results:
        print(f"{r['name']}: {r['status']}" + (f" ({r['points']} points)" if r.get("points") else "")
              + (f" first: {json.dumps(r['first'])}" if r.get("first") else ""))
    if args.table:
        agree = [r for r in results if r["status"] == "agrees"]
        lines = ["# PX4's code against its t transcription", "",
                 f"PX4-Autopilot at {PX4_COMMIT}: each routine's own C++ (the call below) compiled and run on every "
                 f"domain point of its t task (at most {POINTS}), each result compared with t's interpreter "
                 "(t/flight/px4_diff.py).", "",
                 f"- routines compared: {sum(1 for r in results if r.get('points'))}; agree on every point: "
                 f"{len(agree)}; points: {sum(r.get('points', 0) for r in results)}", "",
                 "| t task | PX4 call | status | points | first difference |", "|---|---|---|---|---|"]
        for r in results:
            lines.append(f"| {r['name']} | `{r.get('px4_call', '')}` | {r['status']} | {r.get('points', '')} | "
                         f"{json.dumps(r['first']) if r.get('first') else ''} |")
        Path(args.table).write_text("\n".join(lines) + "\n")
    return 1 if any(r["status"] == "DIFFERS" for r in results) else 0


if __name__ == "__main__":
    sys.exit(main())
