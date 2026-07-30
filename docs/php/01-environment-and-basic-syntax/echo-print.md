# PHP Echo and Print

## Table of Contents

- [Overview](#overview)
- [Using Echo](#using-echo)
- [Using Print](#using-print)
- [Echo vs Print](#echo-vs-print)
- [Quotes and Variables](#quotes-and-variables)
- [Outputting HTML](#outputting-html)
- [PHP Inside HTML](#php-inside-html)
- [Common Mistakes](#common-mistakes)
- [Practice Exercises](#practice-exercises)
- [Quick Reference](#quick-reference)

---

## Overview

Both `echo` and `print` display output in PHP.

They are language constructs rather than normal functions, so parentheses are optional.

```php
<?php

echo 'Hello';
print 'World';
```

This is also valid:

```php
<?php

echo('Hello');
print('World');
```

The common coding style omits parentheses.

---

## Using Echo

### Basic Output

```php
<?php

echo 'Hello, World!';
```

Output:

```text
Hello, World!
```

### Output a Variable

```php
<?php

$name = 'Alan';

echo $name;
```

### Output Multiple Values

`echo` can output multiple comma-separated values:

```php
<?php

echo 'Hello', ' ', 'Alan';
```

Output:

```text
Hello Alan
```

### Concatenate Values

The dot operator `.` joins strings:

```php
<?php

$firstName = 'Alan';
$lastName = 'Le';

echo $firstName . ' ' . $lastName;
```

### Output Numbers and Expressions

```php
<?php

$price = 100;
$quantity = 2;

echo $price * $quantity;
```

Output:

```text
200
```

---

## Using Print

### Basic Output

```php
<?php

print 'Hello, World!';
```

### Output a Variable

```php
<?php

$message = 'Welcome to PHP';

print $message;
```

### Return Value

Unlike `echo`, `print` returns `1`.

```php
<?php

$result = print 'Hello';

echo $result;
```

The output is:

```text
Hello1
```

Using the return value of `print` is uncommon in normal applications.

---

## Echo vs Print

| Feature | `echo` | `print` |
| --- | --- | --- |
| Language construct | Yes | Yes |
| Displays output | Yes | Yes |
| Accepts multiple comma-separated values | Yes | No |
| Returns a value | No | Returns `1` |
| Common usage | More common | Less common |
| Normal performance difference | Negligible | Negligible |

Recommended default:

```php
<?php

echo 'Hello';
```

Use `print` only when you have a specific reason to use it.

---

## Quotes and Variables

### Double-Quoted Strings

Variables are interpreted inside double-quoted strings:

```php
<?php

$name = 'Alan';

echo "Hello, $name!";
```

Output:

```text
Hello, Alan!
```

For clearer variable boundaries, use braces:

```php
<?php

$product = 'Book';

echo "The {$product}s are ready.";
```

### Single-Quoted Strings

Variables are not interpreted inside single-quoted strings:

```php
<?php

$name = 'Alan';

echo 'Hello, $name!';
```

Output:

```text
Hello, $name!
```

Use concatenation with single quotes:

```php
<?php

$name = 'Alan';

echo 'Hello, ' . $name . '!';
```

Output:

```text
Hello, Alan!
```

### Escaping Quotes

```php
<?php

echo 'Alan\'s PHP course';
echo "He said, \"Hello!\"";
```

---

## Outputting HTML

PHP can generate HTML:

```php
<?php

echo '<h1>PHP Tutorial</h1>';
echo '<p>Welcome to the course.</p>';
```

Use HTML escaping when displaying untrusted data:

```php
<?php

$userName = $_GET['name'] ?? 'Guest';

echo '<p>Hello, ' . htmlspecialchars($userName, ENT_QUOTES, 'UTF-8') . '</p>';
```

`htmlspecialchars()` converts special HTML characters and helps prevent HTML injection when outputting text into a page.

---

## PHP Inside HTML

For large HTML sections, write HTML directly rather than creating every tag with `echo`.

Recommended:

```php
<?php

$title = 'Product List';
?>

<h1><?= htmlspecialchars($title, ENT_QUOTES, 'UTF-8') ?></h1>

<ul>
    <li>Product A</li>
    <li>Product B</li>
</ul>
```

The short echo syntax:

```php
<?= $value ?>
```

is equivalent to:

```php
<?php echo $value; ?>
```

Less readable for a large template:

```php
<?php

echo '<h1>Product List</h1>';
echo '<ul>';
echo '<li>Product A</li>';
echo '<li>Product B</li>';
echo '</ul>';
```

Use PHP output statements for dynamic values and ordinary HTML for page structure.

---

## Common Mistakes

### Missing Semicolon

Incorrect:

```php
<?php

echo 'Hello'
```

Correct:

```php
<?php

echo 'Hello';
```

### Broken Quotes

Incorrect:

```php
<?php

echo 'Alan's course';
```

Correct:

```php
<?php

echo "Alan's course";
```

### Expecting Variables in Single Quotes

```php
<?php

$name = 'Alan';

echo 'Hello, $name';
```

This prints `$name` literally. Use double quotes or concatenation.

### Outputting Untrusted HTML Directly

Avoid:

```php
<?php

echo $_GET['name'];
```

Prefer:

```php
<?php

$name = $_GET['name'] ?? '';

echo htmlspecialchars($name, ENT_QUOTES, 'UTF-8');
```

---

## Practice Exercises

### Exercise 1: Echo

Display:

```text
Hello, PHP!
```

```php
<?php

echo 'Hello, PHP!';
```

### Exercise 2: Variables

```php
<?php

$name = 'Alan';
$job = 'Developer';

echo $name . ' is a ' . $job . '.';
```

### Exercise 3: Echo and Print

```php
<?php

echo 'This line uses echo.<br>';
print 'This line uses print.';
```

### Exercise 4: HTML Template

Create a complete HTML page and use `<?= ... ?>` to display:

- A page title.
- A user name.
- The current PHP version from `phpversion()`.

---

## Quick Reference

```php
<?php

echo 'Hello';
print 'Hello';
```

```php
<?php

$name = 'Alan';

echo "Hello, $name";
echo 'Hello, ' . $name;
```

```php
<?= htmlspecialchars($name, ENT_QUOTES, 'UTF-8') ?>
```

Official references:

- [PHP echo](https://www.php.net/manual/en/function.echo.php)
- [PHP print](https://www.php.net/manual/en/function.print.php)
