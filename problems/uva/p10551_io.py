"""UVa 10551 Basic Remains: lines "b p m" until "0"; print p mod m as a base-b integer.
The proved task returns p mod m as a number; writing it in base b is this module's loop."""


def cases(text):
    out = []
    toks = text.split()
    i = 0
    while i < len(toks) and toks[i] != "0":
        b, p, m = int(toks[i]), toks[i + 1], toks[i + 2]
        out.append((b, [int(c) for c in p], [int(c) for c in m]))
        i += 3
    return out


def _base(v, b):
    digits = ""
    while v > 0:
        digits = str(v % b) + digits
        v //= b
    return digits or "0"


def render(text, calls):
    return "".join(f"{_base(r, args[0])}\n" for args, r in calls)
