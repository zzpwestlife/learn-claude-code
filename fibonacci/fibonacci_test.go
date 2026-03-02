// INPUT: Test file for fibonacci package
// OUTPUT: Test suite for Fibonacci and FibonacciSequence functions
// POS: fibonacci/fibonacci_test.go

package fibonacci

import (
	"testing"
)

func TestFibonacci(t *testing.T) {
	tests := []struct {
		name    string
		input   int
		want    uint
		wantErr bool
	}{
		{"zero", 0, 0, false},
		{"one", 1, 1, false},
		{"five", 5, 5, false},
		{"ten", 10, 55, false},
		{"negative", -1, 0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := Fibonacci(tt.input)
			if (err != nil) != tt.wantErr {
				t.Errorf("Fibonacci(%d) error = %v, wantErr %v", tt.input, err, tt.wantErr)
				return
			}
			if !tt.wantErr && got != tt.want {
				t.Errorf("Fibonacci(%d) = %d, want %d", tt.input, got, tt.want)
			}
		})
	}
}

func TestFibonacciSequence(t *testing.T) {
	tests := []struct {
		name    string
		input   int
		want    []uint
		wantErr bool
	}{
		{"empty", 0, []uint{}, false},
		{"one", 1, []uint{0}, false},
		{"five", 5, []uint{0, 1, 1, 2, 3}, false},
		{"negative", -1, nil, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := FibonacciSequence(tt.input)
			if (err != nil) != tt.wantErr {
				t.Errorf("FibonacciSequence(%d) error = %v, wantErr %v", tt.input, err, tt.wantErr)
				return
			}
			if !tt.wantErr && !slicesEqual(got, tt.want) {
				t.Errorf("FibonacciSequence(%d) = %v, want %v", tt.input, got, tt.want)
			}
		})
	}
}

func slicesEqual(a, b []uint) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

func BenchmarkFibonacci(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Fibonacci(20)
	}
}
