t 1
task unflatten2(index: int, rows: int, cols: int) returns (r: seq)
  requires rows > 0 and cols > 0 and 0 <= index and index < rows * cols
  ensures len(r) == 2 and 0 <= r[0] and r[0] < rows and 0 <= r[1] and r[1] < cols
  ensures r[0] * cols + r[1] == index
{
  r := [index / cols, index % cols];
}
