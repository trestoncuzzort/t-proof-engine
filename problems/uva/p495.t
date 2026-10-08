t 1
gate loops
task p495(n: int) returns (r: int)
  requires n >= 0
  ensures r == F(n)
spec fun F(i: int): int
  decreases i
= if i <= 0 then 0 else if i == 1 then 1 else F(i - 1) + F(i - 2)
{
  var a: int := 0;
  var b: int := 1;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant a == F(i) and b == F(i + 1)
    decreases n - i
  {
    var c: int := a + b;
    a := b;
    b := c;
    i := i + 1;
  }
  r := a;
}
