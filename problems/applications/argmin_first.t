t 1
gate loops
task argmin_first(s: seq) returns (r: int)
  requires len(s) > 0
  ensures 0 <= r and r < len(s)
  ensures forall k in [0, len(s)) . s[r] <= s[k]
  ensures forall k in [0, r) . s[r] < s[k]
{
  r := 0;
  var i: int := 1;
  while i < len(s)
    invariant 1 <= i and i <= len(s) and 0 <= r and r < i
    invariant forall k in [0, i) . s[r] <= s[k]
    invariant forall k in [0, r) . s[r] < s[k]
    decreases len(s) - i
  {
    if s[i] < s[r] { r := i; } else { }
    i := i + 1;
  }
}
