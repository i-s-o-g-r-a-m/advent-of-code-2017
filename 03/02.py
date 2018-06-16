from numpy import matrix, concatenate as npcat


class S:

    def __init__(self, target):
        self.target = target
        self.iteration = 0
        self.offset = 0
        self.m = matrix('1')

    def gen_spiral(self):
        vals = range(2, self.target * 2)
        while True:
            start = self.offset + (self.iteration * 8)
            self.iteration += 1
            self.offset = start
            take = self.offset + (self.iteration * 8)
            yield vals[start:take]

    def spiral(self):
        return list(next(self.gen_spiral()))

    def populate_spiral(self):
        new_m = npcat((matrix('0 ' * len(self.m[0].A[0])), self.m), axis=0)
        new_m = npcat((new_m, matrix(('0 ;' * len(new_m))[:-1])), axis=1)
        new_m = npcat((matrix(('0 ;' * len(new_m))[:-1]), new_m), axis=1)
        new_m = npcat((new_m, matrix('0 ' * len(new_m[0].A[0]))), axis=0)
        self.m = new_m

    def nabe_sum(self, row, col):
        coords = [
            (row - 1, col),
            (row - 1, col - 1),
            (row - 1, col + 1),
            (row, col - 1),
            (row, col + 1),
            (row + 1, col),
            (row + 1, col - 1),
            (row + 1, col + 1),
        ]
        vals = []
        for c in coords:
            if c[1] < 0:
                continue
            try:
                val = self.m[c[0]].A1[c[1]]
            except IndexError:
                continue
            vals.append(val)
        return sum(vals)

    def update_cell(self, coords, val):
        rows_before = self.m[0:coords[0]]
        row = self.m[coords[0]]
        rows_after = self.m[coords[0] + 1:]
        row.A1[coords[1]] = val
        self.m = (npcat((rows_before, row, rows_after)))

    def add_spiral_till_target(self):
        while True:
            spiral_len = len(self.spiral())
            side_len = int(spiral_len // 4)
            self.populate_spiral()

            for side in range(0, 4):
                for c in range(1, side_len + 1):
                    if side == 0:
                        start_row = len(self.m) - 1
                        coords = (start_row - c, (len(self.m[0].A1) - 1))
                        cell_sum = self.nabe_sum(*coords)
                        self.update_cell(coords, cell_sum)
                    elif side == 1:
                        start_col = len(self.m[0].A1) - 1
                        coords = (0, start_col - c)
                        cell_sum = self.nabe_sum(*coords)
                        self.update_cell(coords, cell_sum)
                    elif side == 2:
                        start_row = 0
                        coords = (start_row + c, 0)
                        cell_sum = self.nabe_sum(*coords)
                        self.update_cell(coords, cell_sum)
                    elif side == 3:
                        start_col = 0
                        coords = (len(self.m) - 1, start_col + c)
                        cell_sum = self.nabe_sum(*coords)
                        self.update_cell(coords, cell_sum)
                    if cell_sum > self.target:
                        return cell_sum

if __name__ == "__main__":
    s = S(347991)
    found = s.add_spiral_till_target()
    print(found)
    assert found == 349975
