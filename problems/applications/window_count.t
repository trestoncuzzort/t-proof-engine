t 1
task window_count(n: int, block: int) returns (r: int)
  requires n >= 0 and block >= 1
  ensures r >= 0
  ensures forall start in [0, r) . fits(n, block, start)
  ensures r + block >= n
  ensures (r == 0) == (n <= block)
spec fun fits(n: int, block: int, start: int): bool
  decreases 0
= start + block < n
{
  r := max(n - block, 0);
}
