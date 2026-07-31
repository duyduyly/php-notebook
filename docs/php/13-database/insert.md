# Insert Data with PHP PDO

## Table of Contents

- [1. Basic Insert](#1-basic-insert)
- [2. Get the Inserted ID](#2-get-the-inserted-id)
- [3. Validate Input](#3-validate-input)
- [4. Insert Multiple Rows](#4-insert-multiple-rows)
- [5. Transactions](#5-transactions)
- [6. Common Mistakes](#6-common-mistakes)
- [7. Best Practices](#7-best-practices)
- [8. Official Documentation](#8-official-documentation)

---

## 1. Basic Insert

```php
<?php

$sql = <<<'SQL'
INSERT INTO products (
    name,
    slug,
    description,
    price,
    stock,
    status,
    created_at,
    updated_at
) VALUES (
    :name,
    :slug,
    :description,
    :price,
    :stock,
    :status,
    :created_at,
    :updated_at
)
SQL;

$statement = $pdo->prepare($sql);
$now = gmdate('Y-m-d H:i:s');

$statement->execute([
    'name' => 'Keyboard',
    'slug' => 'keyboard',
    'description' => 'Mechanical keyboard',
    'price' => '50.00',
    'stock' => 20,
    'status' => 'active',
    'created_at' => $now,
    'updated_at' => $now,
]);
```

```mermaid
flowchart LR
    A[Validate input] --> B[Prepare INSERT]
    B --> C[Bind values]
    C --> D[Execute]
    D --> E[Read inserted ID]
```

---

## 2. Get the Inserted ID

```php
<?php

$productId = (int) $pdo->lastInsertId();
```

Call `lastInsertId()` on the same PDO connection immediately after the insert.

---

## 3. Validate Input

```php
<?php

$name = trim($_POST['name'] ?? '');
$price = filter_input(INPUT_POST, 'price', FILTER_VALIDATE_FLOAT);
$stock = filter_input(
    INPUT_POST,
    'stock',
    FILTER_VALIDATE_INT,
    ['options' => ['min_range' => 0]]
);

$errors = [];

if ($name === '') {
    $errors['name'] = 'Name is required.';
}

if ($price === false || $price === null || $price < 0) {
    $errors['price'] = 'Enter a valid price.';
}

if ($stock === false || $stock === null) {
    $errors['stock'] = 'Enter valid stock.';
}
```

Prepared statements prevent SQL injection for values, but they do not replace validation.

---

## 4. Insert Multiple Rows

Prepare once and execute many times:

```php
<?php

$products = [
    ['name' => 'Keyboard', 'slug' => 'keyboard', 'price' => '50.00', 'stock' => 20],
    ['name' => 'Mouse', 'slug' => 'mouse', 'price' => '25.00', 'stock' => 35],
];

$statement = $pdo->prepare(
    'INSERT INTO products (
        name, slug, price, stock, status, created_at, updated_at
     ) VALUES (
        :name, :slug, :price, :stock, :status, :created_at, :updated_at
     )'
);

$now = gmdate('Y-m-d H:i:s');

foreach ($products as $product) {
    $statement->execute([
        ...$product,
        'status' => 'active',
        'created_at' => $now,
        'updated_at' => $now,
    ]);
}
```

---

## 5. Transactions

Use a transaction when all inserts must succeed together.

```php
<?php

$pdo->beginTransaction();

try {
    foreach ($products as $product) {
        $statement->execute([
            ...$product,
            'status' => 'active',
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    $pdo->commit();
} catch (Throwable $throwable) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    throw $throwable;
}
```

---

## 6. Common Mistakes

- Concatenating request values into SQL.
- Skipping input validation.
- Using `FLOAT` for money.
- Forgetting database constraints.
- Inserting related records without a transaction.
- Displaying raw `PDOException` messages.
- Generating duplicate slugs without handling a unique constraint.

---

## 7. Best Practices

- Use prepared statements.
- Validate before inserting.
- Use UTC timestamps consistently.
- Use database defaults where appropriate.
- Use transactions for related writes.
- Handle unique-key conflicts safely.
- Return the inserted ID when the caller needs it.
- Keep SQL in a repository or data-access layer as the project grows.

---

## 8. Official Documentation

- [PDO::prepare()](https://www.php.net/manual/en/pdo.prepare.php)
- [PDOStatement::execute()](https://www.php.net/manual/en/pdostatement.execute.php)
- [PDO::lastInsertId()](https://www.php.net/manual/en/pdo.lastinsertid.php)
- [PDO transactions](https://www.php.net/manual/en/pdo.transactions.php)
