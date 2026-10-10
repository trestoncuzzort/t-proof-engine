t 1
task interval_intersection(a: int, b: int, c: int, d: int) returns (r: seq)
  requires a <= b and c <= d
  ensures len(r) == 2 and r[0] <= r[1]
  ensures r[0] == max(a, c)
  ensures r[1] == max(r[0], min(b, d))
{
  var lo: int := a;
  if lo < c { lo := c; } else { }
  var hi: int := b;
  if hi > d { hi := d; } else { }
  if hi < lo { hi := lo; } else { }
  r := [lo, hi];
}
