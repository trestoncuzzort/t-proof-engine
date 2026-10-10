t 1
gate loops
task geometric_series(n: int, base: int) returns (r: int)
  requires n >= 0
  ensures r == gs(n, base)
spec fun gs(k: int, b: int): int
  decreases k
= if k <= 0 then 0 else 1 + b * gs(k - 1, b)
{
  r := 0;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant r == gs(i, base)
    decreases n - i
  {
    r := 1 + base * r;
    i := i + 1;
  }
}
