t 1
gate loops
task p1224(n: int) returns (r: int)
  requires n >= 1
  ensures r == (tt(n) + sym(n)) / 2
spec fun tt(k: int): int
  decreases k
= if k <= 1 then 1 else tt(k - 1) + 2 * tt(k - 2)
spec fun sym(k: int): int
  decreases k
= if k % 2 == 1 then tt((k - 1) / 2) else tt(k / 2) + 2 * tt(k / 2 - 1)
method tiles(k: int) returns (v: int)
  requires k >= 0
  ensures v == tt(k)
{
  var a: int := 1;
  var b: int := 1;
  var i: int := 0;
  while i < k
    invariant 0 <= i and i <= k
    invariant a == tt(i) and b == tt(i + 1)
    decreases k - i
  {
    var c: int := b + 2 * a;
    a := b;
    b := c;
    i := i + 1;
  }
  v := a;
}
{
  var tn: int := tiles(n);
  var s: int := 0;
  if n % 2 == 1 {
    s := tiles((n - 1) / 2);
  } else {
    var h: int := tiles(n / 2);
    var g: int := tiles(n / 2 - 1);
    s := h + 2 * g;
  }
  r := (tn + s) / 2;
}
