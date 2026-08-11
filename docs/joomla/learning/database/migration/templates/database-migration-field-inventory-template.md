# {{SCOPE_NAME}} Migration Field Inventory — {{SIDE}} {{SYSTEM_NAME}} {{VERSION}}

## Inventory Rule

> **Inventory = YES**  
> **Field inventory = 100%**  
> **Mapping decision = required before migration**

Use this single template for either side of a migration:

```text
{{SIDE}} = SOURCE
or
{{SIDE}} = TARGET
```

Schema source of truth:

- `{{SCHEMA_SOURCE_1}}`
- `{{SCHEMA_SOURCE_2}}`
- `{{SCHEMA_SOURCE_N}}`

Companion group/table manifest: `{{GROUP_MANIFEST}}`

```text
Declared tables                 = {{TABLE_COUNT}}
Physical fields                 = {{FIELD_COUNT}}
Unique (table, field)           = {{FIELD_COUNT}}
Duplicate (table, field)        = 0
Missing declared tables         = 0
Missing declared fields         = 0
Baseline physical field coverage = 100%
```

> `100%` above means coverage of the declared schema baseline. Production must still be reconciled against the actual database metadata before migration execution.

---

## Metadata Contract

For every table, preserve:

- ordered physical field list;
- exact authoritative `CREATE TABLE` DDL when available;
- data type and full type;
- length / precision / scale;
- nullability;
- default;
- auto-increment / generated / extra attributes;
- charset and collation;
- comments;
- generated expressions;
- primary key;
- unique indexes;
- normal indexes;
- foreign keys when physically declared;
- engine;
- table charset/collation;
- table comment;
- schema-source file/location.

Migration annotations are separate from physical schema facts. Do not silently modify the authoritative DDL to make source and target look compatible.

---

## Placeholder Contract

| Placeholder | Meaning |
|---|---|
| `{{SCOPE_NAME}}` | Core, extension, component, subsystem, or migration scope |
| `{{SIDE}}` | `SOURCE` or `TARGET` |
| `{{SYSTEM_NAME}}` | Product/extension/system name |
| `{{VERSION}}` | Exact version/tag/build |
| `{{TABLE_COUNT}}` | Declared physical table count |
| `{{FIELD_COUNT}}` | Declared physical field count |
| `{{GROUP_ID}}` | Group such as G0, G1, or custom grouping |
| `{{GROUP_NAME}}` | Human-readable group name |
| `{{TABLE_NAME}}` | Physical table name |
| `{{TABLE_FIELD_COUNT}}` | Number of physical fields in the table |
| `{{FIELD_LIST}}` | Ordered comma-separated physical field names |
| `{{POLICY}}` | Inventory/migration policy annotation |
| `{{OFFICIAL_SOURCE}}` | Exact DDL file/path/version source |
| `{{CREATE_TABLE_DDL}}` | Exact authoritative table DDL |

---

# {{GROUP_ID}} — {{GROUP_NAME}}

**Tables:** `{{GROUP_TABLE_COUNT}}` · **Fields:** `{{GROUP_FIELD_COUNT}}`

Repeat the following section once for every physical table in this group.

## `{{TABLE_NAME}}`

**Fields ({{TABLE_FIELD_COUNT}}):** `{{FIELD_1}}`, `{{FIELD_2}}`, `{{FIELD_3}}`, `...`, `{{FIELD_N}}`

**Policy:** `{{POLICY}}`  
**Official source:** `{{OFFICIAL_SOURCE}}`

```sql
{{CREATE_TABLE_DDL}}
```

### Optional Migration Annotations

Use this section only for migration-relevant facts that are **not** already expressed by the physical DDL.

| Field / Scope | Annotation Type | Value |
|---|---|---|
| `{{FIELD_OR_TABLE}}` | `STRUCTURED` | `{{JSON / REGISTRY / SERIALIZED / URL / PATH / OTHER}}` |
| `{{FIELD_OR_TABLE}}` | `REFERENCE` | `{{REFERENCE_DOMAIN_OR_TARGET}}` |
| `{{FIELD_OR_TABLE}}` | `GENERATED` | `{{GENERATION_RULE}}` |
| `{{FIELD_OR_TABLE}}` | `RUNTIME` | `{{RUNTIME_REASON}}` |
| `{{FIELD_OR_TABLE}}` | `SOURCE_ONLY / TARGET_ONLY` | `{{REASON}}` |

Default rule when an annotation is absent:

```text
Structured = NO
Reference  = none declared by annotation
Schema fact = authoritative DDL
Migration decision = resolved by the migration contract / field mapping document
```

---

# Repeat for All Groups

Generate one explicit section for every group and every physical table.

Do **not** use wildcard table entries in the final inventory such as:

```text
prefix_table_*
all plugin tables
other runtime tables
...
```

Every physical table in the declared scope must be explicit.

---

## Schema Coverage Manifest

### By Group

| Group | Tables | Fields |
|---|---:|---:|
| `{{GROUP_1}}` | `{{COUNT}}` | `{{COUNT}}` |
| `{{GROUP_2}}` | `{{COUNT}}` | `{{COUNT}}` |
| `...` | `...` | `...` |
| **Total** | **{{TABLE_COUNT}}** | **{{FIELD_COUNT}}** |

### By Schema Source

| Schema source | Tables | Fields |
|---|---:|---:|
| `{{SCHEMA_SOURCE_1}}` | `{{COUNT}}` | `{{COUNT}}` |
| `{{SCHEMA_SOURCE_2}}` | `{{COUNT}}` | `{{COUNT}}` |
| `...` | `...` | `...` |
| **Total** | **{{TABLE_COUNT}}** | **{{FIELD_COUNT}}** |

Coverage contract:

```text
Declared physical tables          = {{TABLE_COUNT}}
Explicit table sections           = {{TABLE_COUNT}}
Declared physical fields          = {{FIELD_COUNT}}
Explicit unique table/field pairs = {{FIELD_COUNT}}

Duplicate table sections          = 0
Duplicate table/field pairs       = 0
Missing declared tables           = 0
Missing declared fields           = 0
Extra unexplained tables          = 0
Wildcard inventory entries        = 0

Baseline table coverage           = 100%
Baseline physical field coverage  = 100%
```

---

## Production Reconciliation Gate

The declared manifest is a baseline. The actual database is the source of truth for production coverage.

For MySQL/MariaDB, inventory the actual fields using `information_schema.COLUMNS`.

```sql
SELECT
    c.TABLE_SCHEMA,
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.ORDINAL_POSITION,
    c.DATA_TYPE,
    c.COLUMN_TYPE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    c.COLUMN_KEY,
    c.EXTRA,
    c.CHARACTER_SET_NAME,
    c.COLLATION_NAME,
    c.COLUMN_COMMENT,
    c.GENERATION_EXPRESSION
FROM information_schema.COLUMNS AS c
WHERE c.TABLE_SCHEMA = :database_name
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;
```

If the migration inventory database has an explicit scoped table list, constrain the query to that list rather than assuming every table in the database belongs to the migration scope.

Required production checks:

```text
Actual scoped tables discovered       = 100%
Actual scoped fields discovered       = 100%
Tables inserted into table inventory  = 100%
Fields inserted into field inventory  = 100%

Missing inventory tables              = 0
Missing inventory fields              = 0
Duplicate inventory tables            = 0
Duplicate inventory fields            = 0
Unclassified source/target tables     = 0
Unclassified source/target fields     = 0
Unexplained baseline deviations       = 0
```

A migration run must be blocked if any physical table or field in the declared production scope is absent from inventory or lacks the required downstream mapping decision.

---

## Field-Level QA Queries

### Count physical fields

```sql
SELECT COUNT(*) AS physical_field_count
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = :database_name;
```

When only a subset of database tables belongs to the migration scope, join/filter against the scoped inventory table list.

### Detect duplicate inventory rows

```sql
SELECT
    table_name,
    column_name,
    COUNT(*) AS duplicate_count
FROM migration_inventory.field_inventory
WHERE migration_run_id = :migration_run_id
  AND database_side = :database_side
GROUP BY table_name, column_name
HAVING COUNT(*) > 1;
```

Expected result: **0 rows**.

### Detect missing physical fields

```sql
SELECT
    c.TABLE_NAME,
    c.COLUMN_NAME
FROM information_schema.COLUMNS AS c
JOIN migration_inventory.table_list AS t
  ON t.table_name = c.TABLE_NAME
LEFT JOIN migration_inventory.field_inventory AS f
  ON f.table_name = c.TABLE_NAME
 AND f.column_name = c.COLUMN_NAME
 AND f.migration_run_id = :migration_run_id
 AND f.database_side = :database_side
WHERE c.TABLE_SCHEMA = :database_name
  AND t.migration_run_id = :migration_run_id
  AND f.column_name IS NULL
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;
```

Expected result: **0 rows**.

---

## 100% Field Inventory Checklist

### Baseline Identity

- [ ] Exact system/product/extension name recorded
- [ ] Exact version/tag/build recorded
- [ ] Migration side is explicit: `SOURCE` or `TARGET`
- [ ] Schema authority is documented
- [ ] Schema-source files/locations are documented

### Table Coverage

- [ ] Declared table count established
- [ ] Every physical table has an explicit section
- [ ] Missing declared tables = 0
- [ ] Duplicate table sections = 0
- [ ] Wildcard table entries = 0
- [ ] Group totals reconcile to total table count

### Field Coverage

- [ ] Declared physical field count established
- [ ] Ordered fields listed for every table
- [ ] Every `(table, field)` pair is unique
- [ ] Missing declared fields = 0
- [ ] Duplicate `(table, field)` pairs = 0
- [ ] Group field totals reconcile to total field count

### Physical Metadata

- [ ] Exact authoritative DDL preserved for every table
- [ ] Data types preserved
- [ ] Nullability preserved
- [ ] Defaults preserved
- [ ] Auto-increment/generated attributes preserved
- [ ] Charset/collation preserved where applicable
- [ ] Comments preserved where applicable
- [ ] Primary/unique/normal indexes preserved
- [ ] Foreign keys preserved where physically declared
- [ ] Engine/table options preserved

### Migration-Relevant Annotations

- [ ] Structured fields identified where known
- [ ] Reference fields identified where known
- [ ] Runtime/generated/source-only/target-only fields identified where known
- [ ] Schema facts are kept separate from migration decisions

### Production Reconciliation

- [ ] Actual production tables scanned
- [ ] Actual production fields scanned
- [ ] Baseline vs production differences listed
- [ ] Missing inventory objects = 0
- [ ] Duplicate inventory objects = 0
- [ ] Unexplained production deviations = 0

---

## Final Inventory Gate

```text
BASELINE
--------------------------------------------
Declared tables                      = {{TABLE_COUNT}}
Explicit table sections              = {{TABLE_COUNT}}
Declared physical fields             = {{FIELD_COUNT}}
Unique table/field pairs             = {{FIELD_COUNT}}
Missing declared tables              = 0
Missing declared fields              = 0
Duplicate tables                     = 0
Duplicate table/field pairs          = 0
Wildcard entries                     = 0

PRODUCTION
--------------------------------------------
Actual scoped tables inventoried     = 100%
Actual scoped fields inventoried     = 100%
Unexplained schema deviations        = 0

QUALITY
--------------------------------------------
Schema authority documented          = YES
Exact DDL preserved                  = 100%
Group/table/field totals reconcile   = YES

============================================
{{SIDE}} FIELD INVENTORY             = PASS
============================================
```

> Use this same template to generate both the source field inventory and the target field inventory. The two generated files should differ only in their actual system/version/schema facts and migration-side annotations; their structure and QA gates should remain consistent.
