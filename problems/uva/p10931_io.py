"""UVa 10931 Parity: one I per line until 0; print "The parity of B is P (mod 2)." with B = I in binary.
The proved task counts the 1 bits (P); B is Python's own format(I, "b")."""


def cases(text):
    out = []
    for tok in text.split():
        if int(tok) == 0:
            break
        out.append((int(tok),))
    return out


def render(text, calls):
    return "".join(f"The parity of {format(i, 'b')} is {r} (mod 2).\n" for (i,), r in calls)
