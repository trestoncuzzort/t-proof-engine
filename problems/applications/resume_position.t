t 1
task resume_position(completed: int, per_epoch: int) returns (r: seq)
  requires completed >= 0 and per_epoch > 0
  ensures len(r) == 2 and r[0] >= 0 and 0 <= r[1] and r[1] < per_epoch
  ensures r[0] * per_epoch + r[1] == completed
{
  r := [completed / per_epoch, completed % per_epoch];
}
