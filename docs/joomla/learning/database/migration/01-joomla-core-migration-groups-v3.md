# Joomla Core Database Migration Groups — Joomla 3

> **Workflow authority:** This is the static Joomla 3 reference inventory. Its 78-table / 711-field counts are not live workflow PASS denominators. Every new workflow derives included source tables, fields, and absent-source exceptions from its bound Step 1 snapshot under [`../migration-workflow.md`](../migration-workflow.md).

## Mapping-report synchronization — 2026-08-12

This document is synchronized with the [Joomla 3 → Joomla 6 field mapping report](../joomla-gap-3_6/joomla-3-to-6-field-mapping-report.md).

| Measure | Result |
|---|---:|
| Joomla 3 physical inventory | 78 tables / 711 fields |
| Joomla 6 physical inventory | 76 tables / 832 fields |
| Source-field accounting | 711 / 711 = 100.00% |
| Resolved field decisions | 711 / 711 = 100.00% |
| Resolved relationships | 168 / 168 = 100.00% |
| Field-count migration/rebuild proxy | 691 / 711 = 97.19% |
| Field-count preservation proxy | 697 / 711 = 98.03% |
| Intentionally ignored fields | 14 / 711 = 1.97% |
| Actual migrated rows/values/bytes | Not measured until execution |

Canonical decision reconciliation: `DIRECT 163 + TRANSFORM 134 + ID_MAP 106 + VALUE_MAP 81 + SPLIT 0 + MERGE 0 + DERIVED 1 + REBUILD 206 + ARCHIVE 6 + IGNORE 14 + UNSUPPORTED 0 = 711`; `UNRESOLVED = 0`.

The only intentionally ignored fields are all seven fields in `#__session` and all seven fields in `#__user_keys`; active sessions and remember-me/authentication tokens must be invalidated and recreated. `#__postinstall_messages` is **REBUILD**, `#__utf8_conversion.converted` is **DERIVED**, and ordinary `checked_out` / `checked_out_time` values are **TRANSFORM** fields reset to Joomla 6's not-checked-out state. Joomla 3 `#__ucm_history` is a separate 10-field table and transforms to Joomla 6 `#__history`; it is not part of `#__ucm_content`.

The two percentages are design proxies based on field decisions, not proof that the same percentage of production rows, values, or bytes migrated. Production coverage requires executed reconciliation.

---



## Migration Rule

> **Inventory = YES**  
> **Mapping decision = YES**

Every Joomla 3 core table must be inventoried and assigned a mapping decision before migration starts.

This document uses the **official Joomla 3.10.12 MySQL installation schema** as the core-table baseline.

**Verified baseline:** `78 physical core tables`

Allowed mapping decisions:

- `MIGRATE`
- `TRANSFORM`
- `LOOKUP`
- `REBUILD`
- `REFERENCE_ONLY`
- `ARCHIVE`
- `IGNORE`

**Target rules:**

```text
Core tables in official baseline = 78
Tables explicitly classified     = 78
Unclassified tables              = 0
Wildcard table groups            = 0
```

For a real production database, the inventory process must still compare the actual source schema against this baseline because an older Joomla 3 minor release or local customization may differ.

---

## Table of Contents

- [G0 — System Reference](#g0--system-reference)
- [G1 — Users and Access Foundation](#g1--users-and-access-foundation)
- [G2 — Taxonomy and Shared Definitions](#g2--taxonomy-and-shared-definitions)
- [G3 — Main Content](#g3--main-content)
- [G4 — Content Relations](#g4--content-relations)
- [G5 — Menu and Presentation](#g5--menu-and-presentation)
- [G6 — Modules](#g6--modules)
- [G7 — Supporting Core Components](#g7--supporting-core-components)
- [G8 — Runtime, Generated, and Excluded Data](#g8--runtime-generated-and-excluded-data)
- [Recommended Migration Order](#recommended-migration-order)
- [Coverage Manifest](#coverage-manifest)
- [Field Coverage Gate](#field-coverage-gate)
- [Completion Criteria](#completion-criteria)

---

## G0 — System Reference

Used mainly as mapping/reference data. Do not blindly copy Joomla 3 system rows into Joomla 6.

**Tables: 5**

- `#__extensions`
- `#__schemas`
- `#__update_sites`
- `#__update_sites_extensions`
- `#__updates`

Typical decisions: `REFERENCE_ONLY`, `REBUILD`, or `IGNORE`.

Important:

- Map extensions using stable identity fields such as `type + element + folder + client_id`.
- Do not assume Joomla 3 and Joomla 6 `extension_id` values are identical.
- Do not overwrite Joomla 6 schema/update metadata with Joomla 3 values.

---

## G1 — Users and Access Foundation

Migrate identity and access data before content because later groups depend on users, groups, view levels, and languages.

**Tables: 6**

- `#__languages`
- `#__usergroups`
- `#__users`
- `#__user_usergroup_map`
- `#__viewlevels`
- `#__user_profiles`

Important:

- Map user groups before user-group assignments.
- Remap group IDs stored inside `#__viewlevels.rules`.
- Validate password compatibility before migrating users.

---

## G2 — Taxonomy and Shared Definitions

Prepare categories, tags, custom fields, content-type definitions, and ACL-related structures needed by content.

**Tables: 7**

- `#__assets` — special handling; rebuild/reconcile instead of blind copy
- `#__categories`
- `#__tags`
- `#__content_types`
- `#__fields_groups`
- `#__fields`
- `#__fields_categories`

Important:

- Validate nested-set trees in `#__assets`, `#__categories`, and `#__tags`.
- Do not assume Joomla 3 asset IDs remain valid in Joomla 6.
- Review `#__content_types` as mapping/reference metadata rather than blindly copying it.

---

## G3 — Main Content

Migrate primary Joomla article data after users, view levels, categories, and languages are ready.

**Tables: 3**

- `#__content`
- `#__content_frontpage`
- `#__content_rating`

Main dependencies include:

- `#__categories`
- `#__users`
- `#__viewlevels`
- `#__assets`
- `#__languages`

---

## G4 — Content Relations

Migrate relationships only after the primary content IDs are stable.

**Tables: 6**

- `#__contentitem_tag_map`
- `#__fields_values`
- `#__associations`
- `#__ucm_base`
- `#__ucm_content`
- `#__ucm_history`

Important:

- `#__fields_values.item_id` is context-dependent and must not always be treated as `#__content.id`.
- Remap content IDs and tag IDs.
- Rebuild or validate UCM/history data where practical.

---

## G5 — Menu and Presentation

Menu data depends on content, extension mapping, access levels, and template styles.

**Tables: 3**

- `#__template_styles`
- `#__menu_types`
- `#__menu`

Important:

- Rewrite IDs embedded in menu `link` values.
- Inspect JSON `params` for embedded IDs.
- Map `component_id` through the Joomla 6 extension mapping.
- Validate menu tree values: `parent_id`, `lft`, `rgt`, `level`, and `path`.

---

## G6 — Modules

Migrate module instances after menu IDs and required extension code are ready.

**Tables: 2**

- `#__modules`
- `#__modules_menu`

Important:

- Compatible module code must exist in Joomla 6 before migrating module instances.
- Map module IDs and menu IDs.
- Validate target template positions.
- `#__modules_menu.menuid` must use the mapped Joomla 6 menu ID.

---

## G7 — Supporting Core Components

Migrate remaining Joomla core business/configuration data as separate sub-batches.

**Tables: 14**

### G7.1 Contacts

- `#__contact_details`

### G7.2 Newsfeeds

- `#__newsfeeds`

### G7.3 Banners

- `#__banners`
- `#__banner_clients`
- `#__banner_tracks`

### G7.4 Redirects

- `#__redirect_links`

### G7.5 Messages

- `#__messages`
- `#__messages_cfg`

### G7.6 User Notes

- `#__user_notes`

### G7.7 Privacy

- `#__privacy_requests`
- `#__privacy_consents`

Privacy records may contain personal, legal, or audit data. Decide explicitly whether to migrate or archive them.

### G7.8 Action Log Configuration

- `#__action_logs_extensions`
- `#__action_log_config`
- `#__action_logs_users`

These are configuration/user-preference records related to action logging. Historical action-log events are handled separately in G8.

---

## G8 — Runtime, Generated, and Excluded Data

These tables must still appear in inventory and mapping, but they normally should not be copied directly into Joomla 6.

**Tables: 32**

### G8.1 Authentication and Runtime

- `#__session`
- `#__user_keys`

Typical decision: `IGNORE`.

Active sessions and remember-me/authentication tokens must not be migrated as normal business data.

### G8.2 Search and Generated Index Data

- `#__finder_filters`
- `#__finder_links`
- `#__finder_links_terms0`
- `#__finder_links_terms1`
- `#__finder_links_terms2`
- `#__finder_links_terms3`
- `#__finder_links_terms4`
- `#__finder_links_terms5`
- `#__finder_links_terms6`
- `#__finder_links_terms7`
- `#__finder_links_terms8`
- `#__finder_links_terms9`
- `#__finder_links_termsa`
- `#__finder_links_termsb`
- `#__finder_links_termsc`
- `#__finder_links_termsd`
- `#__finder_links_termse`
- `#__finder_links_termsf`
- `#__finder_taxonomy`
- `#__finder_taxonomy_map`
- `#__finder_terms`
- `#__finder_terms_common`
- `#__finder_tokens`
- `#__finder_tokens_aggregate`
- `#__finder_types`

Typical decision: `REBUILD`.

Migrate the real content and rebuild the Smart Search/Finder index in Joomla 6.

### G8.3 Generated, Historical, or Installation-Specific Data

- `#__action_logs`
- `#__core_log_searches`
- `#__overrider`
- `#__postinstall_messages`
- `#__utf8_conversion`

Typical decisions:

- `#__action_logs` → `ARCHIVE` / `IGNORE`
- `#__core_log_searches` → `ARCHIVE` / `IGNORE`
- `#__overrider` → `REBUILD` / `IGNORE`
- `#__postinstall_messages` → `REBUILD` from the Joomla 6 installation/extension manifests; source rows are accounting evidence only
- `#__utf8_conversion` → `DERIVED`; derive completion from successful charset/collation validation rather than copying the legacy marker

---

## Recommended Migration Order

```text
G0 System Reference
        ↓
G1 Users / Access Foundation
        ↓
G2 Taxonomy / Shared Definitions
        ↓
G3 Main Content
        ↓
G4 Content Relations
        ↓
G5 Menu / Presentation
        ↓
G6 Modules
        ↓
G7 Supporting Core Components
        ↓
G8 Runtime / Generated / Excluded
```

---

## Coverage Manifest

The Joomla 3.10.12 official MySQL installation schema contains **78 physical core tables**.

| Group | Table Count |
|---|---:|
| G0 — System Reference | 5 |
| G1 — Users and Access Foundation | 6 |
| G2 — Taxonomy and Shared Definitions | 7 |
| G3 — Main Content | 3 |
| G4 — Content Relations | 6 |
| G5 — Menu and Presentation | 3 |
| G6 — Modules | 2 |
| G7 — Supporting Core Components | 14 |
| G8 — Runtime, Generated, and Excluded Data | 32 |
| **Total** | **78** |

Coverage contract:

```text
Official Joomla 3.10.12 core tables = 78
Explicitly listed tables            = 78
Duplicate classifications           = 0
Wildcard classifications            = 0
Unclassified tables                 = 0

Baseline table coverage             = 100%
```

---

## Field Coverage Gate

The table-group manifest does not hard-code every column name. The **actual Joomla 3 source database** is the source of truth for field coverage.

Before migration is allowed, the inventory process must scan every column from `information_schema.COLUMNS` for all classified Joomla 3 core tables and store each field in `migration_inventory.field_inventory`.

Required validation:

```text
Actual core tables discovered          = 78/78 baseline tables
Actual core fields discovered          = 100%
Fields inserted into field_inventory   = 100%

Missing inventory fields               = 0
Duplicate inventory fields             = 0
Unclassified source fields             = 0
Fields without mapping decision        = 0
```

Recommended source-field inventory query:

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
WHERE c.TABLE_SCHEMA = :source_database
  AND t.ownership_type = 'CORE'
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;
```

Field-coverage validation must compare the real schema against the inventory:

```text
actual_field_count
=
field_inventory_count

AND

missing_field_count = 0
```

A migration run must be blocked when any actual Joomla 3 core field is absent from `field_inventory` or has no mapping decision.

> **Field coverage definition:** 100% means every physical column that actually exists in the declared Joomla 3 source core tables has been discovered, inventoried, and assigned a migration decision. This is stronger than relying only on a hard-coded field list because it also detects source-database deviations from the Joomla 3.10.12 baseline.

---

## Completion Criteria

Before core migration is considered ready:

```text
Actual source core tables inventoried = 100%
Actual source core fields discovered  = 100%
Core fields inventoried               = 100%
Core tables classified                = 100%
Field mapping decisions completed     = 100%
Mapping decisions completed           = 100%

Missing inventory fields              = 0
Duplicate inventory fields            = 0
Unclassified source fields            = 0
Unclassified tables                   = 0
Unmapped required fields              = 0
Unresolved dependencies               = 0
Unexplained source tables             = 0
```

Only after the mapping gate passes should migration scripts execute.

> The `78/78` coverage applies to the official Joomla 3.10.12 installation schema baseline. The migration inventory must still scan the real source database and flag any additional, missing, customized, third-party, or extension-owned tables before migration.
