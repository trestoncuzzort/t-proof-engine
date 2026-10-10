t 1
task buffer_range(offset: int, length: int, capacity: int) returns (r: bool)
  requires offset >= 0 and length >= 0 and capacity >= 0
  ensures r == (offset + length <= capacity)
{
  r := offset <= capacity and length <= capacity - offset;
}
