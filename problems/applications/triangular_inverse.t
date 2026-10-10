t 1
gate loops
task triangular_inverse(n: int) returns (r: int)
  requires n >= 0
  ensures r >= 0 and r * (r + 1) <= 2 * n
  ensures 2 * n < (r + 1) * (r + 2)
{
  var lo: int := 0;
  var hi: int := n + 1;
  while lo + 1 < hi
    invariant 0 <= lo and lo < hi
    invariant lo * (lo + 1) <= 2 * n and 2 * n < hi * (hi + 1)
    decreases hi - lo
  {
    var mid: int := lo + (hi - lo) / 2;
    if mid * (mid + 1) <= 2 * n { lo := mid; } else { hi := mid; }
  }
  r := lo;
}
