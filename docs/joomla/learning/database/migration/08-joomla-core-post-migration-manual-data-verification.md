# Joomla Core Post-Migration Manual Data Verification Queries

> Manual verification guide for **Joomla 3.10.12 → Joomla 6.1.2** with canonical-core coverage, actual-database discovery, and one complete copy-and-run SQL block for each version.

## Summary

| Scope | Joomla 3 | Joomla 6 |
|---|---:|---:|
| Canonical core tables | **78** | **76** |
| Exact `COUNT(*)` queries | **78** | **76** |
| Full-row `SELECT *` queries | **78** | **76** |
| Canonical query coverage | **100%** | **100%** |
| Actual physical DB coverage | Runtime inventory + missing/extra-table detection | Runtime inventory + missing/extra-table detection |

> [!IMPORTANT]
> **100% query coverage does not automatically mean 100% migration correctness.**  
> Some rows/fields are transformed, remapped, rebuilt, archived, ignored, recreated, or target-owned. Compare according to the migration contract, not raw IDs or row counts alone.

## Source of truth

- [`01-joomla-core-migration-groups-v3.md`](01-joomla-core-migration-groups-v3.md)
- [`02-joomla-core-migration-groups-v6.md`](02-joomla-core-migration-groups-v6.md)
- [`03-joomla-core-migration-fields-v3.md`](03-joomla-core-migration-fields-v3.md)
- [`04-joomla-core-migration-fields-v6.md`](04-joomla-core-migration-fields-v6.md)
- [`05-joomla-core-j3-j6-migration-contract.md`](05-joomla-core-j3-j6-migration-contract.md)
- [`06-joomla-core-table-mapping-migration.md`](06-joomla-core-table-mapping-migration.md)
- [`07-joomla-core-field-mapping-migration.md`](07-joomla-core-field-mapping-migration.md)

## What “100% actual data coverage” means here

To claim complete manual coverage for the selected Joomla prefix:

1. every physical table under that prefix must appear in the runtime inventory;
2. every canonical core table must be present or explicitly proven `ABSENT_SOURCE` where allowed;
3. every canonical table must have one exact `COUNT(*)` query;
4. every canonical table must have one full-row `SELECT *` query;
5. every unexpected physical table must be classified and queried if it contains migration-relevant data;
6. transformed/rebuilt/archived/target-owned data must be reconciled by its handling rule;
7. unexplained missing business data must be zero.

Because the data query uses `SELECT *`, every physical column of each queried table is visible. This still does not replace semantic source-to-target reconciliation.

## How to use

1. Use staging/read-only copies when possible.
2. Select the correct J3 or J6 database.
3. Replace every `#__` in the full SQL block with the real prefix.
4. Set `@table_prefix = 'REAL_PREFIX_'`.
5. Run the coverage gate first.
6. Investigate all missing canonical tables.
7. Investigate all tables reported as `NOT_IN_CANONICAL_CORE_MANIFEST_REVIEW_REQUIRED`.
8. Run the canonical COUNT + data queries.
9. For extra/custom/third-party tables, run the generated queries too.
10. Do not approve migration while any discrepancy is unexplained.

> [!WARNING]
> Full `SELECT *` queries may return very large result sets.

## Handling rules

| Handling | Verification expectation |
|---|---|
| `MIGRATE`, `TRANSFORM`, `MAP` | Business identity/value must survive approved transformation/remapping. |
| `REFERENCE_ONLY` | Reconcile by semantic identity; raw counts/IDs may differ. |
| `REBUILD`, `GENERATE`, `DERIVED` | Verify regenerated Joomla 6 state. |
| `TARGET_OWNED` | Preserve clean Joomla 6 state. |
| `RECREATE`, `RE-ENROL` | Verify equivalent Joomla 6 state was recreated. |
| `ARCHIVE` | Verify source evidence in the approved archive. |
| `IGNORE` | Confirm intentional exclusion of runtime/security data. |
| `ABSENT_SOURCE` | Accept only with physical source-inventory evidence. |

## Table of contents

- [Joomla 3 manifest](#joomla-3-manifest)
  - [J3 G0](#j3-g0)
  - [J3 G1](#j3-g1)
  - [J3 G2](#j3-g2)
  - [J3 G3](#j3-g3)
  - [J3 G4](#j3-g4)
  - [J3 G5](#j3-g5)
  - [J3 G6](#j3-g6)
  - [J3 G7](#j3-g7)
  - [J3 G8](#j3-g8)
- [Full Copy-and-Run SQL — Joomla 3](#j3-full-copy)
- [Joomla 6 manifest](#joomla-6-manifest)
  - [J6 G0](#j6-g0)
  - [J6 G1](#j6-g1)
  - [J6 G2](#j6-g2)
  - [J6 G3](#j6-g3)
  - [J6 G4](#j6-g4)
  - [J6 G5](#j6-g5)
  - [J6 G6](#j6-g6)
  - [J6 G7](#j6-g7)
  - [J6 G8](#j6-g8)
- [Full Copy-and-Run SQL — Joomla 6](#j6-full-copy)
- [Coverage acceptance](#coverage-acceptance)
- [Manual acceptance checklist](#manual-acceptance-checklist)

---

<a id="joomla-3-manifest"></a>

## Joomla 3 Manifest

**Baseline:** Joomla 3.10.12 — **78 core tables / 711 fields**.

For earlier Joomla 3 lineages, missing canonical tables remain visible and may only be accepted as `ABSENT_SOURCE` when actual inventory proves absence.

<a id="j3-g0"></a>

### G0 — System Reference

- `#__extensions` — **REFERENCE_ONLY**
- `#__schemas` — **REFERENCE_ONLY**
- `#__update_sites` — **REFERENCE_ONLY**
- `#__update_sites_extensions` — **REFERENCE_ONLY**
- `#__updates` — **REFERENCE_ONLY**

<a id="j3-g1"></a>

### G1 — Users and Access Foundation

- `#__languages` — **TRANSFORM**
- `#__usergroups` — **TRANSFORM**
- `#__users` — **TRANSFORM**
- `#__user_usergroup_map` — **TRANSFORM**
- `#__viewlevels` — **TRANSFORM**
- `#__user_profiles` — **TRANSFORM**

<a id="j3-g2"></a>

### G2 — Taxonomy and Shared Definitions

- `#__assets` — **REBUILD**
- `#__categories` — **TRANSFORM**
- `#__tags` — **TRANSFORM**
- `#__content_types` — **REFERENCE_ONLY**
- `#__fields_groups` — **TRANSFORM**
- `#__fields` — **TRANSFORM**
- `#__fields_categories` — **TRANSFORM**

<a id="j3-g3"></a>

### G3 — Main Content

- `#__content` — **TRANSFORM**
- `#__content_frontpage` — **TRANSFORM**
- `#__content_rating` — **TRANSFORM**

<a id="j3-g4"></a>

### G4 — Content Relations

- `#__contentitem_tag_map` — **TRANSFORM**
- `#__fields_values` — **TRANSFORM**
- `#__associations` — **TRANSFORM**
- `#__ucm_base` — **REBUILD**
- `#__ucm_content` — **REBUILD**
- `#__ucm_history` — **TRANSFORM → #__history**

<a id="j3-g5"></a>

### G5 — Menu and Presentation

- `#__template_styles` — **TRANSFORM**
- `#__menu_types` — **TRANSFORM**
- `#__menu` — **TRANSFORM**

<a id="j3-g6"></a>

### G6 — Modules

- `#__modules` — **TRANSFORM**
- `#__modules_menu` — **TRANSFORM**

<a id="j3-g7"></a>

### G7 — Supporting Core Components

- `#__contact_details` — **TRANSFORM**
- `#__newsfeeds` — **TRANSFORM**
- `#__banners` — **TRANSFORM**
- `#__banner_clients` — **TRANSFORM**
- `#__banner_tracks` — **ARCHIVE**
- `#__redirect_links` — **TRANSFORM**
- `#__messages` — **TRANSFORM**
- `#__messages_cfg` — **TRANSFORM**
- `#__user_notes` — **TRANSFORM**
- `#__privacy_requests` — **TRANSFORM / ABSENT_SOURCE allowed if proven**
- `#__privacy_consents` — **TRANSFORM / ABSENT_SOURCE allowed if proven**
- `#__action_logs_extensions` — **REFERENCE_ONLY / ABSENT_SOURCE allowed if proven**
- `#__action_log_config` — **REFERENCE_ONLY / ABSENT_SOURCE allowed if proven**
- `#__action_logs_users` — **TRANSFORM / ABSENT_SOURCE allowed if proven**

<a id="j3-g8"></a>

### G8 — Runtime, Generated, Historical, and Excluded

- `#__session` — **IGNORE**
- `#__user_keys` — **IGNORE**
- `#__finder_filters` — **TRANSFORM**
- `#__finder_links` — **REBUILD**
- `#__finder_links_terms0` — **REBUILD**
- `#__finder_links_terms1` — **REBUILD**
- `#__finder_links_terms2` — **REBUILD**
- `#__finder_links_terms3` — **REBUILD**
- `#__finder_links_terms4` — **REBUILD**
- `#__finder_links_terms5` — **REBUILD**
- `#__finder_links_terms6` — **REBUILD**
- `#__finder_links_terms7` — **REBUILD**
- `#__finder_links_terms8` — **REBUILD**
- `#__finder_links_terms9` — **REBUILD**
- `#__finder_links_termsa` — **REBUILD**
- `#__finder_links_termsb` — **REBUILD**
- `#__finder_links_termsc` — **REBUILD**
- `#__finder_links_termsd` — **REBUILD**
- `#__finder_links_termse` — **REBUILD**
- `#__finder_links_termsf` — **REBUILD**
- `#__finder_taxonomy` — **REBUILD**
- `#__finder_taxonomy_map` — **REBUILD**
- `#__finder_terms` — **REBUILD**
- `#__finder_terms_common` — **TRANSFORM**
- `#__finder_tokens` — **REBUILD**
- `#__finder_tokens_aggregate` — **REBUILD**
- `#__finder_types` — **REBUILD**
- `#__action_logs` — **ARCHIVE / ABSENT_SOURCE allowed if proven**
- `#__core_log_searches` — **ARCHIVE**
- `#__overrider` — **TRANSFORM**
- `#__postinstall_messages` — **REBUILD**
- `#__utf8_conversion` — **DERIVED**

<a id="j3-full-copy"></a>

## Full Copy-and-Run SQL — Joomla 3

Copy this entire region. Before running:

- select the J3 source database;
- replace `#__` with the real J3 prefix;
- set `@table_prefix` to the same real prefix.

```sql
-- ============================================================
-- Joomla 3.10.12: ACTUAL DATABASE COVERAGE GATE
-- ============================================================
SET @db_name = DATABASE();
SET @table_prefix = 'REPLACE_WITH_REAL_PREFIX_';

DROP TEMPORARY TABLE IF EXISTS tmp_expected_joomla_core_tables;
CREATE TEMPORARY TABLE tmp_expected_joomla_core_tables (
    group_code VARCHAR(8) NOT NULL,
    table_suffix VARCHAR(128) NOT NULL,
    handling VARCHAR(128) NOT NULL,
    PRIMARY KEY (table_suffix)
);

INSERT INTO tmp_expected_joomla_core_tables (group_code, table_suffix, handling) VALUES
('G0', 'extensions', 'REFERENCE_ONLY'),
('G0', 'schemas', 'REFERENCE_ONLY'),
('G0', 'update_sites', 'REFERENCE_ONLY'),
('G0', 'update_sites_extensions', 'REFERENCE_ONLY'),
('G0', 'updates', 'REFERENCE_ONLY'),
('G1', 'languages', 'TRANSFORM'),
('G1', 'usergroups', 'TRANSFORM'),
('G1', 'users', 'TRANSFORM'),
('G1', 'user_usergroup_map', 'TRANSFORM'),
('G1', 'viewlevels', 'TRANSFORM'),
('G1', 'user_profiles', 'TRANSFORM'),
('G2', 'assets', 'REBUILD'),
('G2', 'categories', 'TRANSFORM'),
('G2', 'tags', 'TRANSFORM'),
('G2', 'content_types', 'REFERENCE_ONLY'),
('G2', 'fields_groups', 'TRANSFORM'),
('G2', 'fields', 'TRANSFORM'),
('G2', 'fields_categories', 'TRANSFORM'),
('G3', 'content', 'TRANSFORM'),
('G3', 'content_frontpage', 'TRANSFORM'),
('G3', 'content_rating', 'TRANSFORM'),
('G4', 'contentitem_tag_map', 'TRANSFORM'),
('G4', 'fields_values', 'TRANSFORM'),
('G4', 'associations', 'TRANSFORM'),
('G4', 'ucm_base', 'REBUILD'),
('G4', 'ucm_content', 'REBUILD'),
('G4', 'ucm_history', 'TRANSFORM_TO_HISTORY'),
('G5', 'template_styles', 'TRANSFORM'),
('G5', 'menu_types', 'TRANSFORM'),
('G5', 'menu', 'TRANSFORM'),
('G6', 'modules', 'TRANSFORM'),
('G6', 'modules_menu', 'TRANSFORM'),
('G7', 'contact_details', 'TRANSFORM'),
('G7', 'newsfeeds', 'TRANSFORM'),
('G7', 'banners', 'TRANSFORM'),
('G7', 'banner_clients', 'TRANSFORM'),
('G7', 'banner_tracks', 'ARCHIVE'),
('G7', 'redirect_links', 'TRANSFORM'),
('G7', 'messages', 'TRANSFORM'),
('G7', 'messages_cfg', 'TRANSFORM'),
('G7', 'user_notes', 'TRANSFORM'),
('G7', 'privacy_requests', 'TRANSFORM_OR_PROVEN_ABSENT_SOURCE'),
('G7', 'privacy_consents', 'TRANSFORM_OR_PROVEN_ABSENT_SOURCE'),
('G7', 'action_logs_extensions', 'REFERENCE_ONLY_OR_PROVEN_ABSENT_SOURCE'),
('G7', 'action_log_config', 'REFERENCE_ONLY_OR_PROVEN_ABSENT_SOURCE'),
('G7', 'action_logs_users', 'TRANSFORM_OR_PROVEN_ABSENT_SOURCE'),
('G8', 'session', 'IGNORE'),
('G8', 'user_keys', 'IGNORE'),
('G8', 'finder_filters', 'TRANSFORM'),
('G8', 'finder_links', 'REBUILD'),
('G8', 'finder_links_terms0', 'REBUILD'),
('G8', 'finder_links_terms1', 'REBUILD'),
('G8', 'finder_links_terms2', 'REBUILD'),
('G8', 'finder_links_terms3', 'REBUILD'),
('G8', 'finder_links_terms4', 'REBUILD'),
('G8', 'finder_links_terms5', 'REBUILD'),
('G8', 'finder_links_terms6', 'REBUILD'),
('G8', 'finder_links_terms7', 'REBUILD'),
('G8', 'finder_links_terms8', 'REBUILD'),
('G8', 'finder_links_terms9', 'REBUILD'),
('G8', 'finder_links_termsa', 'REBUILD'),
('G8', 'finder_links_termsb', 'REBUILD'),
('G8', 'finder_links_termsc', 'REBUILD'),
('G8', 'finder_links_termsd', 'REBUILD'),
('G8', 'finder_links_termse', 'REBUILD'),
('G8', 'finder_links_termsf', 'REBUILD'),
('G8', 'finder_taxonomy', 'REBUILD'),
('G8', 'finder_taxonomy_map', 'REBUILD'),
('G8', 'finder_terms', 'REBUILD'),
('G8', 'finder_terms_common', 'TRANSFORM'),
('G8', 'finder_tokens', 'REBUILD'),
('G8', 'finder_tokens_aggregate', 'REBUILD'),
('G8', 'finder_types', 'REBUILD'),
('G8', 'action_logs', 'ARCHIVE_OR_PROVEN_ABSENT_SOURCE'),
('G8', 'core_log_searches', 'ARCHIVE'),
('G8', 'overrider', 'TRANSFORM'),
('G8', 'postinstall_messages', 'REBUILD'),
('G8', 'utf8_conversion', 'DERIVED');

SELECT
    'Joomla 3.10.12' AS baseline,
    COUNT(*) AS expected_core_tables,
    SUM(CASE WHEN t.TABLE_NAME IS NOT NULL THEN 1 ELSE 0 END) AS physically_present_core_tables,
    COUNT(*) - SUM(CASE WHEN t.TABLE_NAME IS NOT NULL THEN 1 ELSE 0 END) AS missing_canonical_tables,
    ROUND(100 * SUM(CASE WHEN t.TABLE_NAME IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS canonical_table_presence_pct
FROM tmp_expected_joomla_core_tables AS e
LEFT JOIN information_schema.TABLES AS t
    ON t.TABLE_SCHEMA = @db_name
   AND t.TABLE_TYPE = 'BASE TABLE'
   AND t.TABLE_NAME = CONCAT(@table_prefix, e.table_suffix);

SELECT
    e.group_code,
    CONCAT(@table_prefix, e.table_suffix) AS expected_physical_table,
    e.handling,
    'MISSING_CANONICAL_TABLE' AS coverage_status
FROM tmp_expected_joomla_core_tables AS e
LEFT JOIN information_schema.TABLES AS t
    ON t.TABLE_SCHEMA = @db_name
   AND t.TABLE_TYPE = 'BASE TABLE'
   AND t.TABLE_NAME = CONCAT(@table_prefix, e.table_suffix)
WHERE t.TABLE_NAME IS NULL
ORDER BY e.group_code, e.table_suffix;

SELECT
    t.TABLE_NAME AS actual_table,
    t.ENGINE,
    t.TABLE_COLLATION,
    'NOT_IN_CANONICAL_CORE_MANIFEST_REVIEW_REQUIRED' AS coverage_status
FROM information_schema.TABLES AS t
LEFT JOIN tmp_expected_joomla_core_tables AS e
    ON t.TABLE_NAME = CONCAT(@table_prefix, e.table_suffix)
WHERE t.TABLE_SCHEMA = @db_name
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME LIKE CONCAT(@table_prefix, '%')
  AND e.table_suffix IS NULL
ORDER BY t.TABLE_NAME;

SELECT
    t.TABLE_NAME,
    CONCAT('SELECT COUNT(*) AS row_count FROM `', REPLACE(t.TABLE_NAME, '`', '``'), '`;') AS generated_count_query,
    CONCAT('SELECT * FROM `', REPLACE(t.TABLE_NAME, '`', '``'), '`;') AS generated_data_query
FROM information_schema.TABLES AS t
WHERE t.TABLE_SCHEMA = @db_name
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME LIKE CONCAT(@table_prefix, '%')
ORDER BY t.TABLE_NAME;

SELECT
    t.TABLE_NAME,
    t.ENGINE,
    t.TABLE_COLLATION,
    t.TABLE_ROWS AS engine_estimated_rows,
    t.DATA_LENGTH,
    t.INDEX_LENGTH
FROM information_schema.TABLES AS t
WHERE t.TABLE_SCHEMA = @db_name
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME LIKE CONCAT(@table_prefix, '%')
ORDER BY t.TABLE_NAME;

-- ============================================================
-- J3 CANONICAL DATA: 78 COUNT QUERIES + 78 FULL-ROW QUERIES
-- ============================================================
-- G0 — System Reference
SELECT COUNT(*) AS row_count FROM `#__extensions`;
SELECT * FROM `#__extensions`;
SELECT COUNT(*) AS row_count FROM `#__schemas`;
SELECT * FROM `#__schemas`;
SELECT COUNT(*) AS row_count FROM `#__update_sites`;
SELECT * FROM `#__update_sites`;
SELECT COUNT(*) AS row_count FROM `#__update_sites_extensions`;
SELECT * FROM `#__update_sites_extensions`;
SELECT COUNT(*) AS row_count FROM `#__updates`;
SELECT * FROM `#__updates`;

-- G1 — Users and Access Foundation
SELECT COUNT(*) AS row_count FROM `#__languages`;
SELECT * FROM `#__languages`;
SELECT COUNT(*) AS row_count FROM `#__usergroups`;
SELECT * FROM `#__usergroups`;
SELECT COUNT(*) AS row_count FROM `#__users`;
SELECT * FROM `#__users`;
SELECT COUNT(*) AS row_count FROM `#__user_usergroup_map`;
SELECT * FROM `#__user_usergroup_map`;
SELECT COUNT(*) AS row_count FROM `#__viewlevels`;
SELECT * FROM `#__viewlevels`;
SELECT COUNT(*) AS row_count FROM `#__user_profiles`;
SELECT * FROM `#__user_profiles`;

-- G2 — Taxonomy and Shared Definitions
SELECT COUNT(*) AS row_count FROM `#__assets`;
SELECT * FROM `#__assets`;
SELECT COUNT(*) AS row_count FROM `#__categories`;
SELECT * FROM `#__categories`;
SELECT COUNT(*) AS row_count FROM `#__tags`;
SELECT * FROM `#__tags`;
SELECT COUNT(*) AS row_count FROM `#__content_types`;
SELECT * FROM `#__content_types`;
SELECT COUNT(*) AS row_count FROM `#__fields_groups`;
SELECT * FROM `#__fields_groups`;
SELECT COUNT(*) AS row_count FROM `#__fields`;
SELECT * FROM `#__fields`;
SELECT COUNT(*) AS row_count FROM `#__fields_categories`;
SELECT * FROM `#__fields_categories`;

-- G3 — Main Content
SELECT COUNT(*) AS row_count FROM `#__content`;
SELECT * FROM `#__content`;
SELECT COUNT(*) AS row_count FROM `#__content_frontpage`;
SELECT * FROM `#__content_frontpage`;
SELECT COUNT(*) AS row_count FROM `#__content_rating`;
SELECT * FROM `#__content_rating`;

-- G4 — Content Relations
SELECT COUNT(*) AS row_count FROM `#__contentitem_tag_map`;
SELECT * FROM `#__contentitem_tag_map`;
SELECT COUNT(*) AS row_count FROM `#__fields_values`;
SELECT * FROM `#__fields_values`;
SELECT COUNT(*) AS row_count FROM `#__associations`;
SELECT * FROM `#__associations`;
SELECT COUNT(*) AS row_count FROM `#__ucm_base`;
SELECT * FROM `#__ucm_base`;
SELECT COUNT(*) AS row_count FROM `#__ucm_content`;
SELECT * FROM `#__ucm_content`;
SELECT COUNT(*) AS row_count FROM `#__ucm_history`;
SELECT * FROM `#__ucm_history`;

-- G5 — Menu and Presentation
SELECT COUNT(*) AS row_count FROM `#__template_styles`;
SELECT * FROM `#__template_styles`;
SELECT COUNT(*) AS row_count FROM `#__menu_types`;
SELECT * FROM `#__menu_types`;
SELECT COUNT(*) AS row_count FROM `#__menu`;
SELECT * FROM `#__menu`;

-- G6 — Modules
SELECT COUNT(*) AS row_count FROM `#__modules`;
SELECT * FROM `#__modules`;
SELECT COUNT(*) AS row_count FROM `#__modules_menu`;
SELECT * FROM `#__modules_menu`;

-- G7 — Supporting Core Components
SELECT COUNT(*) AS row_count FROM `#__contact_details`;
SELECT * FROM `#__contact_details`;
SELECT COUNT(*) AS row_count FROM `#__newsfeeds`;
SELECT * FROM `#__newsfeeds`;
SELECT COUNT(*) AS row_count FROM `#__banners`;
SELECT * FROM `#__banners`;
SELECT COUNT(*) AS row_count FROM `#__banner_clients`;
SELECT * FROM `#__banner_clients`;
SELECT COUNT(*) AS row_count FROM `#__banner_tracks`;
SELECT * FROM `#__banner_tracks`;
SELECT COUNT(*) AS row_count FROM `#__redirect_links`;
SELECT * FROM `#__redirect_links`;
SELECT COUNT(*) AS row_count FROM `#__messages`;
SELECT * FROM `#__messages`;
SELECT COUNT(*) AS row_count FROM `#__messages_cfg`;
SELECT * FROM `#__messages_cfg`;
SELECT COUNT(*) AS row_count FROM `#__user_notes`;
SELECT * FROM `#__user_notes`;
SELECT COUNT(*) AS row_count FROM `#__privacy_requests`;
SELECT * FROM `#__privacy_requests`;
SELECT COUNT(*) AS row_count FROM `#__privacy_consents`;
SELECT * FROM `#__privacy_consents`;
SELECT COUNT(*) AS row_count FROM `#__action_logs_extensions`;
SELECT * FROM `#__action_logs_extensions`;
SELECT COUNT(*) AS row_count FROM `#__action_log_config`;
SELECT * FROM `#__action_log_config`;
SELECT COUNT(*) AS row_count FROM `#__action_logs_users`;
SELECT * FROM `#__action_logs_users`;

-- G8 — Runtime, Generated, Historical, and Excluded
SELECT COUNT(*) AS row_count FROM `#__session`;
SELECT * FROM `#__session`;
SELECT COUNT(*) AS row_count FROM `#__user_keys`;
SELECT * FROM `#__user_keys`;
SELECT COUNT(*) AS row_count FROM `#__finder_filters`;
SELECT * FROM `#__finder_filters`;
SELECT COUNT(*) AS row_count FROM `#__finder_links`;
SELECT * FROM `#__finder_links`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms0`;
SELECT * FROM `#__finder_links_terms0`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms1`;
SELECT * FROM `#__finder_links_terms1`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms2`;
SELECT * FROM `#__finder_links_terms2`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms3`;
SELECT * FROM `#__finder_links_terms3`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms4`;
SELECT * FROM `#__finder_links_terms4`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms5`;
SELECT * FROM `#__finder_links_terms5`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms6`;
SELECT * FROM `#__finder_links_terms6`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms7`;
SELECT * FROM `#__finder_links_terms7`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms8`;
SELECT * FROM `#__finder_links_terms8`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms9`;
SELECT * FROM `#__finder_links_terms9`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsa`;
SELECT * FROM `#__finder_links_termsa`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsb`;
SELECT * FROM `#__finder_links_termsb`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsc`;
SELECT * FROM `#__finder_links_termsc`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsd`;
SELECT * FROM `#__finder_links_termsd`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_termse`;
SELECT * FROM `#__finder_links_termse`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsf`;
SELECT * FROM `#__finder_links_termsf`;
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy`;
SELECT * FROM `#__finder_taxonomy`;
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy_map`;
SELECT * FROM `#__finder_taxonomy_map`;
SELECT COUNT(*) AS row_count FROM `#__finder_terms`;
SELECT * FROM `#__finder_terms`;
SELECT COUNT(*) AS row_count FROM `#__finder_terms_common`;
SELECT * FROM `#__finder_terms_common`;
SELECT COUNT(*) AS row_count FROM `#__finder_tokens`;
SELECT * FROM `#__finder_tokens`;
SELECT COUNT(*) AS row_count FROM `#__finder_tokens_aggregate`;
SELECT * FROM `#__finder_tokens_aggregate`;
SELECT COUNT(*) AS row_count FROM `#__finder_types`;
SELECT * FROM `#__finder_types`;
SELECT COUNT(*) AS row_count FROM `#__action_logs`;
SELECT * FROM `#__action_logs`;
SELECT COUNT(*) AS row_count FROM `#__core_log_searches`;
SELECT * FROM `#__core_log_searches`;
SELECT COUNT(*) AS row_count FROM `#__overrider`;
SELECT * FROM `#__overrider`;
SELECT COUNT(*) AS row_count FROM `#__postinstall_messages`;
SELECT * FROM `#__postinstall_messages`;
SELECT COUNT(*) AS row_count FROM `#__utf8_conversion`;
SELECT * FROM `#__utf8_conversion`;
```

---

<a id="joomla-6-manifest"></a>

## Joomla 6 Manifest

**Baseline:** Joomla 6.1.2 — **76 core tables / 832 fields**.

A missing canonical Joomla 6 table normally means the target schema requires investigation.

<a id="j6-g0"></a>

### G0 — System Reference

- `#__extensions` — **REFERENCE_ONLY / TARGET_OWNED**
- `#__schemas` — **REFERENCE_ONLY / TARGET_OWNED**
- `#__update_sites` — **REFERENCE_ONLY / TARGET_OWNED**
- `#__update_sites_extensions` — **REFERENCE_ONLY / TARGET_OWNED**
- `#__updates` — **REFERENCE_ONLY / TARGET_OWNED**
- `#__tuf_metadata` — **REFERENCE_ONLY / TARGET_OWNED**

<a id="j6-g1"></a>

### G1 — Users and Access Foundation

- `#__languages` — **MIGRATE / MAP**
- `#__usergroups` — **MIGRATE / MAP**
- `#__users` — **MIGRATE / MAP**
- `#__user_usergroup_map` — **MIGRATE / MAP**
- `#__viewlevels` — **MIGRATE / MAP**
- `#__user_profiles` — **MIGRATE / MAP**

<a id="j6-g2"></a>

### G2 — Taxonomy and Shared Definitions

- `#__assets` — **REBUILD / RECONCILE**
- `#__categories` — **MIGRATE / MAP**
- `#__tags` — **MIGRATE / MAP**
- `#__content_types` — **REFERENCE_ONLY / MAP**
- `#__fields_groups` — **MIGRATE / MAP**
- `#__fields` — **MIGRATE / MAP**
- `#__fields_categories` — **MIGRATE / MAP**
- `#__workflows` — **RECREATE / MAP**
- `#__workflow_stages` — **RECREATE / MAP**
- `#__workflow_transitions` — **RECREATE / MAP**

<a id="j6-g3"></a>

### G3 — Main Content

- `#__content` — **MIGRATE / MAP**
- `#__content_frontpage` — **MIGRATE / MAP**
- `#__content_rating` — **MIGRATE / MAP**

<a id="j6-g4"></a>

### G4 — Content Relations

- `#__contentitem_tag_map` — **MIGRATE / MAP**
- `#__fields_values` — **MIGRATE / MAP**
- `#__associations` — **MIGRATE / MAP**
- `#__ucm_base` — **REBUILD / VALIDATE**
- `#__ucm_content` — **REBUILD / VALIDATE**
- `#__history` — **ARCHIVE / OPTIONAL_MIGRATE**
- `#__workflow_associations` — **GENERATE / MAP**
- `#__schemaorg` — **MIGRATE / MAP**

<a id="j6-g5"></a>

### G5 — Menu and Presentation

- `#__template_styles` — **TRANSFORM / RECREATE**
- `#__template_overrides` — **REBUILD / REVIEW**
- `#__menu_types` — **MIGRATE / MAP**
- `#__menu` — **MIGRATE / MAP**

<a id="j6-g6"></a>

### G6 — Modules

- `#__modules` — **MIGRATE / MAP**
- `#__modules_menu` — **MIGRATE / MAP**

<a id="j6-g7"></a>

### G7 — Supporting Core Components

- `#__contact_details` — **MIGRATE / MAP**
- `#__newsfeeds` — **MIGRATE / MAP**
- `#__banners` — **MIGRATE / MAP**
- `#__banner_clients` — **MIGRATE / MAP**
- `#__banner_tracks` — **ARCHIVE / OPTIONAL_MIGRATE**
- `#__redirect_links` — **MIGRATE / MAP**
- `#__messages` — **MIGRATE / OPTIONAL**
- `#__messages_cfg` — **MIGRATE / OPTIONAL**
- `#__user_notes` — **MIGRATE / MAP**
- `#__privacy_requests` — **MIGRATE / ARCHIVE**
- `#__privacy_consents` — **MIGRATE / ARCHIVE**
- `#__mail_templates` — **MERGE / RECREATE**
- `#__scheduler_tasks` — **RECREATE / SELECTIVE**
- `#__action_logs_extensions` — **TARGET_OWNED / MERGE**
- `#__action_log_config` — **TARGET_OWNED / MERGE**
- `#__action_logs_users` — **MIGRATE / REVIEW**

<a id="j6-g8"></a>

### G8 — Runtime, Generated, and Target-Owned Data

- `#__session` — **IGNORE**
- `#__user_keys` — **IGNORE**
- `#__user_mfa` — **RECREATE / RE-ENROL**
- `#__webauthn_credentials` — **RECREATE / RE-ENROL**
- `#__scheduler_logs` — **IGNORE / ARCHIVE**
- `#__action_logs` — **IGNORE / ARCHIVE**
- `#__finder_filters` — **MIGRATE / RECREATE / REVIEW**
- `#__finder_links` — **REBUILD**
- `#__finder_links_terms` — **REBUILD**
- `#__finder_logging` — **IGNORE / ARCHIVE**
- `#__finder_taxonomy` — **REBUILD**
- `#__finder_taxonomy_map` — **REBUILD**
- `#__finder_terms` — **REBUILD**
- `#__finder_terms_common` — **TARGET_OWNED / REVIEW**
- `#__finder_tokens` — **REBUILD**
- `#__finder_tokens_aggregate` — **REBUILD**
- `#__finder_types` — **REBUILD**
- `#__postinstall_messages` — **TARGET_OWNED**
- `#__overrider` — **MIGRATE / RECREATE / REVIEW**
- `#__guidedtours` — **TARGET_OWNED**
- `#__guidedtour_steps` — **TARGET_OWNED**

<a id="j6-full-copy"></a>

## Full Copy-and-Run SQL — Joomla 6

Copy this entire region. Before running:

- select the J6 target database;
- replace `#__` with the real J6 prefix;
- set `@table_prefix` to the same real prefix.

```sql
-- ============================================================
-- Joomla 6.1.2: ACTUAL DATABASE COVERAGE GATE
-- ============================================================
SET @db_name = DATABASE();
SET @table_prefix = 'REPLACE_WITH_REAL_PREFIX_';

DROP TEMPORARY TABLE IF EXISTS tmp_expected_joomla_core_tables;
CREATE TEMPORARY TABLE tmp_expected_joomla_core_tables (
    group_code VARCHAR(8) NOT NULL,
    table_suffix VARCHAR(128) NOT NULL,
    handling VARCHAR(128) NOT NULL,
    PRIMARY KEY (table_suffix)
);

INSERT INTO tmp_expected_joomla_core_tables (group_code, table_suffix, handling) VALUES
('G0', 'extensions', 'REFERENCE_ONLY_TARGET_OWNED'),
('G0', 'schemas', 'REFERENCE_ONLY_TARGET_OWNED'),
('G0', 'update_sites', 'REFERENCE_ONLY_TARGET_OWNED'),
('G0', 'update_sites_extensions', 'REFERENCE_ONLY_TARGET_OWNED'),
('G0', 'updates', 'REFERENCE_ONLY_TARGET_OWNED'),
('G0', 'tuf_metadata', 'REFERENCE_ONLY_TARGET_OWNED'),
('G1', 'languages', 'MIGRATE_MAP'),
('G1', 'usergroups', 'MIGRATE_MAP'),
('G1', 'users', 'MIGRATE_MAP'),
('G1', 'user_usergroup_map', 'MIGRATE_MAP'),
('G1', 'viewlevels', 'MIGRATE_MAP'),
('G1', 'user_profiles', 'MIGRATE_MAP'),
('G2', 'assets', 'REBUILD_RECONCILE'),
('G2', 'categories', 'MIGRATE_MAP'),
('G2', 'tags', 'MIGRATE_MAP'),
('G2', 'content_types', 'REFERENCE_ONLY_MAP'),
('G2', 'fields_groups', 'MIGRATE_MAP'),
('G2', 'fields', 'MIGRATE_MAP'),
('G2', 'fields_categories', 'MIGRATE_MAP'),
('G2', 'workflows', 'RECREATE_MAP'),
('G2', 'workflow_stages', 'RECREATE_MAP'),
('G2', 'workflow_transitions', 'RECREATE_MAP'),
('G3', 'content', 'MIGRATE_MAP'),
('G3', 'content_frontpage', 'MIGRATE_MAP'),
('G3', 'content_rating', 'MIGRATE_MAP'),
('G4', 'contentitem_tag_map', 'MIGRATE_MAP'),
('G4', 'fields_values', 'MIGRATE_MAP'),
('G4', 'associations', 'MIGRATE_MAP'),
('G4', 'ucm_base', 'REBUILD_VALIDATE'),
('G4', 'ucm_content', 'REBUILD_VALIDATE'),
('G4', 'history', 'ARCHIVE_OPTIONAL_MIGRATE'),
('G4', 'workflow_associations', 'GENERATE_MAP'),
('G4', 'schemaorg', 'MIGRATE_MAP'),
('G5', 'template_styles', 'TRANSFORM_RECREATE'),
('G5', 'template_overrides', 'REBUILD_REVIEW'),
('G5', 'menu_types', 'MIGRATE_MAP'),
('G5', 'menu', 'MIGRATE_MAP'),
('G6', 'modules', 'MIGRATE_MAP'),
('G6', 'modules_menu', 'MIGRATE_MAP'),
('G7', 'contact_details', 'MIGRATE_MAP'),
('G7', 'newsfeeds', 'MIGRATE_MAP'),
('G7', 'banners', 'MIGRATE_MAP'),
('G7', 'banner_clients', 'MIGRATE_MAP'),
('G7', 'banner_tracks', 'ARCHIVE_OPTIONAL_MIGRATE'),
('G7', 'redirect_links', 'MIGRATE_MAP'),
('G7', 'messages', 'MIGRATE_OPTIONAL'),
('G7', 'messages_cfg', 'MIGRATE_OPTIONAL'),
('G7', 'user_notes', 'MIGRATE_MAP'),
('G7', 'privacy_requests', 'MIGRATE_ARCHIVE'),
('G7', 'privacy_consents', 'MIGRATE_ARCHIVE'),
('G7', 'mail_templates', 'MERGE_RECREATE'),
('G7', 'scheduler_tasks', 'RECREATE_SELECTIVE'),
('G7', 'action_logs_extensions', 'TARGET_OWNED_MERGE'),
('G7', 'action_log_config', 'TARGET_OWNED_MERGE'),
('G7', 'action_logs_users', 'MIGRATE_REVIEW'),
('G8', 'session', 'IGNORE'),
('G8', 'user_keys', 'IGNORE'),
('G8', 'user_mfa', 'RECREATE_RE_ENROL'),
('G8', 'webauthn_credentials', 'RECREATE_RE_ENROL'),
('G8', 'scheduler_logs', 'IGNORE_ARCHIVE'),
('G8', 'action_logs', 'IGNORE_ARCHIVE'),
('G8', 'finder_filters', 'MIGRATE_RECREATE_REVIEW'),
('G8', 'finder_links', 'REBUILD'),
('G8', 'finder_links_terms', 'REBUILD'),
('G8', 'finder_logging', 'IGNORE_ARCHIVE'),
('G8', 'finder_taxonomy', 'REBUILD'),
('G8', 'finder_taxonomy_map', 'REBUILD'),
('G8', 'finder_terms', 'REBUILD'),
('G8', 'finder_terms_common', 'TARGET_OWNED_REVIEW'),
('G8', 'finder_tokens', 'REBUILD'),
('G8', 'finder_tokens_aggregate', 'REBUILD'),
('G8', 'finder_types', 'REBUILD'),
('G8', 'postinstall_messages', 'TARGET_OWNED'),
('G8', 'overrider', 'MIGRATE_RECREATE_REVIEW'),
('G8', 'guidedtours', 'TARGET_OWNED'),
('G8', 'guidedtour_steps', 'TARGET_OWNED');

SELECT
    'Joomla 6.1.2' AS baseline,
    COUNT(*) AS expected_core_tables,
    SUM(CASE WHEN t.TABLE_NAME IS NOT NULL THEN 1 ELSE 0 END) AS physically_present_core_tables,
    COUNT(*) - SUM(CASE WHEN t.TABLE_NAME IS NOT NULL THEN 1 ELSE 0 END) AS missing_canonical_tables,
    ROUND(100 * SUM(CASE WHEN t.TABLE_NAME IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS canonical_table_presence_pct
FROM tmp_expected_joomla_core_tables AS e
LEFT JOIN information_schema.TABLES AS t
    ON t.TABLE_SCHEMA = @db_name
   AND t.TABLE_TYPE = 'BASE TABLE'
   AND t.TABLE_NAME = CONCAT(@table_prefix, e.table_suffix);

SELECT
    e.group_code,
    CONCAT(@table_prefix, e.table_suffix) AS expected_physical_table,
    e.handling,
    'MISSING_CANONICAL_TABLE' AS coverage_status
FROM tmp_expected_joomla_core_tables AS e
LEFT JOIN information_schema.TABLES AS t
    ON t.TABLE_SCHEMA = @db_name
   AND t.TABLE_TYPE = 'BASE TABLE'
   AND t.TABLE_NAME = CONCAT(@table_prefix, e.table_suffix)
WHERE t.TABLE_NAME IS NULL
ORDER BY e.group_code, e.table_suffix;

SELECT
    t.TABLE_NAME AS actual_table,
    t.ENGINE,
    t.TABLE_COLLATION,
    'NOT_IN_CANONICAL_CORE_MANIFEST_REVIEW_REQUIRED' AS coverage_status
FROM information_schema.TABLES AS t
LEFT JOIN tmp_expected_joomla_core_tables AS e
    ON t.TABLE_NAME = CONCAT(@table_prefix, e.table_suffix)
WHERE t.TABLE_SCHEMA = @db_name
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME LIKE CONCAT(@table_prefix, '%')
  AND e.table_suffix IS NULL
ORDER BY t.TABLE_NAME;

SELECT
    t.TABLE_NAME,
    CONCAT('SELECT COUNT(*) AS row_count FROM `', REPLACE(t.TABLE_NAME, '`', '``'), '`;') AS generated_count_query,
    CONCAT('SELECT * FROM `', REPLACE(t.TABLE_NAME, '`', '``'), '`;') AS generated_data_query
FROM information_schema.TABLES AS t
WHERE t.TABLE_SCHEMA = @db_name
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME LIKE CONCAT(@table_prefix, '%')
ORDER BY t.TABLE_NAME;

SELECT
    t.TABLE_NAME,
    t.ENGINE,
    t.TABLE_COLLATION,
    t.TABLE_ROWS AS engine_estimated_rows,
    t.DATA_LENGTH,
    t.INDEX_LENGTH
FROM information_schema.TABLES AS t
WHERE t.TABLE_SCHEMA = @db_name
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_NAME LIKE CONCAT(@table_prefix, '%')
ORDER BY t.TABLE_NAME;

-- ============================================================
-- J6 CANONICAL DATA: 76 COUNT QUERIES + 76 FULL-ROW QUERIES
-- ============================================================
-- G0 — System Reference
SELECT COUNT(*) AS row_count FROM `#__extensions`;
SELECT * FROM `#__extensions`;
SELECT COUNT(*) AS row_count FROM `#__schemas`;
SELECT * FROM `#__schemas`;
SELECT COUNT(*) AS row_count FROM `#__update_sites`;
SELECT * FROM `#__update_sites`;
SELECT COUNT(*) AS row_count FROM `#__update_sites_extensions`;
SELECT * FROM `#__update_sites_extensions`;
SELECT COUNT(*) AS row_count FROM `#__updates`;
SELECT * FROM `#__updates`;
SELECT COUNT(*) AS row_count FROM `#__tuf_metadata`;
SELECT * FROM `#__tuf_metadata`;

-- G1 — Users and Access Foundation
SELECT COUNT(*) AS row_count FROM `#__languages`;
SELECT * FROM `#__languages`;
SELECT COUNT(*) AS row_count FROM `#__usergroups`;
SELECT * FROM `#__usergroups`;
SELECT COUNT(*) AS row_count FROM `#__users`;
SELECT * FROM `#__users`;
SELECT COUNT(*) AS row_count FROM `#__user_usergroup_map`;
SELECT * FROM `#__user_usergroup_map`;
SELECT COUNT(*) AS row_count FROM `#__viewlevels`;
SELECT * FROM `#__viewlevels`;
SELECT COUNT(*) AS row_count FROM `#__user_profiles`;
SELECT * FROM `#__user_profiles`;

-- G2 — Taxonomy and Shared Definitions
SELECT COUNT(*) AS row_count FROM `#__assets`;
SELECT * FROM `#__assets`;
SELECT COUNT(*) AS row_count FROM `#__categories`;
SELECT * FROM `#__categories`;
SELECT COUNT(*) AS row_count FROM `#__tags`;
SELECT * FROM `#__tags`;
SELECT COUNT(*) AS row_count FROM `#__content_types`;
SELECT * FROM `#__content_types`;
SELECT COUNT(*) AS row_count FROM `#__fields_groups`;
SELECT * FROM `#__fields_groups`;
SELECT COUNT(*) AS row_count FROM `#__fields`;
SELECT * FROM `#__fields`;
SELECT COUNT(*) AS row_count FROM `#__fields_categories`;
SELECT * FROM `#__fields_categories`;
SELECT COUNT(*) AS row_count FROM `#__workflows`;
SELECT * FROM `#__workflows`;
SELECT COUNT(*) AS row_count FROM `#__workflow_stages`;
SELECT * FROM `#__workflow_stages`;
SELECT COUNT(*) AS row_count FROM `#__workflow_transitions`;
SELECT * FROM `#__workflow_transitions`;

-- G3 — Main Content
SELECT COUNT(*) AS row_count FROM `#__content`;
SELECT * FROM `#__content`;
SELECT COUNT(*) AS row_count FROM `#__content_frontpage`;
SELECT * FROM `#__content_frontpage`;
SELECT COUNT(*) AS row_count FROM `#__content_rating`;
SELECT * FROM `#__content_rating`;

-- G4 — Content Relations
SELECT COUNT(*) AS row_count FROM `#__contentitem_tag_map`;
SELECT * FROM `#__contentitem_tag_map`;
SELECT COUNT(*) AS row_count FROM `#__fields_values`;
SELECT * FROM `#__fields_values`;
SELECT COUNT(*) AS row_count FROM `#__associations`;
SELECT * FROM `#__associations`;
SELECT COUNT(*) AS row_count FROM `#__ucm_base`;
SELECT * FROM `#__ucm_base`;
SELECT COUNT(*) AS row_count FROM `#__ucm_content`;
SELECT * FROM `#__ucm_content`;
SELECT COUNT(*) AS row_count FROM `#__history`;
SELECT * FROM `#__history`;
SELECT COUNT(*) AS row_count FROM `#__workflow_associations`;
SELECT * FROM `#__workflow_associations`;
SELECT COUNT(*) AS row_count FROM `#__schemaorg`;
SELECT * FROM `#__schemaorg`;

-- G5 — Menu and Presentation
SELECT COUNT(*) AS row_count FROM `#__template_styles`;
SELECT * FROM `#__template_styles`;
SELECT COUNT(*) AS row_count FROM `#__template_overrides`;
SELECT * FROM `#__template_overrides`;
SELECT COUNT(*) AS row_count FROM `#__menu_types`;
SELECT * FROM `#__menu_types`;
SELECT COUNT(*) AS row_count FROM `#__menu`;
SELECT * FROM `#__menu`;

-- G6 — Modules
SELECT COUNT(*) AS row_count FROM `#__modules`;
SELECT * FROM `#__modules`;
SELECT COUNT(*) AS row_count FROM `#__modules_menu`;
SELECT * FROM `#__modules_menu`;

-- G7 — Supporting Core Components
SELECT COUNT(*) AS row_count FROM `#__contact_details`;
SELECT * FROM `#__contact_details`;
SELECT COUNT(*) AS row_count FROM `#__newsfeeds`;
SELECT * FROM `#__newsfeeds`;
SELECT COUNT(*) AS row_count FROM `#__banners`;
SELECT * FROM `#__banners`;
SELECT COUNT(*) AS row_count FROM `#__banner_clients`;
SELECT * FROM `#__banner_clients`;
SELECT COUNT(*) AS row_count FROM `#__banner_tracks`;
SELECT * FROM `#__banner_tracks`;
SELECT COUNT(*) AS row_count FROM `#__redirect_links`;
SELECT * FROM `#__redirect_links`;
SELECT COUNT(*) AS row_count FROM `#__messages`;
SELECT * FROM `#__messages`;
SELECT COUNT(*) AS row_count FROM `#__messages_cfg`;
SELECT * FROM `#__messages_cfg`;
SELECT COUNT(*) AS row_count FROM `#__user_notes`;
SELECT * FROM `#__user_notes`;
SELECT COUNT(*) AS row_count FROM `#__privacy_requests`;
SELECT * FROM `#__privacy_requests`;
SELECT COUNT(*) AS row_count FROM `#__privacy_consents`;
SELECT * FROM `#__privacy_consents`;
SELECT COUNT(*) AS row_count FROM `#__mail_templates`;
SELECT * FROM `#__mail_templates`;
SELECT COUNT(*) AS row_count FROM `#__scheduler_tasks`;
SELECT * FROM `#__scheduler_tasks`;
SELECT COUNT(*) AS row_count FROM `#__action_logs_extensions`;
SELECT * FROM `#__action_logs_extensions`;
SELECT COUNT(*) AS row_count FROM `#__action_log_config`;
SELECT * FROM `#__action_log_config`;
SELECT COUNT(*) AS row_count FROM `#__action_logs_users`;
SELECT * FROM `#__action_logs_users`;

-- G8 — Runtime, Generated, and Target-Owned Data
SELECT COUNT(*) AS row_count FROM `#__session`;
SELECT * FROM `#__session`;
SELECT COUNT(*) AS row_count FROM `#__user_keys`;
SELECT * FROM `#__user_keys`;
SELECT COUNT(*) AS row_count FROM `#__user_mfa`;
SELECT * FROM `#__user_mfa`;
SELECT COUNT(*) AS row_count FROM `#__webauthn_credentials`;
SELECT * FROM `#__webauthn_credentials`;
SELECT COUNT(*) AS row_count FROM `#__scheduler_logs`;
SELECT * FROM `#__scheduler_logs`;
SELECT COUNT(*) AS row_count FROM `#__action_logs`;
SELECT * FROM `#__action_logs`;
SELECT COUNT(*) AS row_count FROM `#__finder_filters`;
SELECT * FROM `#__finder_filters`;
SELECT COUNT(*) AS row_count FROM `#__finder_links`;
SELECT * FROM `#__finder_links`;
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms`;
SELECT * FROM `#__finder_links_terms`;
SELECT COUNT(*) AS row_count FROM `#__finder_logging`;
SELECT * FROM `#__finder_logging`;
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy`;
SELECT * FROM `#__finder_taxonomy`;
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy_map`;
SELECT * FROM `#__finder_taxonomy_map`;
SELECT COUNT(*) AS row_count FROM `#__finder_terms`;
SELECT * FROM `#__finder_terms`;
SELECT COUNT(*) AS row_count FROM `#__finder_terms_common`;
SELECT * FROM `#__finder_terms_common`;
SELECT COUNT(*) AS row_count FROM `#__finder_tokens`;
SELECT * FROM `#__finder_tokens`;
SELECT COUNT(*) AS row_count FROM `#__finder_tokens_aggregate`;
SELECT * FROM `#__finder_tokens_aggregate`;
SELECT COUNT(*) AS row_count FROM `#__finder_types`;
SELECT * FROM `#__finder_types`;
SELECT COUNT(*) AS row_count FROM `#__postinstall_messages`;
SELECT * FROM `#__postinstall_messages`;
SELECT COUNT(*) AS row_count FROM `#__overrider`;
SELECT * FROM `#__overrider`;
SELECT COUNT(*) AS row_count FROM `#__guidedtours`;
SELECT * FROM `#__guidedtours`;
SELECT COUNT(*) AS row_count FROM `#__guidedtour_steps`;
SELECT * FROM `#__guidedtour_steps`;
```

---

<a id="coverage-acceptance"></a>

## Coverage Acceptance

### Static canonical coverage

```text
J3 canonical tables        = 78
J3 COUNT queries           = 78
J3 full-row queries        = 78
J3 canonical coverage      = 100%

J6 canonical tables        = 76
J6 COUNT queries           = 76
J6 full-row queries        = 76
J6 canonical coverage      = 100%
```

### Runtime actual-database gate

A manual PASS requires:

```text
ACTUAL PHYSICAL TABLE INVENTORY   = 100%
UNEXPLAINED MISSING TABLES        = 0
UNREVIEWED EXTRA TABLES           = 0
UNEXPLAINED BUSINESS DATA LOSS    = 0
UNRESOLVED TRANSFORM/MAP/REBUILD  = 0
```

`information_schema.TABLES.TABLE_ROWS` can be estimated depending on the engine. Use generated `SELECT COUNT(*)` queries for exact counts.

### Matching counts are not sufficient

`J3 #__content = 470` and `J6 #__content = 470` can still hide a missing article plus a duplicate, wrong ID mappings, lost text, wrong status, invalid JSON, or broken relationships.

For migration-relevant tables, compare business identity and mapped values, not only count.

### Extra physical tables

Tables outside the canonical manifest can be custom, third-party, local migration-control, legacy, or version-specific tables. They are not automatically errors, but they must not be silently ignored.

<a id="manual-acceptance-checklist"></a>

## Manual Acceptance Checklist

- [ ] Correct J3 source database selected.
- [ ] Correct J6 target database selected.
- [ ] Correct prefixes substituted.
- [ ] J3 78-table canonical manifest reconciled.
- [ ] J6 76-table canonical manifest reconciled.
- [ ] Every J3 missing canonical table is fixed or proven `ABSENT_SOURCE`.
- [ ] No J6 canonical table is missing without approved explanation.
- [ ] Every extra prefixed physical table is classified.
- [ ] Exact counts reviewed.
- [ ] Full rows reviewed for migration-relevant tables.
- [ ] Extra/custom/third-party tables queried where relevant.
- [ ] Matching counts were not treated as sufficient proof.
- [ ] ID/value transformations checked.
- [ ] Rebuilds checked as regenerated target state.
- [ ] Archives verified.
- [ ] Target-owned data preserved.
- [ ] Ignored runtime/security data intentionally excluded.
- [ ] Unexplained business-data loss = 0.
- [ ] Unresolved dispositions = 0.

## Final Boundary

This guide is designed to make table omission, row-set omission, and physical-field omission observable. It provides 100% canonical query coverage and runtime discovery of every physical table under the selected prefix, but final no-data-loss approval still requires semantic source-to-target reconciliation.
