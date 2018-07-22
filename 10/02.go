package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

var extraLengths = []int{17, 31, 73, 47, 23}

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

func getInput() (input []int) {
	inputFile, err := ioutil.ReadFile("input.txt")
	check(err)
	inputStr := strings.TrimSpace(string(inputFile))
	input = make([]int, len(inputStr))
	for idx, char := range inputStr {
		input[idx] = int(char)
	}
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

func main() {
	input := getInput()
	list := getList()
	pos := 0
	skipSize := 0
	for i := 0; i < translateIterations; i++ {
		pos, skipSize = translate(list, input, pos, skipSize)
	}
	denseHash := sparseToDense(list)
	hexHash := hexHasher(denseHash)
	if hexHash != "90adb097dd55dea8305c900372258ac6" {
		panic(hexHash)
	} else {
		fmt.Println("hash:", hexHash)
	}
}
