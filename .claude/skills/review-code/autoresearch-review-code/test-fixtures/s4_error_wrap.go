package store

import (
	"fmt"
	"os"
)

// ReadConfig reads a config file.
// BUG: uses %v instead of %w — callers cannot use errors.Is / errors.As
func ReadConfig(path string) ([]byte, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("readConfig: %v", err) // should be %w
	}
	return data, nil
}
