t 1
gate loops
task modular_multiply(a: int, b: int, m: int) returns (r: int)
  requires b >= 0 and m > 0
  ensures 0 <= r and r < m and r == (a * b) % m
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
{
  r := 0;
  var i: int := 0;
  var q: int := 0;
  var aq: int := a / m;
  var residue: int := a % m;
  while i < b
    invariant 0 <= i and i <= b
    invariant 0 <= r and r < m and a * i == q * m + r
    decreases b - i
  {
    r := r + residue;
    q := q + aq;
    if r >= m { r := r - m; q := q + 1; } else { }
    i := i + 1;
  }
  quotient(a * b, m, q, r);
}
