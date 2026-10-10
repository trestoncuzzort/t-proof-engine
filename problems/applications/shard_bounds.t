t 1
task shard_bounds(n: int, workers: int, rank: int) returns (r: seq)
  requires n >= 0 and workers > 0 and 0 <= rank and rank < workers
  ensures len(r) == 2 and 0 <= r[0] and r[0] <= r[1] and r[1] <= n
  ensures r[0] == rank * (n / workers) + min(rank, n % workers)
  ensures r[1] == (rank + 1) * (n / workers) + min(rank + 1, n % workers)
  ensures r[1] - r[0] == n / workers + (if rank < n % workers then 1 else 0)
lemma mul_le(u: int, a: int, b: int)
  requires u >= 0 and a <= b
  ensures u * a <= u * b
  decreases u
{
  if u > 0 { mul_le(u - 1, a, b); } else { }
}
lemma partition(n: int, workers: int, rank: int)
  requires n >= 0 and workers > 0 and 0 <= rank and rank < workers
  ensures 0 <= rank * (n / workers) + min(rank, n % workers)
  ensures (rank + 1) * (n / workers) + min(rank + 1, n % workers) <= n
  ensures min(rank + 1, n % workers) == min(rank, n % workers) + (if rank < n % workers then 1 else 0)
{
  assert n == (n / workers) * workers + n % workers;
  assert n / workers >= 0 and 0 <= n % workers and n % workers < workers;
  mul_le(n / workers, rank + 1, workers);
  if rank < n % workers { } else { }
}
{
  partition(n, workers, rank);
  var q: int := n / workers;
  var extra: int := n % workers;
  var start: int := rank * q + min(rank, extra);
  var size: int := q;
  if rank < extra { size := size + 1; } else { }
  r := [start, start + size];
}
