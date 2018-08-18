package main

import (
	"fmt"
	"io/ioutil"
	"sort"
	"strconv"
	"strings"
)

type position struct {
	current int
	last    int
}

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

func updateScanPos(scanPos map[int]position, layers map[int]int) map[int]position {
	for k := range scanPos {
		depth := layers[k]
		currentPos := scanPos[k].current
		lastPos := scanPos[k].last

		switch {
		case currentPos > lastPos:
			if currentPos+1 == depth {
				scanPos[k] = position{current: currentPos - 1, last: currentPos}
			} else {
				scanPos[k] = position{current: currentPos + 1, last: currentPos}
			}
		case currentPos < lastPos:
			if currentPos == 0 {
				scanPos[k] = position{current: currentPos + 1, last: currentPos}
			} else {
				scanPos[k] = position{current: currentPos - 1, last: currentPos}
			}
		default:
			panic("well that's embarassing")
		}
	}

	return scanPos
}

func computeSeverity(caughtLayers []int, layers map[int]int) (severity int) {
	for _, caught := range caughtLayers {
		depth := layers[caught]
		severity += caught * depth
	}
	return
}

func main() {
	layers := getInput()
	minDepth, maxDepth := minMaxDepths(layers)
	caughtLayers := make([]int, 0)
	scanPos := make(map[int]position)

	for k := range layers {
		scanPos[k] = position{current: 0, last: -1}
	}

	for tick := minDepth; tick <= maxDepth; tick++ {
		currentDepth := layers[tick]
		if currentDepth != 0 {
			if scanPos[tick].current == 0 {
				caughtLayers = append(caughtLayers, tick)
			}
		}
		updateScanPos(scanPos, layers)
	}

	tripSeverity := computeSeverity(caughtLayers, layers)
	if tripSeverity == 748 {
		fmt.Println("trip severity:", tripSeverity)
	} else {
		panic("wrong answer")
	}
}
