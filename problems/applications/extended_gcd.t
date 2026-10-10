t 1
gate loops
task extended_gcd(a: int, b: int) returns (r: seq)
  requires a >= 0 and b >= 0
  ensures len(r) == 3 and r[0] >= 0
  ensures r[0] == gcd_value(a, b) and a * r[1] + b * r[2] == r[0]
spec fun gcd_value(a: int, b: int): int
  decreases max(b, 0)
= if b <= 0 then abs(a) else gcd_value(b, a % b)
lemma bezout_step(a: int, b: int, g: int, rem: int, x: int, y: int, u: int, v: int)
  requires rem > 0 and g == a * x + b * y and rem == a * u + b * v
  ensures g % rem == a * (x - (g / rem) * u) + b * (y - (g / rem) * v)
  ensures gcd_value(g, rem) == gcd_value(rem, g % rem)
{
  assert g == rem * (g / rem) + g % rem;
  assert g - (g / rem) * rem == a * x + b * y - (g / rem) * (a * u + b * v);
}
{
  var g: int := a;
  var rem: int := b;
  var x: int := 1;
  var y: int := 0;
  var u: int := 0;
  var v: int := 1;
  while rem > 0
    invariant g >= 0 and rem >= 0
    invariant g == a * x + b * y and rem == a * u + b * v
    invariant gcd_value(g, rem) == gcd_value(a, b)
    decreases rem
  {
    bezout_step(a, b, g, rem, x, y, u, v);
    var q: int := g / rem;
    var next_rem: int := g % rem;
    var next_x: int := x - q * u;
    var next_y: int := y - q * v;
    g := rem;
    rem := next_rem;
    x := u;
    y := v;
    u := next_x;
    v := next_y;
  }
  r := [g, x, y];
}
