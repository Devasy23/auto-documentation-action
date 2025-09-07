package main

import "fmt"

// Add does addition of two integers.
// It takes two integers a and b as input and returns their sum as an integer.
func Add(a, b int) int {
	return a + b
}

// Multiply does multiplication of two float64 numbers.
// It takes two float64 numbers x and y as input and returns their product as a float64.
func Multiply(x, y float64) float64 {
	return x * y
}

func main() {
	result := Add(5, 3)
	fmt.Printf("Result: %d\n", result)

	product := Multiply(2.5, 4.0)
	fmt.Printf("Product: %.2f\n", product)
}
