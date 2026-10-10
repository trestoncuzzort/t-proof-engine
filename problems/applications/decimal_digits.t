t 1
gate loops
task decimal_digits(n: int) returns (r: int)
  requires n >= 1
  ensures r >= 1 and pow(10, r - 1) <= n and n < pow(10, r)
{
  r := 1;
  var p: int := 10;
  while p <= n
    invariant r >= 1 and p == pow(10, r) and pow(10, r - 1) <= n
    invariant p >= r and p > 0
    decreases n - p
  {
    p := p * 10;
    r := r + 1;
  }
}
