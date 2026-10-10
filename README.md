# t-proof-engine: math problems, solved with proofs

A problem's statement becomes a **specification**, its solution is a **program**, and seven independent proof
systems (Dafny, Verus, SPARK, Frama-C, Lean 4, Rocq, F\*) each check that the program meets the specification for
**every** input. Then the proved code runs on the judge's own test data, where it has to reproduce the expected
output byte for byte.

A kernel's proof counts only if it also **refutes a broken twin**: a copy of the program one edit away, which the
kernel must reject at a concrete input. A specification too weak to tell the two apart is reported, never counted.

## UVa Online Judge math problems, checked against uDebug

| UVa | problem | the `ensures` states | proved, twin refuted | matches uDebug |
|---|---|---|---|---|
| [343](https://onlinejudge.org/external/3/343.pdf) | What Base Is This? | the statement: the first base pair in the statement's search order, and no earlier pair | 1 of 7: Dafny | 4 of 4 files, 200 lines |
| [369](https://onlinejudge.org/external/3/369.pdf) | Combinations | the statement: N!/((N-M)! M!) exactly as written | 3 of 7: Dafny, Frama-C, F* | 2 of 2 files, 1,255 lines |
| [495](https://onlinejudge.org/external/4/495.pdf) | Fibonacci Freeze | the statement: the statement's recurrence, up to F(5000) | 6 of 7: Dafny, Verus, SPARK, Frama-C, Lean, Rocq | 5 of 5 files, 2,989 lines (one more file has no stored output) |
| [496](https://onlinejudge.org/external/4/496.pdf) | Simply Subsets | the statement: subset and disjointness as quantifiers over the two lists | 1 of 7: SPARK | 2 of 2 files, 675 lines |
| [575](https://onlinejudge.org/external/5/575.pdf) | Skew Binary | the statement: digit k weighs 2^(k+1) - 1 | 5 of 7: Dafny, Verus, SPARK, Frama-C, F* | 3 of 3 files, 1,165 lines |
| [991](https://onlinejudge.org/external/9/991.pdf) | Safe Salutations | a model: Catalan numbers count non-crossing handshakes | 7 of 7: Dafny, Verus, SPARK, Frama-C, Lean, Rocq, F* | 1 of 1 files, 19 lines |
| [1224](https://onlinejudge.org/external/12/1224.pdf) | Tile Code | a model: tilings of 2 x n, halved over flips (Burnside) | 5 of 7: Dafny, Verus, SPARK, Frama-C, Lean | 1 of 1 files, 28 lines |
| [10007](https://onlinejudge.org/external/100/10007.pdf) | Count the Trees | a model: n! times the n-th Catalan number | 5 of 7: Dafny, Verus, Lean, Rocq, F* | 3 of 3 files, 657 lines |
| [10223](https://onlinejudge.org/external/102/10223.pdf) | How many nodes? | a model: the smallest n >= 1 with Catalan(n) = x | 1 of 7: Dafny | 1 of 1 files, 100 lines |
| [10268](https://onlinejudge.org/external/102/10268.pdf) | 498-bis | the statement: the stated derivative sum, computed by Horner's rule | 3 of 7: Dafny, Verus, Frama-C | 5 of 5 files, 679 lines |
| [10302](https://onlinejudge.org/external/103/10302.pdf) | Summation of Polynomials | the statement: 1^3 + ... + x^3 by the closed form, Nicomachus' theorem as a lemma | 4 of 7: Dafny, Lean, Rocq, F* | 4 of 4 files, 100,716 lines |
| [10312](https://onlinejudge.org/external/103/10312.pdf) | Expression Bracketing | a model: little Schroeder minus Catalan numbers | 5 of 7: Dafny, Verus, SPARK, Lean, F* | 2 of 2 files, 44 lines |
| [10334](https://onlinejudge.org/external/103/10334.pdf) | Ray Through Glasses | a model: a(n) = a(n-1) + a(n-2), a(0) = 1, a(1) = 2 | 7 of 7: Dafny, Verus, SPARK, Frama-C, Lean, Rocq, F* | 4 of 4 files, 1,075 lines |
| [10541](https://onlinejudge.org/external/105/10541.pdf) | Stripe | a model: C(N - sum + 1, K) by stars and bars | 3 of 7: Dafny, Frama-C, F* | 3 of 3 files, 9 lines |
| [10551](https://onlinejudge.org/external/105/10551.pdf) | Basic Remains | the statement: p mod m in base b, a 1000-digit Horner modulo m | 1 of 7: Dafny | 1 of 1 files, 100 lines |
| [10931](https://onlinejudge.org/external/109/10931.pdf) | Parity | the statement: the number of 1 bits | 7 of 7: Dafny, Verus, SPARK, Frama-C, Lean, Rocq, F* | 2 of 2 files, 53 lines |
| [11384](https://onlinejudge.org/external/113/11384.pdf) | Help is needed for Dexter | a model: the bit length of N | 1 of 7: Dafny | 4 of 4 files, 222 lines |
| [11526](https://onlinejudge.org/external/115/11526.pdf) | H(n) | the statement: the statement's own C++ loop, computed in sqrt(n) blocks | 2 of 7: Dafny, Frama-C | 4 of 4 files, 685 lines |
| [11847](https://onlinejudge.org/external/118/11847.pdf) | Cut the Silver Bar | a model: floor(log2 n) | 1 of 7: Dafny | 3 of 3 files, 21,100 lines |
| [11955](https://onlinejudge.org/external/119/11955.pdf) | Binomial Theorem | the statement: x_i = C(k, i) as the statement defines it | 3 of 7: Dafny, Frama-C, F* | 1 of 1 files, 50 lines |
| [12004](https://onlinejudge.org/external/120/12004.pdf) | Bubble Sort | a model: expected inversions n(n-1)/4 | 5 of 7: Dafny, Verus, SPARK, Frama-C, Lean | 2 of 2 files, 671 lines |
| [12712](https://onlinejudge.org/external/127/12712.pdf) | Pattern Locker | a model: sum of falling factorials modulo 10^13 + 7 | 1 of 7: Dafny | 3 of 3 files, 45,705 lines |
| [12918](https://onlinejudge.org/external/129/12918.pdf) | Lucky Thief | a model: (m-1) + (m-2) + ... + (m-n) | 5 of 7: Dafny, SPARK, Frama-C, Lean, Rocq | 4 of 4 files, 1,352 lines |

**23 problems.** Every one reproduces uDebug's expected output on every test file that has one (179,549 lines). Every one is proved, with its twin refuted, in at least one kernel; 3 are proved in all seven. Per kernel: Dafny 22, Verus 10, SPARK 10, Frama-C 13, Lean 10, Rocq 7, F* 10. Measured on a clean clone of commit 3219642, 2026-10-08; the full matrix is [`problems/uva/AGREEMENT.md`](problems/uva/AGREEMENT.md).

**"The statement"** rows prove the problem exactly as its text defines it: the formula, the recurrence, or (for
11526) the C++ loop the statement prints. **"A model"** rows prove the standard mathematical answer, such as the
Catalan numbers for non-crossing handshakes. That modelling step is not proved; the judge's data tests it.

## One problem, start to finish: UVa 11526, H(n)

The statement defines H(n) by a C++ loop, `for i in 1..n: res += n / i`, and n reaches 2^31 - 1, so the loop
itself is too slow. The specification is that loop, as a recursive sum:

```
task p11526(n: int) returns (r: int)
  ensures r == (if n <= 0 then 0 else hs(n, n))
spec fun hs(n: int, k: int): int
  decreases k
= if k <= 0 then 0 else hs(n, k - 1) + n / k
```

The solution walks n/i in blocks where it is constant, about 2·√n steps. The proof is the reason that is allowed:
for i <= u <= n/(n/i), n/u equals n/i (`block_const`), so a block contributes q·(length) (`block_sum`). Those rest
on three facts about integer division, each proved from scratch in the same file: n/b <= n/a when a <= b, q <= n/u
when u·q <= n, and (n/i)·i <= n. The full source is [`problems/uva/p11526.t`](problems/uva/p11526.t).

## Run it

```sh
python3 t/cli.py verify problems/uva/p11526.t              # each kernel: the program proved, the twin refuted
python3 t/cli.py verify problems/uva --jobs 8              # every problem, every kernel
python3 t/judge.py problems/uva/p11526.t --tests DIR       # the proved code on a judge's NNNN.in.txt / .out.txt
```

`t/judge.py` translates the task's Dafny lowering to Python once (`dafny translate py`, unbounded integers) and
calls the proved method for each case. Each problem's `_io.py` reads the input and prints the answer. The uDebug
test files are not in this repository; export them from uDebug into one folder per problem.

## What is proved, and what is not

- **Proved**, in each kernel the table names: for every input the `requires` allows, the result satisfies the
  `ensures`, and the twin is refuted. Kernels that miss a problem say why in their verify output (most misses are
  nonlinear arithmetic: products, division and powers that Lean's `omega`, Rocq's `lia` and SPARK's provers do
  not close yet).
- **Not proved**: the `_io.py` modules (reading numbers, printing them), Dafny's Python translation and Python
  itself. The judge's expected outputs test all three on every case above.
- **A model row** proves the program computes the model; that the model counts what the story describes is the
  standard mathematics the row names.

The language, its seven lowerings, the specification audits of public benchmarks and the PX4 flight-code work
are in [`ENGINE.md`](ENGINE.md); the registration and read for these problems are in
[`t/PREDICT-2026-10-08-math.md`](t/PREDICT-2026-10-08-math.md).

There are also [40 arithmetic, algorithm and repository applications](problems/applications/README.md):
all 40 proved with their twins refuted in Dafny, 18 also in Lean, measured on a clean checkout of 9ccd6cc.
Their generated programs pass 82,880 independent oracle cases and 13,562 repository comparisons/rejection checks.
The work repairs the judge's compiled-module loading and a locallm training loop that could retry empty epochs
forever. The [application matrix](problems/applications/RESULTS.md) records its two-kernel scope separately.
