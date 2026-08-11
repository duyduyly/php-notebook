# Migration Group Generation Plan

## Purpose

> **Goal: classify 100% of physical database tables in the declared migration scope before table mapping or field mapping begins.**

This plan is reusable for Joomla core, third-party extensions, custom extensions, or other version-to-version database migrations.

It is designed to generate migration-group manifests such as:

```text
<scope>-migration-groups-source.md
<scope>-migration-groups-target.md
```

Use the companion template:

- [`../templates/database-migration-groups-template.md`](../templates/database-migration-groups-template.md)

The key guarantee is not "100% of tables are copied". The guarantee is:

> **100% of physical tables in the declared scope are discovered, inventoried, assigned to exactly one group, given an explicit migration policy, and reconciled against the real database.**

Tables classified as `IGNORE`, `ARCHIVE`, `REBUILD`, `REFERENCE_ONLY`, `TARGET_OWNED`, or `RECREATE` are still part of 100% table coverage.

---

## 1. Fix the Migration Scope

Before scanning tables, define the migration boundary explicitly.

| Item | Required value |
|---|---|
| Scope name | `<component / extension / core / subsystem>` |
| Side | `SOURCE` or `TARGET` |
| System | `<system name>` |
| Version | `<version>` |
| Database | `<database/schema>` |
| Ownership scope | `<CORE / EXTENSION / CUSTOM / explicit set>` |
| Official schema source | `<install.sql / update.sql / package / repository / DDL>` |
| Production database | `<actual database to reconcile>` |

### Gate

```text
Declared scope             = FIXED
System/version             = KNOWN
Ownership boundary         = KNOWN
Schema authority           = IDENTIFIED
Production database        = IDENTIFIED
```

If any item is unknown, do not claim 100% table coverage.

---

## 2. Build the Official Table Baseline

Extract every physical table from authoritative schema sources.

Examples:

```text
installation SQL
upgrade/update SQL
extension install SQL
official release package
official source repository
schema migration files
```

Create a canonical set:

```text
official_table_set
```

Rules:

1. Store every physical table explicitly.
2. Do not use wildcard table names.
3. Deduplicate exact table names.
4. Record the source file/evidence for every table.
5. Include installation-specific, generated, runtime, archive, and relation tables if they physically belong to the declared scope.

### Required checks

```text
official_table_count
=
COUNT(DISTINCT official_table)

Duplicate official tables       = 0
Wildcard table entries          = 0
Unexplained official tables     = 0
```

---

## 3. Scan the Actual Database

The real database must be checked independently from the official baseline.

Recommended MySQL discovery query:

```sql
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE,
    ENGINE,
    TABLE_COLLATION,
    TABLE_COMMENT
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = :database_name
ORDER BY TABLE_NAME;
```

Do not automatically treat every table in the database as part of the migration scope. Classify ownership first.

Recommended ownership values:

```text
CORE
EXTENSION
CUSTOM
THIRD_PARTY
RUNTIME_TOOLING
UNKNOWN
```

For extension migrations, determine ownership using multiple evidence sources when necessary:

```text
table prefix
install/update SQL
extension source code
runtime SQL queries
foreign/logical references
production configuration
```

### Gate

```text
Actual tables discovered       = 100%
Ownership classified           = 100%
UNKNOWN ownership              = 0
```

---

## 4. Reconcile Official Baseline vs Actual Database

Compare:

```text
OFFICIAL TABLE SET
        ↕
ACTUAL IN-SCOPE TABLE SET
```

Every table must enter exactly one reconciliation bucket:

```text
MATCHED
ACTUAL_ONLY
OFFICIAL_ONLY
EXCLUDED_OUT_OF_SCOPE
UNKNOWN
```

### Rules

- `MATCHED` → normal baseline table.
- `ACTUAL_ONLY` → investigate local/custom/legacy tables; never silently discard.
- `OFFICIAL_ONLY` → document why the production instance does not contain it.
- `EXCLUDED_OUT_OF_SCOPE` → must have ownership evidence and reason.
- `UNKNOWN` → blocks PASS.

The effective migration table set is derived from the real declared scope, not from a hard-coded documentation number.

Example:

```text
Official extension tables      = 42
Actual owned tables            = 44
Actual-only owned tables       = 2

Effective migration scope      = 44
```

If the two extra tables belong to the extension, 100% coverage means **44/44**, not 42/42.

### Reconciliation gate

```text
UNKNOWN reconciliation rows    = 0
Unexplained actual tables       = 0
Unexplained official tables     = 0
```

---

## 5. Design Migration Groups

Do not force one fixed group model onto every migration.

Create groups based on business role and dependency order.

A reusable starting model is:

```text
G0 System / Reference
G1 Identity / Foundation
G2 Definitions / Configuration
G3 Primary Business Data
G4 Relations / Mapping
G5 Presentation / Integration
G6 Supporting Data
G7 Historical / Audit
G8 Runtime / Generated / Target-Owned
```

A small extension may need only:

```text
G0 Configuration
G1 Master Data
G2 Transaction Data
G3 Relations
G4 Runtime / Generated
```

The number and names of groups do not determine quality.

The hard invariant is:

```text
Every in-scope physical table
→ exactly one migration group
```

---

## 6. Classify Every Physical Table

Create one row per physical table.

Recommended matrix:

| # | Group | Table | Schema Source | Ownership | Purpose | Initial Policy | Evidence |
|---:|---|---|---|---|---|---|---|
| 1 | `G0` | `<table_a>` | `<install.sql>` | `EXTENSION` | Configuration | `REFERENCE_ONLY` | `<evidence>` |
| 2 | `G1` | `<table_b>` | `<install.sql>` | `EXTENSION` | Master data | `MIGRATE` | `<evidence>` |
| 3 | `G2` | `<table_c>` | `<update.sql>` | `EXTENSION` | Relation | `TRANSFORM` | `<evidence>` |
| 4 | `G4` | `<table_d>` | `<runtime evidence>` | `EXTENSION` | Cache/index | `REBUILD` | `<evidence>` |

### Hard invariant

```text
classified_table_rows
=
COUNT(DISTINCT classified_table)
=
effective_in_scope_table_count
```

Required result:

```text
Missing classifications       = 0
Duplicate classifications     = 0
Wildcard classifications      = 0
Unclassified tables           = 0
```

---

## 7. Assign a Migration Policy to Every Table

Allowed policies should match the migration contract.

Typical values:

```text
MIGRATE
DIRECT
TRANSFORM
LOOKUP
REBUILD
GENERATED
REFERENCE_ONLY
ARCHIVE
IGNORE
TARGET_OWNED
RECREATE
```

A table that will not be copied still requires an explicit policy.

Examples:

```text
business_table      → MIGRATE / TRANSFORM
cache_table         → REBUILD
session_table       → IGNORE
audit_history       → ARCHIVE
system_metadata     → REFERENCE_ONLY
new_target_table    → TARGET_OWNED
new_configuration   → RECREATE
```

Final mapping must not contain unresolved values such as:

```text
UNKNOWN
PENDING
REVIEW
OPTIONAL
SELECTIVE
UNMAPPED
AMBIGUOUS
A / B
```

A group manifest may temporarily document provisional alternatives during analysis, but the final table-mapping contract must resolve them before migration execution.

---

## 8. Identify Dependencies

For every table, document what must exist first.

Example:

```text
category
   ↓
product
   ↓
order
   ↓
order_item
```

Dependency matrix:

| Table | Depends On | Produces Identity/Map | Required Before |
|---|---|---|---|
| `category` | — | `CATEGORY` | `product` |
| `product` | `category` | `PRODUCT` | `order_item` |
| `order` | `user` | `ORDER` | `order_item` |
| `order_item` | `order`, `product` | — | — |

Rules:

1. Include physical foreign keys.
2. Include logical application references.
3. Include IDs embedded in JSON/config/text where known.
4. Include target-owned prerequisites.
5. Flag circular dependencies for phased handling.

### Gate

```text
Required dependencies identified   = 100%
Unresolved dependencies             = 0
Execution order derivable           = YES
```

---

## 9. Explicitly Handle Runtime, Generated, Historical, and Security Tables

These tables are a common source of false "100%" claims because they are often omitted from documentation.

They must remain in the inventory.

Examples:

```text
cache             → REBUILD
session           → IGNORE
search index      → REBUILD
security token    → IGNORE
audit log         → ARCHIVE
installation data → TARGET_OWNED / REFERENCE_ONLY
```

Rule:

> **Not migrated directly does not mean not inventoried.**

### Gate

```text
Runtime tables classified        = 100%
Generated tables classified      = 100%
Historical tables classified     = 100%
Security/install-state tables    = 100%
Silent exclusions                = 0
```

---

## 10. Identify Target-Only Tables

For a target-version manifest, compare source and target table sets and identify new target tables.

```text
TARGET_ONLY = target_in_scope_tables - source_in_scope_tables
```

Every target-only table must receive a resolution such as:

```text
TARGET_OWNED
GENERATED
RECREATE
DEFAULT
REFERENCE_ONLY
```

Example:

```text
Source tables = 40
Target tables = 44
Target-only   = 4

4 / 4 target-only tables classified
```

### Gate

```text
Target-only tables discovered     = 100%
Target-only tables classified     = 100%
Unresolved target-only tables     = 0
```

---

## 11. Build the Coverage Manifest

Each generated migration-group file must include an explicit coverage block.

Template:

```text
Official baseline tables        = X
Actual in-scope tables          = Y
Effective migration scope       = Y

Tables inventoried              = Y / Y
Tables grouped                  = Y / Y
Unique table assignments        = Y / Y
Tables with policy              = Y / Y

Missing tables                  = 0
Duplicate assignments           = 0
Unknown ownership               = 0
Unclassified tables             = 0
Wildcard entries                = 0
Unexplained actual tables       = 0
Unresolved target-only tables   = 0

TABLE INVENTORY COVERAGE        = 100%
```

Do not claim 100% if the denominator is only the official package while the actual database contains additional owned tables.

---

## 12. Require the Field Inventory Gate

Migration groups establish table coverage, not complete field coverage.

After the group manifest passes:

```text
TABLE GROUP PASS
       ↓
FIELD INVENTORY
       ↓
FIELD MAPPING
```

Every classified physical table must later have every physical column discovered and inventoried.

Recommended validation:

```text
actual_physical_fields
=
field_inventory_rows

Missing fields            = 0
Duplicate fields          = 0
Fields without decision   = 0
```

The group manifest must reference the companion field-inventory artifact and block migration if that artifact has not passed.

---

# 100% Table Coverage Checklist

## Scope

- [ ] Migration scope is explicitly defined.
- [ ] Source/target side is explicit.
- [ ] System and version are explicit.
- [ ] Database/schema is explicit.
- [ ] Ownership boundary is explicit.
- [ ] Official schema authority is identified.
- [ ] Actual production database is identified.

## Official Baseline

- [ ] All authoritative schema files were inspected.
- [ ] Every official physical table is listed explicitly.
- [ ] Official table names are deduplicated.
- [ ] Wildcard official entries = 0.
- [ ] Every official table has source/evidence.

## Actual Database Discovery

- [ ] `information_schema.TABLES` or equivalent was scanned.
- [ ] Every actual table was discovered.
- [ ] Ownership was assigned to every actual table.
- [ ] `UNKNOWN` ownership = 0.

## Reconciliation

- [ ] Official vs actual table sets were compared.
- [ ] Every table belongs to `MATCHED`, `ACTUAL_ONLY`, `OFFICIAL_ONLY`, or explicitly `EXCLUDED_OUT_OF_SCOPE`.
- [ ] `UNKNOWN` reconciliation rows = 0.
- [ ] Actual-only owned tables are included in effective scope.
- [ ] Official-only tables have documented reasons.
- [ ] Unexplained actual tables = 0.

## Group Classification

- [ ] Every effective in-scope physical table is in exactly one group.
- [ ] Missing group assignments = 0.
- [ ] Duplicate group assignments = 0.
- [ ] Wildcard group entries = 0.
- [ ] Unclassified tables = 0.
- [ ] `COUNT(rows) = COUNT(DISTINCT table) = effective scope count`.

## Table Policy

- [ ] Every in-scope table has a migration policy.
- [ ] Runtime tables have explicit decisions.
- [ ] Generated tables have explicit decisions.
- [ ] Historical/audit tables have explicit decisions.
- [ ] Security-token/session tables have explicit decisions.
- [ ] Target-owned tables have explicit decisions.
- [ ] No table is silently dropped.

## Dependencies

- [ ] Required table dependencies are documented.
- [ ] Physical foreign-key dependencies are captured.
- [ ] Logical/application dependencies are captured.
- [ ] Circular dependencies have a phased strategy.
- [ ] Unresolved dependencies = 0.
- [ ] Migration order can be derived.

## Target-Only Coverage

- [ ] Target-only tables were computed explicitly.
- [ ] Every target-only table has a resolution.
- [ ] Unresolved target-only tables = 0.

## Next Gate

- [ ] Companion field inventory is required.
- [ ] Field coverage must be 100% before migration execution.
- [ ] Production reconciliation is required again at execution time.

---

# Final Table Group Gate

A migration-group manifest may be marked `PASS` only when all checks below succeed.

```text
SCOPE
----------------------------------------
Declared database scope          = FIXED
Ownership boundary               = FIXED
Schema authority                 = IDENTIFIED
Actual database                  = IDENTIFIED

DISCOVERY
----------------------------------------
Official tables                  = X
Actual in-scope tables           = Y
Effective migration scope        = Y
Unknown ownership                = 0

RECONCILIATION
----------------------------------------
Unexplained actual tables        = 0
Unexplained official tables      = 0
Unknown reconciliation rows      = 0

CLASSIFICATION
----------------------------------------
Tables inventoried               = Y / Y
Tables grouped                   = Y / Y
Unique assignments               = Y / Y
Tables with policies             = Y / Y

Missing tables                   = 0
Duplicate assignments            = 0
Unclassified tables              = 0
Wildcard entries                 = 0

DEPENDENCIES
----------------------------------------
Required dependencies identified = 100%
Unresolved dependencies          = 0
Execution order derivable        = YES

TARGET-ONLY
----------------------------------------
Target-only tables classified    = 100%
Unresolved target-only tables    = 0

NEXT GATE
----------------------------------------
Companion field inventory        = REQUIRED
Field inventory PASS             = REQUIRED BEFORE EXECUTION

========================================
TABLE GROUP COVERAGE              = 100%
TABLE GROUP MANIFEST              = PASS
========================================
```

---

## Output Requirements

For each source or target version, generate one migration-group file from the template and this plan.

Minimum output structure:

```text
1. Scope and migration rule
2. Baseline and schema sources
3. Group definitions
4. Explicit table matrix
5. Dependencies
6. Runtime/generated/historical handling
7. Target-only handling when applicable
8. Coverage manifest
9. Field-inventory gate
10. 100% checklist
11. Final PASS/FAIL gate
```

A generated file must never claim `100%` merely because all documented tables were classified. It must prove that the documented table set equals the **effective physical table set in the declared migration scope**.
