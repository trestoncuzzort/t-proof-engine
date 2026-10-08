t 1
gate loops
task p10551(b: int, p: seq, m: seq) returns (r: int)
  requires b >= 2
  requires forall j in [0, len(p)) . 0 <= p[j] and p[j] < b
  requires val(m, b, len(m)) >= 1
  ensures r == val(p, b, len(p)) % val(m, b, len(m))
spec fun val(s: seq, b: int, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else val(s, b, k - 1) * b + s[k - 1]
lemma val_nonneg(s: seq, b: int, k: int)
  requires b >= 0 and 0 <= k and k <= len(s)
  requires forall j in [0, len(s)) . 0 <= s[j]
  ensures val(s, b, k) >= 0
  decreases k
{
  if k > 0 {
    val_nonneg(s, b, k - 1);
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
{
  var mm: int := 0;
  var j: int := 0;
  while j < len(m)
    invariant 0 <= j and j <= len(m)
    invariant mm == val(m, b, j)
    decreases len(m) - j
  {
    mm := mm * b + m[j];
    j := j + 1;
  }
  var i: int := 0;
  r := 0;
  while i < len(p)
    invariant 0 <= i and i <= len(p)
    invariant r == val(p, b, i) % mm
    decreases len(p) - i
  {
    val_nonneg(p, b, i);
    horner_mod(val(p, b, i), b, p[i], mm);
    r := (r * b + p[i]) % mm;
    i := i + 1;
  }
}
