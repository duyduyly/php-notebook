# PHP Math

## Table of Contents

- [1. Arithmetic Operators](#1-arithmetic-operators)
- [2. Integer Division](#2-integer-division)
- [3. Common Math Functions](#3-common-math-functions)
- [4. Rounding](#4-rounding)
- [5. Powers and Roots](#5-powers-and-roots)
- [6. Random Values](#6-random-values)
- [7. Number Formatting](#7-number-formatting)
- [8. Practical Example](#8-practical-example)
- [9. Common Mistakes](#9-common-mistakes)

---

## 1. Arithmetic Operators

PHP provides standard arithmetic operators without requiring an external package.

```php
<?php

$first = 10;
$second = 3;

echo $first + $second . PHP_EOL;
echo $first - $second . PHP_EOL;
echo $first * $second . PHP_EOL;
echo $first / $second . PHP_EOL;
echo $first % $second . PHP_EOL;
echo $first ** $second . PHP_EOL;
```

| Operator | Meaning | Example |
|---|---|---|
| `+` | Addition | `10 + 3` |
| `-` | Subtraction | `10 - 3` |
| `*` | Multiplication | `10 * 3` |
| `/` | Division | `10 / 3` |
| `%` | Remainder | `10 % 3` |
| `**` | Exponentiation | `10 ** 3` |

Assignment operators shorten updates:

```php
<?php

$total = 100;
$total += 20;
$total -= 10;
$total *= 2;
$total /= 5;
```

---

## 2. Integer Division

Normal division may return a float:

```php
<?php

echo 10 / 3;
```

Output:

```text
3.3333333333333
```

Use `intdiv()` for integer division:

```php
<?php

echo intdiv(10, 3); // 3
```

Division by zero causes an error, so validate the divisor:

```php
<?php

$divisor = 0;

if ($divisor === 0) {
    throw new InvalidArgumentException('Divisor cannot be zero.');
}
```

---

## 3. Common Math Functions

### Absolute value

```php
<?php

echo abs(-20); // 20
```

### Minimum and maximum

```php
<?php

$scores = [80, 95, 72, 88];

echo min($scores); // 72
echo max($scores); // 95
```

### Sum

```php
<?php

$prices = [10.5, 20, 5.25];

echo array_sum($prices);
```

---

## 4. Rounding

Use `round()` for normal rounding:

```php
<?php

echo round(10.4); // 10
echo round(10.5); // 11
```

Specify decimal places:

```php
<?php

$price = 19.9876;

echo round($price, 2); // 19.99
```

Use `ceil()` to round upward:

```php
<?php

echo ceil(10.1); // 11
```

Use `floor()` to round downward:

```php
<?php

echo floor(10.9); // 10
```

| Function | Behavior |
|---|---|
| `round()` | Rounds to the nearest value |
| `ceil()` | Always rounds upward |
| `floor()` | Always rounds downward |

---

## 5. Powers and Roots

```php
<?php

echo sqrt(81); // 9
echo pow(2, 3); // 8
echo 2 ** 3;   // 8
```

Additional constants and functions:

```php
<?php

echo M_PI;
echo pi();
echo deg2rad(180);
echo rad2deg(M_PI);
```

---

## 6. Random Values

Use `random_int()` when stronger randomness is required:

```php
<?php

echo random_int(1, 100);
```

Generate a security-sensitive token with `random_bytes()`:

```php
<?php

$token = bin2hex(random_bytes(16));

echo $token;
```

For ordinary non-security randomness:

```php
<?php

echo mt_rand(1, 100);
```

Do not use predictable random functions for passwords, reset tokens, authentication tokens, or security keys.

---

## 7. Number Formatting

```php
<?php

$amount = 1234567.89;

echo number_format($amount, 2);
```

Output:

```text
1,234,567.89
```

Custom separators:

```php
<?php

$amount = 1234567.89;

echo number_format(
    num: $amount,
    decimals: 2,
    decimal_separator: ',',
    thousands_separator: '.'
);
```

Output:

```text
1.234.567,89
```

`number_format()` creates a display string. Do not use the formatted string for later calculations.

---

## 8. Practical Example

```php
<?php

declare(strict_types=1);

const TAX_RATE = 0.1;

$unitPrice = 49.99;
$quantity = 2;

$subtotal = $unitPrice * $quantity;
$tax = $subtotal * TAX_RATE;
$total = $subtotal + $tax;

echo 'Subtotal: ' . number_format($subtotal, 2) . PHP_EOL;
echo 'Tax: ' . number_format($tax, 2) . PHP_EOL;
echo 'Total: ' . number_format($total, 2) . PHP_EOL;
```

```mermaid
flowchart LR
    A[Receive numeric input] --> B[Validate input]
    B --> C[Convert to required type]
    C --> D[Perform calculation]
    D --> E[Round when necessary]
    E --> F[Format for display]
```

---

## 9. Common Mistakes

- Dividing by zero.
- Confusing casting with rounding.
- Using formatted numbers in calculations.
- Comparing floats directly.
- Using insecure random functions for tokens.
- Rounding too early during a multi-step calculation.

## Practice

Calculate the subtotal, a 10% tax, and final total for three products priced at `25.50`:

```php
<?php

const TAX_RATE = 0.1;

$price = 25.50;
$quantity = 3;
$subtotal = $price * $quantity;
$tax = $subtotal * TAX_RATE;
$total = $subtotal + $tax;

echo number_format($total, 2);
```

## Learning Checklist

- [ ] I can use PHP arithmetic operators.
- [ ] I understand normal and integer division.
- [ ] I can round values correctly.
- [ ] I can generate secure random values.
- [ ] I can format numbers for display.

## Official Resources

- [PHP Math Functions](https://www.php.net/manual/en/book.math.php)
- [PHP Mathematical Functions](https://www.php.net/manual/en/ref.math.php)
- [PHP Random Extension](https://www.php.net/manual/en/book.random.php)
- [W3Schools PHP Math](https://www.w3schools.com/php/php_math.asp)
