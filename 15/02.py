puzzle_input = 2147483647


def gen(factor, divisible, previous):
    def get_new(prev, fact):
        return (prev * fact) % puzzle_input

    while True:
        new = get_new(previous, factor)
        while new % divisible != 0:
            previous = new
            new = get_new(previous, factor)
        yield new
        previous = new


if __name__ == "__main__":
    a = gen(16807, 4, 783)
    b = gen(48271, 8, 325)

    matches = 0

    c = 0
    for z in zip(a, b):
        if "{0:b}".format(z[0])[-16:] == "{0:b}".format(z[1])[-16:]:
            matches += 1
        c += 1
        if c == 5_000_000:
            break

    print(matches)
    assert matches == 336, "wrong answer!"
