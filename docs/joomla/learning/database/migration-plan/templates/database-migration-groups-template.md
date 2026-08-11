# {{SCOPE_NAME}} Database Migration Groups — {{SYSTEM_NAME}} {{VERSION}}

## Template Role

> **Side:** `{{SIDE}}` (`SOURCE` or `TARGET`)  
> **Inventory = YES**  
> **Group classification = 100% required**  
> **Mapping decision = required before migration**

Use this template to generate one migration-group manifest for a single database version or migration side.

Typical generated files:

```text
{{scope}}-migration-groups-v1.md
{{scope}}-migration-groups-v2.md
```

or:

```text
{{scope}}-migration-groups-source.md
{{scope}}-migration-groups-target.md
```

This template is intentionally generic. Do **not** assume Joomla-specific group names, table counts, or G0–G8 unless they are actually appropriate for the system being inventoried.

---

## 1. Migration Rule

Every physical table in the declared `{{SCOPE_NAME}}` database scope must be:

1. discovered;
2. inventoried;
3. assigned to exactly one migration group;
4. assigned a table-level migration policy/decision;
5. linked to its schema source/evidence;
6. reconciled against the real database before production execution.

No table may disappear because it is runtime, generated, obsolete, historical, target-owned, extension-owned, or difficult to migrate. Such tables still require an explicit decision.

### Allowed group/table decisions

Use only decisions needed by the migration contract:

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

A group manifest may describe a provisional policy such as `MIGRATE / MAP` or `TARGET_OWNED / RECREATE` when this document is still an inventory/classification artifact. Before execution, the migration contract must resolve every executable source object to exactly one final outcome.

The following must never remain unresolved at the final mapping gate:

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

---

## 2. Baseline and Source of Truth

| Item | Value |
|---|---|
| Scope | `{{SCOPE_NAME}}` |
| Side | `{{SIDE}}` |
| System / extension | `{{SYSTEM_NAME}}` |
| Version | `{{VERSION}}` |
| Database engine | `{{DATABASE_ENGINE}}` |
| Schema baseline type | `{{OFFICIAL_DDL / INSTALL_SCHEMA / PRODUCTION_SCHEMA / OTHER}}` |
| Physical tables | `{{TABLE_COUNT}}` |
| Physical fields | `{{FIELD_COUNT}}` |
| Companion field manifest | `{{FIELD_MANIFEST_PATH}}` |
| Opposite-side group manifest | `{{OTHER_SIDE_GROUP_MANIFEST_PATH}}` |
| Migration contract | `{{MIGRATION_CONTRACT_PATH}}` |

### Schema authority

List every authoritative schema source used to build this manifest.

| Source | Role | Tables contributed | Fields contributed | Verified |
|---|---|---:|---:|---|
| `{{SCHEMA_SOURCE_1}}` | `{{ROLE}}` | `{{COUNT}}` | `{{COUNT}}` | `YES/NO` |
| `{{SCHEMA_SOURCE_2}}` | `{{ROLE}}` | `{{COUNT}}` | `{{COUNT}}` | `YES/NO` |
| `{{SCHEMA_SOURCE_N}}` | `{{ROLE}}` | `{{COUNT}}` | `{{COUNT}}` | `YES/NO` |

Baseline gate:

```text
Physical tables discovered         = {{TABLE_COUNT}}
Tables represented in manifest     = {{TABLE_COUNT}}
Duplicate classifications          = 0
Missing tables                     = 0
Extra manifest tables              = 0
Wildcard classifications           = 0
Baseline table coverage            = 100%
```

> The baseline describes the declared version/schema authority. The real production database must still be scanned to detect local customizations, missing tables, extra tables, extension-owned objects, or version drift.

---

## 3. Group Design Rules

Groups must reflect migration dependency and data semantics, not arbitrary alphabetical partitioning.

Recommended principles:

- foundational/reference data before dependent business data;
- identity/access before records that reference identities;
- parent/master entities before relationship/link tables;
- primary/business data before generated/index/cache tables;
- target-owned/runtime/security state isolated from migratable business data;
- historical/archive data isolated when it should not become active target state;
- generated data placed after the real source entities it can be rebuilt from;
- each physical table belongs to exactly one group.

Group IDs may be `G0`, `G1`, … or any deterministic naming scheme appropriate to the scope.

Example only:

```text
G0 Reference / System
G1 Identity / Access
G2 Shared Definitions
G3 Primary Business Data
G4 Relations
G5 Presentation / Configuration
G6 Supporting Features
G7 Runtime / Generated / Historical
```

Delete or replace this example when generating a real manifest.

---

## 4. Group Summary

| Group | Group Name | Purpose | Tables | Fields | Typical Policy | Depends On |
|---|---|---|---:|---:|---|---|
| `{{GROUP_ID_1}}` | `{{GROUP_NAME_1}}` | `{{PURPOSE}}` | `{{TABLE_COUNT}}` | `{{FIELD_COUNT}}` | `{{POLICY}}` | `{{DEPENDENCIES}}` |
| `{{GROUP_ID_2}}` | `{{GROUP_NAME_2}}` | `{{PURPOSE}}` | `{{TABLE_COUNT}}` | `{{FIELD_COUNT}}` | `{{POLICY}}` | `{{DEPENDENCIES}}` |
| `{{GROUP_ID_N}}` | `{{GROUP_NAME_N}}` | `{{PURPOSE}}` | `{{TABLE_COUNT}}` | `{{FIELD_COUNT}}` | `{{POLICY}}` | `{{DEPENDENCIES}}` |
| **Total** |  |  | **{{TABLE_COUNT}}** | **{{FIELD_COUNT}}** |  |  |

Required checks:

```text
SUM(group table counts) = {{TABLE_COUNT}}
SUM(group field counts) = {{FIELD_COUNT}}
```

---

# 5. Group Definitions

Repeat the following block once for every migration group.

---

## {{GROUP_ID}} — {{GROUP_NAME}}

{{GROUP_PURPOSE_AND_SEMANTICS}}

**Tables:** `{{GROUP_TABLE_COUNT}}`  
**Physical fields:** `{{GROUP_FIELD_COUNT}}`

| # | Table | Schema Source | Fields | Group Policy | Identity / Dependency Notes |
|---:|---|---|---:|---|---|
| 1 | `{{TABLE_1}}` | `{{SCHEMA_SOURCE}}` | `{{FIELD_COUNT}}` | `{{DECISION}}` | `{{NOTES}}` |
| 2 | `{{TABLE_2}}` | `{{SCHEMA_SOURCE}}` | `{{FIELD_COUNT}}` | `{{DECISION}}` | `{{NOTES}}` |
| N | `{{TABLE_N}}` | `{{SCHEMA_SOURCE}}` | `{{FIELD_COUNT}}` | `{{DECISION}}` | `{{NOTES}}` |

### Group rules

- {{RULE_1}}
- {{RULE_2}}
- {{RULE_3}}

### Dependency contract

```text
Requires groups/tables:
- {{DEPENDENCY_1}}
- {{DEPENDENCY_2}}

Produces identities/maps/state for:
- {{CONSUMER_1}}
- {{CONSUMER_2}}
```

### Special handling

Document any table that is:

- target-owned;
- generated/rebuilt;
- runtime/security state;
- historical/archive-only;
- renamed between versions;
- many-to-one or one-to-many across versions;
- polymorphic/context-dependent;
- dependent on application code/plugins/modules being installed.

If none, state `None` explicitly.

---

<!-- Repeat Section 5 for every group. -->

# 6. Table Classification Manifest

This section is the canonical table-level coverage list for this version.

Every physical table must appear **exactly once**.

| # | Group | Table | Fields | Schema Source | Policy | Notes |
|---:|---|---|---:|---|---|---|
| 1 | `{{GROUP_ID}}` | `{{TABLE_NAME}}` | `{{FIELD_COUNT}}` | `{{SCHEMA_SOURCE}}` | `{{POLICY}}` | `{{NOTES}}` |
| 2 | `{{GROUP_ID}}` | `{{TABLE_NAME}}` | `{{FIELD_COUNT}}` | `{{SCHEMA_SOURCE}}` | `{{POLICY}}` | `{{NOTES}}` |
| N | `{{GROUP_ID}}` | `{{TABLE_NAME}}` | `{{FIELD_COUNT}}` | `{{SCHEMA_SOURCE}}` | `{{POLICY}}` | `{{NOTES}}` |

Coverage invariant:

```text
COUNT(manifest rows)
=
COUNT(DISTINCT table_name)
=
{{TABLE_COUNT}}
```

Forbidden:

```text
{{prefix}}finder_*
{{prefix}}component_*
other wildcard-only table groups
```

Every physical table must be explicit.

---

# 7. Migration / Dependency Order

The order must be derived from actual dependencies for this scope.

```text
{{GROUP_ID_1}} {{GROUP_NAME_1}}
        ↓
{{GROUP_ID_2}} {{GROUP_NAME_2}}
        ↓
{{GROUP_ID_3}} {{GROUP_NAME_3}}
        ↓
...
        ↓
{{GROUP_ID_N}} {{GROUP_NAME_N}}
```

If a group is phased or cyclic, document it explicitly instead of pretending the migration is strictly linear.

Example:

```text
Group A initial reference setup
        ↓
Group B/C/D migration
        ↓
Group A final reconcile
```

Required dependency checks:

```text
Unresolved group dependencies   = 0
Unknown table dependencies      = 0
False ID-equality assumptions   = 0
Unresolved cycles               = 0
```

---

# 8. Schema Coverage

## 8.1 Source-file coverage

| Schema Source | Tables | Fields |
|---|---:|---:|
| `{{SCHEMA_SOURCE_1}}` | `{{COUNT}}` | `{{COUNT}}` |
| `{{SCHEMA_SOURCE_2}}` | `{{COUNT}}` | `{{COUNT}}` |
| `{{SCHEMA_SOURCE_N}}` | `{{COUNT}}` | `{{COUNT}}` |
| **Total** | **{{TABLE_COUNT}}** | **{{FIELD_COUNT}}** |

## 8.2 Group coverage

| Group | Tables | Fields |
|---|---:|---:|
| `{{GROUP_ID_1}} — {{GROUP_NAME_1}}` | `{{COUNT}}` | `{{COUNT}}` |
| `{{GROUP_ID_2}} — {{GROUP_NAME_2}}` | `{{COUNT}}` | `{{COUNT}}` |
| `{{GROUP_ID_N}} — {{GROUP_NAME_N}}` | `{{COUNT}}` | `{{COUNT}}` |
| **Total** | **{{TABLE_COUNT}}** | **{{FIELD_COUNT}}** |

Coverage contract:

```text
Baseline physical tables          = {{TABLE_COUNT}}
Explicit table classifications    = {{TABLE_COUNT}}
Baseline physical fields          = {{FIELD_COUNT}}
Duplicate table assignments       = 0
Missing tables                    = 0
Extra manifest tables             = 0
Wildcard table entries            = 0
Unclassified tables               = 0
Baseline table coverage           = 100%
```

---

# 9. Field Coverage Gate

This group manifest proves table classification. It does **not** replace the field manifest.

The companion field inventory must independently reconcile every physical `(table, field)` pair.

Required production validation:

```text
Actual scoped tables discovered       = 100%
Actual scoped fields discovered       = 100%
Fields inserted into field_inventory  = 100%
Fields with mapping decision           = 100%

Missing inventory fields              = 0
Duplicate inventory fields            = 0
Unclassified source fields            = 0
Fields without mapping decision       = 0
```

Generic MySQL inventory query:

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
    c.COLLATION_NAME
FROM information_schema.COLUMNS AS c
JOIN migration_inventory.table_list AS t
    ON t.table_name = c.TABLE_NAME
WHERE c.TABLE_SCHEMA = :database_name
  AND t.ownership_type = :scope_ownership_type
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;
```

Field inventory invariant:

```text
actual_field_count
=
field_inventory_count

AND

missing_field_count = 0
```

A migration run must be blocked if a discovered physical field is absent from inventory or lacks a mapping decision.

---

# 10. Production Reconciliation

The generated manifest must be compared with the actual database before migration.

At minimum, compare:

```text
information_schema.TABLES
information_schema.COLUMNS
```

Classify every production deviation:

```text
BASELINE_MATCH
CUSTOM_TABLE
CUSTOM_FIELD
MISSING_BASELINE_TABLE
MISSING_BASELINE_FIELD
EXTENSION_OWNED
LEGACY_LEFTOVER
VERSION_DRIFT
UNKNOWN
```

Final reconciliation requires:

```text
Unknown production tables        = 0
Unknown production fields        = 0
Unexplained missing tables       = 0
Unexplained missing fields       = 0
Unclassified custom objects      = 0
```

Do not silently force production deviations into the official/version baseline.

---

# 11. 100% Group Coverage Checklist

## Baseline

- [ ] System/extension and version are explicit.
- [ ] Schema authority is documented.
- [ ] Every schema source is listed.
- [ ] Baseline table count is known.
- [ ] Baseline field count is known.

## Table Discovery

- [ ] Every physical table is explicitly listed.
- [ ] Wildcard-only entries = 0.
- [ ] Missing baseline tables = 0.
- [ ] Extra unexplained manifest tables = 0.
- [ ] Duplicate physical table entries = 0.

## Classification

- [ ] Every physical table belongs to exactly one group.
- [ ] Every table has a group-level migration policy.
- [ ] Runtime/generated/security tables are still classified.
- [ ] Historical/archive tables are still classified.
- [ ] Target-owned tables are still classified.
- [ ] Renamed/restructured tables are documented where known.

## Dependencies

- [ ] Group dependencies are explicit.
- [ ] Table-level critical dependencies are documented.
- [ ] Execution order is derivable.
- [ ] Cyclic/phased migrations are documented.
- [ ] Unresolved dependencies = 0.

## Field Gate

- [ ] Companion field manifest exists.
- [ ] Group table totals reconcile with field manifest tables.
- [ ] Group field totals reconcile with field manifest fields.
- [ ] Every actual production field is inventoried before execution.
- [ ] Fields without mapping decisions = 0 before execution.

## Production Reconciliation

- [ ] Actual database tables were scanned.
- [ ] Actual database fields were scanned.
- [ ] Custom/extra objects were classified.
- [ ] Missing baseline objects were explained.
- [ ] `UNKNOWN` production deviations = 0.

---

# 12. Completion Gate

The generated group manifest is `PASS` only when all definition-level checks succeed.

```text
BASELINE
--------------------------------------
Physical tables                 = {{TABLE_COUNT}}
Physical fields                 = {{FIELD_COUNT}}
Schema sources verified         = 100%

CLASSIFICATION
--------------------------------------
Tables represented              = {{TABLE_COUNT}} / {{TABLE_COUNT}}
Unique table assignments        = {{TABLE_COUNT}} / {{TABLE_COUNT}}
Missing tables                  = 0
Extra manifest tables           = 0
Duplicate assignments           = 0
Wildcard entries                = 0
Unclassified tables             = 0

GROUP ACCOUNTING
--------------------------------------
SUM(group tables)               = {{TABLE_COUNT}}
SUM(group fields)               = {{FIELD_COUNT}}
Unresolved dependencies         = 0

FIELD CONTRACT
--------------------------------------
Companion field manifest        = PRESENT
Field manifest reconciliation   = PASS

======================================
GROUP MANIFEST                  = PASS
======================================
```

Production migration readiness additionally requires:

```text
Actual DB reconciliation        = PASS
Unknown production tables       = 0
Unknown production fields       = 0
Fields without mapping decision = 0
```

> **Definition of 100% group coverage:** every physical table in the declared version/scope is explicitly discovered, assigned exactly once to a migration group, given a migration policy, connected to its schema evidence and dependencies, reconciled with the companion field manifest, and checked against the real production database before execution.

---

## Placeholder Reference

| Placeholder | Meaning |
|---|---|
| `{{SCOPE_NAME}}` | Core, extension name, component, subsystem, or migration scope |
| `{{SIDE}}` | `SOURCE` or `TARGET` |
| `{{SYSTEM_NAME}}` | CMS/application/extension name |
| `{{VERSION}}` | Version represented by this manifest |
| `{{DATABASE_ENGINE}}` | MySQL/MariaDB/PostgreSQL/etc. |
| `{{TABLE_COUNT}}` | Total physical tables in the declared baseline |
| `{{FIELD_COUNT}}` | Total physical fields in the declared baseline |
| `{{GROUP_ID}}` | Deterministic group identifier |
| `{{GROUP_NAME}}` | Semantic group name |
| `{{SCHEMA_SOURCE}}` | Authoritative DDL/schema source |
| `{{POLICY}}` / `{{DECISION}}` | Group/table migration policy |
| `{{FIELD_MANIFEST_PATH}}` | Companion field inventory path |
| `{{MIGRATION_CONTRACT_PATH}}` | Migration contract path |
