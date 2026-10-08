"""UVa 991 Safe Salutations: datasets n (blank-line separated); print the count, a blank line between datasets."""


def cases(text):
    return [(int(t),) for t in text.split()]


def render(text, calls):
    return "\n".join(f"{r}\n" for _, r in calls)
