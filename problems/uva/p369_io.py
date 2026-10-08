"""UVa 369 Combinations: lines "N M" until "0 0"; print "N things taken M at a time is C exactly."."""


def _pairs(text):
    nums = [int(t) for t in text.split()]
    out = []
    for i in range(0, len(nums) - 1, 2):
        n, m = nums[i], nums[i + 1]
        if n == 0 and m == 0:
            break
        out.append((n, m))
    return out


def cases(text):
    return _pairs(text)


def render(text, calls):
    return "".join(f"{n} things taken {m} at a time is {r} exactly.\n" for (n, m), r in calls)
