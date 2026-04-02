package db

import "database/sql"

// GetUser fetches a user by ID.
func GetUser(dsn string, id int) (string, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return "", err
	}
	// BUG: db.Close() is never deferred — connection leak on error paths
	var name string
	err = db.QueryRow("SELECT name FROM users WHERE id = $1", id).Scan(&name)
	if err != nil {
		return "", err
	}
	db.Close()
	return name, nil
}
