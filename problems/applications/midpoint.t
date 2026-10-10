t 1
task midpoint(lo: int, hi: int) returns (r: int)
  requires 0 <= lo and lo <= hi and hi <= 2147483647
  ensures lo <= r and r <= hi
  ensures 2 * r <= lo + hi and lo + hi < 2 * r + 2
  ensures 0 <= hi - lo and hi - lo <= 2147483647
{
  r := lo + (hi - lo) / 2;
}
