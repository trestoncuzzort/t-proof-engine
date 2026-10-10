t 1
gate loops
task integer_sqrt(n: int) returns (r: int)
  requires n >= 0
  ensures r >= 0 and r * r <= n and n < (r + 1) * (r + 1)
{
  var lo: int := 0;
  var hi: int := n + 1;
  while lo + 1 < hi
    invariant 0 <= lo and lo < hi
    invariant lo * lo <= n and n < hi * hi
    decreases hi - lo
  {
    var mid: int := lo + (hi - lo) / 2;
    if mid * mid <= n { lo := mid; } else { hi := mid; }
  }
  r := lo;
}
