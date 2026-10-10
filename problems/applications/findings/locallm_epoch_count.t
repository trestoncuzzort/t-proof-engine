t 1
task locallm_epoch_count(n: int, b: int) returns (r: int)
  requires n >= 0 and b > 0
  ensures r >= 0 and r * b <= n and n < (r + 1) * b
{
  r := max(n / b, 1);
}
