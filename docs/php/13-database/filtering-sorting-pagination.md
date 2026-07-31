# Filtering, Sorting, and Pagination with PDO

## Table of Contents

- [1. Filtering](#1-filtering)
- [2. Partial Search](#2-partial-search)
- [3. Range Filters](#3-range-filters)
- [4. IN Conditions](#4-in-conditions)
- [5. Safe Sorting](#5-safe-sorting)
- [6. Offset Pagination](#6-offset-pagination)
- [7. Cursor Pagination](#7-cursor-pagination)
- [8. Dynamic Query Example](#8-dynamic-query-example)
- [9. Performance and Security](#9-performance-and-security)
- [10. Official Documentation](#10-official-documentation)

---

## 1. Filtering

Exact match:

```php
<?php

$statement = $pdo->prepare(
    'SELECT id, name, price, status
     FROM products
     WHERE status = :status
       AND deleted_at IS NULL
     ORDER BY id DESC'
);

$statement->execute(['status' => 'active']);
$products = $statement->fetchAll();
```

Validate filters with an allowlist before executing the query.

---

## 2. Partial Search

```php
<?php

$search = trim($_GET['search'] ?? '');

$statement = $pdo->prepare(
    'SELECT id, name, price
     FROM products
     WHERE name LIKE :search
       AND deleted_at IS NULL
     ORDER BY name ASC'
);

$statement->execute([
    'search' => '%' . $search . '%',
]);
```

`%` matches any number of characters. A leading wildcard can make normal indexes less effective on large tables.

---

## 3. Range Filters

Price range:

```php
<?php

$statement = $pdo->prepare(
    'SELECT id, name, price
     FROM products
     WHERE price BETWEEN :minimum_price AND :maximum_price
       AND deleted_at IS NULL
     ORDER BY price ASC'
);

$statement->execute([
    'minimum_price' => '20.00',
    'maximum_price' => '100.00',
]);
```

Date range with an exclusive end value:

```php
<?php

$statement = $pdo->prepare(
    'SELECT id, name, created_at
     FROM products
     WHERE created_at >= :start_date
       AND created_at < :end_date
       AND deleted_at IS NULL'
);

$statement->execute([
    'start_date' => '2026-07-01 00:00:00',
    'end_date' => '2026-08-01 00:00:00',
]);
```

---

## 4. IN Conditions

One placeholder cannot safely represent a list of values.

```php
<?php

$ids = [1, 2, 3];

if ($ids === []) {
    $products = [];
} else {
    $placeholders = implode(
        ', ',
        array_fill(0, count($ids), '?')
    );

    $statement = $pdo->prepare(
        "SELECT id, name, price
         FROM products
         WHERE id IN ({$placeholders})
           AND deleted_at IS NULL"
    );

    $statement->execute($ids);
    $products = $statement->fetchAll();
}
```

---

## 5. Safe Sorting

Placeholders work for values, not column names or SQL keywords.

```php
<?php

$allowedColumns = [
    'name' => 'name',
    'price' => 'price',
    'created_at' => 'created_at',
];

$allowedDirections = [
    'asc' => 'ASC',
    'desc' => 'DESC',
];

$requestedColumn = $_GET['sort'] ?? 'created_at';
$requestedDirection = strtolower($_GET['direction'] ?? 'desc');

$sortColumn = $allowedColumns[$requestedColumn]
    ?? $allowedColumns['created_at'];

$sortDirection = $allowedDirections[$requestedDirection]
    ?? $allowedDirections['desc'];

$sql = sprintf(
    'SELECT id, name, price, created_at
     FROM products
     WHERE deleted_at IS NULL
     ORDER BY %s %s',
    $sortColumn,
    $sortDirection
);

$products = $pdo->query($sql)->fetchAll();
```

Only allowlisted SQL fragments are inserted into the query.

---

## 6. Offset Pagination

```php
<?php

$page = filter_input(
    INPUT_GET,
    'page',
    FILTER_VALIDATE_INT,
    ['options' => ['default' => 1, 'min_range' => 1]]
);

$perPage = 20;
$offset = ($page - 1) * $perPage;

$statement = $pdo->prepare(
    'SELECT id, name, price, created_at
     FROM products
     WHERE deleted_at IS NULL
     ORDER BY id DESC
     LIMIT :limit OFFSET :offset'
);

$statement->bindValue(':limit', $perPage, PDO::PARAM_INT);
$statement->bindValue(':offset', $offset, PDO::PARAM_INT);
$statement->execute();

$products = $statement->fetchAll();
```

Count total rows:

```php
<?php

$total = (int) $pdo
    ->query(
        'SELECT COUNT(*)
         FROM products
         WHERE deleted_at IS NULL'
    )
    ->fetchColumn();

$totalPages = max(1, (int) ceil($total / $perPage));
```

```mermaid
flowchart LR
    A[Read page] --> B[Calculate offset]
    B --> C[Count rows]
    C --> D[Fetch limited rows]
    D --> E[Return data and pagination metadata]
```

---

## 7. Cursor Pagination

Large offsets can become slow. Cursor pagination uses the last returned key.

```php
<?php

$statement = $pdo->prepare(
    'SELECT id, name, price
     FROM products
     WHERE id < :last_id
       AND deleted_at IS NULL
     ORDER BY id DESC
     LIMIT :limit'
);

$statement->bindValue(':last_id', $lastId, PDO::PARAM_INT);
$statement->bindValue(':limit', 20, PDO::PARAM_INT);
$statement->execute();
```

Cursor pagination is useful for large feeds and infinite scrolling.

---

## 8. Dynamic Query Example

```php
<?php

$conditions = ['deleted_at IS NULL'];
$parameters = [];

$search = trim($_GET['search'] ?? '');
$status = $_GET['status'] ?? '';

if ($search !== '') {
    $conditions[] = 'name LIKE :search';
    $parameters['search'] = '%' . $search . '%';
}

if (in_array($status, ['active', 'inactive'], true)) {
    $conditions[] = 'status = :status';
    $parameters['status'] = $status;
}

$sql = sprintf(
    'SELECT id, name, price, status
     FROM products
     WHERE %s
     ORDER BY id DESC',
    implode(' AND ', $conditions)
);

$statement = $pdo->prepare($sql);
$statement->execute($parameters);
$products = $statement->fetchAll();
```

---

## 9. Performance and Security

- Validate every filter.
- Allowlist sort columns and directions.
- Cap `per_page`, for example at 100.
- Add indexes based on actual filters and sorts.
- Avoid unbounded result sets.
- Consider cursor pagination for large tables.
- Do not expose private rows only because they match a filter.
- Include authorization and ownership conditions in queries when required.

---

## 10. Official Documentation

- [PDO prepared statements](https://www.php.net/manual/en/pdo.prepared-statements.php)
- [PDOStatement::bindValue()](https://www.php.net/manual/en/pdostatement.bindvalue.php)
- [MySQL LIMIT](https://dev.mysql.com/doc/refman/en/limit-optimization.html)
- [MySQL indexes](https://dev.mysql.com/doc/refman/en/optimization-indexes.html)
