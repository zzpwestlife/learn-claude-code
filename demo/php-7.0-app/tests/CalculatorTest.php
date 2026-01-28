<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use Demo\Calculator;

class CalculatorTest extends TestCase
{
    /** @var Calculator */
    private $calc;

    protected function setUp()
    {
        $this->calc = new Calculator();
    }

    public function testAdd()
    {
        $this->assertEquals(5, $this->calc->add(2, 3));
    }

    public function testDivide()
    {
        $this->assertEquals(2.5, $this->calc->divide(5, 2));
    }

    public function testDivideByZero()
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->calc->divide(5, 0);
    }
    
    public function testGreet()
    {
        $this->assertEquals("Hello, Guest", $this->calc->greet(null));
        $this->assertEquals("Hello, World", $this->calc->greet("World"));
    }
    
    public function testCompare()
    {
        $this->assertEquals(0, $this->calc->compare(1, 1));
        $this->assertEquals(-1, $this->calc->compare(1, 2));
        $this->assertEquals(1, $this->calc->compare(2, 1));
    }
}
