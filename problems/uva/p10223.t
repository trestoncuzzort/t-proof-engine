t 1
gate loops
task p10223(x: int) returns (r: int)
  requires exists k in [1, 40) . cat(k) == x
  ensures 1 <= r and r < 40 and cat(r) == x
  ensures forall k in [1, r) . cat(k) != x
spec fun cat(k: int): int
  decreases k
= if k <= 0 then 1 else cat(k - 1) * (4 * k - 2) / (k + 1)
{
  r := 1;
  var c: int := 1;
  while c != x
    invariant 1 <= r and r < 40
    invariant c == cat(r)
    invariant forall k in [1, r) . cat(k) != x
    invariant exists k in [r, 40) . cat(k) == x
    decreases 40 - r
  {
    r := r + 1;
    c := c * (4 * r - 2) / (r + 1);
  }
}
