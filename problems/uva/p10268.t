t 1
gate loops
task p10268(x: int, a: seq) returns (r: int)
  requires len(a) >= 1
  ensures r == dsum(a, x, 0)
spec fun dsum(a: seq, x: int, i: int): int
  decreases len(a) - i
= if i < 0 or i >= len(a) - 1 then 0 else a[i] * (len(a) - 1 - i) * pow(x, len(a) - 2 - i) + dsum(a, x, i + 1)
lemma pow_step(x: int, e: int)
  requires e >= 1
  ensures pow(x, e) == x * pow(x, e - 1)
{
}
{
  var n: int := len(a) - 1;
  r := 0;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant r * pow(x, n - i) + dsum(a, x, i) == dsum(a, x, 0)
    decreases n - i
  {
    pow_step(x, n - i);
    r := r * x + a[i] * (n - i);
    i := i + 1;
  }
}
