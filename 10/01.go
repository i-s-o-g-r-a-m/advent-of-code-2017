package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

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
	inputStr := strings.Split(strings.TrimSpace(string(inputFile)), ",")
	input = make([]int, len(inputStr))
	for i := range inputStr { // imagine if we had a 'map' built-in :-/
		inputInt, err := strconv.Atoi(inputStr[i])
		check(err)
		input[i] = inputInt
	}
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
		offset := pos + sectionLen - c
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

func translate(list []int, input []int, pos int, skipSize int) []int {
	if len(input) > 0 {
		sectionLen := input[0]
		reverseSection(list, pos, sectionLen)
		newPos := pos + sectionLen + skipSize
		if newPos+1 > len(list) {
			newPos = newPos % len(list)
		}
		translate(list, input[1:len(input)], newPos, skipSize+1)
	}
	return list
}

func main() {
	input := getInput()
	list := getList()
	result := translate(list, input, 0, 0)
	answer := result[0] * result[1]
	if answer != 15990 {
		panic("wrong answer!")
	} else {
		fmt.Println("answer:", answer)
	}
}
