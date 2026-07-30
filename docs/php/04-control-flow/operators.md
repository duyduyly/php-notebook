# PHP Operators

## Table of Contents

- [Overview](#overview)
- [Arithmetic Operators](#arithmetic-operators)
- [Assignment Operators](#assignment-operators)
- [Comparison Operators](#comparison-operators)
- [Logical Operators](#logical-operators)
- [Increment and Decrement](#increment-and-decrement)
- [String Operators](#string-operators)
- [Null Coalescing Operators](#null-coalescing-operators)
- [Operator Precedence](#operator-precedence)
- [Common Mistakes](#common-mistakes)
- [Practice](#practice)
- [Official Resources](#official-resources)

## Overview

Operators perform calculations, assign values, compare data, and combine conditions.

```php
<?php

$price = 100;
$quantity = 3;
$total = $price * $quantity;

echo $total; // 300
```

- `$price` and `$quantity` are operands.
- `*` is the multiplication operator.
- `=` is the assignment operator.

## Arithmetic Operators

| Operator | Meaning | Example | Result |
|---|---|---|---|
| `+` | Addition | `10 + 5` | `15` |
| `-` | Subtraction | `10 - 5` | `5` |
| `*` | Multiplication | `10 * 5` | `50` |
| `/` | Division | `10 / 5` | `2` |
| `%` | Remainder | `10 % 3` | `1` |
| `**` | Exponentiation | `2 ** 3` | `8` |

```php
<?php

$number = 8;

if ($number % 2 === 0) {
    echo 'Even';
} else {
    echo 'Odd';
}
```

## Assignment Operators

| Operator | Example | Equivalent |
|---|---|---|
| `=` | `$x = 10` | Assign `10` |
| `+=` | `$x += 5` | `$x = $x + 5` |
| `-=` | `$x -= 5` | `$x = $x - 5` |
| `*=` | `$x *= 5` | `$x = $x * 5` |
| `/=` | `$x /= 5` | `$x = $x / 5` |
| `%=` | `$x %= 5` | `$x = $x % 5` |
| `.=` | `$text .= 'PHP'` | Append text |
| `??=` | `$x ??= 10` | Assign when null or missing |

```php
<?php

$total = 100;
$total += 20;
$total *= 2;

echo $total; // 240
```

```php
<?php

$config = [];
$config['theme'] ??= 'light';

echo $config['theme'];
```

## Comparison Operators

Comparison operators return `true` or `false`.

| Operator | Meaning |
|---|---|
| `==` | Equal after type conversion |
| `===` | Equal value and type |
| `!=`, `<>` | Not equal after conversion |
| `!==` | Different value or type |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |
| `<=>` | Spaceship comparison |

```php
<?php

var_dump(5 == '5');  // true
var_dump(5 === '5'); // false
```

Prefer strict comparison:

```php
<?php

$status = 'active';

if ($status === 'active') {
    echo 'Active account';
}
```

The spaceship operator returns `-1`, `0`, or `1`:

```php
<?php

echo 5 <=> 10;  // -1
echo 10 <=> 10; // 0
echo 15 <=> 10; // 1
```

## Logical Operators

| Operator | Meaning |
|---|---|
| `&&` | Both conditions are true |
| `||` | At least one condition is true |
| `!` | Reverse a Boolean value |
| `and` | Logical AND with lower precedence |
| `or` | Logical OR with lower precedence |
| `xor` | Exactly one condition is true |

```php
<?php

$age = 25;
$hasTicket = true;

if ($age >= 18 && $hasTicket) {
    echo 'Entry allowed';
}
```

Prefer `&&` and `||` in normal application code because `and` and `or` have lower precedence.

## Increment and Decrement

| Operator | Meaning |
|---|---|
| `++$x` | Increment, then return |
| `$x++` | Return, then increment |
| `--$x` | Decrement, then return |
| `$x--` | Return, then decrement |

```php
<?php

$number = 5;

echo ++$number; // 6

echo $number++; // 6

echo $number;   // 7
```

## String Operators

PHP uses `.` to concatenate strings and `.=` to append.

```php
<?php

$firstName = 'Alan';
$lastName = 'Le';

$fullName = $firstName . ' ' . $lastName;

echo $fullName;
```

```php
<?php

$message = 'Hello';
$message .= ', Alan!';

echo $message;
```

## Null Coalescing Operators

`??` returns the first value that exists and is not `null`.

```php
<?php

$username = $_GET['username'] ?? 'Guest';
```

Values can be chained:

```php
<?php

$name = $profileName
    ?? $accountName
    ?? 'Guest';
```

`??=` assigns a fallback only when the target is missing or null.

## Operator Precedence

```php
<?php

$result = 2 + 3 * 4;
echo $result; // 14
```

Use parentheses to make intent clear:

```php
<?php

$result = (2 + 3) * 4;
echo $result; // 20
```

```mermaid
flowchart LR
    A[Read expression] --> B[Evaluate parentheses]
    B --> C[Apply higher-precedence operators]
    C --> D[Apply lower-precedence operators]
    D --> E[Return result]
```

## Common Mistakes

### Assignment instead of comparison

```php
if ($status = 'active') {
    // Incorrect: assigns a value.
}
```

Use:

```php
if ($status === 'active') {
    // Correct comparison.
}
```

### Loose comparison without a reason

```php
$value = '0';
var_dump($value == false); // Can be confusing
```

Prefer strict comparison when possible.

### Unclear precedence

Avoid complex expressions without parentheses.

## Practice

Check whether a number is even:

```php
<?php

$number = 12;

$result = $number % 2 === 0 ? 'Even' : 'Odd';

echo $result;
```

Sort numbers with the spaceship operator:

```php
<?php

$numbers = [20, 5, 12, 1];

usort($numbers, fn (int $a, int $b): int => $a <=> $b);

print_r($numbers);
```

## Official Resources

- [PHP operators](https://www.php.net/manual/en/language.operators.php)
- [Comparison operators](https://www.php.net/manual/en/language.operators.comparison.php)
- [Logical operators](https://www.php.net/manual/en/language.operators.logical.php)
- [Operator precedence](https://www.php.net/manual/en/language.operators.precedence.php)
