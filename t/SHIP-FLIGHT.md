# Shipped at machine width

Each routine's C lowering proved with WP's machine-integer model and `-wp-rte`, so every signed operation owes a no-overflow proof (t/ship.py). Where an overflow guard is open for the full range, the largest bound ±2^k on every int input and sequence element (lengths at most 1000) under which every goal proves is the routine's proved operating envelope.

- ships for every int32 input: 13
- ships within an envelope: 1
- no envelope found: 1
- contract open at machine width: 3
- not shipped (the C lowering refuses it): 0

| task | status | goals at full width (before inference) | bounds inferred and proved (R4c) | open goals at full width |
|---|---|---|---|---|
| px4_alpha_update | ships for every int32 input | 11/11 |  |  |
| px4_constrain | ships for every int32 input | 9/9 |  |  |
| px4_constrain_f | ships for every int32 input | 9/9 |  |  |
| px4_interp_index | ships for every int32 input | 20/20 |  |  |
| px4_interpolate | not shipped: the contract is open at machine width | 19/23 |  | typed_px4_interpolate_t_assert_5, typed_px4_interpolate_t_assert_6, typed_px4_interpolate_t_assert_7, typed_px4_interpolate_t_assert_8 |
| px4_is_in_range | ships for every int32 input | 7/7 |  |  |
| px4_lerp | not shipped: the contract is open at machine width | 12/14 |  | typed_px4_lerp_t_assert_2, typed_px4_lerp_t_assert_4 |
| px4_max | ships for every int32 input | 6/6 |  |  |
| px4_max3 | ships for every int32 input | 8/8 |  |  |
| px4_min | ships for every int32 input | 6/6 |  |  |
| px4_min3 | ships for every int32 input | 8/8 |  |  |
| px4_negate_i16 | ships for every int32 input | 10/10 |  |  |
| px4_sign | ships for every int32 input | 10/10 |  |  |
| px4_sign_from_bool | ships for every int32 input | 6/6 |  |  |
| px4_sign_no_zero | ships for every int32 input | 9/9 |  |  |
| px4_slew_update | not shipped: the contract is open at machine width | 15/16 |  | typed_px4_slew_update_t_assert_3 |
| px4_sq | ships within ±2^15 | 6/7 |  | typed_px4_sq_t_assert_rte_signed_overflow_2 |
| px4_wrap_int | no envelope found (open even at ±2^4) | 43/50 |  | typed_px4_wrap_int_t_assert_rte_signed_overflow_15, typed_px4_wrap_int_t_assert_rte_signed_overflow_17, typed_px4_wrap_int_t_assert_rte_signed_overflow_2, typed_px4_wrap_int_t_assert_rte_signed_overflow_21, typed_px4_wrap_int_t_assert_rte_signed_overflow_4, typed_px4_wrap_int_t_ensures |
