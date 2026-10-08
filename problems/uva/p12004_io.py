"""UVa 12004 Bubble Sort: T values n; print the average swap count n(n-1)/4 as an integer or reduced p/q.
The proved task returns m = n(n-1)/2, the average times two; reducing m/2 is this module's two lines."""


def cases(text):
    t = text.split()
    return [(int(x),) for x in t[1:1 + int(t[0])]]


def render(text, calls):
    return "".join(f"Case {i + 1}: {r // 2 if r % 2 == 0 else f'{r}/2'}\n" for i, (_, r) in enumerate(calls))
