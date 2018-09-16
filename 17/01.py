import copy

from typing import List


class RingBuffer:
    def __init__(self) -> None:
        self._data = []  # type: List[int]
        self._position = 0

    def move(self, steps: int) -> None:
        new_pos = self._position + steps
        data_len = len(self._data)
        self._position = new_pos % data_len

    def insert(self, value: int) -> None:
        self._data.insert(self._position + 1, value)
        self.move(1)

    @property
    def current_val(self) -> int:
        return self._data[self._position]

    @property
    def data(self) -> List[int]:
        return copy.deepcopy(self._data)


def main():
    buffer = RingBuffer()
    buffer.insert(0)

    puzzle_input = 367

    for val in range(1, 2018):
        buffer.move(puzzle_input)
        buffer.insert(val)
    buffer.move(1)

    print(buffer.current_val)
    assert buffer.current_val == 1487, "wrong answer"


if __name__ == "__main__":
    main()
