t 1
task modular_add(a: int, b: int, m: int) returns (r: int)
  requires m > 0 and 0 <= a and a < m and 0 <= b and b < m
  ensures 0 <= r and r < m and r == (a + b) % m
{
  if a >= m - b { r := a - (m - b); } else { r := a + b; }
}
