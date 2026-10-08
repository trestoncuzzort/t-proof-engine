t 1
gate recursion
task p12004(n: int) returns (r: int)
  requires n >= 1
  ensures 2 * r == n * (n - 1)
lemma mod2_shift(x: int, k: int)
  ensures (x + 2 * k) % 2 == x % 2
{
}
lemma even_pair(n: int)
  requires n >= 1
  ensures n * (n - 1) % 2 == 0
  decreases n
{
  if n > 1 {
    even_pair(n - 1);
    assert n * (n - 1) == (n - 1) * (n - 2) + 2 * (n - 1);
    mod2_shift((n - 1) * (n - 2), n - 1);
  } else {
  }
}
{
  even_pair(n);
  r := n * (n - 1) / 2;
}
