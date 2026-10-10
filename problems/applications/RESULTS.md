# t cross-kernel agreement, 2026-10-10 11:26Z

Cell = real outcome / twin outcome. Agreement means `verified / refuted` in every present column. A real-VERIFIED, twin-VERIFIED cell reads `verified / decorative` (the spec cannot tell real and twin apart) or `verified / unsound` (the twin's own measured witness says a sound kernel must refute it, and this one did not); neither counts as agreement.

| task | dafny | lean |
|---|---|---|
| align_up | verified / refuted | unproved / refuted |
| argmin_first | verified / refuted | verified / refuted |
| arithmetic_series | verified / refuted | verified / refuted |
| batch_bounds | verified / refuted | unproved / refuted |
| binary_power | verified / refuted | verified / refuted |
| bisect_left | verified / refuted | timeout / refuted |
| bisect_right | verified / refuted | timeout / refuted |
| buffer_range | verified / refuted | verified / refuted |
| ceil_div | verified / refuted | unproved / refuted |
| checked_add | verified / refuted | verified / refuted |
| choose_two | verified / refuted | verified / refuted |
| count_inversions | verified / refuted | unproved / refuted |
| decimal_digits | verified / refuted | unproved / unproved |
| extended_gcd | verified / refuted | timeout / timeout |
| flatten2 | verified / refuted | unproved / refuted |
| full_batches | verified / refuted | unproved / refuted |
| geometric_series | verified / refuted | verified / refuted |
| horner | verified / refuted | verified / refuted |
| integer_sqrt | verified / refuted | unproved / unproved |
| interval_intersection | verified / refuted | verified / refuted |
| leap_year | verified / refuted | verified / refuted |
| max_subarray | verified / refuted | unproved / refuted |
| midpoint | verified / refuted | verified / refuted |
| modular_add | verified / refuted | unproved / refuted |
| modular_multiply | verified / refuted | unproved / refuted |
| normalize_index | verified / refuted | verified / refuted |
| peasant_multiply | verified / refuted | unproved / refuted |
| prefix_sums | verified / refuted | verified / refuted |
| quotient_remainder | verified / refuted | unproved / refuted |
| range_length | verified / refuted | unproved / refuted |
| resume_position | verified / refuted | unproved / refuted |
| rolling_context | verified / refuted | verified / refuted |
| run_count | verified / refuted | unproved / refuted |
| saturating_add | verified / refuted | verified / refuted |
| shard_bounds | verified / refuted | unproved / refuted |
| sum_odds | verified / refuted | verified / refuted |
| sum_squares | verified / refuted | verified / refuted |
| triangular_inverse | verified / refuted | unproved / unproved |
| unflatten2 | verified / refuted | unproved / refuted |
| window_count | verified / refuted | verified / refuted |

Kernels present: 2 of 2 (dafny, lean)

Backends:
- dafny: dafny 4.11.0+fcb2042d6d043a2634f0854338c08feeaaaf4ae2
- lean: Lean (version 4.33.1

Verdict basis: every source file hashed.

## Sole blockers

| kernel | sole blocker of | co-blocker of | tasks it alone keeps out of all two |
|---|---|---|---|
| lean | 22 | 0 | align_up, batch_bounds, bisect_left, bisect_right, ceil_div, count_inversions, decimal_digits, extended_gcd, flatten2, full_batches, integer_sqrt, max_subarray, modular_add, modular_multiply, peasant_multiply, quotient_remainder, range_length, resume_position, run_count, shard_bounds, triangular_inverse, unflatten2 |
| dafny | 0 | 0 | (none) |

Of the 22 tasks in one, 22 are lean alone.

## Per kernel

| kernel | carried | real verified | twin refuted where the real is verified | abstains by name |
|---|---|---|---|---|
| dafny | 40 | 40 | 40 of 40 (100%) | 0 |
| lean | 40 | 18 | 18 of 18 (100%) | 0 |

Verified with the twin refuted in all two columns: 18 of 40 tasks.
