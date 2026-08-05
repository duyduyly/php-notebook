# Runnable Joomla Data Migration Example

A small, runnable PHP CLI example that demonstrates how to migrate Joomla-style categories and articles from a source MySQL database to a target MySQL database.

> This is an educational vertical slice, not a production-ready full Joomla 3 to Joomla 6 migrator. It demonstrates the migration pattern: **extract → map → transform → load → validate**.

## Table of Contents

- [1. What This Example Migrates](#1-what-this-example-migrates)
- [2. Requirements](#2-requirements)
- [3. Project Files](#3-project-files)
- [4. Setup](#4-setup)
- [5. Run the Migration](#5-run-the-migration)
- [6. Validate the Result](#6-validate-the-result)
- [7. How It Works](#7-how-it-works)
- [8. Important Limitations](#8-important-limitations)
- [9. Next Steps](#9-next-steps)

---

## 1. What This Example Migrates

The example migrates:

- Categories from `j3_categories` to `j6_categories`.
- Articles from `j3_content` to `j6_content`.
- Source category IDs to target category IDs through `migration_category_map`.

It demonstrates:

- Parent-first category migration.
- Source-to-target ID mapping.
- Article category remapping.
- JSON validation and normalization.
- Zero-date normalization.
- Per-record transactions.
- Retry-safe execution.
- Failed-record logging.
- Reconciliation queries.

---

## 2. Requirements

- PHP 8.1 or later.
- PHP PDO MySQL extension.
- MySQL 8.0 or later.
- Access to create three demo databases.

Verify PHP extensions:

```bash
php -m | grep -E 'PDO|pdo_mysql'
```

---

## 3. Project Files

```text
runnable-migration-example/
├── config.example.php
├── migrate.php
├── README.md
└── sql/
    ├── 01-setup-demo.sql
    └── 02-validate.sql
```

---

## 4. Setup

### 4.1 Create the demo databases and sample data

Run:

```bash
mysql -u root -p < sql/01-setup-demo.sql
```

The script creates:

```text
joomla3_demo
joomla6_demo
joomla_migration_demo
```

### 4.2 Create the local configuration

Copy the example configuration:

```bash
cp config.example.php config.php
```

Update the username and password in `config.php`:

```php
'username' => 'root',
'password' => 'your-password',
```

Do not commit real credentials.

---

## 5. Run the Migration

Run all supported entities:

```bash
php migrate.php all
```

Run only categories:

```bash
php migrate.php categories
```

Run only articles after categories have been migrated:

```bash
php migrate.php articles
```

Expected output:

```text
Starting category migration...
[MIGRATED] category source=10 target=2
[MIGRATED] category source=11 target=3
Category migration completed.
Starting article migration...
[MIGRATED] article source=100 target=1
[MIGRATED] article source=101 target=2
Article migration completed.
Migration completed successfully.
```

Running the command again is safe. Existing successful mappings are skipped.

---

## 6. Validate the Result

Run:

```bash
mysql -u root -p < sql/02-validate.sql
```

The validation script checks:

- Source and target row counts.
- Mapping status counts.
- Articles without valid categories.
- Source-to-target category relationships.
- Failed migration records.

A successful run should report no orphan target articles and no failed mappings.

---

## 7. How It Works

### 7.1 Category migration

Categories are loaded in parent-first order.

```text
Source category
    ↓
Resolve source parent mapping
    ↓
Insert target category
    ↓
Store source ID → target ID
```

The root source parent ID `1` maps to the existing target root category ID `1`.

### 7.2 Article migration

Each article requires an existing category mapping.

```text
Source article.catid
    ↓
Lookup migration_category_map
    ↓
Target article.catid
    ↓
Insert target article
```

If the category mapping is missing, the article is marked as failed instead of being inserted with an invalid relationship.

### 7.3 Retry safety

The mapping tables use the source ID as a primary key. A successfully migrated record is skipped on later runs.

Statuses:

```text
pending
migrated
failed
```

Failed records may be retried after fixing the source data or migration rule.

---

## 8. Important Limitations

This example does not migrate or rebuild:

- Joomla ACL assets.
- Users and access levels.
- Category nested-set values used by a real Joomla installation.
- Joomla 6 workflows.
- Menus and modules.
- Tags and custom fields.
- Extension registry records.
- Joomla events or plugin behavior.

The demo target tables are intentionally simplified. Do not run the setup SQL against a real Joomla database.

For a real Joomla 3 to Joomla 6 migration:

1. Install Joomla 6 fresh.
2. Preserve Joomla 6 installation-owned records.
3. Use exact real schemas from both installations.
4. Add user, access, asset, workflow, menu, module, tag, and field mappings.
5. Use Joomla APIs or CLI commands for Joomla-generated structures.
6. Run at least two complete rehearsals before production cutover.

---

## 9. Next Steps

Extend this example in the following order:

1. Add users and user mappings.
2. Map article authors and access levels.
3. Add Joomla-compatible category tree rebuilding.
4. Add workflow associations.
5. Add menu link ID rewriting.
6. Add modules and module-menu assignments.
7. Add custom extension migrators.
8. Add CSV reconciliation reports.
9. Add `--dry-run`, `--batch-size`, and `--resume` options.
10. Add automated tests.
