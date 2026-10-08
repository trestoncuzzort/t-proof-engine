"""UVa 10312 Expression Bracketing: one n per line; print the number of non-binary bracketings of n letters."""


def cases(text):
    return [(int(t),) for t in text.split()]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
