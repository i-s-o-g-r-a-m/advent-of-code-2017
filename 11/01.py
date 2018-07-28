input = open('input.txt').read().strip().split(',')

coords = [0, 0]

directions = {
    's': [0, 1],
    'n': [0, -1],
    'e': [1, 0],
    'w': [-1, 0],
}

for i, move in enumerate(input):
    odd = abs(coords[0]) % 2
    if len(move) == 2:
        d = [x[0] + x[1] for x in zip(directions[move[1]], directions[move[0]])]
        if not odd and move[0] == 's':
            d = [d[0], d[1] - 1]
        if odd and move[0] == 'n':
            d = [d[0], d[1] + 1]
    else:
        d = directions[move]
    coords = [coords[0] + d[0], coords[1] + d[1]]

moves = 0
while coords != [0, 0]:
    odd = abs(coords[0]) % 2
    moves += 1
    if coords[1] != 0:
        coords = [coords[0] + 1, coords[1] - 1 if not odd else coords[1]]
    else:
        coords = [coords[0] + 1, coords[1]]
assert moves == 773
print(moves)
