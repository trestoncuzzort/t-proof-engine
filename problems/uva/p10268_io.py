"""UVa 10268 498-bis: pairs of lines, x then a0 .. an; print the derivative at x."""


def cases(text):
    lines = [ln for ln in text.splitlines() if ln.strip()]
    out = []
    for i in range(0, len(lines) - 1, 2):
        out.append((int(lines[i]), [int(t) for t in lines[i + 1].split()]))
    return out


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
