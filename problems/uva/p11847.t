t 1
gate loops
task p11847(n: int) returns (r: int)
  requires n >= 1
  ensures r >= 0 and pow(2, r) <= n and n < pow(2, r + 1)
lemma pow_step(e: int)
  requires e >= 0
  ensures pow(2, e + 1) == 2 * pow(2, e)
{
}
{
  r := 0;
  var p: int := 1;
  while 2 * p <= n
    invariant r >= 0 and p == pow(2, r) and p <= n
    decreases n - p
  {
    pow_step(r);
    p := 2 * p;
    r := r + 1;
  }
  pow_step(r);
}
