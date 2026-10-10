t 1
gate loops
task run_count(s: seq) returns (r: int)
  ensures r == runs(s, len(s))
spec fun runs(s: seq, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else if k == 1 then 1 else runs(s, k - 1) + (if s[k - 1] == s[k - 2] then 0 else 1)
{
  r := 0;
  var i: int := 0;
  while i < len(s)
    invariant 0 <= i and i <= len(s) and r == runs(s, i)
    decreases len(s) - i
  {
    if i == 0 or s[i] != s[i - 1] { r := r + 1; } else { }
    i := i + 1;
  }
}
