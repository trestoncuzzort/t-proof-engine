t 1
gate loops
task p264(k: int) returns (r: seq)
  requires k >= 1
  ensures len(r) == 2 and r[0] >= 1 and r[1] >= 1
  ensures tri(r[0] + r[1] - 2) < k and k <= tri(r[0] + r[1] - 1)
  ensures k == tri(r[0] + r[1] - 2) + (if (r[0] + r[1] - 1) % 2 == 0 then r[0] else r[1])
spec fun tri(d: int): int
  decreases 0
= d * (d + 1) / 2
{
  var d: int := 1;
  while d * (d + 1) / 2 < k
    invariant d >= 1 and (d - 1) * d / 2 < k
    decreases k - d
  {
    d := d + 1;
  }
  var e: int := k - (d - 1) * d / 2;
  if d % 2 == 0 {
    r := [e, d + 1 - e];
  } else {
    r := [d + 1 - e, e];
  }
}
