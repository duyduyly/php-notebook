# Connect to a Database with PHP PDO

## Table of Contents

- [1. Overview](#1-overview)
- [2. Requirements](#2-requirements)
- [3. Basic PDO Connection](#3-basic-pdo-connection)
- [4. Connection Configuration](#4-connection-configuration)
- [5. Reusable Database Class](#5-reusable-database-class)
- [6. Error Handling](#6-error-handling)
- [7. Security](#7-security)
- [8. Common Mistakes](#8-common-mistakes)
- [9. Checklist](#9-checklist)
- [10. Official Documentation](#10-official-documentation)

---

## 1. Overview

PDO, or PHP Data Objects, provides a consistent object-oriented API for connecting to databases and executing SQL.

This guide uses MySQL or MariaDB with:

- `utf8mb4` character encoding;
- exception-based error handling;
- associative-array fetch mode;
- native prepared statements.

```mermaid
flowchart LR
    A[PHP application] --> B[Build PDO DSN]
    B --> C[Open database connection]
    C --> D[Prepare and execute SQL]
    D --> E[Fetch results]
```

---

## 2. Requirements

Check enabled PHP modules:

```bash
php -m
```

Required modules:

```text
PDO
pdo_mysql
```

Ubuntu or Debian:

```bash
sudo apt install php-mysql
```

Official PHP Docker image:

```dockerfile
RUN docker-php-ext-install pdo_mysql
```

---

## 3. Basic PDO Connection

```php
<?php

declare(strict_types=1);

$dsn = 'mysql:host=127.0.0.1;port=3306;dbname=php_app;charset=utf8mb4';

$pdo = new PDO(
    $dsn,
    'app_user',
    'secret',
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]
);
```

| Setting | Purpose |
|---|---|
| `host` | Database server address |
| `port` | MySQL port, usually `3306` |
| `dbname` | Database name |
| `charset=utf8mb4` | Full Unicode support |
| `ERRMODE_EXCEPTION` | Throws `PDOException` on failure |
| `FETCH_ASSOC` | Returns associative arrays by default |
| `ATTR_EMULATE_PREPARES=false` | Uses native prepares where supported |

---

## 4. Connection Configuration

Store configuration outside the public web directory.

```php
<?php
// config/database.php

return [
    'host' => $_ENV['DB_HOST'] ?? '127.0.0.1',
    'port' => (int) ($_ENV['DB_PORT'] ?? 3306),
    'database' => $_ENV['DB_DATABASE'] ?? 'php_app',
    'username' => $_ENV['DB_USERNAME'] ?? 'app_user',
    'password' => $_ENV['DB_PASSWORD'] ?? '',
];
```

Do not commit production passwords to Git.

---

## 5. Reusable Database Class

```php
<?php

declare(strict_types=1);

final class Database
{
    public static function connect(array $config): PDO
    {
        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
            $config['host'],
            $config['port'],
            $config['database']
        );

        return new PDO(
            $dsn,
            $config['username'],
            $config['password'],
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]
        );
    }
}
```

Usage:

```php
<?php

$config = require dirname(__DIR__) . '/config/database.php';
$pdo = Database::connect($config);
```

---

## 6. Error Handling

```php
<?php

try {
    $pdo = Database::connect($config);
} catch (PDOException $exception) {
    error_log((string) $exception);

    http_response_code(500);
    exit('Database connection failed.');
}
```

Log technical details, but show a safe message to users.

---

## 7. Security

- Use a dedicated application database account.
- Grant only the permissions the application requires.
- Store secrets in environment variables or a secret manager.
- Use HTTPS when the database is accessed through a remote secure tunnel or API.
- Never show DSNs, usernames, passwords, or stack traces to users.
- Use prepared statements for all dynamic values.

---

## 8. Common Mistakes

- Using the MySQL `root` account in the application.
- Omitting `charset=utf8mb4`.
- Displaying raw `PDOException` messages.
- Hardcoding production credentials.
- Forgetting to enable `pdo_mysql`.
- Using string concatenation for SQL values.

---

## 9. Checklist

- [ ] PDO and `pdo_mysql` are enabled.
- [ ] The DSN contains `charset=utf8mb4`.
- [ ] PDO exception mode is enabled.
- [ ] Default fetch mode is associative.
- [ ] Native prepared statements are preferred.
- [ ] Credentials are outside source control.
- [ ] A least-privilege database user is used.

---

## 10. Official Documentation

- [PDO](https://www.php.net/manual/en/book.pdo.php)
- [PDO connections](https://www.php.net/manual/en/pdo.connections.php)
- [PDO MySQL driver](https://www.php.net/manual/en/ref.pdo-mysql.php)
- [Download PHP](https://www.php.net/downloads.php)
- [MySQL downloads](https://dev.mysql.com/downloads/)
- [MariaDB downloads](https://mariadb.org/download/)
