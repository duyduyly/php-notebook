# PHP Comments

## Table of Contents

- [What Is a Comment?](#what-is-a-comment)
- [Single-Line Comments](#single-line-comments)
- [Multiline Comments](#multiline-comments)
- [Disabling Code Temporarily](#disabling-code-temporarily)
- [PHPDoc Comments](#phpdoc-comments)
- [Good and Bad Comments](#good-and-bad-comments)
- [Practice Exercise](#practice-exercise)
- [Quick Reference](#quick-reference)

---

## What Is a Comment?

A comment is text in source code that PHP does not execute.

Comments are useful for:

- Explaining difficult logic.
- Recording why a technical decision was made.
- Adding temporary development notes.
- Documenting functions, classes, methods, and properties.
- Temporarily disabling code during debugging.

A useful comment should add information that the code itself does not clearly communicate.

---

## Single-Line Comments

### Using `//`

```php
<?php

// Display a welcome message
echo 'Welcome!';
```

A comment can appear after a statement:

```php
<?php

echo 'Welcome!'; // Display the message
```

### Using `#`

```php
<?php

# This is also a single-line comment
echo 'Hello!';
```

The `//` style is more common in modern PHP projects.

Recommended:

```php
// Calculate the final price
```

Less common:

```php
# Calculate the final price
```

---

## Multiline Comments

Use `/*` and `*/` when a comment needs multiple lines.

```php
<?php

/*
This comment uses
multiple lines.
*/
echo 'Hello!';
```

Practical example:

```php
<?php

/*
Calculate the subtotal before applying
any taxes, discounts, or shipping fees.
*/
$subtotal = 100;
```

Do not nest multiline comments because PHP cannot reliably parse nested `/* ... */` blocks.

---

## Disabling Code Temporarily

Disable one line:

```php
<?php

echo 'First line';

// echo 'This line is temporarily disabled';

echo 'Last line';
```

Disable multiple lines:

```php
<?php

/*
echo 'Line one';
echo 'Line two';
echo 'Line three';
*/
```

This is useful during short debugging sessions. Do not keep large blocks of unused code as permanent comments. Git already stores source-code history.

---

## PHPDoc Comments

PHPDoc comments begin with `/**` and are used to document functions, classes, methods, properties, and parameters.

```php
<?php

/**
 * Add two integer values.
 */
function add(int $firstNumber, int $secondNumber): int
{
    return $firstNumber + $secondNumber;
}

echo add(10, 20);
```

A more detailed example:

```php
<?php

/**
 * Calculate a product subtotal.
 *
 * @param float $price Product price.
 * @param int $quantity Number of products.
 *
 * @return float Calculated subtotal.
 */
function calculateSubtotal(float $price, int $quantity): float
{
    return $price * $quantity;
}
```

Development tools can read PHPDoc metadata to provide autocomplete, navigation, type information, and generated API documentation.

Modern PHP type declarations should still be used whenever possible. PHPDoc should provide extra context rather than replace valid language-level types.

---

## Good and Bad Comments

### Bad Comment

```php
<?php

// Set name to Alan
$name = 'Alan';
```

The code already explains what it does.

### Better Comment

```php
<?php

// Use the public display name instead of the legal name.
$name = 'Alan';
```

The second comment explains **why** the value is selected.

### Comment Guidelines

- Explain reasons, constraints, and unusual behavior.
- Keep comments synchronized with the code.
- Remove outdated comments.
- Prefer clear names and simple code over unnecessary comments.
- Do not include passwords, API keys, or private information in comments.
- Use TODO comments only when they are specific and actionable.

Specific TODO:

```php
// TODO: Replace the temporary array with a repository call after API-123 is complete.
```

Weak TODO:

```php
// TODO: Fix this later.
```

---

## Practice Exercise

Create a PHP file containing:

- One `//` comment.
- One `#` comment.
- One multiline comment.
- One PHPDoc comment.

Example:

```php
<?php

// Store the public display name.
$name = 'Alan';

# Display the page heading.
echo '<h1>' . $name . '</h1>';

/*
The paragraph below is generated
by PHP on the server.
*/
echo '<p>Welcome to PHP.</p>';

/**
 * Build a greeting for one user.
 */
function greet(string $userName): string
{
    return 'Hello, ' . $userName . '!';
}
```

---

## Quick Reference

Single-line comments:

```php
// Comment
# Comment
```

Multiline comment:

```php
/*
Multiline comment
*/
```

PHPDoc comment:

```php
/**
 * Documentation comment.
 */
```

Official reference: [PHP comments](https://www.php.net/manual/en/language.basic-syntax.comments.php)
