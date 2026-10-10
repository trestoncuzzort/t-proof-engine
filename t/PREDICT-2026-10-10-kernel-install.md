# T78: extend the runnable kernel coverage

Registered before installing the remaining release archives or running their
proof controls. T75/T76 exercised Dafny and Lean; T77 added the pinned SPARK
release. Verus, F*, Rocq and Frama-C were absent, so previous collected tests
and partial matrices do not establish their current behavior on this host.

Use the versions recorded in `t/RUN-ON-LINUX.md` where available. Fetch release
metadata from the publishers, check archive digests, install below the user
tool directory and retain a small provenance receipt. Do not change system
security policy or overwrite a working toolchain. Rust, if required by Verus,
gets the release's recorded toolchain with the minimal profile.

Bars: each installed adapter identifies its real tool; `abs`, `gcd` and
`reverse` each produce verified/refuted with three agreeing runs per side in
that adapter. A missing dependency or a proof timeout is recorded as such.
After installation controls, run the committed corpus from a clean checkout
and compare with the recorded matrix. Named abstentions and measured solver
limits remain limitations; they are not converted to successful cells. Only
a complete clean seven-kernel matrix could replace `t/AGREEMENT.md`.

Prior work: the repository's Linux installation record, `verifiers/discover.py`,
adapter version and budget definitions, and publisher release metadata at
https://github.com/verus-lang/verus/releases,
https://github.com/FStarLang/FStar/releases and
https://github.com/alire-project/GNAT-FSF-builds/releases.

Results pending.
