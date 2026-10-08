"""UVa 575 Skew Binary: one skew-binary number per line until "0"; print its decimal value."""


def cases(text):
    out = []
    for tok in text.split():
        if tok == "0":
            break
        out.append(([int(c) for c in tok],))
    return out


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
