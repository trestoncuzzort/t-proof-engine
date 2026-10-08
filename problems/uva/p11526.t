t 1
gate loops
task p11526(n: int) returns (r: int)
  ensures r == (if n <= 0 then 0 else hs(n, n))
spec fun hs(n: int, k: int): int
  decreases k
= if k <= 0 then 0 else hs(n, k - 1) + n / k
lemma mul_le_mono(u: int, a: int, b: int)
  requires u >= 0 and a <= b
  ensures u * a <= u * b
  decreases u
{
  if u > 0 {
    mul_le_mono(u - 1, a, b);
  } else {
  }
}
lemma div_lower(n: int, u: int, q: int)
  requires n >= 0 and u >= 1 and q >= 0 and u * q <= n
  ensures q <= n / u
{
  assert n == u * (n / u) + n % u;
  assert 0 <= n % u and n % u < u;
  if n / u < q {
    mul_le_mono(u, n / u, q - 1);
  } else {
  }
}
lemma div_mul_le(n: int, i: int)
  requires n >= 0 and i >= 1
  ensures n / i * i <= n
{
  assert n == i * (n / i) + n % i;
}
lemma div_antitone(n: int, a: int, b: int)
  requires n >= 0 and 1 <= a and a <= b
  ensures n / b <= n / a
{
  div_mul_le(n, b);
  mul_le_mono(n / b, a, b);
  div_lower(n, a, n / b);
}
lemma block_const(n: int, i: int, u: int, q: int)
  requires n >= 1 and 1 <= i and i <= u and q == n / i and q >= 1 and u <= n / q
  ensures n / u == q
{
  div_antitone(n, i, u);
  div_mul_le(n, q);
  div_lower(n, u, q);
}
lemma block_sum(n: int, i: int, u: int, q: int)
  requires n >= 1 and 1 <= i and i - 1 <= u and q == n / i and q >= 1 and u <= n / q
  ensures hs(n, u) == hs(n, i - 1) + q * (u - i + 1)
  decreases u - i + 1
{
  if u >= i {
    block_sum(n, i, u - 1, q);
    block_const(n, i, u, q);
  } else {
  }
}
{
  r := 0;
  if n > 0 {
    var i: int := 1;
    while i <= n
      invariant 1 <= i and i <= n + 1
      invariant r == hs(n, i - 1)
      decreases n + 1 - i
    {
      var q: int := n / i;
      div_lower(n, i, 1);
      div_mul_le(n, i);
      div_lower(n, q, i);
      div_antitone(n, 1, q);
      var j: int := n / q;
      block_sum(n, i, j, q);
      r := r + q * (j - i + 1);
      i := j + 1;
    }
  } else {
  }
}
