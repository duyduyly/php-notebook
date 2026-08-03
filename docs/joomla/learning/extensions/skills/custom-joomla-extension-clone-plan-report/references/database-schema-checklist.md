# Database Schema Checklist

Use this reference to inventory and compare every database object required by a custom Joomla extension.

## Schema objects

- [ ] Tables
- [ ] Columns
- [ ] Data types and lengths
- [ ] Nullability
- [ ] Default values
- [ ] Auto-increment settings
- [ ] Primary keys
- [ ] Unique indexes
- [ ] Normal indexes
- [ ] Foreign keys and referenced actions
- [ ] Character sets
- [ ] Collations
- [ ] Views
- [ ] Triggers
- [ ] Stored procedures or functions, when present

## Evidence sources

Inspect all available sources rather than relying on one SQL file:

```text
Manifest install/uninstall/update declarations
sql/install.mysql.utf8mb4.sql
sql/uninstall.mysql.utf8mb4.sql
sql/updates/mysql/<version>.sql
Runtime references such as #__table_name
Table classes and model queries
Database schema exported from the source environment
Installer script database operations
```

## Required classification

Separate database items into four groups:

1. **Extension schema** — tables, indexes, constraints, views, and other objects required for runtime.
2. **Business data** — records that must be copied or transformed.
3. **Joomla registration data** — records normally recreated by Installer or Discover.
4. **Joomla Core relationships** — category, content, user, group, view level, asset, menu, field, tag, and language IDs requiring mapping.

Do not blindly copy environment-specific IDs when the target project may use different IDs.

## Table inventory fields

| Field | Description |
|---|---|
| Table or object | Exact prefixed or `#__` name |
| Evidence | Files, SQL statements, or source schema proving usage |
| Schema source | Install SQL, update SQL, installer script, or DB export |
| Data required | Yes, No, or Conditional |
| Core relations | Referenced Joomla entities and ID-mapping requirement |
| Clone action | Create, alter, import, transform, map, or recreate |
| Status | Complete, Missing, Partial, Unknown, or Not applicable |

## Coverage rule

```text
Database schema coverage = recreated required schema objects / total required schema objects × 100%
```

Coverage is 100% only when every required object has evidence, a target creation action, and a successful schema comparison.

A table-count match alone is insufficient. Columns, indexes, defaults, constraints, charset, and collation must also match where relevant.
