import sys


sys.setrecursionlimit(10000)


def remove_garbage(s, removed=0):
    head, tail = s[0], s[1:]
    if head == "!":
        return remove_garbage(tail[1:], removed)
    elif head == ">":
        return (tail, removed)
    else:
        return remove_garbage(tail, removed + 1)


def parse(s, depth=1, score=0, garbage_removed=0):
    if not s:
        return (score, garbage_removed)

    head, tail = s[0], s[1:]

    if head == "{":
        return parse(tail, depth + 1, score + depth, garbage_removed)
    elif head == "}":
        return parse(tail, depth - 1, score, garbage_removed)
    elif head == "<":
        cleaned_tail, garbage_count = remove_garbage(tail)
        return parse(cleaned_tail, depth, score, garbage_removed + garbage_count)
    else:
        assert head == ",", head
        return parse(tail, depth, score, garbage_removed)


def main():
    with open("input.txt", "r") as data:
        score, garbage_removed = parse(data.read().strip())

    assert score == 14204
    assert garbage_removed == 6622
    print(score)
    print(garbage_removed)


if __name__ == "__main__":
    main()
