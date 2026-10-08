"""UVa 11231 Black and white painting: lines "n m c" until "0 0 0"; print the number of 8x8 chess boards whose
bottom-right square is white."""


def cases(text):
    t = [int(x) for x in text.split()]
    out = []
    for i in range(0, len(t) - 2, 3):
        if t[i] == 0 and t[i + 1] == 0 and t[i + 2] == 0:
            break
        out.append((t[i], t[i + 1], t[i + 2]))
    return out


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
