t 1
gate loops
task p991(n: int) returns (r: int)
  requires n >= 0
  ensures r == cat(n)
spec fun cat(k: int): int
  decreases k
= if k <= 0 then 1 else cat(k - 1) * (4 * k - 2) / (k + 1)
{
  r := 1;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant r == cat(i)
    decreases n - i
  {
    i := i + 1;
    r := r * (4 * i - 2) / (i + 1);
  }
}
