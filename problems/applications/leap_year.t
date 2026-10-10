t 1
task leap_year(year: int) returns (r: bool)
  ensures r == (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0))
{
  if year % 400 == 0 { r := true; } else {
    if year % 100 == 0 { r := false; } else { r := year % 4 == 0; }
  }
}
