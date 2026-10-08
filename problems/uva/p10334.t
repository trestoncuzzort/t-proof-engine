t 1
gate loops
task p10334(n: int) returns (r: int)
  requires n >= 0
  ensures r == ways(n)
spec fun ways(k: int): int
  decreases k
= if k <= 0 then 1 else if k == 1 then 2 else ways(k - 1) + ways(k - 2)
{
  var a: int := 1;
  var b: int := 2;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant a == ways(i) and b == ways(i + 1)
    decreases n - i
  {
    var c: int := a + b;
    a := b;
    b := c;
    i := i + 1;
  }
  r := a;
}
