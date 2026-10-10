t 1
task normalize_index(i: int, n: int) returns (r: int)
  requires n >= 0
  ensures (r == -1) == (i < -n or i >= n)
  ensures r == -1 or (0 <= r and r < n and (r == i or r == i + n))
{
  var j: int := i;
  if j < 0 { j := j + n; } else { }
  if 0 <= j and j < n { r := j; } else { r := -1; }
}
