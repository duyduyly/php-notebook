# Joomla Core Migration Field Inventory — Joomla 6

## Inventory Rule

> **Inventory = YES**  
> **Mapping decision = NO — inventory first**

This document defines the field-level inventory and verification process for Joomla 6 core database migration.

The goal is not merely to count columns. The goal is to prove that every field in every Joomla 6 core table is discovered exactly once, with enough schema metadata to detect structural differences before mapping or migration begins.

The table grouping source is:

- [`joomla-core-migration-groups-v6.md`](./joomla-core-migration-groups-v6.md)

The baseline is the **official Joomla 6.1.2 MySQL fresh-install schema**:

- `installation/sql/mysql/base.sql`
- `installation/sql/mysql/extensions.sql`
- `installation/sql/mysql/supports.sql`

**Verified core table baseline: `76 physical tables`.**

> The official schema is the baseline. The actual Joomla 6 target database is still the runtime authority for the migration. Any target-only, missing, customized, extension-owned, or unknown table/field must be reported explicitly.

---

## Table of Contents

- [Inventory Rule](#inventory-rule)
- [Coverage Contract](#coverage-contract)
- [Field Metadata Contract](#field-metadata-contract)
- [Core Table Manifest](#core-table-manifest)
- [Step 1 — Configure the Target](#step-1--configure-the-target)
- [Step 2 — Build the 76-Table Core Manifest](#step-2--build-the-76-table-core-manifest)
- [Step 3 — Verify Table Coverage](#step-3--verify-table-coverage)
- [Step 4 — Build the Field Inventory](#step-4--build-the-field-inventory)
- [Step 5 — Inventory Check Constraints](#step-5--inventory-check-constraints)
- [Step 6 — Verify Field Coverage](#step-6--verify-field-coverage)
- [Step 7 — Detect Non-Core Tables](#step-7--detect-non-core-tables)
- [Step 8 — Compare Official Baseline vs Actual Target](#step-8--compare-official-baseline-vs-actual-target)
- [Step 9 — Export the Inventory](#step-9--export-the-inventory)
- [Field Matching Rules](#field-matching-rules)
- [Completion Criteria](#completion-criteria)
- [Execution Checklist](#execution-checklist)

---

## Coverage Contract

A field inventory is complete only when all of the following gates pass.

```text
Joomla baseline version                = 6.1.2
Official core tables expected          = 76
Core tables inventoried                = 76

Actual core fields discovered          = N
Inventory field rows                   = N

Missing core tables                    = 0
Duplicate core table classifications   = 0
Missing core fields                    = 0
Duplicate inventory fields             = 0
Unclassified core fields               = 0
Unexplained target-only fields         = 0
Unexplained baseline-only fields       = 0
Unresolved metadata differences        = 0

Table coverage                         = 100%
Field coverage                         = 100%
Field metadata coverage                = 100%
```

### Important

Do **not** prove core-field coverage with this query alone:

```sql
SELECT COUNT(*)
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = '<JOOMLA6_DATABASE>';
```

That count can include:

- third-party extension tables;
- custom application tables;
- legacy tables;
- temporary/import tables;
- tables created after the Joomla baseline.

Core coverage must be calculated by joining `information_schema` to the explicit **76-table Joomla core manifest**.

---

## Field Metadata Contract

Each field inventory row must preserve the following information.

| Metadata | Required | Purpose |
|---|:---:|---|
| Migration group | ✅ | Connect field to G0–G8 |
| Logical table name | ✅ | Joomla `#__table` identity |
| Physical table name | ✅ | Actual prefixed target table |
| Column name | ✅ | Field identity |
| Ordinal position | ✅ | Detect order differences |
| Data type | ✅ | Base MySQL type |
| Full column type | ✅ | Preserve length, unsigned, enum details |
| Nullable | ✅ | Preserve nullability |
| Default value | ✅ | Preserve target default |
| Character maximum length | ✅ | Character capacity |
| Character octet length | ✅ | Byte capacity |
| Numeric precision | ✅ | Numeric metadata |
| Numeric scale | ✅ | Decimal metadata |
| Datetime precision | ✅ | Temporal metadata |
| Character set | ✅ | Encoding metadata |
| Collation | ✅ | Comparison/sort metadata |
| Column key | ✅ | MySQL PRI/UNI/MUL hint |
| Auto increment / extra | ✅ | Generated/runtime behavior |
| Generated expression | ✅ | Generated-column definition |
| Column comment | ✅ | Schema documentation |
| Primary key membership | ✅ | Key semantics |
| Unique-index membership | ✅ | Uniqueness semantics |
| Indexed | ✅ | Lookup/performance semantics |
| Index names and positions | ✅ | Composite index structure |
| Index type | ✅ | BTREE/FULLTEXT/etc. |
| Physical foreign key | ✅ | Declared referential constraint |
| Referenced table/column | ✅ | Physical dependency |
| ON UPDATE | ✅ | FK behavior |
| ON DELETE | ✅ | FK behavior |
| Table engine | ✅ | Table context |
| Table collation | ✅ | Table context |
| Field fingerprint | ✅ | Fast metadata comparison |

### Physical vs logical relations

A Joomla field can reference another entity without a physical MySQL foreign key.

Therefore keep these concepts separate:

```text
Physical FK
    = declared by MySQL constraint metadata

Logical Joomla relation
    = relationship inferred from Joomla behavior/schema/application logic
```

This document inventories **physical schema facts**. Logical migration relationships belong to the mapping phase.

---

## Core Table Manifest

| Group | Description | Table Count |
|---|---|---:|
| G0 | System Reference | 6 |
| G1 | Users and Access Foundation | 6 |
| G2 | Taxonomy and Shared Definitions | 10 |
| G3 | Main Content | 3 |
| G4 | Content Relations | 8 |
| G5 | Menu and Presentation | 4 |
| G6 | Modules | 2 |
| G7 | Supporting Core Components | 16 |
| G8 | Runtime, Generated, and Target-Owned Data | 21 |
| **Total** |  | **76** |

The manifest must contain explicit table names. Wildcards are not allowed.

---

## Step 1 — Configure the Target

Set the actual Joomla 6 database and table prefix.

```sql
SET @j6_database = DATABASE();
SET @j6_prefix   = 'YOUR_JOOMLA_TABLE_PREFIX_';

SELECT
    @j6_database AS joomla_database,
    @j6_prefix   AS joomla_table_prefix;
```

Example:

```sql
SET @j6_database = 'joomla6';
SET @j6_prefix   = 'abc_';
```

Do not assume the physical prefix is `#__`. `#__` is only Joomla's logical placeholder.

---

## Step 2 — Build the 76-Table Core Manifest

Create a temporary manifest for the current audit session.

```sql
DROP TEMPORARY TABLE IF EXISTS tmp_j6_core_table_manifest;

CREATE TEMPORARY TABLE tmp_j6_core_table_manifest (
    group_code      varchar(2)   NOT NULL,
    group_name      varchar(100) NOT NULL,
    logical_table   varchar(100) NOT NULL,
    table_suffix    varchar(100) NOT NULL,
    PRIMARY KEY (table_suffix),
    UNIQUE KEY uq_logical_table (logical_table)
);

INSERT INTO tmp_j6_core_table_manifest
    (group_code, group_name, logical_table, table_suffix)
VALUES
('G0', 'System Reference', '#__extensions', 'extensions'),
('G0', 'System Reference', '#__schemas', 'schemas'),
('G0', 'System Reference', '#__update_sites', 'update_sites'),
('G0', 'System Reference', '#__update_sites_extensions', 'update_sites_extensions'),
('G0', 'System Reference', '#__updates', 'updates'),
('G0', 'System Reference', '#__tuf_metadata', 'tuf_metadata'),
('G1', 'Users and Access Foundation', '#__languages', 'languages'),
('G1', 'Users and Access Foundation', '#__usergroups', 'usergroups'),
('G1', 'Users and Access Foundation', '#__users', 'users'),
('G1', 'Users and Access Foundation', '#__user_usergroup_map', 'user_usergroup_map'),
('G1', 'Users and Access Foundation', '#__viewlevels', 'viewlevels'),
('G1', 'Users and Access Foundation', '#__user_profiles', 'user_profiles'),
('G2', 'Taxonomy and Shared Definitions', '#__assets', 'assets'),
('G2', 'Taxonomy and Shared Definitions', '#__categories', 'categories'),
('G2', 'Taxonomy and Shared Definitions', '#__tags', 'tags'),
('G2', 'Taxonomy and Shared Definitions', '#__content_types', 'content_types'),
('G2', 'Taxonomy and Shared Definitions', '#__fields_groups', 'fields_groups'),
('G2', 'Taxonomy and Shared Definitions', '#__fields', 'fields'),
('G2', 'Taxonomy and Shared Definitions', '#__fields_categories', 'fields_categories'),
('G2', 'Taxonomy and Shared Definitions', '#__workflows', 'workflows'),
('G2', 'Taxonomy and Shared Definitions', '#__workflow_stages', 'workflow_stages'),
('G2', 'Taxonomy and Shared Definitions', '#__workflow_transitions', 'workflow_transitions'),
('G3', 'Main Content', '#__content', 'content'),
('G3', 'Main Content', '#__content_frontpage', 'content_frontpage'),
('G3', 'Main Content', '#__content_rating', 'content_rating'),
('G4', 'Content Relations', '#__contentitem_tag_map', 'contentitem_tag_map'),
('G4', 'Content Relations', '#__fields_values', 'fields_values'),
('G4', 'Content Relations', '#__associations', 'associations'),
('G4', 'Content Relations', '#__ucm_base', 'ucm_base'),
('G4', 'Content Relations', '#__ucm_content', 'ucm_content'),
('G4', 'Content Relations', '#__history', 'history'),
('G4', 'Content Relations', '#__workflow_associations', 'workflow_associations'),
('G4', 'Content Relations', '#__schemaorg', 'schemaorg'),
('G5', 'Menu and Presentation', '#__template_styles', 'template_styles'),
('G5', 'Menu and Presentation', '#__template_overrides', 'template_overrides'),
('G5', 'Menu and Presentation', '#__menu_types', 'menu_types'),
('G5', 'Menu and Presentation', '#__menu', 'menu'),
('G6', 'Modules', '#__modules', 'modules'),
('G6', 'Modules', '#__modules_menu', 'modules_menu'),
('G7', 'Supporting Core Components', '#__contact_details', 'contact_details'),
('G7', 'Supporting Core Components', '#__newsfeeds', 'newsfeeds'),
('G7', 'Supporting Core Components', '#__banners', 'banners'),
('G7', 'Supporting Core Components', '#__banner_clients', 'banner_clients'),
('G7', 'Supporting Core Components', '#__banner_tracks', 'banner_tracks'),
('G7', 'Supporting Core Components', '#__redirect_links', 'redirect_links'),
('G7', 'Supporting Core Components', '#__messages', 'messages'),
('G7', 'Supporting Core Components', '#__messages_cfg', 'messages_cfg'),
('G7', 'Supporting Core Components', '#__user_notes', 'user_notes'),
('G7', 'Supporting Core Components', '#__privacy_requests', 'privacy_requests'),
('G7', 'Supporting Core Components', '#__privacy_consents', 'privacy_consents'),
('G7', 'Supporting Core Components', '#__mail_templates', 'mail_templates'),
('G7', 'Supporting Core Components', '#__scheduler_tasks', 'scheduler_tasks'),
('G7', 'Supporting Core Components', '#__action_logs_extensions', 'action_logs_extensions'),
('G7', 'Supporting Core Components', '#__action_log_config', 'action_log_config'),
('G7', 'Supporting Core Components', '#__action_logs_users', 'action_logs_users'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__session', 'session'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__user_keys', 'user_keys'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__user_mfa', 'user_mfa'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__webauthn_credentials', 'webauthn_credentials'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__scheduler_logs', 'scheduler_logs'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__action_logs', 'action_logs'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_filters', 'finder_filters'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_links', 'finder_links'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_links_terms', 'finder_links_terms'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_logging', 'finder_logging'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_taxonomy', 'finder_taxonomy'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_taxonomy_map', 'finder_taxonomy_map'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_terms', 'finder_terms'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_terms_common', 'finder_terms_common'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_tokens', 'finder_tokens'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_tokens_aggregate', 'finder_tokens_aggregate'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__finder_types', 'finder_types'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__postinstall_messages', 'postinstall_messages'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__overrider', 'overrider'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__guidedtours', 'guidedtours'),
('G8', 'Runtime, Generated, and Target-Owned Data', '#__guidedtour_steps', 'guidedtour_steps');
```

### Manifest self-check

```sql
SELECT
    COUNT(*) AS manifest_tables,
    COUNT(DISTINCT table_suffix) AS distinct_table_suffixes,
    COUNT(DISTINCT logical_table) AS distinct_logical_tables
FROM tmp_j6_core_table_manifest;
```

Required result:

```text
manifest_tables         = 76
distinct_table_suffixes = 76
distinct_logical_tables = 76
```

Check the group totals:

```sql
SELECT
    group_code,
    group_name,
    COUNT(*) AS table_count
FROM tmp_j6_core_table_manifest
GROUP BY group_code, group_name
ORDER BY group_code;
```

Required totals:

```text
G0 = 6
G1 = 6
G2 = 10
G3 = 3
G4 = 8
G5 = 4
G6 = 2
G7 = 16
G8 = 21
```

---

## Step 3 — Verify Table Coverage

### 3.1 Count actual core tables

```sql
SELECT
    COUNT(*) AS actual_core_tables
FROM tmp_j6_core_table_manifest m
JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = @j6_database
 AND t.TABLE_NAME   = CONCAT(@j6_prefix, m.table_suffix)
 AND t.TABLE_TYPE   = 'BASE TABLE';
```

Required result for an unmodified Joomla 6.1.2 core target:

```text
actual_core_tables = 76
```

### 3.2 Find missing core tables

```sql
SELECT
    m.group_code,
    m.logical_table,
    CONCAT(@j6_prefix, m.table_suffix) AS expected_physical_table
FROM tmp_j6_core_table_manifest m
LEFT JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = @j6_database
 AND t.TABLE_NAME   = CONCAT(@j6_prefix, m.table_suffix)
 AND t.TABLE_TYPE   = 'BASE TABLE'
WHERE t.TABLE_NAME IS NULL
ORDER BY m.group_code, m.logical_table;
```

Required result:

```text
0 rows
```

If rows are returned, stop and resolve the missing tables before claiming 100% field coverage.

---

## Step 4 — Build the Field Inventory

The following query creates **one row per core field** and enriches the field with index, key, and physical foreign-key metadata.

```sql
DROP TEMPORARY TABLE IF EXISTS tmp_j6_core_field_inventory;

CREATE TEMPORARY TABLE tmp_j6_core_field_inventory AS
SELECT
    m.group_code,
    m.group_name,
    m.logical_table,
    c.TABLE_NAME AS physical_table,
    c.COLUMN_NAME AS column_name,
    c.ORDINAL_POSITION AS ordinal_position,

    c.DATA_TYPE AS data_type,
    c.COLUMN_TYPE AS column_type,
    c.IS_NULLABLE AS is_nullable,
    c.COLUMN_DEFAULT AS column_default,

    c.CHARACTER_MAXIMUM_LENGTH AS character_maximum_length,
    c.CHARACTER_OCTET_LENGTH AS character_octet_length,
    c.NUMERIC_PRECISION AS numeric_precision,
    c.NUMERIC_SCALE AS numeric_scale,
    c.DATETIME_PRECISION AS datetime_precision,

    c.CHARACTER_SET_NAME AS character_set_name,
    c.COLLATION_NAME AS collation_name,

    c.COLUMN_KEY AS column_key,
    c.EXTRA AS extra,
    c.GENERATION_EXPRESSION AS generation_expression,
    c.COLUMN_COMMENT AS column_comment,

    COALESCE(i.is_primary_key, 0) AS is_primary_key,
    COALESCE(i.is_unique_indexed, 0) AS is_unique_indexed,
    COALESCE(i.is_indexed, 0) AS is_indexed,
    i.index_metadata,

    COALESCE(fk.has_physical_fk, 0) AS has_physical_fk,
    fk.fk_metadata,

    t.ENGINE AS table_engine,
    t.ROW_FORMAT AS table_row_format,
    t.TABLE_COLLATION AS table_collation,

    SHA2(
        CONCAT_WS(
            '|',
            c.COLUMN_NAME,
            c.ORDINAL_POSITION,
            c.DATA_TYPE,
            c.COLUMN_TYPE,
            c.IS_NULLABLE,
            IF(
                c.COLUMN_DEFAULT IS NULL,
                '<SQL_NULL_OR_NO_DEFAULT>',
                CONCAT('<VALUE>', c.COLUMN_DEFAULT)
            ),
            COALESCE(c.CHARACTER_MAXIMUM_LENGTH, '<NULL>'),
            COALESCE(c.CHARACTER_OCTET_LENGTH, '<NULL>'),
            COALESCE(c.NUMERIC_PRECISION, '<NULL>'),
            COALESCE(c.NUMERIC_SCALE, '<NULL>'),
            COALESCE(c.DATETIME_PRECISION, '<NULL>'),
            COALESCE(c.CHARACTER_SET_NAME, '<NULL>'),
            COALESCE(c.COLLATION_NAME, '<NULL>'),
            c.COLUMN_KEY,
            c.EXTRA,
            COALESCE(c.GENERATION_EXPRESSION, ''),
            COALESCE(c.COLUMN_COMMENT, '')
        ),
        256
    ) AS field_fingerprint

FROM information_schema.COLUMNS c

JOIN tmp_j6_core_table_manifest m
  ON c.TABLE_NAME = CONCAT(@j6_prefix, m.table_suffix)

JOIN information_schema.TABLES t
  ON t.TABLE_SCHEMA = c.TABLE_SCHEMA
 AND t.TABLE_NAME   = c.TABLE_NAME

LEFT JOIN (
    SELECT
        TABLE_SCHEMA,
        TABLE_NAME,
        COLUMN_NAME,
        MAX(INDEX_NAME = 'PRIMARY') AS is_primary_key,
        MAX(NON_UNIQUE = 0 AND INDEX_NAME <> 'PRIMARY') AS is_unique_indexed,
        1 AS is_indexed,
        GROUP_CONCAT(
            CONCAT(
                INDEX_NAME,
                '[seq=', SEQ_IN_INDEX,
                ', unique=', IF(NON_UNIQUE = 0, 'YES', 'NO'),
                ', type=', INDEX_TYPE,
                ', prefix=', COALESCE(CAST(SUB_PART AS char), 'FULL'),
                ']'
            )
            ORDER BY INDEX_NAME, SEQ_IN_INDEX
            SEPARATOR ' | '
        ) AS index_metadata
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = @j6_database
    GROUP BY TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
) i
  ON i.TABLE_SCHEMA = c.TABLE_SCHEMA
 AND i.TABLE_NAME   = c.TABLE_NAME
 AND i.COLUMN_NAME  = c.COLUMN_NAME

LEFT JOIN (
    SELECT
        k.TABLE_SCHEMA,
        k.TABLE_NAME,
        k.COLUMN_NAME,
        1 AS has_physical_fk,
        GROUP_CONCAT(
            CONCAT(
                'constraint=', k.CONSTRAINT_NAME,
                ', ref=', k.REFERENCED_TABLE_NAME, '.', k.REFERENCED_COLUMN_NAME,
                ', on_update=', COALESCE(r.UPDATE_RULE, 'N/A'),
                ', on_delete=', COALESCE(r.DELETE_RULE, 'N/A')
            )
            ORDER BY k.CONSTRAINT_NAME, k.ORDINAL_POSITION
            SEPARATOR ' | '
        ) AS fk_metadata
    FROM information_schema.KEY_COLUMN_USAGE k
    LEFT JOIN information_schema.REFERENTIAL_CONSTRAINTS r
      ON r.CONSTRAINT_SCHEMA = k.CONSTRAINT_SCHEMA
     AND r.CONSTRAINT_NAME   = k.CONSTRAINT_NAME
     AND r.TABLE_NAME        = k.TABLE_NAME
    WHERE k.TABLE_SCHEMA = @j6_database
      AND k.REFERENCED_TABLE_NAME IS NOT NULL
    GROUP BY k.TABLE_SCHEMA, k.TABLE_NAME, k.COLUMN_NAME
) fk
  ON fk.TABLE_SCHEMA = c.TABLE_SCHEMA
 AND fk.TABLE_NAME   = c.TABLE_NAME
 AND fk.COLUMN_NAME  = c.COLUMN_NAME

WHERE c.TABLE_SCHEMA = @j6_database
ORDER BY
    m.group_code,
    m.logical_table,
    c.ORDINAL_POSITION;
```

### Why both `DATA_TYPE` and `COLUMN_TYPE` are required

For example:

```text
DATA_TYPE   = int
COLUMN_TYPE = int unsigned
```

Reducing `int unsigned` to `int` loses migration-relevant information.

### Default values

Keep `COLUMN_DEFAULT` unchanged. Do not normalize these into one value:

```text
NULL
'NULL'
''
0
'0'
CURRENT_TIMESTAMP
```

For exact DDL semantics where MySQL metadata alone is ambiguous, preserve `SHOW CREATE TABLE` output as the final schema evidence.

---

## Step 5 — Inventory Check Constraints

Check constraints are table constraints and may contain expressions involving one or more fields.

```sql
SELECT
    m.group_code,
    m.logical_table,
    tc.TABLE_NAME AS physical_table,
    tc.CONSTRAINT_NAME,
    cc.CHECK_CLAUSE
FROM information_schema.TABLE_CONSTRAINTS tc
JOIN tmp_j6_core_table_manifest m
  ON tc.TABLE_NAME = CONCAT(@j6_prefix, m.table_suffix)
JOIN information_schema.CHECK_CONSTRAINTS cc
  ON cc.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
 AND cc.CONSTRAINT_NAME   = tc.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_SCHEMA = @j6_database
  AND tc.CONSTRAINT_TYPE = 'CHECK'
ORDER BY
    m.group_code,
    m.logical_table,
    tc.CONSTRAINT_NAME;
```

If no rows exist, record:

```text
Physical CHECK constraints = NONE
```

Do not confuse the absence of a physical constraint with the absence of an application-level validation rule.

---

## Step 6 — Verify Field Coverage

### 6.1 Total discovered fields

```sql
SELECT COUNT(*) AS inventory_field_rows
FROM tmp_j6_core_field_inventory;
```

This value is `N` for the actual target and must be used as the target field count.

### 6.2 Count fields per table

```sql
SELECT
    m.group_code,
    m.logical_table,
    COUNT(i.column_name) AS inventoried_fields
FROM tmp_j6_core_table_manifest m
LEFT JOIN tmp_j6_core_field_inventory i
  ON i.logical_table = m.logical_table
GROUP BY
    m.group_code,
    m.logical_table
ORDER BY
    m.group_code,
    m.logical_table;
```

Every one of the 76 tables must appear.

### 6.3 Compare direct discovery vs inventory by table

```sql
SELECT
    m.group_code,
    m.logical_table,
    CONCAT(@j6_prefix, m.table_suffix) AS physical_table,

    COUNT(DISTINCT c.COLUMN_NAME) AS actual_fields,
    COUNT(DISTINCT i.column_name) AS inventory_fields,

    CASE
        WHEN COUNT(DISTINCT c.COLUMN_NAME) = COUNT(DISTINCT i.column_name)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS coverage_status

FROM tmp_j6_core_table_manifest m

LEFT JOIN information_schema.COLUMNS c
  ON c.TABLE_SCHEMA = @j6_database
 AND c.TABLE_NAME   = CONCAT(@j6_prefix, m.table_suffix)

LEFT JOIN tmp_j6_core_field_inventory i
  ON i.logical_table = m.logical_table

GROUP BY
    m.group_code,
    m.logical_table,
    m.table_suffix

ORDER BY
    m.group_code,
    m.logical_table;
```

Required result:

```text
76 / 76 tables = PASS
```

This table-by-table check prevents a false pass where one table is missing two fields while another accidentally contributes two duplicates.

### 6.4 Detect duplicate inventory fields

```sql
SELECT
    logical_table,
    column_name,
    COUNT(*) AS duplicate_count
FROM tmp_j6_core_field_inventory
GROUP BY logical_table, column_name
HAVING COUNT(*) > 1;
```

Required result:

```text
0 rows
```

### 6.5 Actual → inventory difference

```sql
SELECT
    m.group_code,
    m.logical_table,
    c.COLUMN_NAME
FROM information_schema.COLUMNS c
JOIN tmp_j6_core_table_manifest m
  ON c.TABLE_NAME = CONCAT(@j6_prefix, m.table_suffix)
LEFT JOIN tmp_j6_core_field_inventory i
  ON i.logical_table = m.logical_table
 AND i.column_name   = c.COLUMN_NAME
WHERE c.TABLE_SCHEMA = @j6_database
  AND i.column_name IS NULL
ORDER BY m.group_code, m.logical_table, c.ORDINAL_POSITION;
```

Required result:

```text
0 rows
```

### 6.6 Inventory → actual difference

```sql
SELECT
    i.group_code,
    i.logical_table,
    i.column_name
FROM tmp_j6_core_field_inventory i
LEFT JOIN information_schema.COLUMNS c
  ON c.TABLE_SCHEMA = @j6_database
 AND c.TABLE_NAME   = i.physical_table
 AND c.COLUMN_NAME  = i.column_name
WHERE c.COLUMN_NAME IS NULL
ORDER BY i.group_code, i.logical_table, i.ordinal_position;
```

Required result:

```text
0 rows
```

The bidirectional rule is:

```text
Actual − Inventory = 0
Inventory − Actual = 0
```

---

## Step 7 — Detect Non-Core Tables

All target tables that are not part of the explicit 76-table Joomla core manifest must be reported separately.

```sql
SELECT
    t.TABLE_NAME AS physical_table,
    'NON_CORE_OR_UNKNOWN' AS ownership_status
FROM information_schema.TABLES t
LEFT JOIN tmp_j6_core_table_manifest m
  ON t.TABLE_NAME = CONCAT(@j6_prefix, m.table_suffix)
WHERE t.TABLE_SCHEMA = @j6_database
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND m.table_suffix IS NULL
ORDER BY t.TABLE_NAME;
```

These tables may be:

```text
EXTENSION
CUSTOM
LEGACY
IMPORT/STAGING
UNKNOWN
```

Do not automatically classify them as Joomla core.

Examples such as HikaShop, AcyMailing, JCE, or project-specific tables belong to their own extension/custom migration inventory.

---

## Step 8 — Compare Official Baseline vs Actual Target

For strong verification, create or retain a clean Joomla **6.1.2 reference database** built from the official MySQL installation schema.

Example variables:

```sql
SET @baseline_database = 'joomla612_reference';
SET @baseline_prefix   = 'ref_';

SET @target_database   = 'joomla6_target';
SET @target_prefix     = 'abc_';
```

### 8.1 Baseline-only fields

Fields present in the clean Joomla 6.1.2 reference but missing from the target:

```sql
SELECT
    m.group_code,
    m.logical_table,
    b.COLUMN_NAME AS baseline_column
FROM tmp_j6_core_table_manifest m
JOIN information_schema.COLUMNS b
  ON b.TABLE_SCHEMA = @baseline_database
 AND b.TABLE_NAME   = CONCAT(@baseline_prefix, m.table_suffix)
LEFT JOIN information_schema.COLUMNS t
  ON t.TABLE_SCHEMA = @target_database
 AND t.TABLE_NAME   = CONCAT(@target_prefix, m.table_suffix)
 AND t.COLUMN_NAME  = b.COLUMN_NAME
WHERE t.COLUMN_NAME IS NULL
ORDER BY m.group_code, m.logical_table, b.ORDINAL_POSITION;
```

Expected for an exact baseline-compatible target:

```text
0 rows
```

### 8.2 Target-only fields

Fields present in the target but absent from the clean Joomla 6.1.2 reference:

```sql
SELECT
    m.group_code,
    m.logical_table,
    t.COLUMN_NAME AS target_column
FROM tmp_j6_core_table_manifest m
JOIN information_schema.COLUMNS t
  ON t.TABLE_SCHEMA = @target_database
 AND t.TABLE_NAME   = CONCAT(@target_prefix, m.table_suffix)
LEFT JOIN information_schema.COLUMNS b
  ON b.TABLE_SCHEMA = @baseline_database
 AND b.TABLE_NAME   = CONCAT(@baseline_prefix, m.table_suffix)
 AND b.COLUMN_NAME  = t.COLUMN_NAME
WHERE b.COLUMN_NAME IS NULL
ORDER BY m.group_code, m.logical_table, t.ORDINAL_POSITION;
```

Expected for an exact baseline-compatible target:

```text
0 rows
```

A returned row is not automatically an error. It may be a legitimate project customization, but it must be explained and classified.

### 8.3 Same field name but modified metadata

```sql
SELECT
    m.group_code,
    m.logical_table,
    b.COLUMN_NAME,

    b.ORDINAL_POSITION AS baseline_position,
    t.ORDINAL_POSITION AS target_position,

    b.COLUMN_TYPE AS baseline_type,
    t.COLUMN_TYPE AS target_type,

    b.IS_NULLABLE AS baseline_nullable,
    t.IS_NULLABLE AS target_nullable,

    b.COLUMN_DEFAULT AS baseline_default,
    t.COLUMN_DEFAULT AS target_default,

    b.EXTRA AS baseline_extra,
    t.EXTRA AS target_extra,

    b.CHARACTER_SET_NAME AS baseline_charset,
    t.CHARACTER_SET_NAME AS target_charset,

    b.COLLATION_NAME AS baseline_collation,
    t.COLLATION_NAME AS target_collation,

    b.GENERATION_EXPRESSION AS baseline_generation_expression,
    t.GENERATION_EXPRESSION AS target_generation_expression

FROM tmp_j6_core_table_manifest m

JOIN information_schema.COLUMNS b
  ON b.TABLE_SCHEMA = @baseline_database
 AND b.TABLE_NAME   = CONCAT(@baseline_prefix, m.table_suffix)

JOIN information_schema.COLUMNS t
  ON t.TABLE_SCHEMA = @target_database
 AND t.TABLE_NAME   = CONCAT(@target_prefix, m.table_suffix)
 AND t.COLUMN_NAME  = b.COLUMN_NAME

WHERE
       NOT (b.ORDINAL_POSITION <=> t.ORDINAL_POSITION)
    OR NOT (b.COLUMN_TYPE <=> t.COLUMN_TYPE)
    OR NOT (b.IS_NULLABLE <=> t.IS_NULLABLE)
    OR NOT (b.COLUMN_DEFAULT <=> t.COLUMN_DEFAULT)
    OR NOT (b.EXTRA <=> t.EXTRA)
    OR NOT (b.CHARACTER_SET_NAME <=> t.CHARACTER_SET_NAME)
    OR NOT (b.COLLATION_NAME <=> t.COLLATION_NAME)
    OR NOT (b.GENERATION_EXPRESSION <=> t.GENERATION_EXPRESSION)

ORDER BY
    m.group_code,
    m.logical_table,
    b.ORDINAL_POSITION;
```

Each returned row must receive one of these statuses during migration analysis:

```text
MATCH
MODIFIED
TARGET_ONLY
BASELINE_ONLY
```

`MATCH` is not returned by the difference query because it requires no action.

---

## Step 9 — Export the Inventory

### Human-readable inventory

```sql
SELECT *
FROM tmp_j6_core_field_inventory
ORDER BY
    group_code,
    logical_table,
    ordinal_position;
```

### Compact field list

```sql
SELECT
    group_code,
    logical_table,
    column_name,
    ordinal_position,
    column_type,
    is_nullable,
    column_default,
    extra,
    column_key,
    index_metadata,
    fk_metadata,
    field_fingerprint
FROM tmp_j6_core_field_inventory
ORDER BY
    group_code,
    logical_table,
    ordinal_position;
```

Recommended export formats:

```text
CSV      → easiest for diff/audit
JSON     → easiest for tooling
Markdown → easiest for review
SQL      → easiest for repeatable snapshot tables
```

For long-term migration evidence, do not rely only on a temporary table. Export and commit the resulting snapshot or insert it into a permanent audit table.

---

## Field Matching Rules

A field may be considered structurally matched only after the required metadata is compared.

Minimum rule:

```text
FIELD MATCH =
    same logical table
AND same field name
AND same ordinal position
AND same full column type
AND same nullability
AND same default value
AND same extra/generated behavior
AND same character set when applicable
AND same collation when applicable
AND same generation expression when applicable
```

Indexes and physical constraints must be validated separately because `COLUMN_KEY` alone cannot represent every composite or multi-index relationship.

### Do not simplify types

Incorrect:

```text
int unsigned → int
varchar(255) → varchar
decimal(12,4) → decimal
```

Correct:

```text
Preserve COLUMN_TYPE exactly.
```

### Do not simplify indexes

A composite index such as:

```text
KEY idx_example (field_a, field_b)
```

must preserve:

```text
field_a → idx_example position 1
field_b → idx_example position 2
```

---

## Completion Criteria

Field inventory is complete only when all of the following are true.

```text
Official Joomla baseline version locked       = YES
Official schema source identified              = YES

Core table manifest                            = 76
Actual target core tables found                = 76

Every core table has a field inventory         = YES
Every actual core field has one inventory row  = YES

Missing core tables                            = 0
Missing inventory fields                       = 0
Duplicate inventory fields                     = 0

Actual → inventory differences                 = 0
Inventory → actual differences                 = 0

Unexplained target-only core fields            = 0
Unexplained baseline-only core fields          = 0
Unresolved metadata differences                = 0

Table coverage                                 = 100%
Field coverage                                 = 100%
Field metadata coverage                        = 100%

FIELD INVENTORY STATUS                         = PASS
```

Only after this gate passes should field mapping decisions and migration SQL be finalized.

---

## Execution Checklist

### Baseline

- [ ] Joomla version is locked to `6.1.2`.
- [ ] MySQL is the database engine being inventoried.
- [ ] Official `base.sql` is identified.
- [ ] Official `extensions.sql` is identified.
- [ ] Official `supports.sql` is identified.
- [ ] The 76-table grouping document matches this inventory manifest.

### Target setup

- [ ] Correct target database selected.
- [ ] Correct Joomla physical table prefix configured.
- [ ] Actual target schema captured before migration changes.

### Table coverage

- [ ] Manifest table count = `76`.
- [ ] Distinct manifest table count = `76`.
- [ ] Actual target core table count = `76`, or every exception is documented.
- [ ] Missing core table query returns `0` unexplained rows.
- [ ] Non-core tables are reported separately.

### Field coverage

- [ ] Every core field is discovered from `information_schema.COLUMNS`.
- [ ] Every core field is written exactly once to the inventory.
- [ ] Every one of the 76 tables appears in the per-table field count.
- [ ] Duplicate field query returns `0` rows.
- [ ] Actual → inventory difference returns `0` rows.
- [ ] Inventory → actual difference returns `0` rows.

### Metadata coverage

- [ ] Full `COLUMN_TYPE` preserved.
- [ ] Nullability preserved.
- [ ] Default values preserved.
- [ ] Character length/byte length preserved.
- [ ] Numeric precision/scale preserved.
- [ ] Datetime precision preserved.
- [ ] Character set preserved.
- [ ] Collation preserved.
- [ ] `EXTRA` preserved.
- [ ] Generation expressions preserved.
- [ ] Comments preserved.
- [ ] Primary-key membership captured.
- [ ] Unique-index membership captured.
- [ ] All index names and composite positions captured.
- [ ] Physical foreign-key metadata captured.
- [ ] CHECK constraints inventoried.
- [ ] Field fingerprints generated.

### Baseline reconciliation

- [ ] Clean Joomla 6.1.2 reference schema is available or official DDL is retained as evidence.
- [ ] Baseline-only fields reviewed.
- [ ] Target-only fields reviewed.
- [ ] Modified metadata reviewed.
- [ ] Every difference has an explicit explanation/status.

### Final gate

- [ ] Table coverage = `100%`.
- [ ] Field coverage = `100%`.
- [ ] Field metadata coverage = `100%`.
- [ ] Unresolved differences = `0`.
- [ ] `FIELD INVENTORY STATUS = PASS`.

---

## Final Rule

```text
Do not start field mapping because the counts "look correct".

Prove:

76 / 76 core tables
        ↓
100% actual core fields
        ↓
100% metadata captured
        ↓
baseline ↔ target differences explained
        ↓
FIELD INVENTORY STATUS = PASS
        ↓
mapping may begin
```
