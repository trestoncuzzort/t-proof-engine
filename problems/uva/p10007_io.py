"""UVa 10007 Count the Trees: n per line until 0; print the number of labeled binary trees on n elements."""


def cases(text):
    out = []
    for t in text.split():
        if int(t) == 0:
            break
        out.append((int(t),))
    return out


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
