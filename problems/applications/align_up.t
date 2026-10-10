t 1
task align_up(n: int, k: int) returns (r: int)
  requires n >= 0 and k > 0
  ensures n <= r and r < n + k and r % k == 0
lemma mul_le(u: int, a: int, b: int)
  requires u >= 0 and a <= b
  ensures u * a <= u * b
  decreases u
{
  if u > 0 { mul_le(u - 1, a, b); } else { }
}
lemma quotient(n: int, d: int, q: int, rem: int)
  requires d > 0 and 0 <= rem and rem < d and n == q * d + rem
  ensures n / d == q and n % d == rem
{
  assert n == d * (n / d) + n % d;
  assert 0 <= n % d and n % d < d;
  if n / d < q { mul_le(d, n / d, q - 1); } else { }
  if q < n / d { mul_le(d, q + 1, n / d); } else { }
}
lemma aligned(n: int, k: int)
  requires k > 0
  ensures (n + k - n % k) % k == 0
{
  assert n == (n / k) * k + n % k;
  assert n + k - n % k == (n / k + 1) * k;
  quotient(n + k - n % k, k, n / k + 1, 0);
}
{
  var rem: int := n % k;
  if rem == 0 { r := n; } else { aligned(n, k); r := n + (k - rem); }
}
