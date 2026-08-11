# {{SCOPE_NAME}} Database Migration Contract — {{SOURCE_SYSTEM}} {{SOURCE_VERSION}} → {{TARGET_SYSTEM}} {{TARGET_VERSION}}

## Purpose and Guarantee

> **Inventory = 100%**  
> **Source decisions = 100% required**  
> **Target resolution = 100% required**  
> **Production execution is blocked until every gate in this document passes**

This template defines the migration contract that connects the source and target schema inventories/manifests for `{{SCOPE_NAME}}`.

Recommended companion documents:

- `{{SOURCE_GROUP_MANIFEST}}`
- `{{SOURCE_FIELD_MANIFEST}}`
- `{{TARGET_GROUP_MANIFEST}}`
- `{{TARGET_FIELD_MANIFEST}}`
- `{{TABLE_MAPPING_DOCUMENT}}`
- `{{FIELD_MAPPING_DOCUMENT}}`

The contract does **not** define 100% migration as "copy every source row into the target". Runtime, generated, security-token, obsolete, target-owned, or intentionally archived data may require a different final outcome.

The guarantee is:

> **100% of database objects, fields, and records in the declared migration scope are accounted for by an explicit migration decision and verified against the target contract.**

No source table, source field, source record, required target field, ID/reference, structured value, or dependency may disappear silently.

---

## 1. Fixed Baseline

| Item | Baseline |
|---|---|
| Migration scope | `{{SCOPE_NAME}}` |
| Source system | `{{SOURCE_SYSTEM}}` |
| Source version | `{{SOURCE_VERSION}}` |
| Source tables | `{{SOURCE_TABLE_COUNT}}` |
| Source physical fields | `{{SOURCE_FIELD_COUNT}}` |
| Target system | `{{TARGET_SYSTEM}}` |
| Target version | `{{TARGET_VERSION}}` |
| Target tables | `{{TARGET_TABLE_COUNT}}` |
| Target physical fields | `{{TARGET_FIELD_COUNT}}` |
| Source schema authority | `{{SOURCE_SCHEMA_AUTHORITY}}` |
| Target schema authority | `{{TARGET_SCHEMA_AUTHORITY}}` |

Before production execution, reconcile the actual source and target databases with the physical schema authority (for MySQL, normally `information_schema.TABLES` and `information_schema.COLUMNS`).

Production baseline deviations must be explicit:

```text
Unexpected source tables          = 0
Unexpected target tables          = 0
Unexplained source fields         = 0
Unexplained target fields         = 0
Duplicate inventory objects       = 0
```

---

## 2. Allowed Final Decisions

Every source object must resolve to exactly one final outcome.

| Decision | Meaning |
|---|---|
| `DIRECT` | Copy a compatible scalar value after target validation. |
| `TRANSFORM` | Convert a source value/record into the target representation. |
| `LOOKUP` | Resolve a target value through an identity, ID, or value map. |
| `STRUCTURED` | Parse structured content, remap embedded references, validate, and serialize. |
| `DEFAULT` | Use the target DDL/application default. |
| `GENERATED` | Generate target data from migrated entities or target state. |
| `REBUILD` | Do not copy generated source data; rebuild it in the target. |
| `REFERENCE_ONLY` | Use source data only to identify/reconcile target-owned records. |
| `ARCHIVE` | Preserve source data outside active target data. |
| `IGNORE` | Intentionally do not migrate runtime/security/install-state data; reason is mandatory. |
| `TARGET_OWNED` | Preserve the target installation/default value or record. |
| `RECREATE` | Reconfigure/recreate target state using target semantics/API. |

The following are **not valid final decisions**:

```text
UNKNOWN
PENDING
REVIEW
OPTIONAL
SELECTIVE
A / B
UNMAPPED
AMBIGUOUS
```

Any occurrence blocks migration.

---

## 3. Global Mapping Precedence

Every source field must receive one deterministic decision. The first matching rule wins.

```text
1. Source table = IGNORE          → every field = IGNORE
2. Source table = ARCHIVE         → every field = ARCHIVE
3. Source table = REBUILD         → every field = REBUILD
4. Explicit field rule exists     → use explicit field rule
5. Reference field                → LOOKUP
6. Structured field               → STRUCTURED
7. Compatible same-purpose target → DIRECT + VALUE_NORMALIZE
8. Source-only field              → explicit ARCHIVE / IGNORE / TRANSFORM rule
9. No rule matched                → CONTRACT ERROR; migration blocked
```

`DIRECT` never means blind copy. It must validate type, nullability, length/precision, charset/collation where relevant, allowed values, and application semantics.

### Value normalization

`VALUE_NORMALIZE` must define applicable rules such as:

- invalid/legacy date normalization;
- `NULL` vs empty-string semantics;
- charset/encoding preservation;
- target length/precision/scale validation;
- enum/state translation;
- default handling;
- no silent truncation or coercion.

---

## 4. Source Table Mapping Contract

Expected source table decisions:

```text
Official/declared source tables   = {{SOURCE_TABLE_COUNT}}
Table mapping decisions           = {{SOURCE_TABLE_COUNT}}
Missing source tables             = 0
Duplicate source mappings         = 0
Ambiguous source mappings         = 0
```

Use the following canonical table format in `{{TABLE_MAPPING_DOCUMENT}}`:

| # | Group | Source Table | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces Map | Consumes Maps | Execution Order | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `{{GROUP}}` | `{{SOURCE_TABLE}}` | `{{TARGET_TABLE_OR_DESTINATION}}` | `{{FINAL_DECISION}}` | `{{ID_STRATEGY}}` | `{{IDENTITY_KEY}}` | `{{DEPENDENCIES}}` | `{{MAP_PRODUCED}}` | `{{MAPS_CONSUMED}}` | `{{ORDER}}` | `{{VERIFY_RULE}}` | `{{REASON}}` |

Hard rules:

- every source table appears exactly once;
- no wildcard table groups in the final mapping;
- renamed/restructured tables are explicit;
- many-to-one and one-to-many behavior is explicit;
- ignored/archived tables still count as accounted;
- non-source target tables are classified separately.

---

## 5. Target-Only / Target-Generated Structures

Every target table/structure without a direct source table must have one explicit resolution.

| Target Table / Structure | Final Resolution | Dependency / Rule | Verification |
|---|---|---|---|
| `{{TARGET_ONLY_TABLE}}` | `TARGET_OWNED / GENERATED / RECREATE` | `{{RULE}}` | `{{VERIFY_RULE}}` |

Gate:

```text
Target-only structures discovered = 100%
Target-only structures classified = 100%
Unclassified target structures    = 0
```

---

## 6. Field Mapping Contract

Every physical source field must have exactly one final mapping decision.

Canonical format in `{{FIELD_MAPPING_DOCUMENT}}`:

| Source Table | Source Field | Target Table | Target Field | Mapping Type | Rule / Expression | Lookup Domain | Verification |
|---|---|---|---|---|---|---|---|
| `{{SOURCE_TABLE}}` | `{{SOURCE_FIELD}}` | `{{TARGET_TABLE}}` | `{{TARGET_FIELD}}` | `{{FIELD_DECISION}}` | `{{RULE}}` | `{{LOOKUP_DOMAIN}}` | `{{VERIFY_RULE}}` |

Source coverage gate:

```text
Actual source fields discovered    = {{ACTUAL_SOURCE_FIELD_COUNT}}
Source field mapping decisions     = {{ACTUAL_SOURCE_FIELD_COUNT}}
Missing field decisions            = 0
Duplicate field decisions          = 0
Unmapped source fields             = 0
Ambiguous source fields            = 0
```

Required target fields must also resolve to one of:

```text
SOURCE_DIRECT
SOURCE_TRANSFORM
LOOKUP
DEFAULT
GENERATED
TARGET_OWNED
REBUILD
NOT_REQUIRED
```

Target gate:

```text
Required target fields resolved    = 100%
Unresolved required target fields  = 0
```

---

## 7. ID / Identity Mapping Contract

Do not assume source and target numeric IDs are equal.

Recommended runtime/design-time value mapping store:

```text
entity_domain
source_table
source_value
source_identity

target_table
target_value
target_identity

migration_run_id
mapping_status
```

Typical strategies:

```text
ID_MAP
SEMANTIC_LOOKUP
GENERATED
NONE
```

Gate:

```text
Required ID/value mappings resolved = 100%
Missing required mappings           = 0
Duplicate target identity matches   = 0
Ambiguous identity matches          = 0
```

---

## 8. Structured Data Contract

For every structured field, define:

| Item | Required |
|---|---|
| Format | JSON / registry / serialized value / URL / path / query / custom |
| Parser | exact parser/decoder |
| Embedded references | IDs, aliases, URLs, paths, keys |
| Transform rule | deterministic transformation |
| Validation | parse → transform → serialize → reparse |
| Failure policy | block / archive with approved rule |

Gate:

```text
Structured fields classified       = 100%
Structured rules defined           = 100%
Invalid structured values          = 0
Unresolved embedded references     = 0
```

---

## 9. Dependency and Execution Contract

Dependencies must include both physical and logical relationships.

Allowed dependency classifications may include:

```text
PHYSICAL_FK
LOGICAL_REFERENCE
LOOKUP_REFERENCE
STRUCTURED_REFERENCE
FILE_REFERENCE
EXTENSION_REFERENCE
APPLICATION_ORDER
```

Every dependency must define:

- producer/source entity;
- consumer entity;
- mapping domain if applicable;
- required execution order;
- orphan validation;
- cycle/reconciliation strategy where applicable.

Gate:

```text
Dependencies inventoried          = 100%
Dependencies resolved             = 100%
Unresolved hard cycles            = 0
Unresolved references             = 0
Forbidden orphans                 = 0
```

---

## 10. Record Accounting Contract

Every production source row must end in exactly one accounting bucket:

```text
source_rows
= direct_rows
+ transformed_rows
+ rebuilt_source_rows
+ reference_only_rows
+ archived_rows
+ ignored_rows
+ error_rows
```

Final PASS requires:

```text
error_rows       = 0
unaccounted_rows = 0
```

A non-copy outcome is valid only when its decision and reason are explicit.

---

## 11. Verification Contract

Verification must go beyond row counts.

Required checks:

```text
Missing expected records          = 0
Unexpected target records         = 0
Duplicate source→target mappings  = 0
Field mismatches                  = 0
Broken relationships              = 0
Invalid structured values         = 0
Unresolved embedded references    = 0
Unexplained archive/ignore rows   = 0
```

Every expected source identity must resolve to the expected target identity or an explicitly approved non-active outcome.

---

## 12. Production Reconciliation

Before execution, compare the real databases with the declared manifests.

Required checks:

```text
Actual source tables inventoried  = 100%
Actual source fields inventoried  = 100%
Actual target tables inventoried  = 100%
Actual target fields inventoried  = 100%

Unexpected source objects         = 0
Unexpected target objects         = 0
Unexplained schema deviations     = 0
```

If production differs from the declared baseline, regenerate/review the inventories and mapping contract before execution.

---

## 13. Re-run, Idempotency, and Recovery

The migration plan must define:

- deterministic source identity;
- deterministic target lookup;
- idempotent insert/update behavior;
- duplicate prevention;
- resume checkpoints;
- retry policy;
- transaction boundaries;
- failure isolation;
- backup/restore or rollback strategy;
- immutable audit evidence for each run.

Gate:

```text
Safe rerun behavior documented    = YES
Duplicate-on-rerun risk           = 0 unresolved
Recovery procedure documented     = YES
Backup/restore validated          = YES
```

---

## 14. 100% Contract Checklist

### Inventory

- [ ] Source tables inventoried = 100%
- [ ] Source fields inventoried = 100%
- [ ] Target tables inventoried = 100%
- [ ] Target fields inventoried = 100%
- [ ] Production schema reconciled

### Table Mapping

- [ ] Every source table has exactly one final decision
- [ ] Every non-ignored source table has an explicit destination
- [ ] Target-only structures are classified
- [ ] Missing source table mappings = 0
- [ ] Duplicate source table mappings = 0
- [ ] Ambiguous table mappings = 0

### Field Mapping

- [ ] Every source field has exactly one final decision
- [ ] Every required target field has a population strategy
- [ ] Missing source field mappings = 0
- [ ] Duplicate source field mappings = 0
- [ ] Unresolved required target fields = 0

### ID / Value / Structured Data

- [ ] Required ID/value maps = 100%
- [ ] Structured fields classified = 100%
- [ ] Structured transform rules = 100%
- [ ] Unresolved embedded references = 0

### Dependencies

- [ ] Required dependencies inventoried = 100%
- [ ] Dependency execution order resolved
- [ ] Forbidden orphans = 0
- [ ] Unresolved hard cycles = 0

### Data Accounting and Verification

- [ ] Source records accounted = 100%
- [ ] Unaccounted records = 0
- [ ] Missing expected records = 0
- [ ] Unexpected target records = 0
- [ ] Duplicate mappings = 0
- [ ] Field mismatches = 0
- [ ] Broken relationships = 0
- [ ] Invalid structured values = 0

### Decision Quality

- [ ] `UNKNOWN = 0`
- [ ] `PENDING = 0`
- [ ] `REVIEW = 0`
- [ ] `OPTIONAL = 0`
- [ ] `UNMAPPED = 0`
- [ ] `AMBIGUOUS = 0`
- [ ] Slash decisions `A / B = 0`

### Recovery

- [ ] Safe rerun behavior documented
- [ ] Retry/resume behavior documented
- [ ] Backup/restore or rollback documented
- [ ] Audit trail documented

---

## 15. Final Migration Gate

```text
SOURCE INVENTORY
Source tables accounted               = 100%
Source fields accounted               = 100%
Production source inventory           = 100%

TARGET INVENTORY
Target tables accounted               = 100%
Target fields accounted               = 100%
Production target inventory           = 100%

TABLE MAPPING
Source table decisions                = 100%
Unmapped source tables                = 0
Ambiguous table decisions             = 0

FIELD MAPPING
Source field decisions                = 100%
Unmapped source fields                = 0
Ambiguous source fields               = 0

TARGET RESOLUTION
Required target fields resolved       = 100%
Unresolved required fields            = 0

ID / VALUE / STRUCTURED
Required ID/value mappings            = 100%
Structured-field rules                = 100%
Unresolved embedded references        = 0

DECISION QUALITY
UNKNOWN                               = 0
PENDING                               = 0
REVIEW                                = 0
UNMAPPED                              = 0
AMBIGUOUS                             = 0

DATA ACCOUNTING
Source records accounted              = 100%
Unaccounted source records            = 0

VERIFICATION
Missing records                       = 0
Unexpected records                    = 0
Duplicate mappings                    = 0
Field mismatches                      = 0
Broken relationships                  = 0
Invalid structured values             = 0

RECOVERY
Rerun strategy                        = PASS
Backup/restore or rollback            = PASS

============================================
{{SCOPE_NAME}} MIGRATION CONTRACT           = PASS
============================================
```

> This contract is reusable for core migrations, extension migrations, component migrations, or other database-to-database/version-to-version migrations. Replace every `{{PLACEHOLDER}}`, materialize all mapping rows, and run the production reconciliation gates before claiming production PASS.
