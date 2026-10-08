"""UVa 10334 Ray Through Glasses: one n per line; print the number of ray paths with n reflections."""


def cases(text):
    return [(int(t),) for t in text.split()]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
