t 1
task quotient_remainder(n: int, d: int) returns (r: seq)
  requires d > 0
  ensures len(r) == 2
  ensures n == r[0] * d + r[1] and 0 <= r[1] and r[1] < d
{
  var q: int := n / d;
  r := [q, n - q * d];
}
