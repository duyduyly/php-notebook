# {{SCOPE_NAME}} Field Mapping — {{SOURCE_SYSTEM}} {{SOURCE_VERSION}} → {{TARGET_SYSTEM}} {{TARGET_VERSION}}

> **Source field decisions = 100% required**  
> **Required target field resolution = 100% required**  
> **Missing / duplicate / ambiguous mappings = 0**  
> **Production execution is blocked until every mandatory gate passes**

This template is the canonical field-level mapping document for future database migrations. It is designed to connect a complete source field inventory to a complete target field inventory without silently dropping source fields or leaving required target fields unresolved.

The definition of **100% field mapping** in this template is:

> Every physical source field in the declared migration scope has exactly one explicit final decision, every required target field has exactly one valid resolution, and all schema, identity, reference, structured-value, and verification rules required by those decisions are accounted for.

`100% field mapping` does **not** mean that every source field must be copied directly. A field may be transformed, looked up, rebuilt, archived, ignored for an approved reason, or replaced by target-owned/generated data. What is forbidden is a silent or unresolved field.

---

## Contents

1. [Required Inputs](#1-required-inputs)
2. [Fixed Baseline](#2-fixed-baseline)
3. [Placeholder Contract](#3-placeholder-contract)
4. [Allowed Field Decisions](#4-allowed-field-decisions)
5. [Deterministic Mapping Precedence](#5-deterministic-mapping-precedence)
6. [Canonical Field Mapping Table](#6-canonical-field-mapping-table)
7. [Schema Metadata Contract](#7-schema-metadata-contract)
8. [Key and Identity Contract](#8-key-and-identity-contract)
9. [Reference / FK Contract](#9-reference--fk-contract)
10. [Structured Data Contract](#10-structured-data-contract)
11. [Type Compatibility Contract](#11-type-compatibility-contract)
12. [NULL, Default, Date, and Generated-Value Contract](#12-null-default-date-and-generated-value-contract)
13. [Source-Only Field Contract](#13-source-only-field-contract)
14. [Target-Only Field Contract](#14-target-only-field-contract)
15. [Per-Table Mapping Sections](#15-per-table-mapping-sections)
16. [Target Anti-Join](#16-target-anti-join)
17. [Database Materialization Contract](#17-database-materialization-contract)
18. [QA Queries](#18-qa-queries)
19. [100% Field Mapping Checklist](#19-100-field-mapping-checklist)
20. [Final Field Mapping Gate](#20-final-field-mapping-gate)

---

# 1. Required Inputs

Do not create the final field mapping until the following artifacts exist and individually pass their own inventory gates:

| Artifact | Required | Purpose |
|---|:---:|---|
| `{{SOURCE_GROUP_MANIFEST}}` | YES | Declares the complete source table scope. |
| `{{SOURCE_FIELD_MANIFEST}}` | YES | Declares every source physical field and exact schema metadata. |
| `{{TARGET_GROUP_MANIFEST}}` | YES | Declares the complete target table scope. |
| `{{TARGET_FIELD_MANIFEST}}` | YES | Declares every target physical field and exact schema metadata. |
| `{{TABLE_MAPPING_DOCUMENT}}` | YES | Resolves source-table → target-table/table-policy relationships. |
| `{{MIGRATION_CONTRACT}}` | YES | Defines allowed decisions, dependencies, verification, and final gates. |

Required baseline condition:

```text
Source tables inventoried          = 100%
Source fields inventoried          = 100%
Target tables inventoried          = 100%
Target fields inventoried          = 100%
Source table decisions             = 100%
Unknown schema objects             = 0
Unclassified schema deviations     = 0
```

If production schema differs from the declared baseline, reconcile the actual databases first. Do not map an assumed schema.

---

# 2. Fixed Baseline

| Item | Value |
|---|---|
| Migration scope | `{{SCOPE_NAME}}` |
| Source system | `{{SOURCE_SYSTEM}}` |
| Source version | `{{SOURCE_VERSION}}` |
| Source tables | `{{SOURCE_TABLE_COUNT}}` |
| Source physical fields | `{{SOURCE_FIELD_COUNT}}` |
| Source schema authority | `{{SOURCE_SCHEMA_AUTHORITY}}` |
| Target system | `{{TARGET_SYSTEM}}` |
| Target version | `{{TARGET_VERSION}}` |
| Target tables | `{{TARGET_TABLE_COUNT}}` |
| Target physical fields | `{{TARGET_FIELD_COUNT}}` |
| Target schema authority | `{{TARGET_SCHEMA_AUTHORITY}}` |
| Table mapping | `{{TABLE_MAPPING_DOCUMENT}}` |
| Migration contract | `{{MIGRATION_CONTRACT}}` |

Baseline coverage target:

```text
Declared source physical fields       = {{SOURCE_FIELD_COUNT}}
Explicit source mapping decisions     = {{SOURCE_FIELD_COUNT}}
Unique source mapping decisions       = {{SOURCE_FIELD_COUNT}}
Missing source decisions              = 0
Duplicate source decisions            = 0

Declared target physical fields       = {{TARGET_FIELD_COUNT}}
Required target fields resolved       = 100%
Unresolved required target fields     = 0
Unknown target strategy               = 0
```

---

# 3. Placeholder Contract

| Placeholder | Meaning |
|---|---|
| `{{SCOPE_NAME}}` | Core, extension, component, subsystem, or declared migration scope. |
| `{{SOURCE_SYSTEM}}` | Source product/system/extension. |
| `{{SOURCE_VERSION}}` | Exact source version/tag/build. |
| `{{TARGET_SYSTEM}}` | Target product/system/extension. |
| `{{TARGET_VERSION}}` | Exact target version/tag/build. |
| `{{SOURCE_TABLE_COUNT}}` | Number of physical source tables in scope. |
| `{{SOURCE_FIELD_COUNT}}` | Number of physical source fields in scope. |
| `{{TARGET_TABLE_COUNT}}` | Number of physical target tables in scope. |
| `{{TARGET_FIELD_COUNT}}` | Number of physical target fields in scope. |
| `{{GROUP_ID}}` | Migration group such as G0, G1, etc. |
| `{{SOURCE_TABLE}}` | Exact physical source table. |
| `{{SOURCE_FIELD}}` | Exact physical source field. |
| `{{TARGET_TABLE}}` | Exact physical target table or `—`. |
| `{{TARGET_FIELD}}` | Exact physical target field or `—`. |
| `{{MAP}}` | Final field decision code. |
| `{{REFERENCE_TYPE}}` | Reference classification. |
| `{{DOMAIN_OR_PARSER}}` | Lookup domain, parser, structured rule, or special semantic rule. |
| `{{RULE}}` | Deterministic mapping/transform expression. |
| `{{VERIFY}}` | Verification rule for the field. |
| `{{REASON}}` | Required rationale for non-obvious or non-copy decisions. |

---

# 4. Allowed Field Decisions

Use exactly one final field decision for every source field.

| Code | Decision | Meaning | Minimum verification |
|:---:|---|---|---|
| `D` | `DIRECT` | Copy a schema-safe, semantically compatible value. | NULL-safe equality + schema compatibility. |
| `T` | `TRANSFORM` | Convert source representation to target representation. | Expected transform = actual target. |
| `L` | `LOOKUP` | Resolve source identity/value through a mapping domain. | Target exists; no missing/ambiguous lookup. |
| `S` | `STRUCTURED` | Parse payload, remap embedded references, validate, serialize. | Parse → remap → reparse; unresolved embedded refs = 0. |
| `G` | `GENERATED` | Generate target value deterministically. | Generation rule reproducible and valid. |
| `B` | `REBUILD` | Do not copy source generated/derived state; rebuild target state. | Target integrity/rebuild verification passes. |
| `R` | `REFERENCE_ONLY` | Use source field only to reconcile target-owned identity/configuration. | Semantic identity uniquely resolved. |
| `A` | `ARCHIVE` | Preserve source value outside active target representation. | Archive count/hash/accounting verified. |
| `I` | `IGNORE` | Intentionally exclude runtime/security/obsolete value. | Reason mandatory; source value still accounted. |
| `DF` | `DEFAULT` | Target field is resolved by target DDL/application default. | Default is explicit and valid. |
| `TO` | `TARGET_OWNED` | Preserve target installation/configuration value. | Target value retained and validated. |
| `RC` | `RECREATE` | Recreate through target semantics/API/configuration. | Recreated target state verified. |

The following are invalid final decisions and block migration:

```text
UNKNOWN
PENDING
REVIEW
OPTIONAL
SELECTIVE
UNMAPPED
AMBIGUOUS
TBD
A / B
COPY?
```

A human comment such as “probably direct” is not a mapping decision.

---

# 5. Deterministic Mapping Precedence

Apply the first matching rule:

```text
1. Source table final decision = IGNORE
   → all source fields = I unless an explicit stricter field rule exists

2. Source table final decision = ARCHIVE
   → all source fields = A unless an explicit stricter field rule exists

3. Source table final decision = REBUILD
   → all source fields = B unless an explicit source field must be preserved separately

4. Explicit field rule exists
   → use the explicit field rule

5. Field is an identity/reference requiring remap
   → L

6. Field contains structured/embedded references
   → S

7. Field is generated/derived in target
   → G / B / RC according to target semantics

8. Same-purpose scalar target exists and compatibility checks all pass
   → D

9. Source field has no active target representation
   → explicit A / I / T rule with reason

10. No rule matches
    → CONTRACT ERROR; migration blocked
```

Important:

> Same field name is never sufficient evidence for `DIRECT`.

---

# 6. Canonical Field Mapping Table

Use one row for **every physical source field**.

Recommended full format:

| # | Source Table | Source Field | S.Type | S.Null | S.Key | Target Table | Target Field | T.Type | T.Null | T.Key | M | Ref | Domain / Parser | Rule | Verify | Reason |
|---:|---|---|---|:---:|---|---|---|---|:---:|---|:---:|---|---|---|---|---|
| 1 | `{{SOURCE_TABLE}}` | `{{SOURCE_FIELD}}` | `{{SOURCE_COLUMN_TYPE}}` | `{{YES_NO}}` | `{{SOURCE_KEY_ROLE}}` | `{{TARGET_TABLE}}` | `{{TARGET_FIELD}}` | `{{TARGET_COLUMN_TYPE}}` | `{{YES_NO_OR_NA}}` | `{{TARGET_KEY_ROLE}}` | `{{MAP}}` | `{{REFERENCE_TYPE}}` | `{{DOMAIN_OR_PARSER}}` | `{{RULE}}` | `{{VERIFY}}` | `{{REASON}}` |

For a compact document, the per-table body may use:

| Source | S.Type | S.Key | Target | T.Type | T.Key | M | Ref | X / Rule |
|---|---|---|---|---|---|:---:|---|---|
| `{{SOURCE_FIELD}}` | `{{SOURCE_COLUMN_TYPE}}` | `{{SOURCE_KEY_ROLE}}` | `{{TARGET_FIELD}}` | `{{TARGET_COLUMN_TYPE}}` | `{{TARGET_KEY_ROLE}}` | `{{MAP}}` | `{{REFERENCE_TYPE}}` | `{{DOMAIN_OR_PARSER}}` |

The compact table is allowed only when null/default/charset/collation and full verification metadata remain available from the canonical field inventories or the migration database view.

## Mandatory row identity

The canonical uniqueness key is:

```text
(source_version, source_table, source_field)
```

Required result:

```text
Mapping rows          = {{SOURCE_FIELD_COUNT}}
Unique mapping rows   = {{SOURCE_FIELD_COUNT}}
Duplicate source rows = 0
Missing source rows   = 0
```

---

# 7. Schema Metadata Contract

Do not duplicate authoritative DDL manually into multiple documents if the source/target field inventories already preserve it. Instead, the mapping document or mapping database must be able to join every row to these schema facts.

## Required source metadata

```text
ordinal_position
DATA_TYPE
COLUMN_TYPE
IS_NULLABLE
COLUMN_DEFAULT
CHARACTER_MAXIMUM_LENGTH
NUMERIC_PRECISION
NUMERIC_SCALE
CHARACTER_SET_NAME
COLLATION_NAME
EXTRA
key_role
physical_fk_target (when declared)
```

## Required target metadata when a target field exists

```text
ordinal_position
DATA_TYPE
COLUMN_TYPE
IS_NULLABLE
COLUMN_DEFAULT
CHARACTER_MAXIMUM_LENGTH
NUMERIC_PRECISION
NUMERIC_SCALE
CHARACTER_SET_NAME
COLLATION_NAME
EXTRA
key_role
physical_fk_target (when declared)
```

`DATA_TYPE` alone is insufficient. `COLUMN_TYPE` is required because it captures details such as length, precision, scale, and signed/unsigned behavior.

Schema metadata must remain factual. Migration decisions belong in the mapping layer.

---

# 8. Key and Identity Contract

## Canonical key roles

```text
PK
COMPOSITE_PK
UNIQUE
INDEX
NONE
```

Use strongest-role precedence:

```text
COMPOSITE_PK / PK > UNIQUE > INDEX > NONE
```

A field may participate in multiple indexes; preserve full index definitions in the inventory, while the mapping view may expose the strongest role for readability.

## Identity rules

- Never assume source numeric IDs equal target numeric IDs.
- Every remapped identity must have an explicit entity/value mapping domain.
- Primary-key preservation is allowed only when the migration contract explicitly permits it and collision checks pass.
- Composite keys are verified as tuples, not as independent columns.
- Unique constraints must be tested **after** transformation/remapping.
- Auto-increment behavior must not be confused with identity equivalence.
- Natural/stable identities used for matching must be explicit and unique.

Typical identity strategies:

```text
ID_MAP
SEMANTIC_LOOKUP
NATURAL_KEY_LOOKUP
GENERATED_ID
PRESERVE_ID_WITH_COLLISION_GATE
NONE
```

Required gate:

```text
Required source identities mapped       = 100%
Missing identity mappings               = 0
Ambiguous identity matches              = 0
Duplicate incompatible target identities = 0
PK/UNIQUE collisions after remap        = 0
```

---

# 9. Reference / FK Contract

Do not use only `FK = YES/NO`. Database migrations commonly contain logical relationships that are not declared as physical SQL foreign keys.

## Canonical reference types

```text
PHYSICAL_FK
LOGICAL_FK
POLYMORPHIC
EMBEDDED_REFERENCE
SEMANTIC_REFERENCE
NONE
```

| Reference Type | Meaning |
|---|---|
| `PHYSICAL_FK` | SQL-declared foreign key constraint. |
| `LOGICAL_FK` | Field references another entity but no physical FK is declared. |
| `POLYMORPHIC` | Referenced entity/table depends on context/type/discriminator. |
| `EMBEDDED_REFERENCE` | Reference exists inside JSON, serialized data, URL/query, HTML, ACL, Registry, etc. |
| `SEMANTIC_REFERENCE` | Stable semantic identity such as extension/type/template/plugin key. |
| `NONE` | No reference semantics. |

Default classification guidance:

```text
L + fixed entity domain                → LOGICAL_FK unless physical FK exists
L + context-dependent entity           → POLYMORPHIC
S + payload may contain IDs/references → EMBEDDED_REFERENCE
R + stable target-owned identity       → SEMANTIC_REFERENCE
Declared SQL FK                         → PHYSICAL_FK
No relationship                         → NONE
```

When a physical FK exists, also retain the referenced table/column and update/delete semantics from the actual schema.

Required gate:

```text
Declared physical FKs inventoried   = 100%
Logical references classified       = 100%
Polymorphic references classified   = 100%
Embedded references classified      = 100%
Semantic references classified      = 100%
Missing required reference domain   = 0
Unresolved referenced target IDs    = 0
Broken required relationships       = 0
```

---

# 10. Structured Data Contract

Any field containing a structured payload must have an explicit parser/serializer strategy.

Typical structured formats:

```text
JSON
Joomla Registry / key-value registry
serialized PHP
XML
CSV / delimited values
ACL payload
HTML
URL
query string
file/media path
JSON media references
field-plugin value
extension/plugin-specific payload
history/version snapshot
```

For structured payloads that may contain IDs/references, the required flow is:

```text
READ SOURCE
    ↓
PARSE
    ↓
VALIDATE SOURCE SHAPE
    ↓
DISCOVER EMBEDDED REFERENCES
    ↓
MAP IDs / VALUES / PATHS
    ↓
APPLY VERSION-SPECIFIC TRANSFORM
    ↓
SERIALIZE TARGET FORMAT
    ↓
REPARSE TARGET VALUE
    ↓
VERIFY EMBEDDED REFERENCES
```

Forbidden behavior:

```text
blind string replacement of numeric IDs
regex-only mutation of unknown JSON/HTML semantics
silently accepting invalid serialized data
copying secrets/tokens into logs
truncating structured payloads to fit target fields
```

Gate:

```text
Structured source fields discovered = 100%
Structured fields with parser/rule  = 100%
Invalid structured payloads         = 0
Unresolved embedded references      = 0
Serialization/reparse failures      = 0
```

---

# 11. Type Compatibility Contract

A `DIRECT` mapping is permitted only if schema **and semantics** are compatible.

Check at minimum:

| Check | Required |
|---|:---:|
| Same business meaning | YES |
| Source values fit target `COLUMN_TYPE` | YES |
| Signed/unsigned range compatible | YES |
| Length safe | YES |
| Precision/scale safe | YES |
| NULL behavior compatible | YES |
| Charset/encoding compatible | YES |
| Collation/case behavior does not create collisions | YES |
| Target enum/state domain valid | YES |
| PK/UNIQUE constraints remain valid | YES |
| No silent truncation/coercion | YES |

Examples of conditions requiring `TRANSFORM` or blocking migration:

```text
varchar(255) → varchar(100) with values > 100 chars
bigint → int with out-of-range values
signed → unsigned with negative source values
text → JSON with non-JSON source values
datetime zero-date → target strict datetime
case-sensitive source unique key → case-insensitive target collision
source enum/state values not valid in target
```

`DIRECT` QA gate:

```text
Unsafe DIRECT mappings           = 0
Unresolved type narrowing        = 0
Unresolved signedness conflicts  = 0
Unresolved precision loss        = 0
Unresolved collation collisions  = 0
Silent truncation allowed        = 0
```

---

# 12. NULL, Default, Date, and Generated-Value Contract

Every nullable/default/date change must be intentional.

## NULL rules

- Preserve the difference between `NULL`, empty string, zero, and sentinel IDs when application semantics distinguish them.
- Source NULL → target NOT NULL requires an explicit `T`, `DF`, `G`, `TO`, or `RC` strategy.
- Do not silently convert missing values to empty strings or zero.

## Default rules

- A target default is not a substitute for source data unless `DEFAULT` is the approved resolution.
- Application-generated defaults must be distinguished from DDL defaults.
- Timestamp/current-time defaults must be evaluated for reproducibility.

## Legacy date rules

Explicitly handle, when applicable:

```text
0000-00-00
0000-00-00 00:00:00
invalid historical dates
empty date strings
timezone changes
precision changes
NULL vs sentinel date
```

## Generated values

A generated target field must identify:

```text
generation source
algorithm/application rule
required dependencies
execution phase
verification rule
rerun/idempotency behavior
```

Gate:

```text
Unresolved NULLability changes    = 0
Unresolved default behavior       = 0
Invalid target dates              = 0
Unresolved generated fields       = 0
```

---

# 13. Source-Only Field Contract

Every source field absent from the target schema must still have exactly one final decision.

Allowed patterns:

```text
TRANSFORM → value is represented elsewhere in target
ARCHIVE   → source value preserved outside active target model
IGNORE    → intentional exclusion with approved reason
REBUILD   → source derived value replaced by rebuilt target state
REFERENCE_ONLY → value used only to identify target-owned state
```

Forbidden:

```text
Target field = NULL and no reason
field omitted from document
“not needed” with no accounting rule
silent DROP
```

Source-only manifest:

| Source Table | Source Field | Final Decision | Destination / Rule | Verification | Reason |
|---|---|---|---|---|---|
| `{{SOURCE_TABLE}}` | `{{SOURCE_ONLY_FIELD}}` | `{{A/T/I/B/R}}` | `{{RULE_OR_DESTINATION}}` | `{{VERIFY}}` | `{{REASON}}` |

Gate:

```text
Source-only fields discovered    = 100%
Source-only fields resolved      = 100%
Silent source-only drops         = 0
```

---

# 14. Target-Only Field Contract

Run a target anti-join after source mapping. Every target field without a direct source-field mapping must have a target resolution.

Allowed target resolutions:

```text
SOURCE_TRANSFORM
LOOKUP
DEFAULT
GENERATED
TARGET_OWNED
REBUILD
RECREATE
NOT_REQUIRED_BY_SCOPE
```

`NOT_REQUIRED_BY_SCOPE` must have an explicit scope reason; it must not be used as a generic escape hatch.

Target-only manifest:

| Target Table | Target Field | Required? | Resolution | Dependency / Rule | Verification | Reason |
|---|---|:---:|---|---|---|---|
| `{{TARGET_TABLE}}` | `{{TARGET_ONLY_FIELD}}` | `{{YES_NO}}` | `{{RESOLUTION}}` | `{{RULE}}` | `{{VERIFY}}` | `{{REASON}}` |

Gate:

```text
Target fields inventoried          = {{TARGET_FIELD_COUNT}}
Target fields with source mapping  = {{COUNT}}
Target-only fields                 = {{COUNT}}
Target-only fields resolved        = {{COUNT}}
Required target resolution         = 100%
Unresolved required target fields  = 0
Unknown target strategy            = 0
```

---

# 15. Per-Table Mapping Sections

Repeat this section for every source table in the declared migration scope. Do not use wildcard table names in the final generated mapping.

## {{GROUP_ID}} — `{{SOURCE_TABLE}}` → `{{TARGET_TABLE_OR_DESTINATION}}`

**Table decision:** `{{TABLE_DECISION}}`  
**Source fields:** `{{SOURCE_TABLE_FIELD_COUNT}}`  
**Mapped source fields:** `{{SOURCE_TABLE_FIELD_COUNT}}`  
**Missing source fields:** `0`  
**Duplicate source fields:** `0`

| Source | S.Type | S.Null | S.Key | Target | T.Type | T.Null | T.Key | M | Ref | X / Rule |
|---|---|:---:|---|---|---|:---:|---|:---:|---|---|
| `{{FIELD_1}}` | `{{TYPE}}` | `{{Y_N}}` | `{{KEY}}` | `{{TARGET_FIELD_1}}` | `{{TYPE}}` | `{{Y_N}}` | `{{KEY}}` | `{{MAP}}` | `{{REF}}` | `{{DOMAIN_PARSER_RULE}}` |
| `{{FIELD_2}}` | `{{TYPE}}` | `{{Y_N}}` | `{{KEY}}` | `{{TARGET_FIELD_2}}` | `{{TYPE}}` | `{{Y_N}}` | `{{KEY}}` | `{{MAP}}` | `{{REF}}` | `{{DOMAIN_PARSER_RULE}}` |
| `...` | `...` | `...` | `...` | `...` | `...` | `...` | `...` | `...` | `...` | `...` |
| `{{FIELD_N}}` | `{{TYPE}}` | `{{Y_N}}` | `{{KEY}}` | `{{TARGET_FIELD_N}}` | `{{TYPE}}` | `{{Y_N}}` | `{{KEY}}` | `{{MAP}}` | `{{REF}}` | `{{DOMAIN_PARSER_RULE}}` |

### Table-specific rules

```text
Identity rule:      {{IDENTITY_RULE}}
Lookup domains:     {{LOOKUP_DOMAINS}}
Structured parsers: {{STRUCTURED_PARSERS}}
Generated fields:   {{GENERATED_FIELDS}}
Source-only fields: {{SOURCE_ONLY_FIELDS}}
Target-only fields: {{TARGET_ONLY_FIELDS}}
Execution dependency: {{DEPENDENCIES}}
```

### Table verification

```text
Source fields accounted     = {{SOURCE_TABLE_FIELD_COUNT}} / {{SOURCE_TABLE_FIELD_COUNT}}
Missing source decisions    = 0
Duplicate source decisions  = 0
Missing lookup domains      = 0
Missing parser rules        = 0
Unsafe direct mappings      = 0
Unresolved target fields    = 0
```

---

# 16. Target Anti-Join

After all source-field rows are materialized, anti-join the target inventory against mapped target fields.

Conceptual SQL:

```sql
SELECT
    tf.table_name,
    tf.column_name
FROM migration_inventory.field_inventory AS tf
LEFT JOIN migration_mapping.field_mapping AS fm
  ON fm.target_table = tf.table_name
 AND fm.target_field = tf.column_name
 AND fm.source_version = :source_version
 AND fm.target_version = :target_version
WHERE tf.migration_run_id = :migration_run_id
  AND tf.database_side = 'TARGET'
  AND fm.source_field IS NULL
ORDER BY tf.table_name, tf.ordinal_position;
```

Every returned target field must appear in the target-only resolution manifest from section 14.

Required invariant:

```text
mapped target fields
+ resolved target-only fields
= all target fields in declared scope
```

No target field may remain `UNKNOWN` merely because it did not exist in the source version.

---

# 17. Database Materialization Contract

Recommended logical separation:

```text
migration_inventory.field_inventory
    = physical schema facts

migration_mapping.field_mapping
    = field-level migration decisions

migration_mapping.value_mapping
    = runtime/design-time ID and value translations

migration_inventory.table_dependency
    = table/entity/dependency graph
```

No additional “contract table” is required if these structures already preserve all required facts and decisions.

## Recommended unique key for field mapping

```text
(source_version, source_table, source_field)
```

Recommended mapping attributes:

```text
migration_run_id
source_version
source_table
source_field

target_version
target_table
target_field

mapping_type
reference_type
reference_domain
transform_rule
parser_rule
verification_rule
reason
execution_order
status
```

Schema metadata should normally be joined from `field_inventory`, not manually duplicated into `field_mapping`.

## Enriched mapping SELECT

Expected result shape:

```text
source_table
source_field
source_data_type
source_column_type
source_nullable
source_default
source_key_role
source_physical_fk_target

target_table
target_field
target_data_type
target_column_type
target_nullable
target_default
target_key_role
target_physical_fk_target

mapping_type
reference_type
reference_domain
transform_rule
parser_rule
verification_rule
reason
```

Conceptual SQL:

```sql
SELECT
    fm.source_table,
    fm.source_field,
    sf.data_type          AS source_data_type,
    sf.column_type        AS source_column_type,
    sf.is_nullable        AS source_nullable,
    sf.column_default     AS source_default,
    sf.key_role           AS source_key_role,
    sf.physical_fk_target AS source_physical_fk_target,

    fm.target_table,
    fm.target_field,
    tf.data_type          AS target_data_type,
    tf.column_type        AS target_column_type,
    tf.is_nullable        AS target_nullable,
    tf.column_default     AS target_default,
    tf.key_role           AS target_key_role,
    tf.physical_fk_target AS target_physical_fk_target,

    fm.mapping_type,
    fm.reference_type,
    fm.reference_domain,
    fm.transform_rule,
    fm.parser_rule,
    fm.verification_rule,
    fm.reason
FROM migration_mapping.field_mapping AS fm
JOIN migration_inventory.field_inventory AS sf
  ON sf.migration_run_id = fm.migration_run_id
 AND sf.database_side = 'SOURCE'
 AND sf.table_name = fm.source_table
 AND sf.column_name = fm.source_field
LEFT JOIN migration_inventory.field_inventory AS tf
  ON tf.migration_run_id = fm.migration_run_id
 AND tf.database_side = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.column_name = fm.target_field
WHERE fm.migration_run_id = :migration_run_id
  AND fm.source_version = :source_version
  AND fm.target_version = :target_version
ORDER BY fm.source_table, sf.ordinal_position;
```

Adapt column names to the actual migration schema, but preserve the logical output contract.

---

# 18. QA Queries

The following examples assume MySQL/MariaDB and a mapping database similar to section 17.

## 18.1 Source mapping count and uniqueness

```sql
SELECT
    COUNT(*) AS mapping_rows,
    COUNT(DISTINCT CONCAT(source_table, '.', source_field)) AS unique_source_fields
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND source_version = :source_version
  AND target_version = :target_version;
```

Expected:

```text
mapping_rows         = {{SOURCE_FIELD_COUNT}}
unique_source_fields = {{SOURCE_FIELD_COUNT}}
```

## 18.2 Duplicate source mapping decisions

```sql
SELECT
    source_table,
    source_field,
    COUNT(*) AS decision_count
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND source_version = :source_version
  AND target_version = :target_version
GROUP BY source_table, source_field
HAVING COUNT(*) <> 1;
```

Expected result: **0 rows**.

## 18.3 Missing source field mappings

```sql
SELECT
    sf.table_name,
    sf.column_name
FROM migration_inventory.field_inventory AS sf
LEFT JOIN migration_mapping.field_mapping AS fm
  ON fm.migration_run_id = sf.migration_run_id
 AND fm.source_table = sf.table_name
 AND fm.source_field = sf.column_name
 AND fm.source_version = :source_version
 AND fm.target_version = :target_version
WHERE sf.migration_run_id = :migration_run_id
  AND sf.database_side = 'SOURCE'
  AND fm.source_field IS NULL
ORDER BY sf.table_name, sf.ordinal_position;
```

Expected result: **0 rows**.

## 18.4 Invalid final decisions

```sql
SELECT
    source_table,
    source_field,
    mapping_type
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND (
        mapping_type IS NULL
        OR UPPER(mapping_type) IN (
            'UNKNOWN','PENDING','REVIEW','OPTIONAL','SELECTIVE',
            'UNMAPPED','AMBIGUOUS','TBD'
        )
      );
```

Expected result: **0 rows**.

## 18.5 Lookup rows missing reference domain

```sql
SELECT
    source_table,
    source_field
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND mapping_type = 'LOOKUP'
  AND NULLIF(TRIM(reference_domain), '') IS NULL;
```

Expected result: **0 rows**.

## 18.6 Structured rows missing parser/rule

```sql
SELECT
    source_table,
    source_field
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND mapping_type = 'STRUCTURED'
  AND NULLIF(TRIM(parser_rule), '') IS NULL;
```

Expected result: **0 rows**.

## 18.7 Source fields that reference a nonexistent target field

```sql
SELECT
    fm.source_table,
    fm.source_field,
    fm.target_table,
    fm.target_field
FROM migration_mapping.field_mapping AS fm
LEFT JOIN migration_inventory.field_inventory AS tf
  ON tf.migration_run_id = fm.migration_run_id
 AND tf.database_side = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.column_name = fm.target_field
WHERE fm.migration_run_id = :migration_run_id
  AND fm.target_table IS NOT NULL
  AND fm.target_field IS NOT NULL
  AND tf.column_name IS NULL;
```

Expected result: **0 rows**, except destinations intentionally external to the active target schema and explicitly modeled as such.

## 18.8 Unsafe `DIRECT` candidates

The exact implementation depends on the metadata model. At minimum flag `DIRECT` rows where source/target metadata is unresolved or obviously incompatible.

```sql
SELECT
    fm.source_table,
    fm.source_field,
    sf.column_type AS source_type,
    tf.column_type AS target_type
FROM migration_mapping.field_mapping AS fm
JOIN migration_inventory.field_inventory AS sf
  ON sf.migration_run_id = fm.migration_run_id
 AND sf.database_side = 'SOURCE'
 AND sf.table_name = fm.source_table
 AND sf.column_name = fm.source_field
JOIN migration_inventory.field_inventory AS tf
  ON tf.migration_run_id = fm.migration_run_id
 AND tf.database_side = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.column_name = fm.target_field
WHERE fm.migration_run_id = :migration_run_id
  AND fm.mapping_type = 'DIRECT'
  AND (
      sf.data_type IS NULL
      OR tf.data_type IS NULL
      OR sf.column_type IS NULL
      OR tf.column_type IS NULL
  );
```

Expected result: **0 rows**.

This query is only a minimum metadata gate. Real `DIRECT` validation must also inspect data ranges, lengths, precision, NULLs, collation collisions, and domain semantics.

## 18.9 Physical FK discovery

```sql
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_SCHEMA,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = :database_name
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME;
```

## 18.10 Key-role discovery

```sql
SELECT
    s.TABLE_SCHEMA,
    s.TABLE_NAME,
    s.COLUMN_NAME,
    CASE
        WHEN SUM(CASE WHEN s.INDEX_NAME = 'PRIMARY' THEN 1 ELSE 0 END) > 0
             AND COALESCE(pk.pk_cols, 0) > 1
            THEN 'COMPOSITE_PK'
        WHEN SUM(CASE WHEN s.INDEX_NAME = 'PRIMARY' THEN 1 ELSE 0 END) > 0
            THEN 'PK'
        WHEN SUM(CASE WHEN s.NON_UNIQUE = 0 THEN 1 ELSE 0 END) > 0
            THEN 'UNIQUE'
        WHEN COUNT(*) > 0
            THEN 'INDEX'
        ELSE 'NONE'
    END AS key_role
FROM information_schema.STATISTICS AS s
LEFT JOIN (
    SELECT TABLE_SCHEMA, TABLE_NAME, COUNT(*) AS pk_cols
    FROM information_schema.STATISTICS
    WHERE INDEX_NAME = 'PRIMARY'
    GROUP BY TABLE_SCHEMA, TABLE_NAME
) AS pk
  ON pk.TABLE_SCHEMA = s.TABLE_SCHEMA
 AND pk.TABLE_NAME = s.TABLE_NAME
WHERE s.TABLE_SCHEMA = :database_name
GROUP BY s.TABLE_SCHEMA, s.TABLE_NAME, s.COLUMN_NAME, pk.pk_cols
ORDER BY s.TABLE_NAME, s.COLUMN_NAME;
```

---

# 19. 100% Field Mapping Checklist

## A. Baseline identity

- [ ] Exact migration scope recorded
- [ ] Exact source system/version recorded
- [ ] Exact target system/version recorded
- [ ] Source schema authority recorded
- [ ] Target schema authority recorded
- [ ] Source table count fixed
- [ ] Source physical field count fixed
- [ ] Target table count fixed
- [ ] Target physical field count fixed

## B. Inventory prerequisite

- [ ] Source table inventory = 100%
- [ ] Source field inventory = 100%
- [ ] Target table inventory = 100%
- [ ] Target field inventory = 100%
- [ ] Actual production source reconciled
- [ ] Actual production target reconciled
- [ ] Unclassified source schema objects = 0
- [ ] Unclassified target schema objects = 0

## C. Source field coverage

- [ ] Every source physical field appears exactly once
- [ ] Mapping rows = source physical field count
- [ ] Unique source mapping rows = source physical field count
- [ ] Missing source field decisions = 0
- [ ] Duplicate source field decisions = 0
- [ ] Wildcard field decisions = 0
- [ ] Ambiguous field decisions = 0
- [ ] Invalid final decisions = 0

## D. Target resolution

- [ ] Every mapped target field exists or has an explicit external/archive destination
- [ ] Target anti-join executed
- [ ] Every target-only field classified
- [ ] Every required target field resolved
- [ ] Unresolved required target fields = 0
- [ ] Unknown target strategies = 0

## E. Data type and schema compatibility

- [ ] Source `DATA_TYPE` available for every source mapping row
- [ ] Source `COLUMN_TYPE` available for every source mapping row
- [ ] Target metadata available for every mapped target field
- [ ] Length changes checked
- [ ] Precision/scale changes checked
- [ ] Signed/unsigned changes checked
- [ ] Charset/encoding changes checked
- [ ] Collation/case changes checked
- [ ] NULLability changes checked
- [ ] Default changes checked
- [ ] Auto-increment/generated semantics checked
- [ ] Silent truncation/coercion forbidden
- [ ] Unsafe `DIRECT` mappings = 0

## F. Keys and identity

- [ ] PK fields classified
- [ ] Composite PK fields classified
- [ ] UNIQUE fields classified
- [ ] Secondary indexes classified
- [ ] Identity strategy explicit for every entity identity
- [ ] ID equality is never assumed without proof
- [ ] Composite identities verified as tuples
- [ ] PK/UNIQUE collisions after remapping = 0
- [ ] Ambiguous natural-key matches = 0

## G. Reference / FK coverage

- [ ] Physical FKs inventoried
- [ ] Logical FKs identified
- [ ] Polymorphic references identified
- [ ] Embedded references identified
- [ ] Semantic references identified
- [ ] Every `LOOKUP` has a reference domain
- [ ] Missing required reference domains = 0
- [ ] Missing referenced target identities = 0
- [ ] Broken required relationships = 0

## H. Structured fields

- [ ] Structured field discovery = 100%
- [ ] Every structured field has parser/serializer rule
- [ ] Embedded IDs/paths/URLs are explicitly handled where applicable
- [ ] Invalid structured payloads = 0
- [ ] Unresolved embedded references = 0
- [ ] Reparse/serialization failures = 0
- [ ] Blind string ID replacement forbidden

## I. Values / dates / states

- [ ] NULL vs empty vs zero semantics checked
- [ ] Legacy/invalid dates explicitly handled
- [ ] Target state/enum domains checked
- [ ] Boolean/sentinel semantics checked
- [ ] Default-value behavior explicit
- [ ] Generated-value behavior explicit
- [ ] Value mappings have deterministic domains
- [ ] Missing required value mappings = 0

## J. Source-only fields

- [ ] Source-only fields discovered = 100%
- [ ] Every source-only field has explicit final decision
- [ ] Archive destination/rule explicit where used
- [ ] Ignore reason explicit where used
- [ ] Transform destination explicit where used
- [ ] Silent source-only drops = 0

## K. Target-only fields

- [ ] Target-only fields discovered = 100%
- [ ] Required/optional-by-scope status explicit
- [ ] Every target-only field has one resolution
- [ ] Defaults validated
- [ ] Generated/rebuilt/recreated rules explicit
- [ ] Target-owned fields explicit
- [ ] Unresolved target-only fields = 0

## L. Verification readiness

- [ ] Every mapping type has a verification rule
- [ ] `DIRECT` supports NULL-safe equality verification
- [ ] `TRANSFORM` supports expected-vs-actual verification
- [ ] `LOOKUP` supports orphan/missing-map verification
- [ ] `STRUCTURED` supports parse/remap/reparse verification
- [ ] `GENERATED`/`REBUILD` supports integrity verification
- [ ] `ARCHIVE` supports accounting/hash/count verification
- [ ] `IGNORE` supports reason/accounting verification
- [ ] Verification errors must block PASS

## M. Database materialization

- [ ] `field_inventory` remains physical-schema source of truth
- [ ] `field_mapping` remains migration-decision source of truth
- [ ] `value_mapping` remains ID/value translation store
- [ ] Mapping unique key enforced
- [ ] Duplicate mapping rows = 0
- [ ] Enriched source→target SELECT can be produced
- [ ] Production mapping materialization = 100%

## N. Rerun / operational safety

- [ ] Mapping decisions are version-scoped
- [ ] Migration run ID is preserved where required
- [ ] Mapping generation is deterministic
- [ ] Rerun does not create duplicate mapping decisions
- [ ] Rerun does not create conflicting ID/value maps
- [ ] Errors are never silently converted to IGNORE
- [ ] Production source remains immutable

---

# 20. Final Field Mapping Gate

A document may claim **definition-level PASS** only after all declared source and target baseline fields have been reconciled through this template.

A production migration may claim **production PASS** only after the actual source/target databases are materialized and all runtime gates pass.

```text
BASELINE / INVENTORY
--------------------------------------------------
Source tables inventoried                   = 100%
Source physical fields                      = {{SOURCE_FIELD_COUNT}}
Target tables inventoried                   = 100%
Target physical fields                      = {{TARGET_FIELD_COUNT}}
Unknown schema objects                      = 0
Unclassified schema deviations              = 0

SOURCE FIELD DECISIONS
--------------------------------------------------
Mapping rows                                 = {{SOURCE_FIELD_COUNT}}
Unique source mapping rows                   = {{SOURCE_FIELD_COUNT}}
Missing source field decisions               = 0
Duplicate source field decisions             = 0
Ambiguous/invalid final decisions            = 0
Silent source-only drops                     = 0

TARGET RESOLUTION
--------------------------------------------------
Target anti-join processed                   = 100%
Target-only fields classified                = 100%
Required target fields resolved              = 100%
Unresolved required target fields            = 0
Unknown target strategy                      = 0

SCHEMA METADATA
--------------------------------------------------
Source DATA_TYPE/COLUMN_TYPE resolved        = 100%
Mapped target DATA_TYPE/COLUMN_TYPE resolved = 100%
Source key role classified                   = 100%
Mapped target key role classified            = 100%
Unresolved NULL/default changes              = 0
Unsafe DIRECT mappings                       = 0
Unresolved narrowing/truncation              = 0
Unresolved collation collisions              = 0

IDENTITY / REFERENCES
--------------------------------------------------
Required identity/value mappings defined     = 100%
Physical FK inventory                        = 100%
Logical reference classification             = 100%
Polymorphic reference classification         = 100%
Embedded reference classification            = 100%
Semantic reference classification            = 100%
Missing required reference domains           = 0
Ambiguous identity matches                   = 0
PK/UNIQUE collisions                         = 0

STRUCTURED DATA
--------------------------------------------------
Structured fields discovered                 = 100%
Structured fields with parser/rule           = 100%
Invalid structured payloads                  = 0
Unresolved embedded references               = 0

DATABASE MATERIALIZATION
--------------------------------------------------
Actual source field mappings materialized    = 100%
Duplicate materialized mappings              = 0
Missing materialized mappings                = 0
Conflicting value/ID mappings                = 0

VERIFICATION READINESS
--------------------------------------------------
Mapping rows with verification rule          = 100%
Unresolved dependencies                      = 0
Definition-level mapping errors              = 0

==================================================
FIELD MAPPING CONTRACT                       = PASS
==================================================
```

## Required wording for a successful definition-level result

> **100% of source physical fields in the declared migration scope have exactly one explicit mapping decision, and 100% of required target fields have an explicit resolution. No source field is silently dropped and no required target field remains unresolved.**

## Production boundary

Do not convert the definition-level statement above into a claim that production data has already migrated successfully.

Production PASS additionally requires:

```text
actual source/target schema reconciliation = PASS
runtime ID/value mapping                   = PASS
source record accounting                   = 100%
missing expected records                   = 0
unexpected records                         = 0
field value mismatches                     = 0
broken required relationships              = 0
migration execution errors                 = 0
rerun/idempotency checks                    = PASS
```

Only after those runtime checks pass may the wider migration contract claim that all database data in scope has been accounted for and verified.