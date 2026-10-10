# T82: make command-line verification dependable for automation

Registered before new controls or implementation changes. Static inspection
of cli._verify_dir suggests that progress output can enter --json stdout,
declared task names can be substituted for actual input filenames, and the
directory exit status can count an incomplete repetition set or omit an
explicitly requested but unavailable kernel. These are hypotheses until
reproduced, not claims about incorrect kernel proofs.

Bars: JSON mode emits independently parseable JSON records with the actual
source path; progress belongs on stderr. Explicitly requested unavailable
kernels fail before dispatch. A run with fewer than three repetitions cannot
report complete agreement. Invalid worker counts fail before dispatch. A
failed report replacement preserves the previous complete report. Default
three-repeat text output and the existing committed-matrix guards retain their
semantics. Exercise the public command with installed kernels as well as
controlled failure injection.

Prior work: T75's invalid-input and provisional-verdict gates, T79's editor
identity checks, cli.py, run_par.py, cache.py and the existing CLI tests.
The standard JSON decoder provides the independent output-format control:
https://docs.python.org/3/library/json.html. Python documents atomic successful
replacement with os.replace:
https://docs.python.org/3/library/os.html#os.replace.

Results pending.
