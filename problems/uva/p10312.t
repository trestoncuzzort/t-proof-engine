t 1
gate loops
task p10312(n: int) returns (r: int)
  requires n >= 1
  ensures r == sch(n) - cat(n - 1)
spec fun sch(k: int): int
  decreases k
= if k <= 2 then 1 else (3 * (2 * k - 3) * sch(k - 1) - (k - 3) * sch(k - 2)) / k
spec fun cat(k: int): int
  decreases k
= if k <= 0 then 1 else cat(k - 1) * (4 * k - 2) / (k + 1)
{
  var a: int := 1;
  var b: int := 1;
  var c: int := 1;
  var i: int := 1;
  while i < n
    invariant 1 <= i and i <= n
    invariant a == sch(i) and b == sch(i + 1) and c == cat(i - 1)
    decreases n - i
  {
    var nb: int := (3 * (2 * (i + 2) - 3) * b - (i + 2 - 3) * a) / (i + 2);
    c := c * (4 * i - 2) / (i + 1);
    a := b;
    b := nb;
    i := i + 1;
  }
  r := a - c;
}
