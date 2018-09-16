def main():
    puzzle_input = 367
    pos = 0
    buffer_len = 1

    last_val = 0

    for val in range(1, 50_000_000):
        pos = ((pos + puzzle_input) % buffer_len) + 1
        buffer_len += 1
        if pos == 1:
            last_val = val

    print(last_val)
    assert last_val == 25674054, "wrong answer"

if __name__ == "__main__":
    main()
