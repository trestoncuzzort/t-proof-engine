"""UVa 264 Count on Cantor: one term number per line; print "TERM k IS p/q" in Cantor's zigzag enumeration."""


def cases(text):
    return [(int(t),) for t in text.split()]


def render(text, calls):
    return "".join(f"TERM {args[0]} IS {r[0]}/{r[1]}\n" for args, r in calls)
