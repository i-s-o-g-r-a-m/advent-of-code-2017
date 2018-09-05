puzzle_input = 2147483647


def gen(factor, previous):
    while True:
        new = (previous * factor) % puzzle_input
        yield new
        previous = new


if __name__ == "__main__":
    a = gen(16807, 783)
    b = gen(48271, 325)

    matches = 0

    c = 0
    for z in zip(a, b):
        if "{0:b}".format(z[0])[-16:] == "{0:b}".format(z[1])[-16:]:
            matches += 1
        c += 1
        if c == 40_000_000:
            break

    print(matches)
    assert matches == 650, "wrong answer!"
