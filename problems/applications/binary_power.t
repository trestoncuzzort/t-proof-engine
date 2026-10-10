t 1
gate loops
task binary_power(a: int, n: int) returns (r: int)
  requires n >= 0
  ensures r == power(a, n)
spec fun power(a: int, n: int): int
  decreases n
= if n <= 0 then 1 else a * power(a, n - 1)
lemma square_step(a: int, n: int)
  requires n >= 0
  ensures power(a, n) == (if n % 2 == 0 then power(a * a, n / 2) else a * power(a * a, n / 2))
  decreases n
{
  if n >= 2 {
    square_step(a, n - 2);
    assert n / 2 == (n - 2) / 2 + 1;
    assert power(a, n) == a * a * power(a, n - 2);
    assert power(a * a, n / 2) == a * a * power(a * a, (n - 2) / 2);
  } else { }
}
{
  var base: int := a;
  var exp: int := n;
  r := 1;
  while exp > 0
    invariant exp >= 0 and r * power(base, exp) == power(a, n)
    decreases exp
  {
    square_step(base, exp);
    if exp % 2 == 1 { r := r * base; } else { }
    base := base * base;
    exp := exp / 2;
  }
}
