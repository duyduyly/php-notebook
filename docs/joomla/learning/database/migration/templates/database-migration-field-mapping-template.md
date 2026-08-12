# {{SCOPE_NAME}} Field Mapping — {{SOURCE_SYSTEM}} {{SOURCE_VERSION}} → {{TARGET_SYSTEM}} {{TARGET_VERSION}}

> **Source field accounting = 100% required**  
> **Required target field resolution = 100% required**  
> **Missing / ambiguous / silently dropped fields = 0**  
> **Production execution is blocked until every mandatory gate passes**

This template is the canonical field-level mapping document for reusable database migrations. It connects a complete source field inventory to a complete target field inventory and materializes the decisions required by the migration contract.

## Required Generated Filename

Every generated field-mapping document **must use the migration scope name as a filename prefix**.

```text
<scope>-field-mapping-migration.md
```

Examples:

```text
hikashop-field-mapping-migration.md
acymailing-field-mapping-migration.md
joomla-core-field-mapping-migration.md
cars-field-mapping-migration.md
```

Recommended normalization:

```text
lowercase
kebab-case
no spaces
stable scope name
```

Do not use a generic unscoped filename such as `field-mapping-migration.md` when multiple migration scopes may coexist.

Companion table mapping must use the same scope prefix:

```text
<scope>-table-mapping-migration.md
```

---

## Contents

1. [Purpose and 100% Definition](#1-purpose-and-100-definition)
2. [Required Inputs](#2-required-inputs)
3. [Fixed Baseline](#3-fixed-baseline)
4. [Canonical Mapping Decisions](#4-canonical-mapping-decisions)
5. [Mapping Cardinality](#5-mapping-cardinality)
6. [Deterministic Mapping Precedence](#6-deterministic-mapping-precedence)
7. [Canonical Mapping Record](#7-canonical-mapping-record)
8. [Schema Metadata Contract](#8-schema-metadata-contract)
9. [Key and Identity Contract](#9-key-and-identity-contract)
10. [Reference / FK Contract](#10-reference--fk-contract)
11. [Structured Data Contract](#11-structured-data-contract)
12. [Type Compatibility Contract](#12-type-compatibility-contract)
13. [NULL, Default, Date, Enum, and Sentinel Rules](#13-null-default-date-enum-and-sentinel-rules)
14. [Source-Only Field Contract](#14-source-only-field-contract)
15. [Target-Only Field Contract](#15-target-only-field-contract)
16. [Per-Table Mapping Section](#16-per-table-mapping-section)
17. [Database Materialization Contract](#17-database-materialization-contract)
18. [QA Queries](#18-qa-queries)
19. [100% Field Mapping Checklist](#19-100-field-mapping-checklist)
20. [Final Field Mapping Gate](#20-final-field-mapping-gate)
21. [Field Readiness Status](#21-field-readiness-status)

---

# 1. Purpose and 100% Definition

The field mapping must answer, for every in-scope source field:

```text
What source field is this?
Which target field(s), destination, or accounting outcome receive it?
What mapping decision applies?
What type/key/reference constraints must be respected?
What identity/value mapping is required?
Does the value require parsing or transformation?
How will the result be verified?
```

The correct definition of **100% field mapping** is:

> **Every physical source field in the declared migration scope is explicitly accounted for by at least one deterministic final mapping/accounting decision, and every required target physical field has at least one explicit population or resolution strategy.**

This is intentionally broader than `mapping row count = source field count` because reusable migrations must support one-to-many and many-to-one mappings.

`100% field mapping` does **not** mean every source field is copied directly. Valid outcomes may include transform, lookup, rebuild, archive, ignore with reason, reference-only handling, generated target data, target-owned data, or recreation.

What is forbidden:

```text
silent source-field drop
unresolved target required field
unknown decision
ambiguous final mapping
unverified direct copy
missing reference domain
missing structured parser/rule
```

---

# 2. Required Inputs

Do not generate final field mappings from table/column-name similarity alone.

Required artifacts:

| Artifact | Required | Purpose |
|---|:---:|---|
| `{{SOURCE_GROUP_MANIFEST}}` | YES | Complete source table scope. |
| `{{SOURCE_FIELD_MANIFEST}}` | YES | Complete source physical field inventory and schema facts. |
| `{{TARGET_GROUP_MANIFEST}}` | YES | Complete target table scope. |
| `{{TARGET_FIELD_MANIFEST}}` | YES | Complete target physical field inventory and schema facts. |
| `{{TABLE_MAPPING_DOCUMENT}}` | YES | Fixes source-table → target-table/destination decisions. |
| `{{MIGRATION_CONTRACT}}` | YES | Defines allowed decisions, accounting, references, dependencies, and verification rules. |
| `{{MIGRATION_PROFILE}}` | Optional | Platform/application-specific semantics. |
| `{{EXPLICIT_OVERRIDES}}` | Optional | Evidence-backed exceptions to generic/profile rules. |

Hard prerequisite gate:

```text
Source table inventory                 = PASS
Source field inventory                 = PASS
Target table inventory                 = PASS
Target field inventory                 = PASS
Table mapping                          = PASS
Source fields inventoried              = 100%
Target fields inventoried              = 100%
Unknown schema objects                 = 0
Unclassified schema deviations         = 0
```

If production schema differs from the declared baseline, reconcile the actual databases before production execution.

---

# 3. Fixed Baseline

| Item | Value |
|---|---|
| Migration scope | `{{SCOPE_NAME}}` |
| Output filename | `{{SCOPE_SLUG}}-field-mapping-migration.md` |
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
| Migration profile | `{{MIGRATION_PROFILE_OR_NONE}}` |

Coverage is calculated by distinct field identity, not raw mapping action count:

```text
Distinct source fields accounted      = {{SOURCE_FIELD_COUNT}} / {{SOURCE_FIELD_COUNT}}
Unmapped source fields                = 0
Silent source drops                   = 0

Required target fields resolved       = 100%
Unresolved required target fields     = 0
Unknown target strategy               = 0
```

Canonical field identities:

```text
SOURCE_FIELD_KEY = (source_version, source_table, source_field)
TARGET_FIELD_KEY = (target_version, target_table, target_field)
```

---

# 4. Canonical Mapping Decisions

Allowed final decisions:

| Code | Decision | Meaning |
|:---:|---|---|
| `D` | `DIRECT` | Copy a schema-safe and semantically compatible scalar value. |
| `T` | `TRANSFORM` | Convert source representation/value to target representation/value. |
| `L` | `LOOKUP` | Resolve target identity/value through a mapping domain. |
| `S` | `STRUCTURED` | Parse structured content, remap embedded references, validate, serialize. |
| `G` | `GENERATED` | Generate target value/state deterministically. |
| `B` | `REBUILD` | Do not copy generated source state; rebuild target state. |
| `R` | `REFERENCE_ONLY` | Use source value only to resolve/reconcile a target-owned identity. |
| `A` | `ARCHIVE` | Preserve source value outside the active target representation. |
| `I` | `IGNORE` | Intentionally exclude runtime/security/obsolete value; reason mandatory. |
| `DF` | `DEFAULT` | Resolve target field using an approved DDL/application default. |
| `TO` | `TARGET_OWNED` | Preserve target installation/configuration value. |
| `RC` | `RECREATE` | Recreate through target-version semantics/API/configuration. |

Invalid final states:

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

Any invalid final state blocks PASS.

---

# 5. Mapping Cardinality

Reusable field mapping must support:

```text
ONE_TO_ONE
ONE_TO_MANY
MANY_TO_ONE
MANY_TO_MANY
ONE_TO_NONE
NONE_TO_ONE
```

Examples:

```text
ONE_TO_ONE
old.title → new.title

ONE_TO_MANY
old.full_name → new.first_name
old.full_name → new.last_name

MANY_TO_ONE
old.address1 + old.address2 + old.city → new.address_json

ONE_TO_NONE
old.runtime_token → IGNORE

NONE_TO_ONE
no source field → new.created_at DEFAULT
```

Use a `mapping_group_key` when multiple rows form one logical transformation.

Example:

```text
mapping_group_key = CUSTOMER_NAME_001
mapping_cardinality = MANY_TO_ONE
```

A legitimate multi-row group is **not** a duplicate mapping error.

Gate:

```text
Unknown cardinality                 = 0
Invalid mapping groups              = 0
Orphan mapping-group members        = 0
Conflicting grouped transform rules = 0
```

---

# 6. Deterministic Mapping Precedence

Apply the first valid rule, with explicit overrides taking priority:

```text
1. Explicit evidence-backed field override
2. Parent table IGNORE / ARCHIVE / REBUILD inheritance
3. Identity/reference field requiring remap
4. Structured field / embedded reference
5. Generated/derived target semantics
6. Explicit rename/transform rule
7. Same-purpose scalar with all compatibility checks PASS → DIRECT
8. Source-only field → explicit TRANSFORM / ARCHIVE / IGNORE / REFERENCE_ONLY / REBUILD
9. No rule → CONTRACT ERROR
```

Hard rules:

```text
same field name != DIRECT proof
same SQL type != semantic compatibility proof
same numeric ID != identity equivalence proof
```

Candidate matching may suggest mappings, but final mappings must be materialized and verified.

---

# 7. Canonical Mapping Record

Recommended logical attributes:

```text
row_kind

source_version
source_table
source_field

target_version
target_table
target_field

mapping_group_key
mapping_cardinality
mapping_type
field_status

identity_strategy
reference_type
reference_domain

parser_rule
transform_rule
verification_rule

rule_origin
evidence
reason
execution_order
status
```

`field_status` is the readable physical/readiness classification defined in [Field Readiness Status](#21-field-readiness-status). It is separate from lifecycle `status` such as `DRAFT` / `FINAL`.

Recommended `row_kind` values:

```text
SOURCE_MAPPING
TARGET_RESOLUTION
```

`TARGET_RESOLUTION` permits target-only fields to be materialized without fake source fields.

Recommended `rule_origin` values:

```text
GENERIC
PROFILE
EXPLICIT
TABLE_INHERITED
```

Evidence examples:

```text
official schema rename
same semantic + verified compatible type
migration contract
logical dependency evidence
platform profile rule
production data check
```

---

# 8. Schema Metadata Contract

Physical schema facts should normally remain in `field_inventory` and be joined into `field_mapping` instead of manually duplicated into mapping rows.

Required source metadata:

```text
ordinal_position
DATA_TYPE
COLUMN_TYPE
canonical_type_family
CHARACTER_MAXIMUM_LENGTH
NUMERIC_PRECISION
NUMERIC_SCALE
IS_NULLABLE
COLUMN_DEFAULT
EXTRA / generated / identity attributes
CHARACTER_SET_NAME
COLLATION_NAME
key_role
index memberships
physical FK metadata when declared
```

Required target metadata when a target field exists:

```text
ordinal_position
DATA_TYPE
COLUMN_TYPE
canonical_type_family
CHARACTER_MAXIMUM_LENGTH
NUMERIC_PRECISION
NUMERIC_SCALE
IS_NULLABLE
COLUMN_DEFAULT
EXTRA / generated / identity attributes
CHARACTER_SET_NAME
COLLATION_NAME
key_role
index memberships
physical FK metadata when declared
```

Recommended canonical type families:

```text
STRING
INTEGER
DECIMAL
FLOAT
BOOLEAN
TEMPORAL
BINARY
JSON
XML
UUID
ENUM
ARRAY
OTHER
```

Keep raw database-specific types as authoritative facts; the canonical family is only for cross-database comparison.

`DATA_TYPE` alone is insufficient. `COLUMN_TYPE` or equivalent full type metadata is required to detect length, precision, scale, and signedness differences.

---

# 9. Key and Identity Contract

Canonical key roles:

```text
PK
COMPOSITE_PK
UNIQUE
INDEX
NONE
```

Use strongest-role display precedence:

```text
COMPOSITE_PK / PK > UNIQUE > INDEX > NONE
```

Preserve complete index definitions in inventory even when the readable mapping exposes only the strongest role.

Typical identity strategies:

```text
ID_MAP
SEMANTIC_LOOKUP
NATURAL_KEY_LOOKUP
GENERATED_ID
PRESERVE_ID_WITH_COLLISION_GATE
NONE
```

Rules:

- never assume source numeric IDs equal target numeric IDs;
- natural keys used for matching must be explicitly proven unique;
- composite keys are verified as tuples;
- auto-increment behavior does not imply ID equivalence;
- PK/UNIQUE constraints must be tested after transformation and ID remapping;
- target collision policy must be explicit.

Gate:

```text
Required identity strategies defined  = 100%
Missing identity mapping domains      = 0
Ambiguous identity matches            = 0
PK collisions                         = 0
Composite PK collisions               = 0
UNIQUE collisions                     = 0
```

---

# 10. Reference / FK Contract

Do not reduce relationships to `FK = YES/NO`.

Canonical reference types:

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
| `POLYMORPHIC` | Entity/domain depends on context/type/discriminator. |
| `EMBEDDED_REFERENCE` | Reference exists inside structured payload such as JSON, URL/query, HTML, ACL, serialized data, etc. |
| `SEMANTIC_REFERENCE` | Stable semantic identity such as type/plugin/template/extension key. |
| `NONE` | No reference semantics. |

Default guidance:

```text
LOOKUP + fixed domain                  → LOGICAL_FK unless physical FK exists
LOOKUP + context-dependent domain      → POLYMORPHIC
STRUCTURED + embedded IDs/references   → EMBEDDED_REFERENCE
REFERENCE_ONLY + stable identity       → SEMANTIC_REFERENCE
declared SQL FK                        → PHYSICAL_FK
```

When a physical FK exists, also preserve:

```text
referenced table
referenced column
constraint name
ON UPDATE
ON DELETE
```

Gate:

```text
Declared physical FKs inventoried      = 100%
Logical references classified          = 100%
Polymorphic references classified      = 100%
Embedded references classified         = 100%
Semantic references classified         = 100%
Missing required reference domains     = 0
Broken required references             = 0
Ambiguous polymorphic references       = 0
```

---

# 11. Structured Data Contract

Typical structured formats:

```text
JSON
JSONB
XML
Joomla Registry / key-value registry
serialized PHP
serialized application payload
CSV / delimited values
ARRAY
ACL payload
HTML
URL
query string
file/media path
field-plugin value
history/version snapshot
custom encoding
```

Every structured field must define:

```text
format
parser
source-shape validation
embedded reference discovery
ID/value/path remapping
version-specific transform
serializer
target-shape validation
reparse validation
failure policy
```

Required execution pattern:

```text
READ
  ↓
PARSE
  ↓
VALIDATE
  ↓
DISCOVER REFERENCES
  ↓
MAP IDs / VALUES / PATHS
  ↓
TRANSFORM
  ↓
SERIALIZE
  ↓
REPARSE
  ↓
VERIFY
```

Forbidden:

```text
blind raw-string ID replacement
silent parse failure
silent structured-field drop
```

Gate:

```text
Structured fields discovered           = 100%
Structured fields with parser/rule      = 100%
Invalid source payloads unresolved      = 0
Unresolved embedded references          = 0
Reparse/serialization failures          = 0
```

---

# 12. Type Compatibility Contract

A `DIRECT` decision is valid only after schema and semantic checks pass.

Check at minimum:

```text
semantic purpose
canonical type family
raw source/target type
length
precision
scale
signedness
NULLability
default behavior
charset/encoding
collation/case sensitivity
generated/identity semantics
constraint compatibility
```

Examples requiring review:

```text
VARCHAR(500) → VARCHAR(255)
INT → UNSIGNED INT
DECIMAL(18,6) → DECIMAL(10,2)
nullable → NOT NULL
case-insensitive → case-sensitive unique target
TEXT → VARCHAR
string enum → numeric status
```

Actual-data evidence may prove a narrowing safe, but it must be measured and recorded.

Example:

```sql
SELECT MAX(CHAR_LENGTH(source_field)) AS max_length
FROM source_table;
```

Gate:

```text
Unsafe DIRECT mappings                 = 0
Unresolved narrowing                   = 0
Unresolved precision/scale loss        = 0
Unresolved signedness mismatch         = 0
Unresolved charset/collation collision = 0
Silent truncation/coercion paths        = 0
```

---

# 13. NULL, Default, Date, Enum, and Sentinel Rules

Explicitly review:

```text
NULL
empty string
0
negative IDs
root/sentinel IDs
boolean representations
enums/states
legacy invalid dates
zero dates
default values
generated defaults
```

Rules:

- target `NOT NULL` requires a valid source/default/generated value;
- invalid or legacy dates require explicit transform rules;
- default substitution must preserve application semantics;
- sentinel values must be interpreted before ID lookup;
- enum/state domain changes require explicit value mapping;
- negative or special IDs must not be treated as ordinary foreign IDs;
- `NULL` and empty string must remain distinct when business semantics require it.

Gate:

```text
Unresolved NULL/default changes        = 0
Unresolved date normalization rules    = 0
Unresolved enum/state mappings         = 0
Unknown sentinel semantics             = 0
```

---

# 14. Source-Only Field Contract

Compute:

```text
SOURCE FIELD UNIVERSE
-
SOURCE FIELDS WITH ACTIVE TARGET REPRESENTATION
=
SOURCE-ONLY FIELD SET
```

Every source-only field must receive one explicit outcome, such as:

```text
TRANSFORM elsewhere
ARCHIVE
IGNORE
REFERENCE_ONLY
REBUILD
```

Required metadata:

```text
field_status = MISSING
final decision
reason
destination/accounting rule
verification rule
```

Forbidden outcome:

```text
silent DROP
```

Gate:

```text
Source-only fields discovered          = 100%
Source-only fields resolved            = 100%
Source-only fields marked MISSING      = 100%
Silent source-only drops               = 0
```

---

# 15. Target-Only Field Contract

Compute:

```text
TARGET FIELD UNIVERSE
-
TARGET FIELDS POPULATED/RESOLVED FROM SOURCE
=
TARGET-ONLY FIELD SET
```

Every required target-only field must receive one explicit resolution:

```text
DEFAULT
GENERATED
TARGET_OWNED
RECREATE
LOOKUP
REBUILD
NOT_REQUIRED_BY_SCOPE
```

`NOT_REQUIRED_BY_SCOPE` requires an explicit reason and target/application evidence.

Target-only rows must use:

```text
field_status = MISSING
```

because one physical side of the source/target pair is absent. `MISSING` does not automatically mean unresolved or invalid; the mapping decision still determines whether the row is correctly resolved.

Gate:

```text
Target-only fields discovered          = 100%
Target-only fields classified          = 100%
Target-only fields marked MISSING      = 100%
Required target fields resolved        = 100%
Unresolved required target fields      = 0
Unknown target strategy                = 0
```

Source coverage alone is never sufficient for PASS.

---

# 16. Per-Table Mapping Section

Repeat this section for every mapped source table or logical table-mapping group.

## `{{SOURCE_TABLE}}` → `{{TARGET_TABLE_OR_DESTINATION}}`

**Table mapping:** `{{TABLE_MAPPING_TYPE}}`  
**Group:** `{{GROUP_ID}}`  
**Source fields:** `{{SOURCE_TABLE_FIELD_COUNT}}`  
**Target fields:** `{{TARGET_TABLE_FIELD_COUNT}}`

Recommended review table:

| # | Source | S.Type | S.Null | S.Key | Target | T.Type | T.Null | T.Key | Field Status | Card. | M | Ref | Domain / Parser | Rule | Verify |
|---:|---|---|:---:|---|---|---|:---:|---|---|---|:---:|---|---|---|---|
| 1 | `{{SOURCE_FIELD}}` | `{{SOURCE_COLUMN_TYPE}}` | `{{S_NULL}}` | `{{S_KEY}}` | `{{TARGET_FIELD}}` | `{{TARGET_COLUMN_TYPE}}` | `{{T_NULL}}` | `{{T_KEY}}` | `{{FIELD_STATUS}}` | `{{CARDINALITY}}` | `{{MAP}}` | `{{REFERENCE_TYPE}}` | `{{DOMAIN_OR_PARSER}}` | `{{RULE}}` | `{{VERIFY}}` |

Additional machine-readable attributes may remain in the structured mapping dataset/database even if omitted from the readable Markdown table:

```text
mapping_group_key
identity_strategy
source_default
target_default
charset/collation
parser_rule
rule_origin
evidence
reason
execution_order
field_status
status
```

Per-table gate:

```text
Distinct source fields accounted       = 100%
Field status classified                = 100%
Invalid field status                   = 0
Source-only fields resolved            = 100%
Required target fields resolved        = 100%
Unknown/ambiguous field decisions      = 0
Unsafe DIRECT                          = 0
Missing lookup/reference domain        = 0
Missing structured rule                = 0
```

---

# 17. Database Materialization Contract

Recommended logical separation:

```text
migration_inventory.field_inventory
    = physical schema facts

migration_mapping.field_mapping
    = static field-level migration decisions

migration_mapping.value_mapping
    = runtime/design-time ID/value translations

migration_inventory.table_dependency
    = dependency graph
```

No additional contract table is required when the existing model preserves all required facts.

Recommended field-mapping attributes:

```text
migration_run_id
row_kind
source_version
source_table
source_field
target_version
target_table
target_field
mapping_group_key
mapping_cardinality
mapping_type
field_status
identity_strategy
reference_type
reference_domain
parser_rule
transform_rule
verification_rule
rule_origin
evidence
reason
execution_order
status
```

Recommended source mapping identity:

```text
(source_version, source_table, source_field, mapping_group_key, target_table, target_field)
```

Do not enforce a uniqueness model that prevents legitimate one-to-many mappings.

For source coverage, count distinct source field keys rather than raw mapping rows.

Enriched mapping view should expose:

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

field_status
mapping_cardinality
mapping_type
identity_strategy
reference_type
reference_domain
parser_rule
transform_rule
verification_rule
rule_origin
evidence
reason
```

---

# 18. QA Queries

The examples below assume MySQL/MariaDB and an inventory/mapping database with equivalent logical columns.

## 18.1 Distinct source field coverage

```sql
SELECT
    COUNT(DISTINCT CONCAT(source_table, '.', source_field)) AS covered_source_fields
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND row_kind = 'SOURCE_MAPPING'
  AND source_version = :source_version
  AND target_version = :target_version;
```

Expected:

```text
covered_source_fields = {{SOURCE_FIELD_COUNT}}
```

## 18.2 Missing source mappings

```sql
SELECT
    sf.table_name,
    sf.column_name
FROM migration_inventory.field_inventory AS sf
LEFT JOIN migration_mapping.field_mapping AS fm
  ON fm.migration_run_id = sf.migration_run_id
 AND fm.row_kind = 'SOURCE_MAPPING'
 AND fm.source_table = sf.table_name
 AND fm.source_field = sf.column_name
WHERE sf.migration_run_id = :migration_run_id
  AND sf.database_side = 'SOURCE'
  AND fm.source_field IS NULL
ORDER BY sf.table_name, sf.ordinal_position;
```

Expected result: **0 rows**.

## 18.3 Invalid final decisions

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

## 18.4 Lookup/reference rows missing domain

```sql
SELECT
    source_table,
    source_field,
    reference_type,
    reference_domain
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND mapping_type = 'LOOKUP'
  AND NULLIF(TRIM(reference_domain), '') IS NULL;
```

Expected result: **0 rows**.

## 18.5 Structured mappings missing parser/rule

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

## 18.6 Target-resolution coverage

```sql
SELECT
    COUNT(DISTINCT CONCAT(target_table, '.', target_field)) AS resolved_target_fields
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND target_table IS NOT NULL
  AND target_field IS NOT NULL
  AND status = 'FINAL';
```

Compare the result against the set of required target fields from `field_inventory`.

Expected:

```text
unresolved_required_target_fields = 0
```

## 18.7 Physical FK discovery

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

A missing physical FK does not imply a missing logical dependency.

## 18.8 Key-role discovery

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

## 18.9 Field readiness status QA

```sql
SELECT
    field_status,
    COUNT(*) AS mapping_rows
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
GROUP BY field_status
ORDER BY field_status;
```

Allowed values:

```text
READY
SKIP
MISSING
```

Invalid/null status query:

```sql
SELECT *
FROM migration_mapping.field_mapping
WHERE migration_run_id = :migration_run_id
  AND (
      field_status IS NULL
      OR field_status NOT IN ('READY', 'SKIP', 'MISSING')
  );
```

Expected result: **0 rows**.

Consistency checks:

```text
READY   + missing source/target physical side = INVALID
MISSING + both physical sides present         = INVALID
SKIP    + missing reason                      = INVALID
both source and target absent                 = INVALID
```

---

# 19. 100% Field Mapping Checklist

## A. Naming and baseline

- [ ] Scope name is explicit
- [ ] Filename follows `<scope>-field-mapping-migration.md`
- [ ] Source system/version explicit
- [ ] Target system/version explicit
- [ ] Source schema authority explicit
- [ ] Target schema authority explicit
- [ ] Table mapping PASS

## B. Inventory prerequisite

- [ ] Source table inventory = 100%
- [ ] Target table inventory = 100%
- [ ] Source field inventory = 100%
- [ ] Target field inventory = 100%
- [ ] Actual production schema reconciled before production execution
- [ ] Unknown schema objects = 0

## C. Source field coverage

- [ ] Source field universe generated
- [ ] Every source physical field has >= 1 final mapping/accounting decision
- [ ] Distinct source field coverage = 100%
- [ ] Unmapped source fields = 0
- [ ] Silent source drops = 0
- [ ] Source-only fields resolved = 100%

## D. Target resolution

- [ ] Target field universe generated
- [ ] Target anti-join executed
- [ ] Target-only fields classified = 100%
- [ ] Required target fields resolved = 100%
- [ ] Unresolved required target fields = 0
- [ ] Unknown target strategy = 0

## E. Mapping decision quality

- [ ] Allowed final decisions only
- [ ] UNKNOWN = 0
- [ ] PENDING = 0
- [ ] REVIEW = 0
- [ ] OPTIONAL = 0
- [ ] UNMAPPED = 0
- [ ] AMBIGUOUS = 0
- [ ] Rule origin recorded where required
- [ ] Evidence/reason recorded where required

## F. Cardinality

- [ ] ONE_TO_ONE supported
- [ ] ONE_TO_MANY supported
- [ ] MANY_TO_ONE supported
- [ ] MANY_TO_MANY supported
- [ ] ONE_TO_NONE supported
- [ ] NONE_TO_ONE supported
- [ ] Mapping group keys used for grouped transforms
- [ ] Invalid mapping groups = 0
- [ ] Orphan group members = 0

## G. Type/schema compatibility

- [ ] Source raw/full data type available
- [ ] Target raw/full data type available for mapped target fields
- [ ] Length checked
- [ ] Precision/scale checked
- [ ] Signed/unsigned checked
- [ ] NULLability checked
- [ ] Defaults checked
- [ ] Generated/identity semantics checked
- [ ] Charset/encoding checked
- [ ] Collation/case changes checked
- [ ] Silent truncation/coercion forbidden
- [ ] Unsafe DIRECT = 0

## H. Keys and identity

- [ ] PK classified
- [ ] Composite PK classified
- [ ] UNIQUE classified
- [ ] Index memberships inventoried
- [ ] Identity strategy explicit
- [ ] Numeric ID equality never assumed without proof
- [ ] Natural-key uniqueness proven where used
- [ ] PK collisions = 0
- [ ] Composite PK collisions = 0
- [ ] UNIQUE collisions = 0
- [ ] Ambiguous identities = 0

## I. Reference coverage

- [ ] Physical FKs inventoried
- [ ] Logical FKs classified
- [ ] Polymorphic references classified
- [ ] Embedded references classified
- [ ] Semantic references classified
- [ ] Required reference domains present
- [ ] Missing reference domains = 0
- [ ] Broken required references = 0
- [ ] Ambiguous polymorphic references = 0

## J. Structured data

- [ ] Structured fields discovered = 100%
- [ ] Parser/serializer rule defined for each structured mapping
- [ ] Embedded references explicitly handled
- [ ] Invalid payloads unresolved = 0
- [ ] Unresolved embedded references = 0
- [ ] Reparse failures = 0
- [ ] Raw-string ID replacement forbidden

## K. Special values and constraints

- [ ] NULL semantics checked
- [ ] Empty-string semantics checked
- [ ] Zero/sentinel semantics checked
- [ ] Negative-ID semantics checked where applicable
- [ ] Legacy/invalid dates handled
- [ ] Enum/state mappings resolved
- [ ] Default semantics checked
- [ ] Generated values checked
- [ ] NOT NULL violations = 0
- [ ] CHECK/domain violations = 0

## L. Database materialization

- [ ] `field_inventory` remains physical schema source of truth
- [ ] `field_mapping` remains static decision source of truth
- [ ] `value_mapping` remains runtime/design-time ID/value store
- [ ] `row_kind` available
- [ ] `field_status` available with READY / SKIP / MISSING only
- [ ] mapping cardinality available
- [ ] mapping group available
- [ ] rule origin/evidence available
- [ ] seed/materialization process idempotent
- [ ] legitimate multi-row mapping groups are not rejected as duplicates
- [ ] enriched source→target mapping view available

## M. Verification readiness

- [ ] DIRECT verification defined
- [ ] TRANSFORM verification defined
- [ ] LOOKUP orphan/ambiguity verification defined
- [ ] STRUCTURED parse/remap/reparse verification defined
- [ ] GENERATED/REBUILD integrity verification defined
- [ ] ARCHIVE accounting verification defined
- [ ] IGNORE reason/accounting verification defined
- [ ] DEFAULT/TARGET_OWNED/RECREATE verification defined
- [ ] Unverifiable final mappings = 0

## N. Reuse and operational safety

- [ ] Generic rules separated from application/platform profile
- [ ] Profile rules versioned
- [ ] Explicit overrides versioned
- [ ] Mapping decisions version-scoped
- [ ] Mapping generation deterministic
- [ ] Production source remains immutable
- [ ] Errors are never auto-converted to IGNORE
- [ ] Rerun does not create conflicting mapping actions/value maps

## O. Field readiness status

- [ ] Every mapping row has exactly one `field_status`
- [ ] Allowed values are only READY / SKIP / MISSING
- [ ] READY rows have both physical sides present
- [ ] READY rows have executable/final mapping rules
- [ ] SKIP rows have an explicit skip reason
- [ ] MISSING rows have exactly one physical side absent
- [ ] MISSING rows have an explicit mapping/accounting outcome
- [ ] MISSING is not treated automatically as a migration error
- [ ] Invalid/null field status rows = 0

---

# 20. Final Field Mapping Gate

A document may claim definition-level PASS only when all declared source and target schema fields are accounted for by this contract.

```text
NAMING
--------------------------------------------------
Scoped output filename                     = YES
Filename pattern                           = <scope>-field-mapping-migration.md

BASELINE / INVENTORY
--------------------------------------------------
Source tables inventoried                  = 100%
Source fields inventoried                  = 100%
Target tables inventoried                  = 100%
Target fields inventoried                  = 100%
Unknown schema objects                     = 0
Unclassified schema deviations             = 0

SOURCE COVERAGE
--------------------------------------------------
Distinct source fields accounted           = 100%
Unmapped source fields                     = 0
Silent source-field drops                  = 0
Source-only fields resolved                = 100%

TARGET COVERAGE
--------------------------------------------------
Target anti-join processed                 = 100%
Target-only fields classified              = 100%
Required target fields resolved            = 100%
Unresolved required target fields          = 0
Unknown target strategy                    = 0

FIELD STATUS
--------------------------------------------------
Field status classified                    = 100%
Invalid/null field status                  = 0
READY with missing physical side           = 0
MISSING with both physical sides present   = 0
SKIP without explicit reason               = 0

MAPPING QUALITY
--------------------------------------------------
Final mapping decisions                    = 100%
Invalid/unknown/pending decisions           = 0
Unknown cardinality                        = 0
Invalid mapping groups                     = 0
Missing required rule evidence             = 0

SCHEMA COMPATIBILITY
--------------------------------------------------
Required field metadata resolved           = 100%
Unsafe DIRECT                              = 0
Unresolved type conversions                = 0
Unresolved narrowing/truncation            = 0
Unresolved NULL/default changes            = 0
Unresolved collation collisions            = 0

IDENTITY / CONSTRAINTS
--------------------------------------------------
Required identity strategies defined       = 100%
Ambiguous identity matches                 = 0
PK collisions                              = 0
Composite PK collisions                    = 0
UNIQUE collisions                          = 0
Constraint violations                      = 0

REFERENCES / STRUCTURED
--------------------------------------------------
Required reference classification          = 100%
Missing required reference domains         = 0
Broken required references                 = 0
Structured fields classified               = 100%
Structured fields with parser/rule          = 100%
Unresolved embedded references             = 0

VERIFICATION / MATERIALIZATION
--------------------------------------------------
Mappings with verification rule            = 100%
Unverifiable final mappings                = 0
Missing materialized source coverage       = 0
Conflicting runtime/design value maps       = 0

==================================================
FIELD MAPPING CONTRACT                      = PASS
==================================================
```

Required definition-level success statement:

> **100% of source physical fields in the declared migration scope are explicitly accounted for, and 100% of required target physical fields have an explicit resolution. Every mapping row is also classified as READY, SKIP, or MISSING; no source field is silently dropped and no required target field remains unresolved.**

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

---

# 21. Field Readiness Status

`field_status` is a compact human-readable classification that answers whether a source/target field pair is immediately mappable, intentionally skipped, or physically missing on one side.

Allowed values are exactly:

| Field Status | Meaning | Required rule |
|---|---|---|
| `READY` | Source and target physical fields both exist and the mapping rule is complete enough to execute. | Mapping decision/rules/verification must be final and valid. |
| `SKIP` | The migration intentionally performs no active mapping/copy for this field. | Explicit reason is mandatory; normally paired with `IGNORE` or an explicitly not-required target resolution. |
| `MISSING` | Exactly one physical side does not exist: source-only or target-only field. | Must still have an explicit mapping/accounting outcome and reason. |

### Deterministic precedence

Apply these rules in order:

```text
1. Exactly one physical side is absent
   → MISSING

2. Both physical sides exist, but the approved rule intentionally skips active mapping/copy
   → SKIP

3. Both physical sides exist and mapping + verification are complete
   → READY

4. Anything else
   → CONTRACT ERROR (do not invent another field_status)
```

Important semantics:

```text
MISSING != automatically failed
MISSING != automatically skipped
SKIP    != silently dropped
READY   != DIRECT only
```

Examples:

| Source | Target | Field Status | Mapping Type | Meaning |
|---|---|---|---|---|
| `title` | `title` | `READY` | `DIRECT` | Both fields exist and can be copied after compatibility verification. |
| `asset_id` | `asset_id` | `READY` | `LOOKUP` | Both fields exist but identity must be remapped. |
| `legacy_token` | `legacy_token` | `SKIP` | `IGNORE` | Both fields may exist, but migration intentionally excludes the value. |
| `otpKey` | `—` | `MISSING` | `ARCHIVE` | Source-only field; no active target field exists, but source value is accounted/archived. |
| `—` | `created_at` | `MISSING` | `DEFAULT` | Target-only field; source field is absent and target default resolves it. |
| `—` | `workflow_id` | `MISSING` | `GENERATED` | Target-only field generated from target-version semantics. |

### Required consistency rules

```text
READY
- source physical field exists
- target physical field exists
- lifecycle status is final/approved for execution
- required transform/reference/parser/verification rules exist

SKIP
- skip is intentional
- reason is explicit
- accounting behavior is explicit
- silent data loss is forbidden

MISSING
- exactly one physical side is absent
- reason is explicit
- source-only or target-only resolution is explicit
- a valid MISSING row may still satisfy definition-level PASS
```

`field_status` must not replace:

```text
mapping_type
row_kind
mapping_cardinality
lifecycle status (DRAFT / FINAL)
coverage_status
```

It is an additional classification used for review, QA, database materialization, and generated documents such as Joomla core field mapping.
