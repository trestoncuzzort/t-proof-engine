"""UVa 10541 Stripe: T cases "N K k1..kK"; print the number of 1xN stripes with that code.
Model (stars and bars): the K black runs need K-1 separating whites; the count is C(N - sum + 1, K), 0 when that
top is below K. The proved task computes both cases: 0, or C(n, m) = n!/((n-m)! m!)."""


def _cases(text):
    t = [int(x) for x in text.split()]
    out, i = [], 1
    for _ in range(t[0]):
        n, k = t[i], t[i + 1]
        code = t[i + 2:i + 2 + k]
        i += 2 + k
        out.append((n - sum(code) + 1, k))
    return out


def cases(text):
    return _cases(text)


def render(text, calls):
    return "".join(f"{r}\n" for _, r in calls)
