t 1
task p12918(n: int, m: int) returns (r: int)
  requires 1 <= n and n <= m
  ensures 2 * r == 2 * n * m - n * (n + 1)
lemma mod2_shift(x: int, k: int)
  ensures (x + 2 * k) % 2 == x % 2
{
}
lemma even_pair(n: int)
  requires n >= 0
  ensures n * (n + 1) % 2 == 0
  decreases n
{
  if n > 0 {
    even_pair(n - 1);
    assert n * (n + 1) == (n - 1) * n + 2 * n;
    mod2_shift((n - 1) * n, n);
  } else {
  }
}
{
  even_pair(n);
  r := n * m - n * (n + 1) / 2;
}
