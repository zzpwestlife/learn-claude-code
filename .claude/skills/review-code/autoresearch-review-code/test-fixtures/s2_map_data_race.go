package cache

import "sync"

var store = map[string]string{}

// SetAll writes multiple keys concurrently.
// BUG: concurrent map writes without mutex → data race
func SetAll(pairs map[string]string) {
	var wg sync.WaitGroup
	for k, v := range pairs {
		wg.Add(1)
		go func(k, v string) {
			defer wg.Done()
			store[k] = v // RACE: no lock
		}(k, v)
	}
	wg.Wait()
}
