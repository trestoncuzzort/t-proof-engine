t 1
gate loops
task p12712(n: int, lo: int, hi: int) returns (r: int)
  requires n >= 1 and 1 <= lo and lo <= hi and hi <= n
  ensures r == psum(n, lo, hi) % 10000000000007
spec fun ff(n: int, k: int): int
  decreases k
= if k <= 0 then 1 else ff(n, k - 1) * (n - k + 1)
spec fun psum(n: int, lo: int, k: int): int
  decreases k
= if k < lo or k <= 0 then 0 else psum(n, lo, k - 1) + ff(n, k)
lemma ff_nonneg(n: int, k: int)
  requires 0 <= k and k <= n
  ensures ff(n, k) >= 0
  decreases k
{
  if k > 0 {
    ff_nonneg(n, k - 1);
  } else {
  }
}
lemma psum_nonneg(n: int, lo: int, k: int)
  requires 0 <= k and k <= n
  ensures psum(n, lo, k) >= 0
  decreases k
{
  if k > 0 {
    psum_nonneg(n, lo, k - 1);
    ff_nonneg(n, k);
  } else {
  }
}
lemma mul_ge(d: int, k: int)
  requires d >= 1 and k >= 1
  ensures d * k >= d
  decreases k
{
  if k > 1 {
    mul_ge(d, k - 1);
    assert d * k == d * (k - 1) + d;
  } else {
  }
}
lemma mul_ge_or(d: int, k: int)
  requires d >= 1
  ensures k < 1 or d * k >= d
{
  if k >= 1 {
    mul_ge(d, k);
  } else {
  }
}
lemma mul_le_or(d: int, k: int)
  requires d >= 1
  ensures k > -1 or d * k <= -d
{
  if k <= -1 {
    mul_ge(d, -k);
    assert d * (-k) == -(d * k);
  } else {
  }
}
lemma mod_unique(y: int, d: int, q: int, c: int)
  requires d >= 1 and 0 <= c and c < d and y == d * q + c
  ensures y % d == c
{
  assert y == d * (y / d) + y % d;
  assert 0 <= y % d and y % d < d;
  assert d * (q - y / d) == d * q - d * (y / d);
  mul_ge_or(d, q - y / d);
  mul_le_or(d, q - y / d);
}
lemma mod_shift(x: int, k: int, d: int)
  requires d >= 1 and k >= 0
  ensures (x + d * k) % d == x % d
{
  assert x == d * (x / d) + x % d;
  assert 0 <= x % d and x % d < d;
  assert x + d * k == d * (x / d + k) + x % d;
  mod_unique(x + d * k, d, x / d + k, x % d);
}
lemma horner_mod(v: int, b: int, c: int, d: int)
  requires d >= 1 and v >= 0 and b >= 0
  ensures (v * b + c) % d == (v % d * b + c) % d
{
  assert v == d * (v / d) + v % d;
  assert v / d >= 0;
  assert v * b + c == v % d * b + c + d * (v / d * b);
  mod_shift(v % d * b + c, v / d * b, d);
}
lemma add_mod(a: int, c: int, d: int)
  requires d >= 1 and a >= 0 and c >= 0
  ensures (a % d + c % d) % d == (a + c) % d
{
  assert a == d * (a / d) + a % d;
  assert c == d * (c / d) + c % d;
  assert a / d >= 0 and c / d >= 0;
  assert a + c == a % d + c % d + d * (a / d + c / d);
  mod_shift(a % d + c % d, a / d + c / d, d);
}
{
  var p: int := 1;
  var s: int := 0;
  var k: int := 0;
  while k < hi
    invariant 0 <= k and k <= hi
    invariant p == ff(n, k) % 10000000000007
    invariant s == psum(n, lo, k) % 10000000000007
    decreases hi - k
  {
    k := k + 1;
    ff_nonneg(n, k - 1);
    horner_mod(ff(n, k - 1), n - k + 1, 0, 10000000000007);
    p := p * (n - k + 1) % 10000000000007;
    if k >= lo {
      psum_nonneg(n, lo, k - 1);
      ff_nonneg(n, k);
      add_mod(psum(n, lo, k - 1), ff(n, k), 10000000000007);
      s := (s + p) % 10000000000007;
    } else {
    }
  }
  r := s;
}
