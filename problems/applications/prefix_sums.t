t 1
gate loops
task prefix_sums(s: seq) returns (r: seq)
  ensures len(r) == len(s) + 1 and r[0] == 0
  ensures forall k in [0, len(s)) . r[k + 1] - r[k] == s[k]
{
  r := [0];
  var i: int := 0;
  while i < len(s)
    invariant 0 <= i and i <= len(s)
    invariant len(r) == i + 1 and r[0] == 0
    invariant forall k in [0, i) . r[k + 1] - r[k] == s[k]
    decreases len(s) - i
  {
    r := r + [r[i] + s[i]];
    i := i + 1;
  }
}
