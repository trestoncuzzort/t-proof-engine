# PX4's code against its t transcription

PX4-Autopilot at dd804e4b9c490aed051bb36f8d3fca1ee137be2a: each routine's own C++ (the call below) compiled and run on every domain point of its t task (at most 400), each result compared with t's interpreter (t/flight/px4_diff.py).

- routines compared: 17; agree on every point: 16; points: 5145

| t task | PX4 call | status | points | first difference |
|---|---|---|---|---|
| px4_alpha_update | `[&]{ AlphaFilter<double> f; f.setAlpha((float)alpha); f.reset(state); return f.update(sample); }()` | agrees once PX4's float narrowing of alpha is applied | 400 |  |
| px4_constrain | `math::constrain<int64_t>(val, min_val, max_val)` | agrees | 400 |  |
| px4_constrain_f | `math::constrain<double>(val, min_val, max_val)` | agrees | 400 |  |
| px4_interp_index | `` | not diffed: the index is internal to interpolateNXY, which returns only the interpolated value |  |  |
| px4_interpolate | `math::interpolate<double>(value, x_low, x_high, y_low, y_high)` | agrees | 400 |  |
| px4_is_in_range | `math::isInRange<int64_t>(val, min_val, max_val)` | agrees | 400 |  |
| px4_lerp | `math::lerp<double>(a, b, s)` | agrees | 400 |  |
| px4_max | `math::max<int64_t>(a, b)` | agrees | 400 |  |
| px4_max3 | `math::max<int64_t>(a, b, c)` | agrees | 400 |  |
| px4_min | `math::min<int64_t>(a, b)` | agrees | 400 |  |
| px4_min3 | `math::min<int64_t>(a, b, c)` | agrees | 400 |  |
| px4_negate_i16 | `math::negate<int16_t>((int16_t)value)` | agrees | 85 |  |
| px4_sign | `matrix::sign<int64_t>(val)` | agrees | 86 |  |
| px4_sign_from_bool | `math::signFromBool(positive)` | agrees | 2 |  |
| px4_sign_no_zero | `math::signNoZero<int64_t>(val)` | agrees | 86 |  |
| px4_slew_update | `[&]{ SlewRate<double> sr(value); sr.setSlewRate(slew_rate); return sr.update(new_value, (float)dt); }()` | agrees | 400 |  |
| px4_sq | `math::sq<int64_t>(val)` | agrees | 86 |  |
| px4_wrap_int | `matrix::wrap<int64_t>(x, low, high)` | agrees | 400 |  |
