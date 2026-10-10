t 1
task batch_bounds(n: int, b: int, i: int) returns (r: seq)
  requires n >= 0 and b > 0 and i >= 0 and i * b < n
  ensures len(r) == 2 and r[0] == i * b
  ensures 0 <= r[0] and r[0] < r[1] and r[1] <= n
  ensures r[1] - r[0] <= b
  ensures r[1] == n or r[1] - r[0] == b
{
  var start: int := i * b;
  if n - start < b { r := [start, n]; } else { r := [start, start + b]; }
}
