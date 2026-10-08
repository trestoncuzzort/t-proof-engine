"""UVa 496 Simply Subsets: pairs of lines, set A then set B; print their relation.
The judge's lines repeat elements despite the statement, so a set is read by membership."""

MESSAGES = ["A is a proper subset of B", "B is a proper subset of A", "A equals B", "A and B are disjoint", "I'm confused!"]


def cases(text):
    lines = text.replace("\r\n", "\n").split("\n")
    while lines and not lines[-1].strip():
        lines.pop()
    return [([int(t) for t in lines[i].split()], [int(t) for t in lines[i + 1].split()]) for i in range(0, len(lines) - 1, 2)]


def render(text, calls):
    return "".join(MESSAGES[r] + "\n" for _, r in calls)
