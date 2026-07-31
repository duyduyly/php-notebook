# PHP Basic Syntax

## Table of Contents

- [Opening Tag](#opening-tag)
- [Statements and Semicolons](#statements-and-semicolons)
- [Variables](#variables)
- [Case Sensitivity](#case-sensitivity)
- [File Extension](#file-extension)
- [Whitespace](#whitespace)
- [PHP Inside HTML](#php-inside-html)
- [Common Syntax Errors](#common-syntax-errors)
- [Practice Exercises](#practice-exercises)
- [Quick Reference](#quick-reference)

---

## Opening Tag

PHP code begins with:

```php
<?php
```

Example:

```php
<?php

echo 'Hello, PHP!';
```

A PHP-only file should normally omit the closing `?>` tag.

Recommended:

```php
<?php

echo 'Hello, PHP!';
```

Avoiding the closing tag helps prevent accidental whitespace from being sent to the browser.

---

## Statements and Semicolons

A statement is an instruction that PHP executes.

```php
<?php

$message = 'Welcome to PHP';
echo $message;
```

Most PHP statements end with a semicolon:

```php
$name = 'Alan';
echo $name;
```

Incorrect:

```php
$name = 'Alan'
echo $name;
```

The missing semicolon causes a syntax error.

---

## Variables

PHP variables begin with `$`.

```php
<?php

$name = 'Alan';
$age = 26;

echo $name;
echo $age;
```

Variable names are case-sensitive:

```php
<?php

$name = 'Alan';

echo $name; // Alan
echo $Name; // Different and undefined variable
```

Use descriptive variable names:

```php
$productPrice = 100;
$userDisplayName = 'Alan';
```

---

## Case Sensitivity

PHP keywords such as `echo`, `if`, and `class` are not case-sensitive.

```php
<?php

echo 'First';
ECHO 'Second';
```

Lowercase keywords are the accepted coding convention:

```php
<?php

echo 'Recommended style';
```

Variables are case-sensitive:

```php
<?php

$color = 'blue';

echo $color;
echo $Color; // Undefined variable
```

Use consistent casing for variables, functions, classes, and filenames even where PHP may allow variations.

---

## File Extension

PHP files use the `.php` extension.

```text
index.php
login.php
product.php
api.php
```

A normal web server does not process PHP code inside an `.html` file unless it has been specially configured.

---

## Whitespace

PHP generally ignores extra spaces and empty lines between statements.

Both examples work:

```php
<?php
$name = 'Alan';
echo $name;
```

```php
<?php

$name = 'Alan';

echo $name;
```

Use whitespace to improve readability:

```php
<?php

$firstName = 'Alan';
$lastName = 'Le';

echo $firstName . ' ' . $lastName;
```

---

## PHP Inside HTML

PHP and HTML can exist in the same `.php` file.

```php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP Example</title>
</head>
<body>
    <h1>My First PHP Page</h1>

    <?php
    echo '<p>Hello from PHP!</p>';
    ?>
</body>
</html>
```

### Short Echo Syntax

```php
<?= $value ?>
```

is equivalent to:

```php
<?php echo $value; ?>
```

Example:

```php
<?php

$pageTitle = 'PHP Getting Started';
$userName = 'Alan';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><?= $pageTitle ?></title>
</head>
<body>
    <h1><?= $pageTitle ?></h1>
    <p>Hello, <?= $userName ?>!</p>
</body>
</html>
```

For large HTML sections, write HTML directly and use PHP only where dynamic output is needed.

---

## Common Syntax Errors

### Missing Semicolon

```php
<?php

echo 'Hello'
echo 'World';
```

Correct:

```php
<?php

echo 'Hello';
echo 'World';
```

### Missing `$`

Incorrect:

```php
name = 'Alan';
```

Correct:

```php
$name = 'Alan';
```

### Incorrect Variable Case

```php
<?php

$userName = 'Alan';

echo $username;
```

Correct:

```php
<?php

$userName = 'Alan';

echo $userName;
```

### Incorrect Quotes

Incorrect:

```php
<?php

echo 'Alan's PHP course';
```

Correct:

```php
<?php

echo "Alan's PHP course";
```

Or escape the apostrophe:

```php
<?php

echo 'Alan\'s PHP course';
```

### Opening a PHP File Directly

This path usually does not execute PHP:

```text
file:///C:/projects/index.php
```

Start a server:

```bash
php -S localhost:8000
```

Then open:

```text
http://localhost:8000
```

---

## Practice Exercises

### Exercise 1: Basic Output

Create `exercise-01.php` and display:

```text
Hello, PHP!
```

```php
<?php

echo 'Hello, PHP!';
```

### Exercise 2: Variables

Create `$name` and `$job`, then display one sentence.

```php
<?php

$name = 'Alan';
$job = 'Developer';

echo $name . ' is a ' . $job . '.';
```

### Exercise 3: PHP Inside HTML

Create a complete HTML page and use PHP to display a page title and user name.

---

## Quick Reference

```php
<?php

$name = 'Alan';

echo 'Hello, ' . $name;
```

Run a file:

```bash
php index.php
```

Start the development server:

```bash
php -S localhost:8000
```

Official reference: [PHP basic syntax](https://www.php.net/manual/en/language.basic-syntax.php)
