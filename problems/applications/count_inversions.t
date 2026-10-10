t 1
gate loops
task count_inversions(s: seq) returns (r: int)
  ensures r == inversions(s, len(s))
spec fun smaller(s: seq, k: int, j: int): int
  decreases j
= if k < 0 or k >= len(s) or j <= 0 or j > k then 0 else smaller(s, k, j - 1) + (if s[j - 1] > s[k] then 1 else 0)
spec fun inversions(s: seq, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else inversions(s, k - 1) + smaller(s, k - 1, k - 1)
{
  r := 0;
  var i: int := 0;
  while i < len(s)
    invariant 0 <= i and i <= len(s) and r == inversions(s, i)
    decreases len(s) - i
  {
    var j: int := 0;
    var count: int := 0;
    while j < i
      invariant 0 <= j and j <= i and count == smaller(s, i, j)
      decreases i - j
    {
      if s[j] > s[i] { count := count + 1; } else { }
      j := j + 1;
    }
    r := r + count;
    i := i + 1;
  }
}
