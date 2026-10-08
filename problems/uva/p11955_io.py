"""UVa 11955 Binomial Theorem: T lines "(a+b)^k"; print "Case N: " and the expansion. The proved task gives each
coefficient C(k, i) = k!/((k-i)! i!) as the statement defines x_i; spelling out the terms is this module."""
import re


def _parse(text):
    lines = [ln.strip() for ln in text.splitlines() if ln.strip()]
    out = []
    for ln in lines[1:1 + int(lines[0])]:
        a, b, k = re.fullmatch(r"\((\w+)\+(\w+)\)\^(\d+)", ln).groups()
        out.append((a, b, int(k)))
    return out


def cases(text):
    return [(k, i) for _, _, k in _parse(text) for i in range(k + 1)]


def _pw(v, e):
    return "" if e == 0 else v if e == 1 else f"{v}^{e}"


def render(text, calls):
    coef = {args: r for args, r in calls}
    lines = []
    for n, (a, b, k) in enumerate(_parse(text), 1):
        terms = []
        for i in range(k + 1):
            parts = [p for p in (str(coef[(k, i)]) if coef[(k, i)] != 1 else "", _pw(a, k - i), _pw(b, i)) if p]
            terms.append("*".join(parts))
        lines.append(f"Case {n}: " + "+".join(terms))
    return "\n".join(lines) + "\n"
