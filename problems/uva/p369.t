t 1
gate loops
task p369(n: int, m: int) returns (r: int)
  requires 0 <= m and m <= n
  ensures fact(n - m) * fact(m) >= 1
  ensures r == fact(n) / (fact(n - m) * fact(m))
spec fun fact(k: int): int
  decreases k
= if k <= 0 then 1 else k * fact(k - 1)
lemma fact_pos(k: int)
  requires k >= 0
  ensures fact(k) >= 1
  decreases k
{
  if k > 0 {
    fact_pos(k - 1);
  } else {
  }
}
{
  var a: int := 1;
  var i: int := 0;
  while i < n
    invariant 0 <= i and i <= n
    invariant a == fact(i)
    decreases n - i
  {
    i := i + 1;
    a := i * a;
  }
  var b: int := 1;
  var j: int := 0;
  while j < n - m
    invariant 0 <= j and j <= n - m
    invariant b == fact(j)
    decreases n - m - j
  {
    j := j + 1;
    b := j * b;
  }
  var c: int := 1;
  var k: int := 0;
  while k < m
    invariant 0 <= k and k <= m
    invariant c == fact(k)
    decreases m - k
  {
    k := k + 1;
    c := k * c;
  }
  fact_pos(n - m);
  fact_pos(m);
  r := a / (b * c);
}
