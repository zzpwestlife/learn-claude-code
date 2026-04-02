package service

// UserService is a fat interface with 8 methods — violates Go's "keep interfaces small" idiom.
// Callers that only need Read are forced to implement Write methods too.
type UserService interface {
	GetUser(id int) (*User, error)
	ListUsers() ([]*User, error)
	CreateUser(u *User) error
	UpdateUser(u *User) error
	DeleteUser(id int) error
	ChangePassword(id int, pw string) error
	SendWelcomeEmail(id int) error
	AuditLog(id int, action string) error
}

type User struct {
	ID   int
	Name string
}
