package api

import (
	"encoding/json"
	"net/http"
	"time"
)

// SlowHandler calls an external service but ignores the request context.
// BUG: if client disconnects, the expensive call still runs to completion.
func SlowHandler(w http.ResponseWriter, r *http.Request) {
	// ctx := r.Context() is never used
	result, err := expensiveExternalCall()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(result)
}

func expensiveExternalCall() (string, error) {
	time.Sleep(5 * time.Second) // simulated slow call, not context-aware
	return "ok", nil
}
