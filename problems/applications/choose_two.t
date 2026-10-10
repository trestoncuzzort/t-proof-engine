t 1
gate loops
task choose_two(n: int) returns (r: int)
  requires n >= 0
  ensures 2 * r == n * (n - 1)
{
  r := 0;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant 2 * r == i * (i - 1)
    decreases n - i
  {
    r := r + i;
    i := i + 1;
  }
}
