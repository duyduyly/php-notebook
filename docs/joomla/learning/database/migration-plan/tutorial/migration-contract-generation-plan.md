# Migration Contract Generation Plan

## Purpose

> **Goal: generate a migration contract that accounts for 100% of in-scope source tables, source fields, required target structures/fields, mapping decisions, references, structured values, dependencies, and source records before production migration is allowed to PASS.**

This plan is reusable for Joomla core, third-party extensions, custom extensions, or other database/version migrations.

Use the companion template:

- [`../templates/database-migration-contract-template.md`](../templates/database-migration-contract-template.md)

Required prerequisite plans:

- [`migration-group-generation-plan.md`](./migration-group-generation-plan.md)
- [`migration-field-generation-plan.md`](./migration-field-generation-plan.md)

The contract is the layer that connects inventory to executable migration logic:

```text
SOURCE GROUP PASS
        +
SOURCE FIELD PASS
        +
TARGET GROUP PASS
        +
TARGET FIELD PASS
        ↓
TABLE MAPPING
        ↓
FIELD MAPPING
        ↓
ID / VALUE / STRUCTURED / DEPENDENCY RULES
        ↓
RECORD ACCOUNTING
        ↓
VERIFICATION + RECOVERY
        ↓
MIGRATION CONTRACT PASS
```

The 100% guarantee does **not** mean every source row is copied 1:1. It means:

> **Every in-scope source object and record has one explicit, deterministic, verifiable outcome, and every required target object has one explicit resolution. Nothing may disappear silently.**

Valid non-copy outcomes include `REBUILD`, `REFERENCE_ONLY`, `ARCHIVE`, `IGNORE`, `TARGET_OWNED`, `GENERATED`, and `RECREATE` when the reason and verification rule are explicit.

---

# 1. Require All Inventory Gates to PASS

Do not build the final migration contract from guessed table/field sets.

Required input artifacts:

| Artifact | Required status |
|---|---|
| Source migration-group manifest | `PASS` |
| Source field inventory | `PASS` |
| Target migration-group manifest | `PASS` |
| Target field inventory | `PASS` |
| Production source reconciliation | `PASS` or explicitly scheduled as a blocking pre-execution gate |
| Production target reconciliation | `PASS` or explicitly scheduled as a blocking pre-execution gate |

### Hard prerequisite gate

```text
Source tables classified          = 100%
Source physical fields inventoried = 100%
Target tables classified          = 100%
Target physical fields inventoried = 100%

Missing source tables             = 0
Missing source fields             = 0
Missing target tables             = 0
Missing target fields             = 0
Duplicate inventory objects       = 0
Unknown ownership                 = 0
```

If any inventory gate fails, the contract cannot claim 100%.

---

# 2. Freeze the Effective Migration Baseline

The contract denominator must come from the effective production-aware inventory, not a hard-coded documentation number.

Record:

```text
SOURCE_TABLE_COUNT
SOURCE_FIELD_COUNT
TARGET_TABLE_COUNT
TARGET_FIELD_COUNT
```

These counts must be derived from the reconciled migration scope.

Example:

```text
Official source fields     = 711
Production custom fields   = 3
Effective source fields    = 714

Contract source denominator = 714
```

The contract may not use 711/711 to claim 100% when 714 actual in-scope fields exist.

### Baseline gate

```text
Effective source tables fixed       = YES
Effective source fields fixed       = YES
Effective target tables fixed       = YES
Effective target fields fixed       = YES
Unexplained production deviations   = 0
```

---

# 3. Define Canonical Final Decisions

Use one controlled vocabulary across table mapping, field mapping, execution, and verification.

Recommended canonical decisions:

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
RECREATE
```

These are invalid final states:

```text
UNKNOWN
PENDING
REVIEW
OPTIONAL
SELECTIVE
UNMAPPED
AMBIGUOUS
A / B
TODO
TBD
```

### Decision-quality gate

```text
UNKNOWN       = 0
PENDING       = 0
REVIEW        = 0
OPTIONAL      = 0
UNMAPPED      = 0
AMBIGUOUS     = 0
Slash choices = 0
```

Any unresolved final state blocks execution.

---

# 4. Generate the Table Mapping Contract

Create exactly one final mapping row for every effective source table.

Recommended table mapping matrix:

| # | Group | Source Table | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces Map | Consumes Maps | Execution Order | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `Gx` | `<source_table>` | `<target_table / archive / none>` | `<decision>` | `<strategy>` | `<identity>` | `<dependencies>` | `<domain>` | `<domains>` | `<order>` | `<verify>` | `<reason>` |

Required rules:

1. Every source table appears exactly once.
2. Every source table has one final decision.
3. Every non-ignored/non-archived table has an explicit target/destination or rebuild/reference rule.
4. Renamed/restructured tables are explicit.
5. Many-to-one mappings are explicit.
6. One-to-many mappings are explicit.
7. Runtime/generated/security/history tables still appear.
8. No wildcard row substitutes for physical tables.
9. Each row has an ID/identity strategy when applicable.
10. Each row has a verification strategy.

### Table mapping hard invariant

```text
table_mapping_rows
=
COUNT(DISTINCT source_table)
=
effective_source_table_count
```

### Table mapping gate

```text
Source table decisions           = 100%
Missing source table mappings    = 0
Duplicate source table mappings  = 0
Ambiguous source table mappings  = 0
Unverifiable table mappings      = 0
```

---

# 5. Resolve Target-Only / Target-Generated Tables

Compute target structures that are not direct destinations of source tables.

Conceptually:

```text
TARGET_ONLY
=
required target structures
-
resolved source destinations
```

Every target-only structure must receive one explicit resolution:

```text
TARGET_OWNED
GENERATED
RECREATE
DEFAULT
REFERENCE_ONLY
REBUILD
NOT_REQUIRED
```

Recommended matrix:

| Target Table / Structure | Resolution | Dependency | Population Rule | Verification |
|---|---|---|---|---|
| `<target_only>` | `TARGET_OWNED` | `<dependency>` | `<rule>` | `<verify>` |

### Target table gate

```text
Target-only structures discovered = 100%
Target-only structures resolved   = 100%
Unresolved target-only structures = 0
```

---

# 6. Generate the Field Mapping Contract

Every effective source physical field must receive exactly one final handling decision.

Recommended field mapping matrix:

| Group | Source Table | Source Field | Target Table | Target Field | Mapping Type | Rule Code | Lookup Domain | Structured Format | Verify | Reason |
|---|---|---|---|---|---|---|---|---|---|---|
| `Gx` | `<source>` | `<field>` | `<target>` | `<field>` | `DIRECT` | `COPY_NORMALIZED` | — | — | `<verify>` | `<reason>` |

Do not use shortcuts such as:

```text
all same-name fields = DIRECT
all *_id = LOOKUP
all params = STRUCTURED
```

Such rules may help generate candidates, but the final materialized field mapping must account for every physical source field explicitly or through a deterministic machine-verifiable expansion whose result is stored and checked.

### Deterministic field precedence

Recommended precedence:

```text
1. Parent table = IGNORE         → field = IGNORE
2. Parent table = ARCHIVE        → field = ARCHIVE
3. Parent table = REBUILD        → field = REBUILD
4. Explicit field override       → use override
5. Reference field               → LOOKUP
6. Structured field              → STRUCTURED
7. Compatible scalar field       → DIRECT + VALUE_NORMALIZE
8. Source-only field             → explicit TRANSFORM / ARCHIVE / IGNORE / REFERENCE_ONLY
9. No rule                       → CONTRACT ERROR
```

### Source field hard invariant

```text
field_mapping_rows_for_source_scope
=
COUNT(DISTINCT source_table, source_field)
=
effective_source_field_count
```

### Source field gate

```text
Source fields with decisions     = 100%
Missing source field decisions   = 0
Duplicate source field decisions = 0
Unmapped source fields           = 0
Ambiguous source fields          = 0
```

---

# 7. Resolve Every Required Target Field

Source coverage alone is insufficient. A target table can have new required fields that do not exist in the source.

For every required target field, assign exactly one population strategy:

```text
SOURCE_DIRECT
SOURCE_TRANSFORM
LOOKUP
DEFAULT
GENERATED
TARGET_OWNED
REBUILD
RECREATE
NOT_REQUIRED
```

`NOT_REQUIRED` must be justified by target DDL/application semantics.

Recommended target-resolution matrix:

| Target Table | Target Field | Required? | Resolution | Source / Rule | Verification |
|---|---|---:|---|---|---|
| `<table>` | `<field>` | YES | `DEFAULT` | target DDL default | `<verify>` |

### Target field gate

```text
Required target fields identified = 100%
Required target fields resolved   = 100%
Unresolved required target fields = 0
```

This prevents a migration from claiming 100% merely because every source field has a decision while the target insert/update remains incomplete.

---

# 8. Build the ID / Identity / Value Mapping Contract

Never assume source and target numeric IDs are equal.

For every identity-bearing domain, define one strategy:

```text
ID_MAP
SEMANTIC_LOOKUP
GENERATED
PRESERVE_ONLY_IF_PROVEN
NONE
```

Recommended mapping domains:

```text
USER
CATEGORY
PRODUCT
ORDER
CONTENT
MENU
MODULE
EXTENSION
CUSTOM_DOMAIN
```

Runtime/design-time value mapping should record at least:

```text
migration_run_id
mapping_domain
source_table
source_value
source_identity
target_table
target_value
target_identity
mapping_status
```

### ID/value mapping gate

```text
Required mapping domains identified = 100%
Required source identities resolved = 100%
Missing required mappings           = 0
Duplicate target identity matches   = 0
Ambiguous identity matches          = 0
```

---

# 9. Define Structured Data Rules

Structured fields require parse/remap/serialize validation rather than string copy.

Possible formats:

```text
JSON
Registry/config strings
PHP serialized data
CSV/delimited IDs
XML
URLs/query strings
file paths
HTML containing IDs/links
application-specific payloads
```

For every structured field define:

| Requirement | Value |
|---|---|
| Format | exact encoding/format |
| Parser | exact parser/decoder |
| Embedded references | IDs/keys/aliases/URLs/paths |
| Transform rule | deterministic rule code |
| Serializer | exact output serialization |
| Validation | parse → transform → serialize → reparse |
| Failure policy | block or explicitly approved archive path |

### Structured-data gate

```text
Structured fields classified      = 100%
Structured rules defined          = 100%
Embedded reference domains known  = 100%
Invalid structured values         = 0
Unresolved embedded references    = 0
```

---

# 10. Resolve All Dependencies

Dependencies include more than physical foreign keys.

Required dependency types may include:

```text
PHYSICAL_FK
LOGICAL_REFERENCE
LOOKUP_REFERENCE
STRUCTURED_REFERENCE
FILE_REFERENCE
EXTENSION_REFERENCE
APPLICATION_ORDER
TARGET_PREREQUISITE
```

For every dependency record:

```text
producer
consumer
mapping domain
execution phase/order
required/optional semantics
orphan rule
cycle strategy
verification rule
```

### Dependency gate

```text
Required dependencies inventoried = 100%
Required dependencies resolved    = 100%
Unresolved references             = 0
Forbidden orphans                 = 0
Unresolved hard cycles            = 0
Execution order derivable         = YES
```

---

# 11. Define Record Accounting Before Execution

Every source record must have one accounting outcome.

Canonical invariant:

```text
source_rows
=
direct_rows
+ transformed_rows
+ rebuilt_source_rows
+ reference_only_rows
+ archived_rows
+ ignored_rows
+ error_rows
```

For table-level policies, define how source rows enter the appropriate bucket.

Examples:

```text
TRANSFORM       → expected target identity exists
REBUILD         → source row counted as rebuild input; target structure regenerated
REFERENCE_ONLY  → source identity resolves target-owned row
ARCHIVE         → archive evidence written
IGNORE          → explicit reason and ignored-row accounting
```

### Accounting gate

Before final production PASS:

```text
Source records accounted = 100%
Unaccounted records       = 0
Error records             = 0
```

---

# 12. Define Verification From the Same Contract

The executor and verifier must consume the same mapping rules or rule codes. Do not implement migration one way and independently re-describe verification another way.

Required verification levels:

```text
TABLE
FIELD
RECORD
REFERENCE
STRUCTURED VALUE
TREE / HIERARCHY
TARGET-ONLY STATE
ARCHIVE / IGNORE ACCOUNTING
```

Required final checks:

```text
Missing expected records          = 0
Unexpected target records         = 0
Duplicate source→target mappings  = 0
Field mismatches                  = 0
Broken relationships              = 0
Invalid structured values         = 0
Unresolved embedded references    = 0
Unexplained archive rows          = 0
Unexplained ignore rows           = 0
```

Row counts alone are not sufficient. Each expected source identity must resolve to the expected target identity or an explicitly approved non-active outcome.

---

# 13. Define Idempotency, Re-run, and Recovery

A production-ready contract must define safe execution behavior.

Required items:

```text
deterministic source identity
deterministic target lookup
insert/update/upsert rule
duplicate prevention
resume/checkpoint strategy
retry policy
transaction boundary
failure isolation
backup/restore or rollback
audit evidence
```

### Recovery gate

```text
Safe rerun behavior documented   = YES
Duplicate-on-rerun risk          = 0 unresolved
Resume/retry behavior            = DEFINED
Backup/restore or rollback       = VALIDATED
Audit trail                      = DEFINED
```

---

# 14. Production Reconciliation Before Execution

Even after the document-level contract is complete, rescan the actual source and target databases before execution.

Required checks:

```text
Actual source tables  = contract source tables
Actual source fields  = contract source fields
Actual target tables  = contract target tables
Actual target fields  = contract target fields
```

Any new production deviation must invalidate the stale contract until the inventory/mapping is regenerated or explicitly reconciled.

### Production gate

```text
Unexpected source tables       = 0
Unexpected source fields       = 0
Unexpected target tables       = 0
Unexpected target fields       = 0
Unexplained schema deviations  = 0
```

---

# 15. 100% Migration Contract Checklist

## Prerequisite Inventory

- [ ] Source migration-group manifest = `PASS`.
- [ ] Source field inventory = `PASS`.
- [ ] Target migration-group manifest = `PASS`.
- [ ] Target field inventory = `PASS`.
- [ ] Effective production-aware table/field counts are fixed.
- [ ] Unexplained inventory deviations = 0.

## Table Mapping

- [ ] Every effective source table appears exactly once.
- [ ] Every source table has one final decision.
- [ ] Every non-ignored/non-archived source table has an explicit target/rebuild/reference rule.
- [ ] Renamed tables are explicit.
- [ ] Many-to-one mappings are explicit.
- [ ] One-to-many mappings are explicit.
- [ ] Runtime/generated/security/history tables are explicit.
- [ ] Missing source table mappings = 0.
- [ ] Duplicate source table mappings = 0.
- [ ] Ambiguous source table mappings = 0.

## Target Table Resolution

- [ ] Target-only structures are explicitly computed.
- [ ] Every required target-only table/structure has one resolution.
- [ ] Unresolved target-only structures = 0.

## Source Field Mapping

- [ ] Every effective source field appears exactly once in final materialized mapping coverage.
- [ ] Every source field has one final decision.
- [ ] Missing source field mappings = 0.
- [ ] Duplicate source field mappings = 0.
- [ ] Unmapped source fields = 0.
- [ ] Ambiguous source fields = 0.

## Target Field Resolution

- [ ] Every required target field is identified.
- [ ] Every required target field has one population strategy.
- [ ] Unresolved required target fields = 0.

## ID / Value Mapping

- [ ] Identity-bearing domains are identified = 100%.
- [ ] ID/semantic lookup strategy exists for every required domain.
- [ ] Missing required ID/value mappings = 0 at final verification.
- [ ] Duplicate target identities = 0.
- [ ] Ambiguous identity matches = 0.

## Structured Data

- [ ] Structured fields identified = 100%.
- [ ] Parser/serializer rules defined = 100%.
- [ ] Embedded reference domains identified = 100%.
- [ ] Invalid structured values = 0 at final verification.
- [ ] Unresolved embedded references = 0.

## Dependencies

- [ ] Physical dependencies inventoried.
- [ ] Logical dependencies inventoried.
- [ ] Structured/reference dependencies inventoried.
- [ ] Target prerequisites inventoried.
- [ ] Unresolved dependencies = 0.
- [ ] Forbidden orphans = 0.
- [ ] Unresolved hard cycles = 0.

## Record Accounting

- [ ] Every source table has a record-accounting strategy.
- [ ] Every source row ends in exactly one accounting bucket.
- [ ] Unaccounted rows = 0.
- [ ] Error rows = 0 before final PASS.

## Verification

- [ ] Every table mapping has a verification rule.
- [ ] Every field mapping has a verification rule or inherits a deterministic validated rule.
- [ ] Missing expected records = 0.
- [ ] Unexpected target records = 0.
- [ ] Duplicate source→target mappings = 0.
- [ ] Field mismatches = 0.
- [ ] Broken relationships = 0.
- [ ] Invalid structured values = 0.

## Decision Quality

- [ ] `UNKNOWN = 0`.
- [ ] `PENDING = 0`.
- [ ] `REVIEW = 0`.
- [ ] `OPTIONAL = 0`.
- [ ] `SELECTIVE = 0`.
- [ ] `UNMAPPED = 0`.
- [ ] `AMBIGUOUS = 0`.
- [ ] Slash choices `A / B = 0`.

## Recovery

- [ ] Safe rerun behavior documented.
- [ ] Resume/retry behavior documented.
- [ ] Duplicate-on-rerun prevention documented.
- [ ] Backup/restore or rollback validated.
- [ ] Migration audit trail defined.

## Production Reconciliation

- [ ] Actual source database rescanned before execution.
- [ ] Actual target database rescanned before execution.
- [ ] Contract denominators match actual in-scope objects.
- [ ] Unexplained source deviations = 0.
- [ ] Unexplained target deviations = 0.

---

# 16. Final Contract Gate

A contract may be marked **definition-level PASS** only when every mapping and resolution decision is complete.

A migration may be marked **production PASS** only after execution and verification also pass.

```text
PREREQUISITES
------------------------------------------------
Source group manifest                = PASS
Source field inventory               = PASS
Target group manifest                = PASS
Target field inventory               = PASS

SOURCE INVENTORY
------------------------------------------------
Source tables accounted              = X / X
Source fields accounted              = Y / Y
Missing source inventory objects     = 0

TARGET INVENTORY
------------------------------------------------
Target tables accounted              = A / A
Target fields accounted              = B / B
Missing target inventory objects     = 0

TABLE MAPPING
------------------------------------------------
Source table decisions               = X / X
Missing source table mappings        = 0
Duplicate source table mappings      = 0
Ambiguous source table mappings      = 0

TARGET TABLE RESOLUTION
------------------------------------------------
Required target-only structures      = 100% resolved
Unresolved target structures         = 0

FIELD MAPPING
------------------------------------------------
Source field decisions               = Y / Y
Missing source field mappings        = 0
Duplicate source field mappings      = 0
Ambiguous source field mappings      = 0

TARGET FIELD RESOLUTION
------------------------------------------------
Required target fields               = 100% resolved
Unresolved required target fields    = 0

ID / VALUE / STRUCTURED
------------------------------------------------
Required mapping domains             = 100% classified
Required ID/value mappings           = 100% resolved at final verification
Structured-field rules               = 100%
Unresolved embedded references       = 0

DEPENDENCIES
------------------------------------------------
Required dependencies                = 100% resolved
Unresolved references                = 0
Forbidden orphans                    = 0
Unresolved hard cycles               = 0

DECISION QUALITY
------------------------------------------------
UNKNOWN                              = 0
PENDING                              = 0
REVIEW                               = 0
OPTIONAL                             = 0
UNMAPPED                             = 0
AMBIGUOUS                            = 0
Slash choices                        = 0

RECORD ACCOUNTING
------------------------------------------------
Source records accounted             = 100%
Unaccounted source records           = 0
Error records                        = 0

VERIFICATION
------------------------------------------------
Missing records                      = 0
Unexpected records                   = 0
Duplicate mappings                   = 0
Field mismatches                     = 0
Broken relationships                 = 0
Invalid structured values            = 0

RECOVERY
------------------------------------------------
Rerun strategy                       = PASS
Backup/restore or rollback           = PASS
Audit trail                           = PASS

================================================
MIGRATION CONTRACT DEFINITION         = PASS
PRODUCTION MIGRATION                  = PASS only after execution verification
================================================
```

---

## Output Requirements

Generate one contract per migration scope using the companion contract template.

Minimum output structure:

```text
1. Purpose and guarantee
2. Fixed/effective baseline
3. Canonical decisions
4. Table mapping contract
5. Target-only table resolution
6. Field mapping contract
7. Required target-field resolution
8. ID/value/identity mapping
9. Structured data rules
10. Dependency/execution contract
11. Record accounting
12. Verification contract
13. Production reconciliation
14. Idempotency/recovery
15. 100% checklist
16. Final definition/production gates
```

A generated contract must never claim 100% merely because all known documentation rows have decisions. It must prove that the contract covers the **effective production-aware migration scope** and that every source object/record and required target object has an explicit, verifiable outcome.
