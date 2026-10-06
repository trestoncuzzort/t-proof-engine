# Working in this repository

`README.md` is the public summary. `t/SPEC.md` is the language of record and `t/SYNTAX.md` is its grammar.
`t/AGREEMENT.md` is the matrix every claim about a kernel is read from. The registrations and reads of the
current programme are in `t/PREDICT-2026-10-06-t-expansion.md`, and the landscape that set its order is in
`internal/RESEARCH-2026-10-06-landscape.md`.

## The rules that matter

1. **Measure before you claim.** Every number traces to a command that produced it. Before asserting something,
   run the thing that would falsify it.
2. **An honest refusal beats a false verdict.** When a lowering cannot express a construct, the kernel refuses it
   by name ("... is not lowered yet (SPEC.md '<section>')").
   - Never weaken a specification or drop an invariant.
   - Never let a tactic succeed without closing its goal, and never emit an axiom. Lean's audit admits only
     `propext`, `Classical.choice` and `Quot.sound`; ACSL gets no `axiom`; Frama-C's recursive logic
     definitions each carry their own termination lemma.
   - Both rules were learned the hard way. Lean once left goals for `sorryAx` to discharge, and Frama-C once
     emitted a false invariant of its own.
3. **The twin rule is the claim.** A cell counts only as `verified / refuted`: the real program proved, and the
   twin refuted by a certificate the kernel accepts at a measured witness. An exit code alone never counts. A real
   proved with a twin that is not refuted is decorative or unsound, never agreement.
4. **Write the prediction before the run.** A change registers what it expects in a `PREDICT-*.md` file before it
   runs: the bars, and what would falsify the design. After the run, the read says which bars held and which
   missed, plainly.
5. **Look for it before you write it.** Check this repository's own record (`internal/`, `t/PREDICT-*.md`,
   `t/SPEC.md`) and then published work before writing code. The `commit-msg` hook in `.githooks/` refuses a
   commit that changes Python and cites neither a source nor `INVENTED:` (install it with
   `cp .githooks/commit-msg .git/hooks/`).
6. **No assistant attribution anywhere.** That covers commits, docs and comments. Commit messages say what was
   measured and why, in plain prose.
7. **This repository is public.** No personal or institutional identifiers: no home directories naming an
   account, no hostnames, no credentials.

## How a change lands

1. Register it in the PREDICT file.
2. Write the lowering and its text-level tests (`t/test_*.py`).
3. Re-run that kernel's whole column, so a cell that moved without being named shows up:

       T_MIN_KERNELS=1 python3 t/cli.py verify t/tasks --kernels lean --jobs 2 --table /tmp/lean-col.md

4. Write the read and commit.
5. Install `t/AGREEMENT.md` only from a matrix run on a clean clone. The table it writes already carries the
   sole-blocker and per-kernel sections:

       python3 t/cli.py verify t/tasks --jobs 3 --table t/AGREEMENT.md

   The README's numbers follow the installed table, never a column re-run.

Kernels need their PATH, or a kernel reads ABSENT or MALFORMED for every cell. With the install layout in
`t/RUN-ON-LINUX.md`:

    export PATH="$HOME/.cargo/bin:$HOME/.opam/default/bin:$HOME/.elan/bin:$HOME/.local/fstar/fstar/bin:$HOME/.local/gnatprove/gnatprove-x86_64-linux-16.1.0-1/bin:$HOME/.local/verus/verus-x86-linux:$HOME/.local/dafny:$PATH"

A full matrix runs seven kernels at once. Cap its memory (for example, a `systemd-run --user -p MemoryMax=8G`
unit) on a machine that is also used for other work.

## Who consumes the engine

[dawnr](https://github.com/trestoncuzzort/dawnr) carries a pinned copy of this engine under its `t/` directory,
with the commit it came from recorded in `t/ENGINE.md` there. Engine changes land here first, and dawnr syncs
afterwards. A change that would alter what dawnr's pipeline reads (the task format, the verdict words, the table
format) says so in its commit message.
