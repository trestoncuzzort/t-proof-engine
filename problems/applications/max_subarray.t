t 1
gate loops
task max_subarray(s: seq) returns (r: int)
  requires len(s) > 0
  ensures r == best(s, len(s))
spec fun ending(s: seq, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else if k == 1 then s[0] else max(s[k - 1], ending(s, k - 1) + s[k - 1])
spec fun best(s: seq, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else if k == 1 then s[0] else max(best(s, k - 1), ending(s, k))
{
  r := s[0];
  var tail: int := s[0];
  var i: int := 1;
  while i < len(s)
    invariant 1 <= i and i <= len(s)
    invariant tail == ending(s, i) and r == best(s, i)
    decreases len(s) - i
  {
    tail := max(s[i], tail + s[i]);
    r := max(r, tail);
    i := i + 1;
  }
}
