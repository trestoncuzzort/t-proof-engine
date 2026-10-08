"""UVa 495 Fibonacci Freeze: one n per line; print "The Fibonacci number for n is F(n)"."""


def cases(text):
    return [(int(tok),) for tok in text.split()]


def render(text, calls):
    return "".join(f"The Fibonacci number for {args[0]} is {r}\n" for args, r in calls)
