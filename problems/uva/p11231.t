t 1
gate recursion
task p11231(n: int, m: int, c: int) returns (r: int)
  requires n >= 8 and m >= 8 and (c == 0 or c == 1)
  ensures r == grid(n, m, c, 7)
spec fun white(n: int, m: int, c: int, i: int, j: int): bool
  decreases 0
= (n - 1 - i + (m - 1 - j)) % 2 == 1 - c
spec fun row(n: int, m: int, c: int, i: int, k: int): int
  decreases m - k
= if k >= m then 0 else (if white(n, m, c, i, k) then 1 else 0) + row(n, m, c, i, k + 1)
spec fun grid(n: int, m: int, c: int, k: int): int
  decreases n - k
= if k >= n then 0 else row(n, m, c, k, 7) + grid(n, m, c, k + 1)
lemma row_pair(n: int, m: int, c: int, i: int, k: int)
  requires k <= m and (c == 0 or c == 1)
  ensures row(n, m, c, i, k) + row(n, m, c, i + 1, k) == m - k
  decreases m - k
{
  if k < m {
    row_pair(n, m, c, i, k + 1);
  } else {
  }
}
lemma last_row(n: int, m: int, c: int, k: int)
  requires k <= m and (c == 0 or c == 1)
  ensures row(n, m, c, n - 1, k) == (m - k + c) / 2
  decreases m - k
{
  if k < m {
    last_row(n, m, c, k + 1);
  } else {
  }
}
lemma grid_closed(n: int, m: int, c: int, k: int)
  requires k <= n and m >= 7 and (c == 0 or c == 1)
  ensures grid(n, m, c, k) == ((n - k) * (m - 7) + c) / 2
  decreases n - k
{
  if k <= n - 2 {
    grid_closed(n, m, c, k + 2);
    row_pair(n, m, c, k, 7);
    assert (n - k) * (m - 7) == (n - k - 2) * (m - 7) + 2 * (m - 7);
  } else {
    if k == n - 1 {
      last_row(n, m, c, 7);
    } else {
    }
  }
}
{
  grid_closed(n, m, c, 7);
  r := ((n - 7) * (m - 7) + c) / 2;
}
