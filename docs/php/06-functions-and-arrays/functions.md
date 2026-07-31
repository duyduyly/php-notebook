# PHP Functions

## Table of Contents

- [Overview](#overview)
- [Basic Functions](#basic-functions)
- [Parameters and Arguments](#parameters-and-arguments)
- [Return Values](#return-values)
- [Type Declarations](#type-declarations)
- [Default and Named Arguments](#default-and-named-arguments)
- [Variable Scope](#variable-scope)
- [Anonymous and Arrow Functions](#anonymous-and-arrow-functions)
- [Variadic Functions](#variadic-functions)
- [Common Mistakes](#common-mistakes)
- [Practice](#practice)
- [Official Documentation](#official-documentation)

## Overview

A function is a reusable block of code that performs one clear task.

Functions help you:

- Avoid duplicated logic.
- Divide a program into smaller units.
- Accept input through parameters.
- Return processed results.
- Test business logic independently.

```mermaid
flowchart LR
    A[Call function] --> B[Receive arguments]
    B --> C[Execute function body]
    C --> D[Return result]
    D --> E[Continue caller code]
```

## Basic Functions

```php
<?php

function sayHello(): void
{
    echo 'Hello, PHP!';
}

sayHello();
```

- `function` declares a function.
- `sayHello` is the function name.
- `()` contains parameters.
- `void` means that no value is returned.

Use descriptive verb-based names:

```php
calculateTotal();
validateEmail();
findUser();
formatPrice();
```

## Parameters and Arguments

A **parameter** is declared in a function. An **argument** is the actual value passed to it.

```php
<?php

function greet(string $name): string
{
    return "Hello, {$name}!";
}

echo greet('Alan');
```

Multiple parameters:

```php
<?php

function calculateSubtotal(float $price, int $quantity): float
{
    return $price * $quantity;
}

echo calculateSubtotal(19.99, 3);
```

## Return Values

Use `return` to send a result back to the caller.

```php
<?php

function add(int $first, int $second): int
{
    return $first + $second;
}

$total = add(10, 20);
```

Execution stops immediately after `return`:

```php
<?php

function classifyAge(int $age): string
{
    if ($age < 0) {
        return 'Invalid age';
    }

    if ($age >= 18) {
        return 'Adult';
    }

    return 'Minor';
}
```

Prefer returning values instead of printing inside business functions. Returned values can be reused, tested, logged, or formatted later.

## Type Declarations

Common parameter and return types:

- `int`
- `float`
- `string`
- `bool`
- `array`
- `object`
- `callable`
- `iterable`
- `mixed`
- `void`

Nullable type:

```php
<?php

function getUserName(?array $user): ?string
{
    return $user['name'] ?? null;
}
```

Union type:

```php
<?php

function normalizeId(int|string $id): string
{
    return (string) $id;
}
```

Strict types can be enabled at the beginning of a file:

```php
<?php

declare(strict_types=1);
```

## Default and Named Arguments

Default parameter:

```php
<?php

function greet(string $name = 'Guest'): string
{
    return "Hello, {$name}!";
}

echo greet();
echo greet('Alan');
```

Place required parameters before optional parameters:

```php
<?php

function createUser(string $name, string $role = 'viewer'): array
{
    return [
        'name' => $name,
        'role' => $role,
    ];
}
```

Named arguments improve readability:

```php
<?php

$user = createUser(
    name: 'Alan',
    role: 'admin'
);
```

Parameter names become part of the public API when callers use named arguments.

## Variable Scope

Variables declared inside a function have local scope.

```php
<?php

function createMessage(): string
{
    $message = 'Local message';

    return $message;
}
```

Pass outside values explicitly:

```php
<?php

$message = 'Hello';

function showMessage(string $message): void
{
    echo $message;
}

showMessage($message);
```

Avoid `global` in normal application code because it creates hidden dependencies.

A static local variable keeps its value between calls:

```php
<?php

function nextNumber(): int
{
    static $number = 0;

    return ++$number;
}
```

## Anonymous and Arrow Functions

Anonymous function:

```php
<?php

$greet = function (string $name): string {
    return "Hello, {$name}!";
};

echo $greet('Alan');
```

Capture an outside variable with `use`:

```php
<?php

$prefix = 'Hello';

$greet = function (string $name) use ($prefix): string {
    return "{$prefix}, {$name}!";
};
```

Arrow function:

```php
<?php

$double = fn (int $number): int => $number * 2;
```

Arrow functions are best for short, single-expression logic.

## Variadic Functions

A variadic parameter accepts any number of arguments:

```php
<?php

function sum(int ...$numbers): int
{
    return array_sum($numbers);
}

echo sum(10, 20, 30);
```

Spread an array into arguments:

```php
<?php

$numbers = [10, 20, 30];

echo sum(...$numbers);
```

## Common Mistakes

### Forgetting to return a value

```php
<?php

function add(int $a, int $b): int
{
    return $a + $b;
}
```

### Printing instead of returning

Prefer:

```php
function calculateTotal(array $values): int|float
{
    return array_sum($values);
}
```

### Too many responsibilities

A function should not validate input, save data, send email, and generate HTML at the same time. Split unrelated tasks into smaller functions.

### Overusing global variables

Pass dependencies through parameters instead.

## Practice

Create a function that calculates an average:

```php
<?php

function calculateAverage(array $numbers): float
{
    if ($numbers === []) {
        return 0.0;
    }

    return array_sum($numbers) / count($numbers);
}

echo calculateAverage([10, 20, 30]);
```

## Official Documentation

- [PHP functions](https://www.php.net/manual/en/language.functions.php)
- [Function arguments](https://www.php.net/manual/en/functions.arguments.php)
- [Return values](https://www.php.net/manual/en/functions.returning-values.php)
- [Anonymous functions](https://www.php.net/manual/en/functions.anonymous.php)
- [Arrow functions](https://www.php.net/manual/en/functions.arrow.php)
