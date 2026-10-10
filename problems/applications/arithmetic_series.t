t 1
gate loops
task arithmetic_series(n: int, a: int, d: int) returns (r: int)
  requires n >= 0
  ensures 2 * r == n * (2 * a + (n - 1) * d)
{
  r := 0;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant 2 * r == i * (2 * a + (i - 1) * d)
    decreases n - i
  {
    r := r + a + i * d;
    i := i + 1;
  }
}
