# PX4 flight code in t

These tasks restate functions from [PX4-Autopilot](https://github.com/PX4/PX4-Autopilot), an open-source autopilot
for drones and other vehicles. PX4 is licensed under the BSD 3-Clause License; a copy is in `LICENSE-PX4`. Each body
follows PX4's code at commit `dd804e4b9c490aed051bb36f8d3fca1ee137be2a` statement by statement. PX4 ships no
formal contracts, so every `requires` and `ensures` here is this repository's, and `t/audit.py` reads zero survivors
on each: every one-edit change to a body is caught.

PX4's functions are C++ templates. The integer ones are stated over t's integers and compared at `int64_t`. The float
ones are stated over t's `float`, IEEE binary64, and compared at `double`; PX4 flies most of them at `float`, binary32.

| t task | PX4 function | file:line | instantiation compared |
|---|---|---|---|
| px4_constrain | `math::constrain` | src/lib/mathlib/math/Limits.hpp:111 | int64_t |
| px4_min | `math::min(a, b)` | src/lib/mathlib/math/Limits.hpp:69 | int64_t |
| px4_max | `math::max(a, b)` | src/lib/mathlib/math/Limits.hpp:90 | int64_t |
| px4_min3 | `math::min(a, b, c)` | src/lib/mathlib/math/Limits.hpp:84 | int64_t |
| px4_max3 | `math::max(a, b, c)` | src/lib/mathlib/math/Limits.hpp:105 | int64_t |
| px4_is_in_range | `math::isInRange` | src/lib/mathlib/math/Limits.hpp:133 | int64_t |
| px4_sign_no_zero | `math::signNoZero` | src/lib/mathlib/math/Functions.hpp:52 | int64_t |
| px4_sign | `matrix::sign` | src/lib/matrix/matrix/helper_functions.hpp:147 | int64_t |
| px4_sign_from_bool | `math::signFromBool` | src/lib/mathlib/math/Functions.hpp:63 | bool |
| px4_sq | `math::sq` | src/lib/mathlib/math/Functions.hpp:69 | int64_t |
| px4_negate_i16 | `math::negate<int16_t>` | src/lib/mathlib/math/Functions.hpp:258 | int16_t |
| px4_wrap_int | `matrix::wrap` (integer) | src/lib/matrix/matrix/helper_functions.hpp:83 | int64_t |
| px4_interp_index | the index search of `math::interpolateNXY` | src/lib/mathlib/math/Functions.hpp:201 | not compared (internal) |
| px4_constrain_f | `math::constrain` | src/lib/mathlib/math/Limits.hpp:111 | double |
| px4_lerp | `math::lerp` | src/lib/mathlib/math/Functions.hpp:245 | double |
| px4_interpolate | `math::interpolate` | src/lib/mathlib/math/Functions.hpp:152 | double |
| px4_slew_update | `SlewRate::update` | src/lib/slew_rate/SlewRate.hpp:79 | double, `dt` as PX4's `float` |
| px4_alpha_update | `AlphaFilter::updateCalculation` | src/lib/mathlib/math/filter/AlphaFilter.hpp:169 | double, `alpha` as PX4's `float` |

**Transcription notes.**
- `matrix::wrap`'s local `range` is named `rng` here; `range` is an Ada keyword, and the renamed form collides with
  SPARK's emitted package.
- `matrix::sign` and `math::signNoZero` subtract two C++ booleans; t has no boolean arithmetic, so each comparison
  sets an int to 1 or 0 first.
- The integer `wrap` uses C++'s truncating `/` and `%` where t's are Euclidean. The operands there are never
  negative (`low - x > 0` on the branch that divides, `x - low >= 0` after it), and on non-negative operands the
  two agree.
- `interpolateNXY` evaluates `value > x[index + 1]` before `index < N - 2`, as here; `x[index + 1]` is always
  defined because the loop keeps `index <= N - 2`.
- `px4_interpolate` requires `x_high - x_low >= 1` over inputs within ±1000. PX4 states neither, but t's floats are
  defined only when finite, and a small gap can overflow the slope `(y_high - y_low) / (x_high - x_low)`. The bound
  is what this proof covers; stating it is part of the finding.
- `SlewRate<double>::update` takes `dt` as `float`, and `AlphaFilter<double>` stores `alpha` as a `float` member, so
  PX4 narrows both to binary32 before use.

**Checked against PX4 itself.** `px4_diff.py` fetches PX4's headers at the pinned commit (the platform header is
replaced by a two-macro stub), compiles each function's own C++, and runs it on every domain point of its t task. It
compares each result with t's interpreter. The table is `t/PX4-DIFF.md`.
