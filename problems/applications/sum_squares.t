t 1
gate loops
task sum_squares(n: int) returns (r: int)
  requires n >= 0
  ensures 6 * r == n * (n + 1) * (2 * n + 1)
{
  r := 0;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant 6 * r == i * (i + 1) * (2 * i + 1)
    decreases n - i
  {
    i := i + 1;
    r := r + i * i;
  }
}
