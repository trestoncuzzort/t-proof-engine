t 1
gate loops
task p10931(n: int) returns (r: int)
  requires n >= 0
  ensures r == ones(n)
spec fun ones(m: int): int
  decreases m
= if m <= 0 then 0 else m % 2 + ones(m / 2)
{
  r := 0;
  var m: int := n;
  while m > 0
    invariant m >= 0
    invariant r + ones(m) == ones(n)
    decreases m
  {
    r := r + m % 2;
    m := m / 2;
  }
}
