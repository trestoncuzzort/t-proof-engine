"""UVa 11526 H(n): T, then T signed 32-bit integers n; print H(n) for each."""


def cases(text):
    toks = text.split()
    t = int(toks[0])
    return [(int(x),) for x in toks[1:1 + t]]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
