package main

import (
	"fmt"
	"strconv"
	"strings"
)

const hashKey = "hfdlxzhv"

const denseHashSize = 16
const translateIterations = 64

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func getList() (list []int) {
	list = make([]int, 256)
	for i := range list {
		list[i] = i
	}
	return
}

func getInput(iter int) (input []int) {
	inputStr := strings.TrimSpace(string(hashKey) + "-" + strconv.Itoa(iter))
	input = make([]int, len(inputStr))
	for idx, char := range inputStr {
		input[idx] = int(char)
	}

	extraLengths := []int{17, 31, 73, 47, 23}
	input = append(input, extraLengths...)

	return
}

func reverseSection(list []int, pos int, sectionLen int) {
	c := 0
	secondHalf := make([]int, sectionLen/2+1)
	for c <= sectionLen/2 {
		curPos := pos + c
		if curPos+1 > len(list) {
			curPos = curPos % len(list)
		}
		cur := list[curPos]
		offset := pos + sectionLen - c - 1
		if offset+1 > len(list) {
			offset = offset % len(list)
		}
		secondHalf[c] = list[offset]
		list[offset] = cur
		c += 1
	}
	c = 0
	for c <= sectionLen/2 {
		curPos := pos + c
		if curPos+1 > len(list) {
			curPos = curPos % len(list)
		}
		list[curPos] = secondHalf[c]
		c += 1
	}
}

func translate(list []int, input []int, pos int, skipSize int) (int, int) {
	sectionLen := input[0]
	reverseSection(list, pos, sectionLen)
	newPos := pos + sectionLen + skipSize
	if newPos+1 > len(list) {
		newPos = newPos % len(list)
	}
	tail := input[1:len(input)]
	if len(tail) == 0 {
		return newPos, skipSize + 1
	} else {
		return translate(list, tail, newPos, skipSize+1)
	}
}

func sparseToDense(list []int) (dense []int) {
	dense = make([]int, 0)
	for i := 0; i < len(list); i = i + denseHashSize {
		xord := 0
		for j := i; j < i+denseHashSize; j++ {
			xord = xord ^ list[j]
		}
		dense = append(dense, xord)
	}
	return
}

func hexHasher(list []int) (h string) {
	for i := range list {
		h += fmt.Sprintf("%02x", list[i])
	}
	return
}

func computeHash(row int) string {
	input := getInput(row)
	list := getList()
	pos := 0
	skipSize := 0
	for i := 0; i < translateIterations; i++ {
		pos, skipSize = translate(list, input, pos, skipSize)
	}
	denseHash := sparseToDense(list)
	return hexHasher(denseHash)
}

func hexToBinStr(hex string) (binStr string) {
	for _, char := range hex {
		toInt, err := strconv.ParseInt(string(char), 16, 64)
		check(err)
		toBin := fmt.Sprintf("%04s", strconv.FormatInt(toInt, 2))
		binStr += toBin
	}
	return
}

func computeUsedSquares(rows []string) (used int64) {
	for _, row := range rows {
		for _, square := range row {
			val, err := strconv.ParseInt(string(square), 10, 64)
			check(err)
			used += val
		}
	}
	return
}

func main() {
	rows := make([]string, 0)
	for row := 0; row < 128; row++ {
		hash := computeHash(row)
		binHash := hexToBinStr(hash)
		rows = append(rows, binHash)
	}

	used := computeUsedSquares(rows)
	fmt.Println("used:", used)

	if used != 8230 {
		panic("wrong answer!")
	}
}
