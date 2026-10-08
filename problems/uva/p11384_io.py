"""UVa 11384 Help is needed for Dexter: N per line; print the minimum moves L. Model: the bit length of N."""


def cases(text):
    return [(int(t),) for t in text.split()]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
