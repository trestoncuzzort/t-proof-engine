t 1
task checked_add(a: int, b: int, limit: int) returns (r: bool)
  requires 0 <= a and a <= limit and 0 <= b and b <= limit
  ensures r == (a + b <= limit)
{
  r := a <= limit - b;
}
