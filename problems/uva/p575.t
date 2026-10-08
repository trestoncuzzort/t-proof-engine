t 1
gate loops
task p575(s: seq) returns (r: int)
  ensures r == skew(s, 0)
spec fun skew(s: seq, i: int): int
  decreases len(s) - i
= if i < 0 or i >= len(s) then 0 else s[i] * (pow(2, len(s) - i) - 1) + skew(s, i + 1)
{
  r := 0;
  var w: int := 1;
  var k: int := len(s);
  while k > 0
    invariant 0 <= k and k <= len(s)
    invariant w == pow(2, len(s) - k + 1) - 1
    invariant r == skew(s, k)
    decreases k
  {
    k := k - 1;
    r := r + s[k] * w;
    w := 2 * w + 1;
  }
}
