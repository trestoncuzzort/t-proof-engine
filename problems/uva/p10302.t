t 1
gate recursion
task p10302(x: int) returns (r: int)
  requires x >= 0
  ensures r == cubes(x)
spec fun cubes(n: int): int
  decreases n
= if n <= 0 then 0 else cubes(n - 1) + n * n * n
lemma nicomachus(n: int)
  requires n >= 0
  ensures 4 * cubes(n) == n * n * (n + 1) * (n + 1)
  decreases n
{
  if n > 0 {
    nicomachus(n - 1);
  } else {
  }
}
{
  nicomachus(x);
  r := x * x * (x + 1) * (x + 1) / 4;
}
