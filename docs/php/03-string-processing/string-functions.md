# PHP String Functions

PHP provides built-in functions for inspecting, searching, splitting, joining, and comparing strings.

## `strlen()` — Get Length

```php
<?php

$text = 'PHP Tutorial';

echo strlen($text);
```

Output:

```text
12
```

Use `mb_strlen()` for UTF-8 characters:

```php
<?php

$text = 'Tiếng Việt';

echo mb_strlen($text, 'UTF-8');
```

## `str_word_count()` — Count Words

```php
<?php

$text = 'PHP is easy to learn';

echo str_word_count($text);
```

Output:

```text
5
```

This function is most reliable for simple Latin text. For complex Unicode text, use Unicode-aware processing.

## `strpos()` — Find a Position

`strpos()` returns the position of the first match.

```php
<?php

$text = 'I am learning PHP';
$position = strpos($text, 'PHP');

echo $position;
```

Positions start from `0`.

Always compare with `!== false`:

```php
<?php

$text = 'PHP is useful';

if (strpos($text, 'PHP') !== false) {
    echo 'PHP was found.';
}
```

Incorrect:

```php
<?php

if (strpos($text, 'PHP')) {
    echo 'PHP was found.';
}
```

This fails when the match is at position `0`.

Modern alternatives:

```php
<?php

$text = 'PHP is useful';

var_dump(str_contains($text, 'PHP'));
var_dump(str_starts_with($text, 'PHP'));
var_dump(str_ends_with($text, 'useful'));
```

## `substr_count()` — Count Occurrences

```php
<?php

$text = 'PHP is popular. PHP is practical.';

echo substr_count($text, 'PHP');
```

Output:

```text
2
```

## `strcmp()` — Compare Strings

```php
<?php

$result = strcmp('apple', 'apple');

var_dump($result);
```

Results:

* `0`: both strings are equal.
* Less than `0`: the first string comes before the second.
* Greater than `0`: the first string comes after the second.

Case-insensitive comparison:

```php
<?php

var_dump(strcasecmp('PHP', 'php'));
```

For simple equality, use strict comparison:

```php
<?php

var_dump('PHP' === 'PHP');
```

## `explode()` — Split a String

```php
<?php

$csv = 'PHP,Java,JavaScript';
$languages = explode(',', $csv);

print_r($languages);
```

Limit the number of parts:

```php
<?php

$value = 'first:second:third';
$parts = explode(':', $value, 2);

print_r($parts);
```

## `implode()` — Join an Array

```php
<?php

$languages = ['PHP', 'Java', 'JavaScript'];
$result = implode(', ', $languages);

echo $result;
```

Output:

```text
PHP, Java, JavaScript
```

## Split and Join Flow

```mermaid
flowchart LR
    A[Original string] -->|explode| B[Array of values]
    B --> C[Filter or modify values]
    C -->|implode| D[New string]
```

Practical example:

```php
<?php

$tagsInput = ' php, joomla, docker ';
$tags = explode(',', $tagsInput);
$tags = array_map(
    static fn (string $tag): string => trim($tag),
    $tags
);

$result = implode(', ', $tags);

echo $result;
```

Output:

```text
php, joomla, docker
```

---

## Official Resources

* [PHP string functions](https://www.php.net/manual/en/ref.strings.php)
* [str_contains()](https://www.php.net/manual/en/function.str-contains.php)

## Learning Checklist

* [ ] I can measure, search, compare, split, and join strings.
* [ ] I correctly compare `strpos()` with `!== false`.
