t 1
gate loops
task horner(s: seq, x: int) returns (r: int)
  ensures r == poly(s, x, len(s))
spec fun poly(s: seq, x: int, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else poly(s, x, k - 1) * x + s[k - 1]
{
  r := 0;
  var i: int := 0;
  while i < len(s)
    invariant 0 <= i and i <= len(s) and r == poly(s, x, i)
    decreases len(s) - i
  {
    r := r * x + s[i];
    i := i + 1;
  }
}
