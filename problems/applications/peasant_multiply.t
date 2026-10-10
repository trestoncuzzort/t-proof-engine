t 1
gate loops
task peasant_multiply(x: int, y: int) returns (r: int)
  requires y >= 0
  ensures r == x * y
lemma double_step(x: int, y: int, a: int, b: int, total: int)
  requires b > 0 and total + a * b == x * y
  ensures total + (if b % 2 == 1 then a else 0) + (2 * a) * (b / 2) == x * y
{
  assert b == 2 * (b / 2) + b % 2;
  assert 0 <= b % 2 and b % 2 < 2;
  if b % 2 == 0 { } else { assert b % 2 == 1; }
}
{
  var a: int := x;
  var b: int := y;
  r := 0;
  while b > 0
    invariant b >= 0 and r + a * b == x * y
    decreases b
  {
    double_step(x, y, a, b, r);
    if b % 2 == 1 { r := r + a; } else { }
    a := 2 * a;
    b := b / 2;
  }
}
