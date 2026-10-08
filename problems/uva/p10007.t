t 1
gate loops
task p10007(n: int) returns (r: int)
  requires n >= 0
  ensures r == fact(n) * cat(n)
spec fun fact(k: int): int
  decreases k
= if k <= 0 then 1 else k * fact(k - 1)
spec fun cat(k: int): int
  decreases k
= if k <= 0 then 1 else cat(k - 1) * (4 * k - 2) / (k + 1)
{
  var f: int := 1;
  var c: int := 1;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant f == fact(i) and c == cat(i)
    decreases n - i
  {
    i := i + 1;
    f := i * f;
    c := c * (4 * i - 2) / (i + 1);
  }
  r := f * c;
}
