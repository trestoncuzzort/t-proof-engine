# PX4 findings refuted at real inputs

Each finding's own body, at the input a real PX4 message or buffer carries (t/flight/findings/real_inputs.json), lowered with its refutation certificate in every kernel (t/refute_at.py). REFUTED means the kernel accepted the certificate.

| finding | input | kind | dafny | verus | spark | framac | lean | rocq | fstar | refuted |
|---|---|---|---|---|---|---|---|---|---|---|
| px4_wrap_bin_any | a bin one past a full turn below zero; PX4 returns -1 | value | refuted | refuted | refuted | refuted | refuted | refuted | refuted | 7/7 |
| px4_sumd_receive_any | PX4's 64-byte buffer and a valid 32-channel frame | undefined | refuted | refuted | refuted | refuted | refuted | refuted | unproved | 6/7 |
| px4_request_event_any | a request for events 0..40 against PX4's default 20-event buffer | value | refuted | refuted | refuted | refuted | refuted | refuted | refuted | 7/7 |
| px4_arm_param_any | COMPONENT_ARM_DISARM param1 = 257 | value | refuted | refuted | refuted | refuted | refuted | refuted | refuted | 7/7 |
| px4_stream_interval_any | a requested interval of 2^31 us, about 36 minutes | value | refuted | refuted | refuted | refuted | refuted | refuted | refuted | 7/7 |
