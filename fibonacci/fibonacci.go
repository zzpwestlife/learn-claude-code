// INPUT: Package fibonacci provides Fibonacci sequence implementations
// OUTPUT: Core Fibonacci computation functions
// POS: fibonacci/fibonacci.go

// Package fibonacci implements the Fibonacci sequence using an iterative approach.
package fibonacci

import (
	"errors"
)

// Fibonacci returns the nth Fibonacci number.
// Returns an error if n is negative.
// Time complexity: O(n), Space complexity: O(1)
func Fibonacci(n int) (uint, error) {
	if n < 0 {
		return 0, errors.New("Fibonacci: negative input not allowed")
	}

	if n == 0 {
		return 0, nil
	}
	if n == 1 {
		return 1, nil
	}

	var prev, curr uint = 0, 1
	for i := 2; i <= n; i++ {
		prev, curr = curr, prev+curr
	}

	return curr, nil
}

// FibonacciSequence returns the first n Fibonacci numbers.
// Returns an error if n is negative.
func FibonacciSequence(n int) ([]uint, error) {
	if n < 0 {
		return nil, errors.New("FibonacciSequence: negative input not allowed")
	}
	if n == 0 {
		return []uint{}, nil
	}
	if n == 1 {
		return []uint{0}, nil
	}

	result := make([]uint, n)
	result[1] = 1

	for i := 2; i < n; i++ {
		result[i] = result[i-1] + result[i-2]
	}

	return result, nil
}
