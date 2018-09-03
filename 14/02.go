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

func hexToBin(hex string) (binVals []int64) {
	binStr := ""
	for _, char := range hex {
		toInt, err := strconv.ParseInt(string(char), 16, 64)
		check(err)
		toBin := fmt.Sprintf("%04s", strconv.FormatInt(toInt, 2))
		binStr += toBin
	}
	for _, s := range binStr {
		binVal, err := strconv.ParseInt(string(s), 10, 64)
		check(err)
		binVals = append(binVals, binVal)
	}
	return binVals
}

func computeUsedSquares(rows [][]int64) (used int64) {
	for _, row := range rows {
		for _, square := range row {
			used += square
		}
	}
	return
}

func immediateNeighbors(row int, col int, matrix [][]int64) (neighbors []string) {
	if row > 0 && matrix[row-1][col] == 1 {
		neighbors = append(neighbors, strconv.Itoa(row-1)+"-"+strconv.Itoa(col))
	}
	if col > 0 && matrix[row][col-1] == 1 {
		neighbors = append(neighbors, strconv.Itoa(row)+"-"+strconv.Itoa(col-1))
	}
	if col < len(matrix[row])-1 && matrix[row][col+1] == 1 {
		neighbors = append(neighbors, strconv.Itoa(row)+"-"+strconv.Itoa(col+1))
	}
	if row < len(matrix)-1 && matrix[row+1][col] == 1 {
		neighbors = append(neighbors, strconv.Itoa(row+1)+"-"+strconv.Itoa(col))
	}
	return
}

func unknownRegion(id string, regions [][]string) bool {
	for _, r := range regions {
		for _, val := range r {
			if id == val {
				return false
			}
		}
	}
	return true
}

func mapRegion(
	neighbors []string,
	lookup map[string][]string,
	accum map[string]int,
) map[string]int {
	for _, n := range neighbors {
		if accum[n] == 0 {
			accum[n] = 1
			for k, _ := range mapRegion(lookup[n], lookup, accum) {
				if accum[k] == 0 {
					accum[k] = 1
				}
			}
		}
	}
	return accum
}

func getRegion(id string, lookup map[string][]string) (region []string) {
	region = append(region, id)
	for k, _ := range mapRegion(lookup[id], lookup, make(map[string]int)) {
		region = append(region, k)
	}
	return region
}

func countRegions(matrix [][]int64) (count int) {
	neighbors := make(map[string][]string)
	regions := make([][]string, 0)

	for rowIdx, row := range matrix {
		for colIdx, val := range row {
			if val == 1 {
				id := strconv.Itoa(rowIdx) + "-" + strconv.Itoa(colIdx)
				neighbors[id] = immediateNeighbors(rowIdx, colIdx, matrix)
			}
		}
	}

	for k, _ := range neighbors {
		if unknownRegion(k, regions) {
			region := getRegion(k, neighbors)
			regions = append(regions, region)
		}
	}

	return len(regions)
}

func main() {
	matrix := make([][]int64, 0)
	for row := 0; row < 128; row++ {
		hash := computeHash(row)
		binHash := hexToBin(hash)
		matrix = append(matrix, binHash)
	}

	regions := countRegions(matrix)
	fmt.Println(regions)
	if regions != 1103 {
		panic("wrong answer!")
	}
}
