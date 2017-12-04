target = 347991
manhattan_dist = 0


iteration = [0]
offset = [0]
def next_spiral():
    vals = range(2, target * 2)
    while True:
        start = offset[0] + (iteration[0] * 8)
        iteration[0] += 1
        offset[0] = start
        take = offset[0] + (iteration[0] * 8)
        yield vals[start:take]


spiral = []
while target not in spiral:
    spiral = list(next((next_spiral())))
    manhattan_dist += 1


side_len = int(len(spiral) // 4)
half_side = side_len // 2


sides = [
    [spiral[-1]] + spiral[0:side_len],
    spiral[side_len - 1:side_len * 2],
    spiral[(side_len * 2) - 1: side_len * 3],
    spiral[(side_len * 3) - 1: side_len * 4],
]
for side in sides:
    if target in side:
        manhattan_dist += abs(half_side - side.index(target))
        break

print(manhattan_dist)
assert manhattan_dist == 480
