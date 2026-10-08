# t cross-kernel agreement, 2026-10-08 18:47Z

Cell = real outcome / twin outcome. Agreement means `verified / refuted` in every present column. A real-VERIFIED, twin-VERIFIED cell reads `verified / decorative` (the spec cannot tell real and twin apart) or `verified / unsound` (the twin's own measured witness says a sound kernel must refute it, and this one did not); neither counts as agreement.

| task | dafny | verus | spark | framac | lean | rocq | fstar |
|---|---|---|---|---|---|---|---|
| p10007 | verified / refuted | verified / refuted | timeout / refuted | timeout / refuted | verified / refuted | verified / refuted | verified / refuted |
| p10223 | verified / refuted | unproved / refuted | timeout / refuted | timeout / refuted | verified / unproved | unproved / refuted | timeout / timeout |
| p10268 | verified / refuted | verified / refuted | timeout / refuted | verified / refuted | unproved / refuted | unproved / refuted | verified / timeout |
| p10302 | verified / refuted | unproved / refuted | timeout / refuted | timeout / refuted | verified / refuted | verified / refuted | verified / refuted |
| p10312 | verified / refuted | verified / refuted | verified / refuted | timeout / refuted | verified / refuted | timeout / refuted | verified / refuted |
| p10334 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted |
| p10541 | verified / refuted | unproved / refuted | timeout / refuted | verified / refuted | unproved / refuted | unproved / refuted | verified / refuted |
| p10551 | verified / refuted | timeout / refuted | timeout / refuted | abstain / abstain | unproved / refuted | unproved / refuted | timeout / malformed |
| p10931 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted |
| p11384 | verified / refuted | unproved / refuted | timeout / refuted | timeout / refuted | unproved / refuted | unproved / refuted | unproved / refuted |
| p11526 | verified / refuted | unproved / refuted | timeout / refuted | verified / refuted | unproved / refuted | unproved / refuted | timeout / refuted |
| p11847 | verified / refuted | unproved / refuted | timeout / refuted | timeout / refuted | unproved / refuted | unproved / refuted | unproved / refuted |
| p11955 | verified / refuted | unproved / refuted | timeout / refuted | verified / refuted | unproved / refuted | unproved / refuted | verified / refuted |
| p12004 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | unproved / refuted | timeout / refuted |
| p1224 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | timeout / refuted | verified / timeout |
| p12712 | verified / refuted | timeout / refuted | timeout / refuted | malformed / malformed | unproved / refuted | unproved / refuted | timeout / timeout |
| p12918 | verified / refuted | unproved / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | timeout / refuted |
| p343 | verified / refuted | unproved / unproved | abstain / abstain | abstain / abstain | abstain / abstain | abstain / abstain | abstain / abstain |
| p369 | verified / refuted | unproved / refuted | timeout / refuted | verified / refuted | unproved / refuted | unproved / refuted | verified / refuted |
| p495 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / unproved |
| p496 | verified / unproved | unproved / refuted | verified / refuted | abstain / abstain | abstain / abstain | abstain / abstain | abstain / abstain |
| p575 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | unproved / refuted | unproved / refuted | verified / refuted |
| p991 | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted | verified / refuted |

Kernels present: 7 of 7 (dafny, verus, spark, framac, lean, rocq, fstar)

Backends:
- dafny: dafny 4.11.0+fcb2042d6d043a2634f0854338c08feeaaaf4ae2
- verus: verus 0.2026.08.30.b432e82
- spark: gnatprove FSF 16.1.0 / Why3 for gnatprove version 1.8.2+git
- framac: frama-c 33.0 (Arsenic) / alt-ergo 2.4.3-free
- lean: Lean (version 4.33.1
- rocq: The Rocq Prover, version 9.2
- fstar: F* 2026.08.30 / platform=Linux_x86_64 / system=Unix / compiler=OCaml 5.3.0 / date=2026-08-30 16:26:18 +0000 / commit=2b82aefeff37f78509c876844954b07fcb8813ff

Verdict basis: every source file hashed; e.g. `p10007.dfy` 8d293eaf5b954153…, `p10007.rs` 597161c011eef6fd…

## Sole blockers

| kernel | sole blocker of | co-blocker of | tasks it alone keeps out of all seven |
|---|---|---|---|
| fstar | 1 | 12 | p495 |
| dafny | 0 | 1 | (none) |
| verus | 0 | 13 | (none) |
| spark | 0 | 13 | (none) |
| framac | 0 | 10 | (none) |
| lean | 0 | 13 | (none) |
| rocq | 0 | 16 | (none) |

Of the 1 tasks in six, 1 is fstar alone.

## Per kernel

| kernel | carried | real verified | twin refuted where the real is verified | abstains by name |
|---|---|---|---|---|
| dafny | 23 | 23 | 22 of 23 (95%) | 0 |
| verus | 23 | 10 | 10 of 10 (100%) | 0 |
| spark | 22 | 10 | 10 of 10 (100%) | 1 |
| framac | 20 | 13 | 13 of 13 (100%) | 3 |
| lean | 21 | 11 | 10 of 11 (90%) | 2 |
| rocq | 21 | 7 | 7 of 7 (100%) | 2 |
| fstar | 21 | 13 | 10 of 13 (76%) | 2 |

Verified with the twin refuted in all seven columns: 3 of 23 tasks.
