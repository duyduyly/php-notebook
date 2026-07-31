# PHP Namespaces and Composer Autoloading

## Table of Contents

- [1. Overview](#1-overview)
- [2. Define a Namespace](#2-define-a-namespace)
- [3. Import Classes with `use`](#3-import-classes-with-use)
- [4. Aliases](#4-aliases)
- [5. Recommended Project Structure](#5-recommended-project-structure)
- [6. Composer PSR-4 Autoloading](#6-composer-psr-4-autoloading)
- [7. Common Mistakes](#7-common-mistakes)
- [8. Best Practices](#8-best-practices)
- [9. Official Documentation](#9-official-documentation)

---

## 1. Overview

Namespaces organize classes and prevent naming conflicts.

```text
App\Domain\User
Vendor\Package\User
```

These classes may share the short name `User` while remaining separate types.

## 2. Define a Namespace

```php
<?php

declare(strict_types=1);

namespace App\Domain;

final readonly class User
{
    public function __construct(
        public int $id,
        public string $name
    ) {
    }
}
```

The namespace declaration normally appears after `declare()` and before class declarations.

## 3. Import Classes with `use`

```php
<?php

declare(strict_types=1);

namespace App\Service;

use App\Domain\User;
use DateTimeImmutable;

final class UserService
{
    public function create(): User
    {
        $createdAt = new DateTimeImmutable();

        return new User(1, 'Alan');
    }
}
```

A fully qualified class name starts with a backslash:

```php
$user = new \App\Domain\User(1, 'Alan');
```

## 4. Aliases

Use `as` when imported class names conflict.

```php
<?php

use App\Domain\User;
use Vendor\Package\User as VendorUser;

$appUser = new User(1, 'Alan');
$vendorUser = new VendorUser();
```

## 5. Recommended Project Structure

```text
oop-example/
├── composer.json
├── public/
│   └── index.php
├── src/
│   ├── Domain/
│   │   ├── Order.php
│   │   └── Product.php
│   ├── Contract/
│   │   ├── LoggerInterface.php
│   │   └── PaymentGatewayInterface.php
│   ├── Service/
│   │   └── OrderService.php
│   ├── Infrastructure/
│   │   ├── FileLogger.php
│   │   └── FakePaymentGateway.php
│   └── Exception/
│       └── PaymentFailedException.php
└── storage/
    └── logs/
```

| Directory | Namespace |
|---|---|
| `src/Domain` | `App\Domain` |
| `src/Contract` | `App\Contract` |
| `src/Service` | `App\Service` |
| `src/Infrastructure` | `App\Infrastructure` |
| `src/Exception` | `App\Exception` |

## 6. Composer PSR-4 Autoloading

Composer can load classes automatically.

`composer.json`:

```json
{
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  }
}
```

Generate the autoloader:

```bash
composer dump-autoload
```

Load it from the application entry point:

```php
<?php

declare(strict_types=1);

require dirname(__DIR__) . '/vendor/autoload.php';

use App\Service\OrderService;
```

PSR-4 mapping:

```text
App\Service\OrderService
        ↓
src/Service/OrderService.php
```

```mermaid
flowchart LR
    A[Request class App Service OrderService] --> B[Composer autoloader]
    B --> C[Map App prefix to src]
    C --> D[Load src/Service/OrderService.php]
```

## 7. Common Mistakes

- Namespace and directory path do not match.
- Filename case differs from class name on Linux.
- Forgetting `composer dump-autoload` after changing autoload configuration.
- Declaring multiple unrelated classes in one file.
- Importing a class but using the wrong alias.

## 8. Best Practices

- Use one primary class per file.
- Match namespace, directory, and filename exactly.
- Use PSR-4 autoloading in real projects.
- Organize namespaces by responsibility.
- Avoid deep, meaningless namespace nesting.
- Import classes explicitly with `use`.

## 9. Official Documentation

- [PHP Namespaces](https://www.php.net/manual/en/language.namespaces.php)
- [Importing and Aliasing](https://www.php.net/manual/en/language.namespaces.importing.php)
- [Autoloading Classes](https://www.php.net/manual/en/language.oop5.autoload.php)
- [Composer Autoloading](https://getcomposer.org/doc/01-basic-usage.md#autoloading)
- [PSR-4 Standard](https://www.php-fig.org/psr/psr-4/)
- [Download Composer](https://getcomposer.org/download/)
