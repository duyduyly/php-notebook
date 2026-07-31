# PHP Traits

## Table of Contents

- [1. Overview](#1-overview)
- [2. Basic Trait](#2-basic-trait)
- [3. Multiple Traits](#3-multiple-traits)
- [4. Conflict Resolution](#4-conflict-resolution)
- [5. Good and Bad Uses](#5-good-and-bad-uses)
- [6. Best Practices](#6-best-practices)
- [7. Official Documentation](#7-official-documentation)

---

## 1. Overview

Traits reuse focused methods and properties across unrelated classes. PHP supports one parent class, but a class can use multiple traits.

## 2. Basic Trait

```php
<?php

trait HasTimestamps
{
    private ?DateTimeImmutable $createdAt = null;
    private ?DateTimeImmutable $updatedAt = null;

    protected function initializeTimestamps(): void
    {
        $now = new DateTimeImmutable();
        $this->createdAt = $now;
        $this->updatedAt = $now;
    }

    public function touch(): void
    {
        $this->updatedAt = new DateTimeImmutable();
    }
}

final class Article
{
    use HasTimestamps;

    public function __construct(public string $title)
    {
        $this->initializeTimestamps();
    }
}
```

## 3. Multiple Traits

```php
<?php

trait HasUuid
{
    private string $uuid;

    protected function initializeUuid(): void
    {
        $this->uuid = bin2hex(random_bytes(16));
    }
}

trait CanBeArchived
{
    private bool $archived = false;

    public function archive(): void
    {
        $this->archived = true;
    }
}

final class Document
{
    use HasUuid;
    use CanBeArchived;
}
```

## 4. Conflict Resolution

Two traits may define the same method.

```php
<?php

trait FileMessage
{
    public function message(): string
    {
        return 'File message';
    }
}

trait DatabaseMessage
{
    public function message(): string
    {
        return 'Database message';
    }
}

final class Reporter
{
    use FileMessage;
    use DatabaseMessage {
        FileMessage::message insteadof DatabaseMessage;
        DatabaseMessage::message as databaseMessage;
    }
}
```

## 5. Good and Bad Uses

Good uses:

- Small timestamp behavior.
- UUID support.
- Focused formatting or serialization helpers.

Risky uses:

- Large hidden business workflows.
- Many unrelated dependencies.
- Traits that require undocumented properties.
- Using traits to avoid proper composition.

## 6. Best Practices

- Keep traits small and cohesive.
- Document required properties or methods.
- Avoid mutable shared behavior that is hard to test.
- Prefer composition for replaceable services.
- Resolve conflicts explicitly.

## 7. Official Documentation

- [PHP Traits](https://www.php.net/manual/en/language.oop5.traits.php)
