"""UVa 11847 Cut the Silver Bar: n per line until 0; print the minimum number of cuts. Model: floor(log2 n)."""


def cases(text):
    out = []
    for t in text.split():
        if int(t) == 0:
            break
        out.append((int(t),))
    return out


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
