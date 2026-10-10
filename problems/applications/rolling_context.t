t 1
task rolling_context(s: seq, capacity: int) returns (r: seq)
  requires capacity > 0
  ensures len(r) == min(len(s), capacity)
  ensures forall i in [0, len(r)) . r[i] == s[len(s) - len(r) + i]
{
  var start: int := 0;
  if len(s) > capacity { start := len(s) - capacity; } else { }
  r := s[start..len(s)];
}
