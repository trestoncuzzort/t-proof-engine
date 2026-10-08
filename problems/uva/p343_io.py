"""UVa 343 What Base Is This?: pairs "X Y"; print the first bases (base for X outer, base for Y inner, 2..36) in
which they are equal, or that there are none. Digits 0-9 and A-Z are read here as 0..35."""


def _digits(tok):
    return [int(c, 36) for c in tok]


def _pairs(text):
    t = text.split()
    return [(t[i], t[i + 1]) for i in range(0, len(t) - 1, 2)]


def cases(text):
    return [(_digits(a), _digits(b)) for a, b in _pairs(text)]


def render(text, calls):
    out = []
    for (a, b), (_, r) in zip(_pairs(text), calls):
        out.append(f"{a} (base {r[0]}) = {b} (base {r[1]})" if r[0] else f"{a} is not equal to {b} in any base 2..36")
    return "\n".join(out) + "\n"
