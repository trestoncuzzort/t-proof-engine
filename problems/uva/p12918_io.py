"""UVa 12918 Lucky Thief: T cases "n m"; print the minimum number of tries. Model: (m-1) + (m-2) + ... + (m-n)."""


def cases(text):
    t = [int(x) for x in text.split()]
    return [(t[1 + 2 * i], t[2 + 2 * i]) for i in range(t[0])]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
