package main

import (
	"fmt"
	"strconv"
	"strings"
)

func convertMask(mask int) string {
	var bytes [4]string
	for i := 0; i < 4; i++ {
		// writing from left to right
		if mask >= 8 {
			// if there are more than 8 bits write 255 and substract 8
			bytes[i] = "255"
			mask -= 8
		} else {
			// subtract the remaining bits from 256
			bytes[i] = fmt.Sprint(256 - 1<<(8-uint(mask)))
			mask = 0 // write 0 until we reach 4 bytes
		}
	}
	return strings.Join(bytes[:], ".")
}

func convertHexToBits(hex string) int {
	value, err := strconv.ParseUint(hex, 16, 32)
	if err != nil {
		return 0
	}

	// Count the number of leading ones in the binary representation
	ones := strings.Count(fmt.Sprintf("%032b", value), "1")

	return ones
}
