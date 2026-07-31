# JSON Data Exchange in PHP

## Table of Contents

- [1. Overview](#1-overview)
- [2. JSON Fundamentals](#2-json-fundamentals)
- [3. Encode PHP Data](#3-encode-php-data)
- [4. Decode JSON](#4-decode-json)
- [5. Read a JSON Request Body](#5-read-a-json-request-body)
- [6. Return JSON Responses](#6-return-json-responses)
- [7. HTTP Status Codes and Content Types](#7-http-status-codes-and-content-types)
- [8. Complete JSON API Example](#8-complete-json-api-example)
- [9. Security and Validation](#9-security-and-validation)
- [10. Common Mistakes](#10-common-mistakes)
- [11. Best Practices](#11-best-practices)
- [12. Practice Exercises](#12-practice-exercises)
- [13. Official Documentation](#13-official-documentation)
- [14. Summary](#14-summary)

---

## 1. Overview

JSON is the most common format for exchanging structured data between PHP applications, browsers, and external APIs.

Typical flow:

```mermaid
flowchart LR
    A[Client data] --> B[Encode as JSON]
    B --> C[Send HTTP request]
    C --> D[PHP reads php://input]
    D --> E[Decode and validate]
    E --> F[Process request]
    F --> G[Encode JSON response]
    G --> H[Client receives result]
```

Use JSON for:

- REST-style APIs
- Frontend JavaScript requests
- External service integrations
- Configuration and data files
- Queue and webhook payloads

---

## 2. JSON Fundamentals

JSON supports:

- Objects
- Arrays
- Strings
- Numbers
- Booleans
- `null`

```json
{
  "user": {
    "id": 123,
    "name": "Alan"
  },
  "roles": ["developer", "editor"],
  "active": true,
  "deleted_at": null
}
```

JSON property names and strings use double quotes.

---

## 3. Encode PHP Data

Use `json_encode()` to convert PHP data into JSON.

```php
<?php

declare(strict_types=1);

$data = [
    'name' => 'Alan',
    'age' => 26,
    'active' => true,
];

$json = json_encode(
    $data,
    JSON_UNESCAPED_UNICODE
    | JSON_UNESCAPED_SLASHES
    | JSON_THROW_ON_ERROR
);

echo $json;
```

Output:

```json
{"name":"Alan","age":26,"active":true}
```

Readable output:

```php
<?php

echo json_encode(
    $data,
    JSON_PRETTY_PRINT
    | JSON_UNESCAPED_UNICODE
    | JSON_THROW_ON_ERROR
);
```

### Useful options

| Constant | Purpose |
|---|---|
| `JSON_THROW_ON_ERROR` | Throws `JsonException` on failure |
| `JSON_PRETTY_PRINT` | Produces readable formatting |
| `JSON_UNESCAPED_UNICODE` | Keeps Unicode characters readable |
| `JSON_UNESCAPED_SLASHES` | Keeps URLs readable |
| `JSON_INVALID_UTF8_SUBSTITUTE` | Replaces invalid UTF-8 |
| `JSON_PRESERVE_ZERO_FRACTION` | Preserves values such as `10.0` |

Prefer `JSON_THROW_ON_ERROR` so encoding problems cannot fail silently.

---

## 4. Decode JSON

Use `json_decode()` to convert JSON into PHP data.

```php
<?php

$json = <<<'JSON'
{
  "name": "Alan",
  "age": 26,
  "active": true
}
JSON;

try {
    $data = json_decode(
        $json,
        true,
        512,
        JSON_THROW_ON_ERROR
    );
} catch (JsonException $exception) {
    exit('Invalid JSON.');
}

echo $data['name'];
```

Recommended signature:

```php
json_decode($json, true, 512, JSON_THROW_ON_ERROR)
```

This returns associative arrays and throws explicit exceptions.

---

## 5. Read a JSON Request Body

JSON request bodies are not normally placed in `$_POST`.

Read the raw body from `php://input`.

```php
<?php

declare(strict_types=1);

$contentType = $_SERVER['CONTENT_TYPE'] ?? '';

if (!str_starts_with($contentType, 'application/json')) {
    http_response_code(415);
    exit('Content-Type must be application/json.');
}

$rawBody = file_get_contents('php://input');

if ($rawBody === false) {
    http_response_code(400);
    exit('Could not read request body.');
}

try {
    $input = json_decode(
        $rawBody,
        true,
        512,
        JSON_THROW_ON_ERROR
    );
} catch (JsonException $exception) {
    http_response_code(400);
    exit('Invalid JSON.');
}

if (!is_array($input)) {
    http_response_code(400);
    exit('Expected a JSON object.');
}
```

Valid syntax does not mean valid business data. Validate every decoded field.

---

## 6. Return JSON Responses

```php
<?php

http_response_code(200);
header('Content-Type: application/json; charset=utf-8');

 echo json_encode([
    'success' => true,
    'data' => [
        'message' => 'Request completed.',
    ],
], JSON_THROW_ON_ERROR);
```

Reusable helper:

```php
<?php

declare(strict_types=1);

function jsonResponse(
    array $payload,
    int $statusCode = 200
): never {
    http_response_code($statusCode);

    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');

    echo json_encode(
        $payload,
        JSON_UNESCAPED_UNICODE
        | JSON_UNESCAPED_SLASHES
        | JSON_THROW_ON_ERROR
    );

    exit;
}
```

Consistent error response:

```php
<?php

jsonResponse([
    'success' => false,
    'error' => [
        'code' => 'VALIDATION_ERROR',
        'message' => 'The submitted data is invalid.',
        'fields' => [
            'email' => 'Enter a valid email address.',
        ],
    ],
], 422);
```

---

## 7. HTTP Status Codes and Content Types

### Common status codes

| Status | Meaning |
|---|---|
| `200` | Successful request |
| `201` | Resource created |
| `204` | Success without a response body |
| `400` | Invalid request |
| `401` | Authentication required |
| `403` | Access forbidden |
| `404` | Resource not found |
| `405` | HTTP method not allowed |
| `409` | Resource conflict |
| `415` | Unsupported content type |
| `422` | Validation failed |
| `429` | Too many requests |
| `500` | Unexpected server error |

### Common content types

| Format | Content type |
|---|---|
| JSON | `application/json` |
| XML | `application/xml` |
| Standard form | `application/x-www-form-urlencoded` |
| File form | `multipart/form-data` |
| Plain text | `text/plain` |
| HTML | `text/html` |

---

## 8. Complete JSON API Example

This learning endpoint supports:

- `GET /api/tasks.php`
- `POST /api/tasks.php`
- JSON requests and responses
- Validation
- Local JSON-file storage

```php
<?php

declare(strict_types=1);

const STORAGE_FILE = __DIR__ . '/../storage/tasks.json';

function jsonResponse(array $payload, int $statusCode = 200): never
{
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');

    echo json_encode(
        $payload,
        JSON_UNESCAPED_UNICODE
        | JSON_UNESCAPED_SLASHES
        | JSON_THROW_ON_ERROR
    );

    exit;
}

function readTasks(): array
{
    if (!is_file(STORAGE_FILE)) {
        return [];
    }

    $json = file_get_contents(STORAGE_FILE);

    if ($json === false) {
        throw new RuntimeException('Could not read tasks.');
    }

    $tasks = json_decode(
        $json,
        true,
        512,
        JSON_THROW_ON_ERROR
    );

    return is_array($tasks) ? $tasks : [];
}

function writeTasks(array $tasks): void
{
    $directory = dirname(STORAGE_FILE);

    if (!is_dir($directory)) {
        $created = mkdir($directory, 0775, true);

        if (!$created && !is_dir($directory)) {
            throw new RuntimeException('Could not create storage directory.');
        }
    }

    $json = json_encode(
        $tasks,
        JSON_PRETTY_PRINT
        | JSON_UNESCAPED_UNICODE
        | JSON_THROW_ON_ERROR
    );

    if (file_put_contents(STORAGE_FILE, $json . PHP_EOL, LOCK_EX) === false) {
        throw new RuntimeException('Could not save tasks.');
    }
}

try {
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

    if ($method === 'GET') {
        jsonResponse([
            'success' => true,
            'data' => readTasks(),
        ]);
    }

    if ($method !== 'POST') {
        header('Allow: GET, POST');

        jsonResponse([
            'success' => false,
            'error' => [
                'code' => 'METHOD_NOT_ALLOWED',
                'message' => 'Only GET and POST are allowed.',
            ],
        ], 405);
    }

    $contentType = $_SERVER['CONTENT_TYPE'] ?? '';

    if (!str_starts_with($contentType, 'application/json')) {
        jsonResponse([
            'success' => false,
            'error' => [
                'code' => 'UNSUPPORTED_MEDIA_TYPE',
                'message' => 'Content-Type must be application/json.',
            ],
        ], 415);
    }

    $rawBody = file_get_contents('php://input');

    if ($rawBody === false) {
        jsonResponse([
            'success' => false,
            'error' => [
                'code' => 'INVALID_BODY',
                'message' => 'Could not read the request body.',
            ],
        ], 400);
    }

    try {
        $input = json_decode(
            $rawBody,
            true,
            512,
            JSON_THROW_ON_ERROR
        );
    } catch (JsonException $exception) {
        jsonResponse([
            'success' => false,
            'error' => [
                'code' => 'INVALID_JSON',
                'message' => 'The JSON body is invalid.',
            ],
        ], 400);
    }

    $title = isset($input['title']) && is_string($input['title'])
        ? trim($input['title'])
        : '';

    if ($title === '') {
        jsonResponse([
            'success' => false,
            'error' => [
                'code' => 'VALIDATION_ERROR',
                'message' => 'The submitted data is invalid.',
                'fields' => [
                    'title' => 'Title is required.',
                ],
            ],
        ], 422);
    }

    $tasks = readTasks();

    $task = [
        'id' => bin2hex(random_bytes(8)),
        'title' => $title,
        'completed' => false,
        'created_at' => (new DateTimeImmutable())->format(DATE_ATOM),
    ];

    $tasks[] = $task;
    writeTasks($tasks);

    jsonResponse([
        'success' => true,
        'data' => $task,
    ], 201);
} catch (Throwable $exception) {
    jsonResponse([
        'success' => false,
        'error' => [
            'code' => 'INTERNAL_ERROR',
            'message' => 'An unexpected server error occurred.',
        ],
    ], 500);
}
```

Use a database instead of a JSON file in real concurrent applications.

---

## 9. Security and Validation

Always validate:

- Required fields
- Data types
- String lengths
- Numeric ranges
- Allowed values
- Authentication
- Authorization
- Resource ownership

Also:

- Limit request-body size.
- Use prepared SQL statements.
- Protect cookie-authenticated state changes with CSRF tokens.
- Restrict CORS intentionally.
- Hide internal errors from clients.
- Log detailed failures on the server.

---

## 10. Common Mistakes

### Expecting JSON in `$_POST`

Read it from:

```php
file_get_contents('php://input')
```

### Not setting `Content-Type`

```php
header('Content-Type: application/json; charset=utf-8');
```

### Ignoring JSON errors

Use:

```php
JSON_THROW_ON_ERROR
```

### Returning inconsistent response formats

Use one predictable success and error structure across endpoints.

### Trusting decoded data

Valid JSON syntax does not prove valid application values.

---

## 11. Best Practices

- Use JSON for most modern APIs.
- Read request bodies from `php://input`.
- Use `JSON_THROW_ON_ERROR`.
- Validate `Content-Type`.
- Return correct HTTP status codes.
- Keep response structures consistent.
- Validate every decoded value.
- Avoid exposing exception details.
- Use a database for production storage.

---

## 12. Practice Exercises

### Encode PHP data

```php
<?php

$user = [
    'id' => 1,
    'name' => 'Alan',
    'active' => true,
];

 echo json_encode(
    $user,
    JSON_PRETTY_PRINT
    | JSON_UNESCAPED_UNICODE
    | JSON_THROW_ON_ERROR
);
```

### Decode JSON

```php
<?php

$json = '{"name":"Keyboard","price":50}';

$product = json_decode(
    $json,
    true,
    512,
    JSON_THROW_ON_ERROR
);

echo $product['name'];
```

### Create a JSON response

```php
<?php

header('Content-Type: application/json; charset=utf-8');

 echo json_encode([
    'success' => true,
    'data' => [
        'message' => 'Hello from PHP.',
    ],
], JSON_THROW_ON_ERROR);
```

---

## 13. Official Documentation

- [PHP JSON extension](https://www.php.net/manual/en/book.json.php)
- [`json_encode()`](https://www.php.net/manual/en/function.json-encode.php)
- [`json_decode()`](https://www.php.net/manual/en/function.json-decode.php)
- [JSON constants](https://www.php.net/manual/en/json.constants.php)
- [PHP input streams](https://www.php.net/manual/en/wrappers.php.php)
- [Download PHP](https://www.php.net/downloads.php)

---

## 14. Summary

| Topic | Purpose |
|---|---|
| JSON | Compact structured data format |
| `json_encode()` | Converts PHP data to JSON |
| `json_decode()` | Converts JSON to PHP data |
| `php://input` | Reads the raw request body |
| HTTP status | Describes the request result |
| Content type | Declares the response or request format |

Recommended defaults:

- Use JSON for modern PHP APIs.
- Use `JSON_THROW_ON_ERROR`.
- Validate all decoded values.
- Return consistent response shapes.
- Use correct content types and status codes.
