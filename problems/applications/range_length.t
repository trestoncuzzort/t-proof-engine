t 1
task range_length(start: int, stop: int, step: int) returns (r: int)
  requires step > 0
  ensures r >= 0 and ((r == 0) == (stop <= start))
  ensures r == 0 or (start + (r - 1) * step < stop and stop <= start + r * step)
{
  if start >= stop { r := 0; } else { r := 1 + (stop - 1 - start) / step; }
}
