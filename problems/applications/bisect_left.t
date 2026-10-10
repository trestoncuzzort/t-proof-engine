t 1
gate loops
task bisect_left(s: seq, x: int) returns (r: int)
  requires forall i in [0, len(s)) . forall j in [i, len(s)) . s[i] <= s[j]
  ensures 0 <= r and r <= len(s)
  ensures forall i in [0, r) . s[i] < x
  ensures forall i in [r, len(s)) . s[i] >= x
{
  var lo: int := 0;
  var hi: int := len(s);
  while lo < hi
    invariant 0 <= lo and lo <= hi and hi <= len(s)
    invariant forall i in [0, lo) . s[i] < x
    invariant forall i in [hi, len(s)) . s[i] >= x
    decreases hi - lo
  {
    var mid: int := (lo + hi) / 2;
    if s[mid] < x { lo := mid + 1; } else { hi := mid; }
  }
  r := lo;
}
