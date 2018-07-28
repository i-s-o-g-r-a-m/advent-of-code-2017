def traverse_grid(input):
    directions = {"s": [0, 1], "n": [0, -1], "e": [1, 0], "w": [-1, 0]}

    max_distance = 0

    coords = [0, 0]
    for move in input:
        odd = abs(coords[0]) % 2
        if len(move) == 2:
            d = [x[0] + x[1] for x in zip(directions[move[1]], directions[move[0]])]
            if not odd and move[0] == "s":
                d = [d[0], d[1] - 1]
            if odd and move[0] == "n":
                d = [d[0], d[1] + 1]
        else:
            d = directions[move]
        coords = [coords[0] + d[0], coords[1] + d[1]]
        dist = go_home(coords)
        if dist > max_distance:
            max_distance = dist

    return (coords, max_distance)


def find_direction(from_pos, to_pos):
    if from_pos == to_pos:
        raise Exception("...")
    lat, lng = "", ""
    if from_pos[1] > to_pos[1]:
        lat = "n"
    elif from_pos[1] < to_pos[1]:
        lat = "s"
    if from_pos[0] > to_pos[0]:
        lng = "w"
    elif from_pos[0] < to_pos[0]:
        lng = "e"
    direction = lat + lng
    assert direction != ""
    return direction


def go_home(position):
    direction = find_direction(from_pos=position, to_pos=(0, 0))

    moves = 0
    diagonal_done = False

    while position != [0, 0]:
        even = not abs(position[0]) % 2
        moves += 1

        if 0 in position and not diagonal_done:
            direction = find_direction(from_pos=position, to_pos=(0, 0))
            diagonal_done = True

        if len(direction) == 2:
            if direction == "ne":
                position = [position[0] + 1, position[1] - 1 if even else position[1]]
            elif direction == "nw":
                position = [position[0] - 1, position[1] - 1 if even else position[1]]
            elif direction == "sw":
                position = [position[0] - 1, position[1] + 1 if even else position[1]]
            elif direction == "se":
                position = [position[0] + 1, position[1] + 1 if even else position[1]]
            else:
                raise Exception("unknown direction {}".format(direction))
        else:
            assert len(direction) == 1
            if direction == "s":
                position = [position[0], position[1] + 1]
            elif direction == "n":
                position = [position[0], position[1] - 1]
            elif direction == "e":
                position = [position[0] + 1, position[1]]
            elif direction == "w":
                position = [position[0] - 1, position[1]]
            else:
                raise Exception("unknown direction {}".format(direction))

    return moves


def main():
    initial_moves = open("input.txt").read().strip().split(",")
    position, max_dist = traverse_grid(initial_moves)
    return_home_steps = go_home(position)
    print(return_home_steps)
    print(max_dist)
    assert return_home_steps == 773
    assert max_dist == 1560


if __name__ == "__main__":
    main()
