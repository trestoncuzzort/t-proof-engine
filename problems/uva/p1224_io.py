"""UVa 1224 Tile Code: T, then T values n; print the number of tile codes of length n up to flipping."""


def cases(text):
    t = text.split()
    return [(int(x),) for x in t[1:1 + int(t[0])]]


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
