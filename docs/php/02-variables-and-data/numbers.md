# PHP Numbers

## Table of Contents

- [1. Numeric Types](#1-numeric-types)
- [2. Integers](#2-integers)
- [3. Floating-Point Numbers](#3-floating-point-numbers)
- [4. Numeric Strings](#4-numeric-strings)
- [5. Precision and Money](#5-precision-and-money)
- [6. Validation](#6-validation)
- [7. Common Mistakes](#7-common-mistakes)
- [8. Practice](#8-practice)

---

## 1. Numeric Types

PHP mainly uses two numeric types:

- `int` for whole numbers.
- `float` for decimal numbers.

```php
<?php

$quantity = 10;   // int
$price = 19.99;   // float

var_dump($quantity, $price);
```

---

## 2. Integers

An integer is a whole number without a decimal part.

```php
<?php

$positive = 100;
$negative = -50;
$zero = 0;
```

### Integer formats

```php
<?php

$decimal = 255;
$binary = 0b11111111;
$octal = 0377;
$hexadecimal = 0xFF;

var_dump($decimal, $binary, $octal, $hexadecimal);
```

All four variables represent `255`.

### Numeric separators

Underscores improve readability:

```php
<?php

$oneMillion = 1_000_000;
$largeFileSize = 10_000_000_000;
```

### Integer limits

```php
<?php

echo PHP_INT_MIN . PHP_EOL;
echo PHP_INT_MAX . PHP_EOL;
echo PHP_INT_SIZE . PHP_EOL;
```

The exact limits depend on the operating system and PHP build.

---

## 3. Floating-Point Numbers

A float stores a number with a decimal part:

```php
<?php

$price = 19.99;
$percentage = 12.5;
$scientific = 1.5e3;

echo $scientific; // 1500
```

Scientific notation is useful for very large or very small values:

```php
<?php

$large = 1.2e6;
$small = 1.2e-6;
```

---

## 4. Numeric Strings

A numeric string contains a valid numeric value:

```php
<?php

var_dump(is_numeric('123'));
var_dump(is_numeric('12.5'));
var_dump(is_numeric('-10'));
var_dump(is_numeric('hello'));
```

PHP may automatically convert numeric strings during calculations:

```php
<?php

$quantity = '5';
$total = $quantity * 10;

echo $total; // 50
```

Explicit validation and conversion are clearer:

```php
<?php

$quantityInput = '5';

if (!is_numeric($quantityInput)) {
    throw new InvalidArgumentException('Quantity must be numeric.');
}

$quantity = (int) $quantityInput;
```

---

## 5. Precision and Money

Floating-point values cannot represent every decimal exactly:

```php
<?php

$result = 0.1 + 0.2;

var_dump($result === 0.3); // Usually false
```

Use a tolerance when comparing calculated floats:

```php
<?php

$result = 0.1 + 0.2;
$expected = 0.3;
$tolerance = 0.00001;

var_dump(abs($result - $expected) < $tolerance);
```

For money, storing the smallest currency unit is often safer:

```php
<?php

$priceInCents = 1999;
$quantity = 3;
$totalInCents = $priceInCents * $quantity;

echo $totalInCents; // 5997
```

Use a decimal arithmetic library when exact decimal calculations are required.

```mermaid
flowchart LR
    A[Receive numeric input] --> B[Validate value]
    B --> C[Convert to int or float]
    C --> D[Calculate]
    D --> E[Round when required]
    E --> F[Format for display]
```

---

## 6. Validation

```php
<?php

var_dump(is_int(100));
var_dump(is_float(10.5));
var_dump(is_numeric('123'));
var_dump(is_finite(10.5));
var_dump(is_infinite(INF));
var_dump(is_nan(NAN));
```

Use `filter_var()` when validating integer input:

```php
<?php

$value = filter_var('25', FILTER_VALIDATE_INT);

if ($value === false) {
    echo 'Invalid integer';
} else {
    echo $value;
}
```

---

## 7. Common Mistakes

- Comparing floats directly with `===`.
- Assuming an integer has unlimited size.
- Trusting numeric strings without validation.
- Using floats for money without considering precision.
- Confusing casting with rounding.

Casting removes the decimal part:

```php
<?php

echo (int) 19.99; // 19
```

Rounding changes the value according to a rule:

```php
<?php

echo round(19.99); // 20
```

---

## 8. Practice

Create a product calculation using integer cents:

```php
<?php

$unitPriceInCents = 2550;
$quantity = 3;
$totalInCents = $unitPriceInCents * $quantity;
$total = $totalInCents / 100;

echo number_format($total, 2);
```

## Learning Checklist

- [ ] I understand integers and floats.
- [ ] I can use binary, octal, and hexadecimal integers.
- [ ] I understand numeric strings.
- [ ] I understand floating-point precision limitations.
- [ ] I can validate numeric input.

## Official Resources

- [PHP Integers](https://www.php.net/manual/en/language.types.integer.php)
- [PHP Floating-Point Numbers](https://www.php.net/manual/en/language.types.float.php)
- [PHP Numeric Strings](https://www.php.net/manual/en/language.types.numeric-strings.php)
- [W3Schools PHP Numbers](https://www.w3schools.com/php/php_numbers.asp)
