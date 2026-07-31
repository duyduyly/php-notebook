# PHP Static Members

## Table of Contents

- [1. Overview](#1-overview)
- [2. Static Properties](#2-static-properties)
- [3. Static Methods](#3-static-methods)
- [4. Class Constants](#4-class-constants)
- [5. `self`, `parent`, and `static`](#5-self-parent-and-static)
- [6. Common Mistakes](#6-common-mistakes)
- [7. Best Practices](#7-best-practices)
- [8. Official Documentation](#8-official-documentation)

---

## 1. Overview

Static members belong to the class itself rather than one object.

```php
ClassName::method();
ClassName::$property;
ClassName::CONSTANT;
```

Use static members carefully because mutable static state can create hidden dependencies.

## 2. Static Properties

```php
<?php

final class ConnectionCounter
{
    private static int $count = 0;

    public function __construct()
    {
        self::$count++;
    }

    public static function getCount(): int
    {
        return self::$count;
    }
}

new ConnectionCounter();
new ConnectionCounter();

echo ConnectionCounter::getCount();
```

Static properties are shared across all instances during the request.

## 3. Static Methods

```php
<?php

final class StringHelper
{
    public static function slug(string $value): string
    {
        $value = strtolower(trim($value));
        $value = preg_replace('/[^a-z0-9]+/', '-', $value);

        return trim((string) $value, '-');
    }
}

echo StringHelper::slug('Hello PHP World');
```

A static method cannot use `$this`.

## 4. Class Constants

```php
<?php

final class Order
{
    public const STATUS_PENDING = 'pending';
    public const STATUS_PAID = 'paid';
    public const STATUS_CANCELLED = 'cancelled';
}

$status = Order::STATUS_PENDING;
```

Typed class constants are available in modern PHP:

```php
<?php

final class Pagination
{
    public const int DEFAULT_PAGE_SIZE = 20;
}
```

## 5. `self`, `parent`, and `static`

### `self`

Refers to the class where the code is defined.

```php
<?php

class BaseModel
{
    protected static string $type = 'base';

    public static function typeUsingSelf(): string
    {
        return self::$type;
    }
}
```

### `parent`

Calls parent behavior.

```php
parent::__construct();
parent::someMethod();
```

### `static`

Supports late static binding.

```php
<?php

class BaseModel
{
    protected static string $type = 'base';

    public static function type(): string
    {
        return static::$type;
    }
}

final class UserModel extends BaseModel
{
    protected static string $type = 'user';
}

echo UserModel::type();
```

## 6. Common Mistakes

- Using mutable static properties as global storage.
- Putting every helper into a static class.
- Hiding required dependencies behind static calls.
- Confusing `self::` with late static binding.

## 7. Best Practices

- Use static methods for truly stateless operations.
- Prefer class constants for fixed values.
- Avoid mutable global static state.
- Inject replaceable services instead of accessing them statically.
- Use `static::` only when late static binding is intentional.

## 8. Official Documentation

- [Static Keyword](https://www.php.net/manual/en/language.oop5.static.php)
- [Class Constants](https://www.php.net/manual/en/language.oop5.constants.php)
- [Late Static Bindings](https://www.php.net/manual/en/language.oop5.late-static-bindings.php)
