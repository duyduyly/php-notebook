# Migration Field Generation Plan

## Purpose

> **Goal: inventory and account for 100% of physical database fields belonging to the tables that already passed the migration-group gate.**

This plan is reusable for Joomla core, third-party extensions, custom extensions, or other version-to-version database migrations.

It is designed to generate field-inventory manifests such as:

```text
<scope>-migration-fields-source.md
<scope>-migration-fields-target.md
```

Use the companion template:

- [`../templates/database-migration-field-inventory-template.md`](../templates/database-migration-field-inventory-template.md)

The required prerequisite is:

- [`migration-group-generation-plan.md`](./migration-group-generation-plan.md)

The key guarantee is not "all documented fields are listed". The guarantee is:

> **100% of physical columns that actually belong to the effective in-scope tables are discovered, inventoried exactly once, reconciled with authoritative schema evidence, and carried forward to the field-mapping gate.**

A field may later become `DIRECT`, `TRANSFORM`, `LOOKUP`, `STRUCTURED`, `DEFAULT`, `GENERATED`, `REBUILD`, `REFERENCE_ONLY`, `ARCHIVE`, `IGNORE`, or `TARGET_OWNED`, but it may never disappear silently from inventory.

---

# 1. Require Migration-Group PASS First

Field discovery must not independently guess which tables belong to the migration.

The table set comes from the completed migration-group manifest.

```text
MIGRATION GROUP MANIFEST
        ↓
Effective in-scope tables = Y / Y
Missing tables            = 0
Duplicate tables          = 0
Unclassified tables       = 0
Unknown ownership         = 0
        ↓
FIELD INVENTORY MAY START
```

Required inputs:

| Input | Requirement |
|---|---|
| Scope name | Exact migration scope |
| Side | `SOURCE` or `TARGET` |
| System | Exact product/system/extension |
| Version | Exact version/tag/build |
| Database/schema | Actual database being inventoried |
| Group manifest | Must already be `PASS` |
| Effective table set | Explicit physical table list |
| Schema authority | Official DDL/package/repository/migration source |

### Hard prerequisite gate

```text
Group manifest exists                 = YES
Group manifest PASS                   = YES
Effective in-scope table count        = Y
Unique effective tables               = Y
Missing group tables                  = 0
Duplicate group tables                = 0
Unknown ownership                     = 0
```

If table coverage has not passed, field coverage cannot claim 100%.

---

# 2. Derive the Field Scope From the Grouped Tables

The field scope is derived from the exact physical tables already classified by the migration-group plan.

Do not scan the whole database and assume every discovered field belongs to the migration.

Conceptually:

```text
effective_table_set
=
all physical tables assigned to the declared migration scope

field_scope
=
all physical columns belonging to effective_table_set
```

For every table in the group manifest:

```text
classified table
      ↓
scan all physical columns
      ↓
create one field inventory row per physical column
```

### Hard invariant

```text
Every effective in-scope table
→ all physical columns discovered
→ all physical columns inventoried
```

No wildcard field rule may replace explicit discovery.

Invalid final inventory examples:

```text
all fields
all *_id fields
all params fields
other metadata fields
...
```

---

# 3. Build the Authoritative Field Baseline

For each effective in-scope table, inspect the authoritative schema source.

Possible sources include:

```text
installation SQL
upgrade/update SQL
extension install SQL
official release package
official repository schema files
migration files
ORM/entity migrations
authoritative CREATE TABLE output
```

Build a canonical baseline of explicit `(table, field)` pairs.

Example:

```text
(table_a, id)
(table_a, title)
(table_a, params)
(table_b, id)
(table_b, table_a_id)
```

For every baseline field preserve at minimum:

```text
table name
column name
ordinal position
data type
full column type
nullability
default
column key
extra attributes
auto-increment/generated state
charset/collation where applicable
comment
generation expression where applicable
schema source/evidence
```

When available, preserve the exact authoritative `CREATE TABLE` DDL for the table.

### Baseline checks

```text
Official/evidenced tables represented   = 100%
Official/evidenced fields explicit      = 100%
Duplicate (table, field) pairs           = 0
Wildcard field entries                   = 0
Unexplained baseline fields              = 0
```

---

# 4. Scan the Actual Database Fields

The actual database is the production source of truth for physical field coverage.

For MySQL/MariaDB use `information_schema.COLUMNS` and constrain the query to the effective table set from the migration-group manifest.

Recommended query:

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
JOIN migration_inventory.table_list AS t
  ON t.table_name = c.TABLE_NAME
WHERE c.TABLE_SCHEMA = :database_name
  AND t.migration_run_id = :migration_run_id
  AND t.in_migration_scope = 1
ORDER BY
    c.TABLE_NAME,
    c.ORDINAL_POSITION;
```

If `table_list` uses different physical columns, adapt the join while preserving the same invariant: **only tables that passed the migration-group scope are scanned**.

### Required actual-field set

Create:

```text
actual_field_set
=
DISTINCT (TABLE_NAME, COLUMN_NAME)
for every effective in-scope table
```

The production denominator is:

```text
actual_field_count
=
COUNT(actual_field_set)
```

This value must not be hard-coded from documentation.

Example:

```text
Official baseline fields = 711
Production custom fields = 3
Actual scoped fields      = 714

100% field coverage       = 714 / 714
not                       = 711 / 711
```

---

# 5. Reconcile Baseline Fields vs Actual Fields

Compare:

```text
AUTHORITATIVE FIELD BASELINE
             ↕
ACTUAL DATABASE FIELD SET
```

Every `(table, field)` pair must enter exactly one reconciliation bucket:

```text
MATCHED
ACTUAL_ONLY
BASELINE_ONLY
EXCLUDED_OUT_OF_SCOPE
UNKNOWN
```

Rules:

- `MATCHED` → expected field exists in production.
- `ACTUAL_ONLY` → investigate custom/local/legacy field; if its table is in scope, the field is included unless explicitly proven out-of-scope.
- `BASELINE_ONLY` → document why the actual database does not contain the official/evidenced field.
- `EXCLUDED_OUT_OF_SCOPE` → only valid when the parent table or field is explicitly outside the declared scope with evidence.
- `UNKNOWN` → blocks PASS.

### Effective physical field set

For production inventory:

```text
effective_field_set
=
all actual physical fields
on all effective in-scope tables
```

The actual schema wins for production field-count coverage.

### Reconciliation gate

```text
UNKNOWN field reconciliation rows    = 0
Unexplained actual-only fields        = 0
Unexplained baseline-only fields      = 0
Fields from missing/unclassified table = 0
```

---

# 6. Create Exactly One Inventory Row per Physical Field

Every physical field must have exactly one inventory identity:

```text
(database_side, table_name, column_name)
```

or, when inventory is run-specific:

```text
(migration_run_id, database_side, table_name, column_name)
```

Recommended inventory record:

| Field | Purpose |
|---|---|
| `migration_run_id` | Inventory run identity |
| `database_side` | `SOURCE` / `TARGET` |
| `group_id` | Inherited from migration-group manifest |
| `table_name` | Physical table |
| `column_name` | Physical field |
| `ordinal_position` | Physical order |
| `data_type` | Base SQL type |
| `column_type` | Full SQL type |
| `is_nullable` | Nullability |
| `column_default` | Default |
| `column_key` | Key metadata |
| `extra` | Auto increment/generated/etc. |
| `character_set_name` | Charset where applicable |
| `collation_name` | Collation where applicable |
| `column_comment` | Column comment |
| `generation_expression` | Generated-column expression |
| `schema_source` | Evidence/source |
| `structured_type` | JSON/registry/serialized/URL/path/etc. when known |
| `reference_domain` | Logical reference domain when known |
| `field_role` | Data/reference/runtime/generated/source-only/target-only/etc. |

### Hard invariant

```text
field_inventory_rows
=
COUNT(DISTINCT table_name, column_name)
=
effective_actual_field_count
```

Required result:

```text
Missing physical fields          = 0
Duplicate field inventory rows   = 0
Fields on unknown tables         = 0
Fields without group inheritance = 0
```

---

# 7. Preserve Group → Table → Field Lineage

Every field must be traceable back to exactly one table and exactly one migration group.

```text
GROUP
  ↓
TABLE
  ↓
FIELD
```

Required lineage:

```text
field.group_id
=
parent table.group_id
```

A field must never be assigned to a different group independently from its parent table.

Recommended QA:

```sql
SELECT
    f.table_name,
    f.column_name,
    f.group_id AS field_group,
    t.group_id AS table_group
FROM migration_inventory.field_inventory AS f
JOIN migration_inventory.table_list AS t
  ON t.migration_run_id = f.migration_run_id
 AND t.database_side = f.database_side
 AND t.table_name = f.table_name
WHERE f.migration_run_id = :migration_run_id
  AND f.database_side = :database_side
  AND (
      f.group_id <> t.group_id
      OR f.group_id IS NULL
      OR t.group_id IS NULL
  );
```

Expected result: **0 rows**.

---

# 8. Preserve Exact Physical Metadata

Field inventory must record schema facts exactly rather than normalizing source and target to look compatible.

For every physical field preserve, when available:

```text
name
ordinal position
base data type
full data type
length
precision
scale
unsigned/signed semantics
nullability
default
primary/unique/index participation
auto-increment
extra attributes
charset
collation
comment
generated expression
```

Table-level DDL should also preserve:

```text
primary key
unique indexes
normal indexes
foreign keys
engine
table charset/collation
table comment
```

Rule:

> **Inventory records what physically exists. Mapping decides what to do with it later.**

Do not silently change:

```text
NULL → NOT NULL
text → longtext
varchar length
integer signedness
default values
zero-date behavior
collation
index structure
```

Those differences belong in field mapping/transform rules.

---

# 9. Detect Migration-Relevant Field Roles

After physical discovery, annotate migration-relevant roles without changing schema facts.

Recommended roles:

```text
SCALAR_DATA
PRIMARY_ID
REFERENCE
STRUCTURED
GENERATED
RUNTIME
SECURITY_STATE
SOURCE_ONLY
TARGET_ONLY
DERIVED
UNKNOWN_ROLE
```

`UNKNOWN_ROLE` may exist during analysis but must not conceal the physical field. Before the final migration contract executes, every migration-relevant field must have a resolved handling rule.

## Reference detection

Check more than physical foreign keys.

Potential references include:

```text
physical foreign keys
*_id / *_ids conventions
parent IDs
user IDs
category/product/order IDs
polymorphic item IDs
IDs stored in JSON
IDs stored in registry/config values
IDs embedded in URLs/query strings
IDs embedded in serialized data
application-level lookup keys
```

## Structured detection

Identify fields containing formats such as:

```text
JSON
Joomla Registry/config strings
PHP serialized values
CSV/delimited IDs
URLs/query strings
file paths
HTML with embedded links/IDs
XML
other application-specific encoded data
```

### Annotation gate

```text
Known references annotated          = 100%
Known structured fields annotated   = 100%
Known generated/runtime fields      = 100%
Silent embedded-ID assumptions      = 0
```

This is an annotation gate, not yet the final field-mapping gate.

---

# 10. Handle Source-Only and Target-Only Fields Explicitly

When comparing two versions, compute field-level differences per mapped/related table.

```text
SOURCE_ONLY_FIELDS
=
source effective fields - target compatible fields

TARGET_ONLY_FIELDS
=
target effective fields - source compatible fields
```

Do not require same-name fields to prove compatibility; field mapping performs that decision later.

Every source-only field must remain inventoried and later resolve to a mapping outcome such as:

```text
TRANSFORM
ARCHIVE
IGNORE
REBUILD
REFERENCE_ONLY
```

Every required target-only field must later resolve to a population strategy such as:

```text
SOURCE_TRANSFORM
LOOKUP
DEFAULT
GENERATED
TARGET_OWNED
REBUILD
RECREATE
NOT_REQUIRED
```

### Gate

```text
Source-only fields inventoried      = 100%
Target-only fields inventoried      = 100%
Unexplained schema-difference fields = 0
```

---

# 11. Reconcile Field Counts by Table and Group

Do not rely only on one global field count.

Validate three levels:

```text
DATABASE TOTAL
GROUP TOTALS
TABLE TOTALS
```

For each table:

```text
actual table field count
=
inventory table field count
```

For each group:

```text
SUM(actual fields for group tables)
=
SUM(inventory fields for group tables)
```

Global:

```text
SUM(all group field counts)
=
SUM(all table field counts)
=
actual effective field count
=
unique inventory field count
```

### Recommended coverage matrix

| Group | Tables | Actual Fields | Inventory Fields | Missing | Duplicate | Status |
|---|---:|---:|---:|---:|---:|---|
| `G0` | `X` | `X` | `X` | `0` | `0` | `PASS` |
| `G1` | `X` | `X` | `X` | `0` | `0` | `PASS` |
| `...` | `...` | `...` | `...` | `...` | `...` | `...` |
| **Total** | **Y** | **Z** | **Z** | **0** | **0** | **PASS** |

This catches errors that a global count alone can miss.

---

# 12. Detect Missing Physical Fields

Recommended QA query:

```sql
SELECT
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.ORDINAL_POSITION
FROM information_schema.COLUMNS AS c
JOIN migration_inventory.table_list AS t
  ON t.table_name = c.TABLE_NAME
 AND t.migration_run_id = :migration_run_id
 AND t.database_side = :database_side
LEFT JOIN migration_inventory.field_inventory AS f
  ON f.table_name = c.TABLE_NAME
 AND f.column_name = c.COLUMN_NAME
 AND f.migration_run_id = :migration_run_id
 AND f.database_side = :database_side
WHERE c.TABLE_SCHEMA = :database_name
  AND t.in_migration_scope = 1
  AND f.column_name IS NULL
ORDER BY
    c.TABLE_NAME,
    c.ORDINAL_POSITION;
```

Expected result:

```text
0 rows
```

Any returned row means field coverage is below 100%.

---

# 13. Detect Extra / Phantom Inventory Fields

Inventory must also prove it does not contain fields that do not physically exist in the selected actual database unless explicitly tagged as baseline-only evidence.

Recommended QA:

```sql
SELECT
    f.table_name,
    f.column_name
FROM migration_inventory.field_inventory AS f
JOIN migration_inventory.table_list AS t
  ON t.table_name = f.table_name
 AND t.migration_run_id = f.migration_run_id
 AND t.database_side = f.database_side
LEFT JOIN information_schema.COLUMNS AS c
  ON c.TABLE_SCHEMA = :database_name
 AND c.TABLE_NAME = f.table_name
 AND c.COLUMN_NAME = f.column_name
WHERE f.migration_run_id = :migration_run_id
  AND f.database_side = :database_side
  AND t.in_migration_scope = 1
  AND c.COLUMN_NAME IS NULL;
```

Expected result for the actual-production inventory set:

```text
0 rows
```

If baseline-only schema evidence is stored in the same table, it must be explicitly distinguished from actual-production inventory so the two populations cannot be confused.

---

# 14. Detect Duplicate Inventory Fields

Recommended QA:

```sql
SELECT
    table_name,
    column_name,
    COUNT(*) AS duplicate_count
FROM migration_inventory.field_inventory
WHERE migration_run_id = :migration_run_id
  AND database_side = :database_side
GROUP BY
    table_name,
    column_name
HAVING COUNT(*) > 1;
```

Expected result:

```text
0 rows
```

Recommended database uniqueness rule:

```text
UNIQUE (
    migration_run_id,
    database_side,
    table_name,
    column_name
)
```

---

# 15. Build the Field Coverage Manifest

Every generated field manifest must contain explicit coverage evidence.

Template:

```text
GROUP INPUT
--------------------------------------------
Effective in-scope tables             = Y
Grouped tables represented            = Y / Y
Tables missing field inventory        = 0

BASELINE
--------------------------------------------
Authoritative baseline fields         = B
Duplicate baseline pairs              = 0
Wildcard field entries                = 0

ACTUAL DATABASE
--------------------------------------------
Actual effective physical fields      = Z
Actual-only fields explained          = 100%
Baseline-only fields explained        = 100%
Unknown reconciliation fields         = 0

INVENTORY
--------------------------------------------
Field inventory rows                  = Z
Unique (table, field) pairs           = Z
Fields with group lineage             = Z / Z

Missing physical fields               = 0
Duplicate inventory fields            = 0
Phantom inventory fields              = 0
Fields on unclassified tables         = 0
Fields without group                  = 0

RECONCILIATION
--------------------------------------------
Table field totals reconcile          = 100%
Group field totals reconcile          = 100%
Global field total reconciles         = YES

============================================
PHYSICAL FIELD COVERAGE               = 100%
FIELD INVENTORY                       = PASS
============================================
```

Do not claim 100% using only the authoritative package count when the actual database contains additional fields on in-scope tables.

---

# 16. Require the Field-Mapping Gate Next

The field inventory proves physical field coverage. It does not by itself prove the fields can already be migrated.

Required lifecycle:

```text
TABLE GROUP PASS
      ↓
FIELD INVENTORY PASS
      ↓
TABLE MAPPING PASS
      ↓
FIELD MAPPING PASS
      ↓
VALUE / ID MAPPING
      ↓
EXECUTION
      ↓
VERIFICATION
```

Every source field discovered by this plan must later receive exactly one final field-mapping decision.

Typical final decisions:

```text
DIRECT
TRANSFORM
LOOKUP
STRUCTURED
DEFAULT
GENERATED
REBUILD
REFERENCE_ONLY
ARCHIVE
IGNORE
TARGET_OWNED
```

Final field mapping must enforce:

```text
Source physical fields with decision = 100%
Required target fields resolved       = 100%
Unmapped source fields                = 0
Unresolved required target fields     = 0
Ambiguous field decisions             = 0
```

---

# 100% Field Coverage Checklist

## Prerequisite — Migration Group

- [ ] Migration-group manifest exists.
- [ ] Migration-group manifest is `PASS`.
- [ ] Effective in-scope tables are explicit.
- [ ] Missing group tables = 0.
- [ ] Duplicate group tables = 0.
- [ ] Unclassified tables = 0.
- [ ] Unknown ownership = 0.

## Scope

- [ ] Scope name is explicit.
- [ ] Side is explicit: `SOURCE` or `TARGET`.
- [ ] Exact system/version is recorded.
- [ ] Actual database/schema is recorded.
- [ ] Schema authority is identified.
- [ ] Production database is identified.

## Baseline Discovery

- [ ] All authoritative schema sources were inspected.
- [ ] Every baseline physical field is explicit as `(table, field)`.
- [ ] Every baseline field belongs to an effective in-scope table or has an explicit out-of-scope reason.
- [ ] Duplicate baseline `(table, field)` pairs = 0.
- [ ] Wildcard field entries = 0.
- [ ] Every baseline field has source/evidence.

## Actual Database Discovery

- [ ] Every effective in-scope table was scanned through database metadata.
- [ ] Every physical field on every effective table was discovered.
- [ ] Actual physical field count was computed dynamically.
- [ ] Actual field denominator is not hard-coded from documentation.
- [ ] Fields on tables outside scope are not mixed into the denominator.

## Baseline ↔ Actual Reconciliation

- [ ] Every field belongs to `MATCHED`, `ACTUAL_ONLY`, `BASELINE_ONLY`, or explicitly `EXCLUDED_OUT_OF_SCOPE`.
- [ ] Unknown reconciliation fields = 0.
- [ ] Actual-only fields are explained.
- [ ] Actual-only fields on in-scope tables are included in production inventory.
- [ ] Baseline-only fields have documented reasons.
- [ ] Unexplained schema differences = 0.

## Field Inventory

- [ ] Every actual in-scope physical field has exactly one inventory row.
- [ ] Unique `(table, field)` identity is enforced.
- [ ] Missing physical fields = 0.
- [ ] Duplicate inventory fields = 0.
- [ ] Phantom production inventory fields = 0.
- [ ] Fields on unknown/unclassified tables = 0.
- [ ] Fields without group lineage = 0.

## Group → Table → Field Lineage

- [ ] Every field inherits the parent table group.
- [ ] Field group differs from parent table group = 0.
- [ ] Every group table has its physical fields represented.
- [ ] Table field totals reconcile.
- [ ] Group field totals reconcile.
- [ ] Global field total reconciles.

## Physical Metadata

- [ ] Column names preserved exactly.
- [ ] Ordinal positions preserved.
- [ ] Data types preserved.
- [ ] Full column types preserved.
- [ ] Nullability preserved.
- [ ] Defaults preserved.
- [ ] Key metadata preserved.
- [ ] Auto-increment/generated/extra attributes preserved.
- [ ] Charset/collation preserved where applicable.
- [ ] Comments preserved where applicable.
- [ ] Generation expressions preserved where applicable.
- [ ] Exact authoritative table DDL preserved when available.

## Migration-Relevant Annotation

- [ ] Known reference fields identified.
- [ ] Known structured fields identified.
- [ ] Known generated fields identified.
- [ ] Known runtime/security fields identified.
- [ ] Source-only fields identified.
- [ ] Target-only fields identified.
- [ ] Embedded-ID risks are not silently ignored.
- [ ] Schema facts remain separate from migration decisions.

## Source / Target Difference Coverage

- [ ] Source-only fields inventoried = 100%.
- [ ] Target-only fields inventoried = 100%.
- [ ] No field is removed from inventory because it lacks a same-name counterpart.
- [ ] Required target-field population strategy is delegated to field mapping.

## Next Gate

- [ ] Field inventory `PASS` is required before field mapping.
- [ ] Every source field must later receive one final mapping decision.
- [ ] Every required target field must later receive one population strategy.
- [ ] Production reconciliation must be rerun before execution.

---

# Final Field Inventory Gate

A field-inventory manifest may be marked `PASS` only when all checks below succeed.

```text
GROUP PREREQUISITE
--------------------------------------------
Migration-group manifest             = PASS
Effective in-scope tables            = Y
Grouped tables represented           = Y / Y

DISCOVERY
--------------------------------------------
Actual effective physical fields     = Z
Fields discovered                    = Z / Z
Unique actual (table, field)         = Z / Z

RECONCILIATION
--------------------------------------------
Unknown reconciliation fields        = 0
Unexplained actual-only fields       = 0
Unexplained baseline-only fields     = 0

INVENTORY
--------------------------------------------
Field inventory rows                 = Z
Unique inventory (table, field)      = Z
Fields with valid group lineage      = Z / Z

Missing physical fields              = 0
Duplicate inventory fields           = 0
Phantom production fields            = 0
Fields on unclassified tables        = 0
Fields without group                 = 0

COUNT INVARIANTS
--------------------------------------------
Per-table field counts reconcile     = 100%
Per-group field counts reconcile     = 100%
Global physical field count          = inventory unique field count

METADATA
--------------------------------------------
Required physical metadata captured  = 100%
Schema authority/evidence recorded   = 100%

NEXT GATE
--------------------------------------------
Field mapping                        = REQUIRED
Source field decisions               = 100% REQUIRED
Required target resolutions          = 100% REQUIRED

============================================
PHYSICAL FIELD COVERAGE               = 100%
FIELD INVENTORY                       = PASS
============================================
```

---

## Output Requirements

For every source or target version, generate one field-inventory file using this plan and:

- [`../templates/database-migration-field-inventory-template.md`](../templates/database-migration-field-inventory-template.md)

Minimum output structure:

```text
1. Scope and prerequisite group manifest
2. Authoritative schema sources
3. Explicit group → table → field sections
4. Ordered field lists
5. Exact physical metadata / authoritative DDL
6. Migration-relevant annotations
7. Baseline ↔ actual reconciliation
8. Per-table field coverage
9. Per-group field coverage
10. Global field coverage
11. 100% checklist
12. Final PASS/FAIL gate
```

A generated field manifest must never claim `100%` merely because every field from a documentation file was copied into Markdown. It must prove:

```text
all actual physical columns
on all effective in-scope grouped tables
=
all unique production field inventory rows
```

with:

```text
missing   = 0
duplicate = 0
unknown   = 0
phantom   = 0
```

Only then may **physical field coverage = 100%** be declared.
