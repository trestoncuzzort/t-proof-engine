#!/usr/bin/env python3
"""test_flight.py: t/flight/, PX4's functions restated in t. Every task is well-formed, its contract admits no
survivor (t/audit.py), the README names it, and the PX4 harness either calls PX4 for it or says why not. No
network, compiler or kernel."""
from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE / "flight"))

import audit  # noqa: E402
import check_wf  # noqa: E402
import px4_diff  # noqa: E402
import tasks_io  # noqa: E402

TASKS = sorted((HERE / "flight").glob("*.t"))


def test_every_task_is_well_formed_and_audited():
    assert len(TASKS) >= 18
    for p in TASKS:
        task = tasks_io.load_task(str(p))
        assert check_wf.check_wf(task) == [], p
        res = audit.classify(task)
        assert res["status"] == "ok" and not res["survivors"], (p.name, res.get("survivors"))


def test_every_task_is_tied_to_px4():
    readme = (HERE / "flight" / "README.md").read_text()
    for p in TASKS:
        name = tasks_io.load_task(str(p))["name"]
        assert f"| {name} |" in readme, name
        assert (name in px4_diff.CALLS) != (name in px4_diff.NOT_DIFFED), name
