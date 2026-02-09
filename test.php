<?php
class User {
    public $name;
    public function __construct($name) {
        $this->name = $name;
    }
    public function sayHello() {
        echo "Hello, " . $this->name;
    }
}

$user = new User("Claude");
$user->sayHello();
