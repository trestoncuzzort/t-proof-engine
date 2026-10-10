t 1
task full_batches(n: int, b: int) returns (r: int)
  requires n >= 0 and b > 0
  ensures r >= 0 and r * b <= n and n < (r + 1) * b
  ensures (r > 0) == (n >= b)
{
  r := n / b;
}
