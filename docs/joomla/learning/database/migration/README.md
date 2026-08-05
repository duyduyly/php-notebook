# Joomla 3 to Joomla 6 SQL-First Migration

A practical structure for auditing, prechecking, migrating, rebuilding, validating, and rolling back selected Joomla 3 data into a fresh Joomla 6 database.

## Table of Contents

- [1. Migration Type](#1-migration-type)
- [2. Safety Rules](#2-safety-rules)
- [3. Configuration](#3-configuration)
- [4. Execution Order](#4-execution-order)
- [5. Folder Responsibilities](#5-folder-responsibilities)
- [6. Validation](#6-validation)
- [7. Rollback](#7-rollback)

## 1. Migration Type

This is a **one-time, batch-based, SQL-first ETL migration**.

```text
Joomla 3 source
  -> inventory
  -> precheck
  -> ID mapping
  -> ordered SQL migration
  -> Joomla-aware rebuild
  -> validation
  -> report
```

MySQL performs inventory, checks, bulk inserts, mapping, and reconciliation. `rebuild/rebuild.php` boots Joomla 6 for operations that should not be done with raw SQL alone.

## 2. Safety Rules

1. Run against staging copies first.
2. Back up the Joomla 3 source and fresh Joomla 6 target.
3. Replace all example database names and prefixes.
4. Compare exact schemas with `SHOW CREATE TABLE`.
5. Stop when a precheck returns unresolved records.
6. Do not copy sessions, cache, Finder indexes, `#__extensions`, or `#__schemas`.
7. Prefer restoring the target snapshot over partial production rollback.

## 3. Configuration

```bash
cp config/database.example.php config/database.php
mysql -u root -p joomla_migration < config/mapping.sql
```

Default example names:

```text
joomla3_source.j3_
joomla6_target.j6_
joomla_migration
```

## 4. Execution Order

```bash
mysql -u root -p < inventory/content-inventory.sql
mysql -u root -p < inventory/category-inventory.sql
mysql -u root -p < inventory/menu-inventory.sql
mysql -u root -p < inventory/module-inventory.sql
mysql -u root -p < inventory/extension-inventory.sql

mysql -u root -p < precheck/orphan-checks.sql
mysql -u root -p < precheck/duplicate-alias-checks.sql
mysql -u root -p < precheck/invalid-json-checks.sql
mysql -u root -p < precheck/zero-date-checks.sql
mysql -u root -p < precheck/tree-checks.sql

mysql -u root -p < migrate/users.sql
mysql -u root -p < migrate/categories.sql
mysql -u root -p < migrate/content.sql
mysql -u root -p < migrate/workflows.sql
mysql -u root -p < migrate/tags.sql
mysql -u root -p < migrate/fields.sql
mysql -u root -p < migrate/menus.sql
mysql -u root -p < migrate/modules.sql

php rebuild/rebuild.php

mysql -u root -p < validate/counts.sql
mysql -u root -p < validate/relationships.sql
mysql -u root -p < validate/checksums.sql
```

## 5. Folder Responsibilities

| Folder | Responsibility |
|---|---|
| `config/` | Connections and reusable ID mapping tables |
| `inventory/` | Source scope and usage |
| `precheck/` | Data defects that must be resolved |
| `migrate/` | Ordered data migration scripts |
| `rebuild/` | Joomla-aware generated structures |
| `validate/` | Counts, relationships, checksums, and behavior |
| `rollback/` | Rehearsal rollback by mapped target IDs |
| `reports/` | Run results, exceptions, and sign-off |

## 6. Validation

```text
approved source records
=
migrated + approved skipped + failed + manual review
```

Database checks are not enough. Complete `validate/behavior-checklist.md` after every rehearsal.

## 7. Rollback

The SQL rollback is intended for rehearsals. Production rollback should restore the Joomla 6 baseline snapshot and return traffic to Joomla 3.
