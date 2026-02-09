package main

import (
	"demo/pkg/helper"
	"fmt"
)

func Hello() {
	fmt.Println("Hello, World!")
}

func main() {
	Hello()
	helper.DoMagic()
}
