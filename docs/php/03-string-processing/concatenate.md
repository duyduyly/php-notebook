# Concatenating PHP Strings

Concatenation means combining strings. PHP uses the dot operator (`.`).

## Basic Concatenation

```php
<?php

$firstName = 'Alan';
$lastName = 'Le';
$fullName = $firstName . ' ' . $lastName;

echo $fullName;
```

Output:

```text
Alan Le
```

## Concatenation Assignment

Use `.=` to append text to an existing string.

```php
<?php

$message = 'Hello';
$message .= ', Alan';
$message .= '!';

echo $message;
```

Output:

```text
Hello, Alan!
```

## String Interpolation

Double-quoted strings can include variables:

```php
<?php

$name = 'Alan';
$language = 'PHP';

echo "$name is learning $language.";
```

Use braces when the variable boundary is unclear:

```php
<?php

$product = 'book';

echo "There are many {$product}s.";
```

## Concatenate Function Results

```php
<?php

$firstName = ' alan ';
$lastName = ' le ';

$fullName = ucfirst(trim($firstName))
    . ' '
    . ucfirst(trim($lastName));

echo $fullName;
```

Output:

```text
Alan Le
```

## Build HTML Carefully

```php
<?php

$title = 'PHP Tutorial';
$html = '<h1>'
    . htmlspecialchars($title, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
    . '</h1>';

echo $html;
```

Escape untrusted text before inserting it into HTML.

## Common Mistake

PHP does not use `+` for string concatenation.

Incorrect:

```php
<?php

echo 'Hello ' + $name;
```

Correct:

```php
<?php

echo 'Hello ' . $name;
```

---

## Official Resources

* [PHP string operators](https://www.php.net/manual/en/language.operators.string.php)
* [htmlspecialchars()](https://www.php.net/manual/en/function.htmlspecialchars.php)

## Learning Checklist

* [ ] I can concatenate with `.` and append with `.=`.
* [ ] I escape untrusted values before HTML output.
