t 1
task saturating_add(a: int, b: int, limit: int) returns (r: int)
  requires 0 <= a and a <= limit and 0 <= b and b <= limit
  ensures 0 <= r and r <= limit
  ensures r == (if a + b <= limit then a + b else limit)
{
  if a > limit - b { r := limit; } else { r := a + b; }
}
