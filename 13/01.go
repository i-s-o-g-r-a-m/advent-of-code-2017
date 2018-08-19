package main

import (
	"fmt"
	"io/ioutil"
	"sort"
	"strconv"
	"strings"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func getInput() map[int]int {
	inputFile, err := ioutil.ReadFile("input.txt")
	check(err)
	layers := make(map[int]int)
	for _, line := range strings.Split(strings.TrimSpace(string(inputFile)), "\n") {
		fields := strings.Split(line, ": ")
		depth, err := strconv.Atoi(fields[0])
		check(err)
		scannerRange, err := strconv.Atoi(fields[1])
		check(err)
		layers[depth] = scannerRange
	}
	return layers
}

func minMaxDepths(layers map[int]int) (min, max int) {
	keys := make([]int, 0)
	for k := range layers {
		keys = append(keys, k)
	}
	sort.Ints(keys)
	return keys[0], keys[len(keys)-1]
}

func main() {
	layers := getInput()
	minDepth, maxDepth := minMaxDepths(layers)
	severity := 0

	for tick := minDepth; tick <= maxDepth; tick++ {
		depth := layers[tick]
		if depth != 0 {
			pos := tick % ((depth * 2) - 2)
			if pos == 0 {
				severity += tick * depth
			}
		}
	}

	if severity == 748 {
		fmt.Println("trip severity:", severity)
	} else {
		fmt.Println("wrong:", severity)
	}
}
