t 1
gate loops
task p496(a: seq, b: seq) returns (r: int)
  ensures r == (if sub(a, b) and sub(b, a) then 2 else if sub(a, b) then 0 else if sub(b, a) then 1 else if disj(a, b) then 3 else 4)
spec fun sub(x: seq, y: seq): bool
  decreases len(x)
= forall i in [0, len(x)) . exists j in [0, len(y)) . x[i] == y[j]
spec fun disj(x: seq, y: seq): bool
  decreases len(x)
= forall i in [0, len(x)) . forall j in [0, len(y)) . x[i] != y[j]
method has(y: seq, v: int) returns (f: bool)
  ensures f == (exists j in [0, len(y)) . y[j] == v)
{
  f := false;
  var j: int := 0;
  while j < len(y)
    invariant 0 <= j and j <= len(y)
    invariant f == (exists k in [0, j) . y[k] == v)
    decreases len(y) - j
  {
    if y[j] == v {
      f := true;
    } else {
    }
    j := j + 1;
  }
}
method subm(x: seq, y: seq) returns (s: bool)
  ensures s == sub(x, y)
{
  s := true;
  var i: int := 0;
  while i < len(x)
    invariant 0 <= i and i <= len(x)
    invariant s == (forall k in [0, i) . exists j in [0, len(y)) . x[k] == y[j])
    decreases len(x) - i
  {
    var h: bool := has(y, x[i]);
    if not h {
      s := false;
    } else {
    }
    i := i + 1;
  }
}
method disjm(x: seq, y: seq) returns (d: bool)
  ensures d == disj(x, y)
{
  d := true;
  var i: int := 0;
  while i < len(x)
    invariant 0 <= i and i <= len(x)
    invariant d == (forall k in [0, i) . forall j in [0, len(y)) . x[k] != y[j])
    decreases len(x) - i
  {
    var h: bool := has(y, x[i]);
    if h {
      d := false;
    } else {
    }
    i := i + 1;
  }
}
{
  var sa: bool := subm(a, b);
  var sb: bool := subm(b, a);
  var dj: bool := disjm(a, b);
  if sa and sb {
    r := 2;
  } else {
    if sa {
      r := 0;
    } else {
      if sb {
        r := 1;
      } else {
        if dj {
          r := 3;
        } else {
          r := 4;
        }
      }
    }
  }
}
