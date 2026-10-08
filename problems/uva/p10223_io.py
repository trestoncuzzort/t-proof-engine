"""UVa 10223 How many nodes?: one Catalan number per line; print the smallest n >= 1 with C(n) equal to it."""


def cases(text):
    return [(int(t),) for t in text.split()]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
