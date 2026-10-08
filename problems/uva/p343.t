t 1
gate loops
task p343(x: seq, y: seq) returns (r: seq)
  requires forall j in [0, len(x)) . 0 <= x[j] and x[j] < 36
  requires forall j in [0, len(y)) . 0 <= y[j] and y[j] < 36
  ensures len(r) == 2
  ensures r[0] == 0 or (2 <= r[0] and r[0] < 37 and 2 <= r[1] and r[1] < 37 and same(x, y, r[0], r[1]))
  ensures r[0] == 0 or (forall b1 in [2, r[0]) . none(x, y, b1))
  ensures r[0] == 0 or (forall b2 in [2, r[1]) . not same(x, y, r[0], b2))
  ensures r[0] != 0 or (forall b1 in [2, 37) . none(x, y, b1))
spec fun valb(s: seq, b: int, k: int): int
  decreases k
= if k <= 0 or k > len(s) then 0 else valb(s, b, k - 1) * b + s[k - 1]
spec fun fits(s: seq, b: int): bool
  decreases len(s)
= forall j in [0, len(s)) . s[j] < b
spec fun same(x: seq, y: seq, b1: int, b2: int): bool
  decreases len(x)
= fits(x, b1) and fits(y, b2) and valb(x, b1, len(x)) == valb(y, b2, len(y))
spec fun none(x: seq, y: seq, b1: int): bool
  decreases len(x)
= forall b2 in [2, 37) . not same(x, y, b1, b2)
method value(s: seq, b: int) returns (v: int)
  ensures v == valb(s, b, len(s))
{
  v := 0;
  var j: int := 0;
  while j < len(s)
    invariant 0 <= j and j <= len(s)
    invariant v == valb(s, b, j)
    decreases len(s) - j
  {
    v := v * b + s[j];
    j := j + 1;
  }
}
method fitsm(s: seq, b: int) returns (f: bool)
  ensures f == fits(s, b)
{
  f := true;
  var j: int := 0;
  while j < len(s)
    invariant 0 <= j and j <= len(s)
    invariant f == (forall k in [0, j) . s[k] < b)
    decreases len(s) - j
  {
    if s[j] >= b {
      f := false;
    } else {
    }
    j := j + 1;
  }
}
method samem(x: seq, y: seq, b1: int, b2: int) returns (e: bool)
  ensures e == same(x, y, b1, b2)
{
  var f1: bool := fitsm(x, b1);
  var f2: bool := fitsm(y, b2);
  var v1: int := value(x, b1);
  var v2: int := value(y, b2);
  e := f1 and f2 and v1 == v2;
}
{
  r := [0, 0];
  var b1: int := 2;
  while b1 < 37
    invariant 2 <= b1 and b1 <= 37
    invariant r == [0, 0]
    invariant forall c1 in [2, b1) . none(x, y, c1)
    decreases 37 - b1
  {
    var b2: int := 2;
    while b2 < 37
      invariant 2 <= b2 and b2 <= 37
      invariant forall c2 in [2, b2) . not same(x, y, b1, c2)
      decreases 37 - b2
    {
      var e: bool := samem(x, y, b1, b2);
      if e {
        return [b1, b2];
      } else {
      }
      b2 := b2 + 1;
    }
    b1 := b1 + 1;
  }
}
