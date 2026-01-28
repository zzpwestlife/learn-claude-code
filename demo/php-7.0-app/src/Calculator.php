<?php
declare(strict_types=1);

namespace Demo;

class Calculator
{
    /**
     * @param int $a
     * @param int $b
     * @return int
     */
    public function add(int $a, int $b): int
    {
        return $a + $b;
    }

    /**
     * @param int $a
     * @param int $b
     * @return float
     */
    public function divide(int $a, int $b): float
    {
        if ($b === 0) {
            throw new \InvalidArgumentException("Division by zero");
        }
        return $a / $b;
    }
    
    /**
     * Example of PHP 7.0 return type but using PHPDoc for nullable/void/object concepts
     * @param string|null $name
     * @return string
     */
    public function greet($name = null): string 
    {
        // Nullable types (?string) are NOT supported in 7.0, so we don't use them in signature
        // We use default value null instead
        $actualName = $name ?? "Guest"; // Null coalescing operator (PHP 7.0+)
        return "Hello, " . $actualName;
    }
    
    /**
     * Example using spaceship operator (PHP 7.0+)
     * @param int $a
     * @param int $b
     * @return int
     */
    public function compare(int $a, int $b): int
    {
        return $a <=> $b;
    }
}
