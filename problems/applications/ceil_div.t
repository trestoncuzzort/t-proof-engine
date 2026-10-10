t 1
task ceil_div(n: int, d: int) returns (r: int)
  requires d > 0
  ensures (r - 1) * d < n and n <= r * d
{
  r := -( (-n) / d );
}
