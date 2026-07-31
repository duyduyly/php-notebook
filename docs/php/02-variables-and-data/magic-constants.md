# PHP Magic Constants

## Table of Contents

- [1. What Are Magic Constants?](#1-what-are-magic-constants)
- [2. `__LINE__`](#2-__line__)
- [3. `__FILE__`](#3-__file__)
- [4. `__DIR__`](#4-__dir__)
- [5. `__FUNCTION__`](#5-__function__)
- [6. `__CLASS__`](#6-__class__)
- [7. `__METHOD__`](#7-__method__)
- [8. `__NAMESPACE__`](#8-__namespace__)
- [9. `__TRAIT__`](#9-__trait__)
- [10. `ClassName::class`](#10-classnameclass)
- [11. Practical Logging Example](#11-practical-logging-example)
- [12. Practice](#12-practice)

---

## 1. What Are Magic Constants?

Magic constants are predefined values whose result depends on where they are used.

Most magic constants start and end with double underscores.

| Constant | Description |
|---|---|
| `__LINE__` | Current line number |
| `__FILE__` | Full path of the current file |
| `__DIR__` | Directory of the current file |
| `__FUNCTION__` | Current function name |
| `__CLASS__` | Current class name |
| `__TRAIT__` | Current trait name |
| `__METHOD__` | Current class method name |
| `__NAMESPACE__` | Current namespace |
| `ClassName::class` | Fully qualified class name |

These values are especially useful for paths, debugging, logging, dependency configuration, and framework service registration.

---

## 2. `__LINE__`

`__LINE__` returns the current line number in the source file.

```php
<?php

echo __LINE__;
```

Useful for:

- Debugging.
- Logging.
- Error tracing.

The result changes when code is moved to another line, so do not use it as a permanent business identifier.

---

## 3. `__FILE__`

`__FILE__` returns the full path and filename of the current file.

```php
<?php

echo __FILE__;
```

Example output:

```text
/var/www/html/index.php
```

Common uses:

```php
<?php

error_log('Executed file: ' . __FILE__);
```

The exact path differs between environments.

---

## 4. `__DIR__`

`__DIR__` returns the directory containing the current file.

```php
<?php

echo __DIR__;
```

Use it to build reliable absolute paths:

```php
<?php

require_once __DIR__ . '/config/database.php';
```

This is safer than depending on the current working directory:

```php
<?php

// Less reliable because the working directory may differ.
require_once 'config/database.php';
```

### Include flow

```mermaid
flowchart LR
    A[Current PHP file] --> B[Read __DIR__]
    B --> C[Append relative file path]
    C --> D[Create absolute path]
    D --> E[require_once target file]
```

---

## 5. `__FUNCTION__`

`__FUNCTION__` returns the current function name.

```php
<?php

function calculateTotal(): void
{
    echo __FUNCTION__;
}

calculateTotal();
```

Output:

```text
calculateTotal
```

It can be useful in function-level log messages.

---

## 6. `__CLASS__`

`__CLASS__` returns the current class name, including its namespace when applicable.

```php
<?php

class ProductService
{
    public function showClassName(): void
    {
        echo __CLASS__;
    }
}

$service = new ProductService();
$service->showClassName();
```

Output:

```text
ProductService
```

With a namespace:

```php
<?php

namespace App\Service;

class ProductService
{
    public function showClassName(): void
    {
        echo __CLASS__;
    }
}
```

The result is:

```text
App\Service\ProductService
```

---

## 7. `__METHOD__`

`__METHOD__` returns the current class method name, including the class name.

```php
<?php

class ProductService
{
    public function create(): void
    {
        echo __METHOD__;
    }
}

$service = new ProductService();
$service->create();
```

Output:

```text
ProductService::create
```

This is more specific than `__FUNCTION__` inside a class method.

---

## 8. `__NAMESPACE__`

`__NAMESPACE__` returns the current namespace.

```php
<?php

namespace App\Service;

echo __NAMESPACE__;
```

Output:

```text
App\Service
```

It is useful when generating names or debugging namespace resolution.

---

## 9. `__TRAIT__`

`__TRAIT__` returns the current trait name.

```php
<?php

trait Logger
{
    public function showTraitName(): void
    {
        echo __TRAIT__;
    }
}

class Service
{
    use Logger;
}

$service = new Service();
$service->showTraitName();
```

Output:

```text
Logger
```

With namespaces, the fully qualified trait name is returned.

---

## 10. `ClassName::class`

The `::class` syntax returns a class's fully qualified name as a string.

```php
<?php

namespace App\Service;

class ProductService
{
}

echo ProductService::class;
```

Output:

```text
App\Service\ProductService
```

Common uses:

- Dependency injection configuration.
- Service containers.
- Event listener registration.
- Framework configuration.
- Joomla service registration.
- Class maps.

Example configuration:

```php
<?php

$services = [
    ProductService::class => static fn () => new ProductService(),
];
```

Unlike a manually typed class-name string, `::class` is easier for IDEs and refactoring tools to understand.

---

## 11. Practical Logging Example

```php
<?php

function processOrder(int $orderId): void
{
    $message = sprintf(
        '[%s:%d] %s is processing order %d',
        __FILE__,
        __LINE__,
        __FUNCTION__,
        $orderId
    );

    error_log($message);
}

processOrder(1001);
```

Class method example:

```php
<?php

class OrderService
{
    public function process(int $orderId): void
    {
        error_log(sprintf(
            '[%s:%d] %s processing order %d',
            __FILE__,
            __LINE__,
            __METHOD__,
            $orderId
        ));
    }
}
```

Be careful when exposing file paths in browser responses. Internal server paths can reveal environment information. Prefer writing debug details to protected logs.

---

## 12. Practice

Display the current file, directory, line, and function:

```php
<?php

function showDebugInformation(): void
{
    echo 'File: ' . __FILE__ . PHP_EOL;
    echo 'Directory: ' . __DIR__ . PHP_EOL;
    echo 'Line: ' . __LINE__ . PHP_EOL;
    echo 'Function: ' . __FUNCTION__ . PHP_EOL;
}

showDebugInformation();
```

Create a class and compare `__CLASS__`, `__METHOD__`, and `ClassName::class`:

```php
<?php

namespace App\Service;

class DemoService
{
    public function inspect(): void
    {
        echo __CLASS__ . PHP_EOL;
        echo __METHOD__ . PHP_EOL;
        echo DemoService::class . PHP_EOL;
    }
}

(new DemoService())->inspect();
```

## Learning Checklist

- [ ] I can identify the main PHP magic constants.
- [ ] I can build safe file paths with `__DIR__`.
- [ ] I understand the difference between `__FUNCTION__` and `__METHOD__`.
- [ ] I can use `ClassName::class` in configuration.
- [ ] I know not to expose internal file paths publicly.

## Official Resources

- [PHP Magic Constants](https://www.php.net/manual/en/language.constants.magic.php)
- [PHP Constants](https://www.php.net/manual/en/language.constants.php)
- [PHP Namespaces](https://www.php.net/manual/en/language.namespaces.php)
- [W3Schools PHP Magic Constants](https://www.w3schools.com/php/php_magic_constants.asp)
