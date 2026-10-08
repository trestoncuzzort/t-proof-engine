"""UVa 12712 Pattern Locker: T cases "L M N"; print "Case X: count mod 10000000000007"."""


def cases(text):
    t = text.split()
    k = int(t[0])
    return [(int(t[1 + 3 * i]) ** 2, int(t[2 + 3 * i]), int(t[3 + 3 * i])) for i in range(k)]


def render(text, calls):
    return "".join(f"Case {i + 1}: {r}\n" for i, (_, r) in enumerate(calls))
