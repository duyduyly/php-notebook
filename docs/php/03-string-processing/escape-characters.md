# PHP Escape Characters

An escape character starts with a backslash (`\`). It gives special meaning to the next character.

Most escape sequences are interpreted inside double-quoted strings.

## Common Escape Sequences

| Sequence | Meaning |
| --- | --- |
| `\"` | Double quote |
| `\'` | Single quote |
| `\\` | Backslash |
| `\n` | New line |
| `\r` | Carriage return |
| `\t` | Tab |
| `\$` | Dollar sign |

## Escape Double Quotes

```php
<?php

echo "He said, \"Hello!\"";
```

You can also avoid escaping by changing the outer quote style:

```php
<?php

echo 'He said, "Hello!"';
```

## Escape Single Quotes

```php
<?php

echo 'Alan\'s PHP course';
```

Or:

```php
<?php

echo "Alan's PHP course";
```

## New Lines

```php
<?php

echo "First line\nSecond line";
```

This creates a visible new line in command-line output. In HTML, `\n` changes the source code but does not necessarily create a visible browser line break.

Use `<br>`:

```php
<?php

echo "First line<br>Second line";
```

Or safely convert new lines from text:

```php
<?php

$text = "First line\nSecond line";

echo nl2br(
    htmlspecialchars($text, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
);
```

## Tabs

```php
<?php

echo "Name:\tAlan";
```

## Escape a Dollar Sign

```php
<?php

echo "The price is \$100.";
```

Output:

```text
The price is $100.
```

## Windows Paths

Use escaped backslashes:

```php
<?php

$path = "C:\\xampp\\htdocs\\project";
```

Single quotes can reduce escaping:

```php
<?php

$path = 'C:\xampp\htdocs\project';
```

Forward slashes often work in PHP paths on Windows:

```php
<?php

$path = 'C:/xampp/htdocs/project';
```

## Single Quotes vs Double Quotes

| Feature | Single quotes | Double quotes |
| --- | --- | --- |
| Variable interpolation | No | Yes |
| `\n` and `\t` interpretation | No | Yes |
| Escape single quote | `\'` | Usually unnecessary |
| Escape double quote | Usually unnecessary | `\"` |

---

## Official Resources

* [PHP string syntax](https://www.php.net/manual/en/language.types.string.php)
* [nl2br()](https://www.php.net/manual/en/function.nl2br.php)

## Learning Checklist

* [ ] I understand common escape sequences.
* [ ] I know the difference between CLI newlines and HTML line breaks.
