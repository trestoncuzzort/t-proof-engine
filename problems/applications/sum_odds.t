t 1
gate loops
task sum_odds(n: int) returns (r: int)
  requires n >= 0
  ensures r == n * n
{
  r := 0;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant r == i * i
    decreases n - i
  {
    r := r + 2 * i + 1;
    i := i + 1;
  }
}
