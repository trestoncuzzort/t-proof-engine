"""UVa 10302 Summation of Polynomials: one x per line; print 1^3 + 2^3 + ... + x^3."""


def cases(text):
    return [(int(tok),) for tok in text.split()]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
