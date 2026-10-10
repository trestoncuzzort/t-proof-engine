t 1
task flatten2(row: int, col: int, rows: int, cols: int) returns (r: int)
  requires rows > 0 and cols > 0 and 0 <= row and row < rows and 0 <= col and col < cols
  ensures 0 <= r and r < rows * cols
  ensures r / cols == row and r % cols == col
lemma mul_le(u: int, a: int, b: int)
  requires u >= 0 and a <= b
  ensures u * a <= u * b
  decreases u
{
  if u > 0 { mul_le(u - 1, a, b); } else { }
}
lemma quotient(n: int, d: int, q: int, rem: int)
  requires d > 0 and 0 <= rem and rem < d and n == q * d + rem
  ensures n / d == q and n % d == rem
{
  assert n == d * (n / d) + n % d;
  assert 0 <= n % d and n % d < d;
  if n / d < q { mul_le(d, n / d, q - 1); } else { }
  if q < n / d { mul_le(d, q + 1, n / d); } else { }
}
{
  r := row * cols + col;
  quotient(r, cols, row, col);
  mul_le(cols, row + 1, rows);
}
