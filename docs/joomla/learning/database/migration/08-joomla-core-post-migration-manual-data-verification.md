# Joomla Core Post-Migration Manual Data Verification Queries

> Manual SQL reference for post-migration comparison between **Joomla 3.10.12** and **Joomla 6.1.2** core databases.

## Purpose

Use this document after a Joomla 3 → Joomla 6 migration to manually inspect:

- the number of rows in every canonical Joomla core table;
- the complete row data in every canonical Joomla core table;
- migration/rebuild/target-owned behavior without silently excluding tables.

This guide deliberately includes the full canonical table manifests:

| Database | Canonical core tables | COUNT queries | Row-list queries | Query coverage |
|---|---:|---:|---:|---:|
| Joomla 3.10.12 | 78 | 78 | 78 | 100% |
| Joomla 6.1.2 | 76 | 76 | 76 | 100% |
| **Total** | **154** | **154** | **154** | **100%** |

> [!IMPORTANT]
> **100% query coverage does not mean every Joomla 3 row must exist unchanged in Joomla 6.**
> Some tables are transformed, rebuilt, archived, ignored, recreated, or owned by the Joomla 6 installation.
> Compare each table according to its **Handling** value.

## How to use this guide

1. Make both databases read-only for manual verification whenever possible.
2. Replace `#__` in the copied SQL with the real Joomla table prefix.
   - Example source prefix: `abc_`
   - Example target prefix: `xyz_`
3. Run the **Count query** first.
4. Run the **Data query** to inspect the complete rows and values.
5. Compare Joomla 3 and Joomla 6 according to the migration contract, not raw IDs alone.
6. Record any missing, unexpected, or unexplained row before approving the migration.

> [!NOTE]
> These queries intentionally use `SELECT *` because this document is a **manual full-row inspection reference**.  
> Large runtime/generated tables may return many rows.

## Comparison rules

| Handling type | Manual verification expectation |
|---|---|
| `MIGRATE`, `TRANSFORM`, `MAP` | Verify the business record/value is preserved after approved ID/value transformation. |
| `REFERENCE_ONLY` | Use source rows only to identify/reconcile target-owned records. Raw row counts do not need to match. |
| `REBUILD`, `GENERATE`, `DERIVED` | Verify Joomla 6 regenerated valid target state. Do not expect source rows or IDs to match. |
| `TARGET_OWNED` | Keep Joomla 6 installation-owned state. Do not overwrite it with Joomla 3 rows. |
| `RECREATE`, `RE-ENROL` | Verify equivalent Joomla 6 configuration/state was recreated using Joomla 6 semantics. |
| `ARCHIVE` | Verify the source evidence is retained in the approved migration archive; active Joomla 6 rows may differ. |
| `IGNORE` | Source runtime/security data is intentionally not migrated. |
| `OPTIONAL`, `REVIEW`, `SELECTIVE` | The final workflow must have an explicit approved disposition before PASS. |

## Canonical source caveat

The Joomla 3 section covers the official **Joomla 3.10.12 78-table baseline**. A real source database may be from an earlier Joomla 3 lineage or may contain local customizations.

If a canonical table is physically absent:

- do **not** delete it from this document;
- record it as `ABSENT_SOURCE`;
- prove absence from the actual database inventory;
- do not treat an SQL `table does not exist` error as migrated data.

## Table of contents

- [Joomla 3 queries](#joomla-3)
  - [G0 — System Reference](#j3-g0)
  - [G1 — Users and Access Foundation](#j3-g1)
  - [G2 — Taxonomy and Shared Definitions](#j3-g2)
  - [G3 — Main Content](#j3-g3)
  - [G4 — Content Relations](#j3-g4)
  - [G5 — Menu and Presentation](#j3-g5)
  - [G6 — Modules](#j3-g6)
  - [G7 — Supporting Core Components](#j3-g7)
  - [G8 — Runtime, Generated, Historical, and Excluded](#j3-g8)
- [Joomla 6 queries](#joomla-6)
  - [G0 — System Reference](#j6-g0)
  - [G1 — Users and Access Foundation](#j6-g1)
  - [G2 — Taxonomy and Shared Definitions](#j6-g2)
  - [G3 — Main Content](#j6-g3)
  - [G4 — Content Relations](#j6-g4)
  - [G5 — Menu and Presentation](#j6-g5)
  - [G6 — Modules](#j6-g6)
  - [G7 — Supporting Core Components](#j6-g7)
  - [G8 — Runtime, Generated, and Target-Owned Data](#j6-g8)
- [Coverage verification](#coverage-verification)
- [Manual acceptance checklist](#manual-acceptance-checklist)

---

<a id="joomla-3"></a>

# Joomla 3 Queries

**Canonical baseline:** Joomla 3.10.12 — **78 core tables**.

<a id="j3-g0"></a>

## G0 — System Reference

**Tables in this group:** 5

| # | Table | Handling |
|---:|---|---|
| 1 | `#__extensions` | `REFERENCE_ONLY` |
| 2 | `#__schemas` | `REFERENCE_ONLY` |
| 3 | `#__update_sites` | `REFERENCE_ONLY` |
| 4 | `#__update_sites_extensions` | `REFERENCE_ONLY` |
| 5 | `#__updates` | `REFERENCE_ONLY` |

### `#__extensions`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__extensions`;
```

**Data query**

```sql
SELECT * FROM `#__extensions`;
```

### `#__schemas`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__schemas`;
```

**Data query**

```sql
SELECT * FROM `#__schemas`;
```

### `#__update_sites`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__update_sites`;
```

**Data query**

```sql
SELECT * FROM `#__update_sites`;
```

### `#__update_sites_extensions`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__update_sites_extensions`;
```

**Data query**

```sql
SELECT * FROM `#__update_sites_extensions`;
```

### `#__updates`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__updates`;
```

**Data query**

```sql
SELECT * FROM `#__updates`;
```

---

<a id="j3-g1"></a>

## G1 — Users and Access Foundation

**Tables in this group:** 6

| # | Table | Handling |
|---:|---|---|
| 1 | `#__languages` | `TRANSFORM` |
| 2 | `#__usergroups` | `TRANSFORM` |
| 3 | `#__users` | `TRANSFORM` |
| 4 | `#__user_usergroup_map` | `TRANSFORM` |
| 5 | `#__viewlevels` | `TRANSFORM` |
| 6 | `#__user_profiles` | `TRANSFORM` |

### `#__languages`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__languages`;
```

**Data query**

```sql
SELECT * FROM `#__languages`;
```

### `#__usergroups`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__usergroups`;
```

**Data query**

```sql
SELECT * FROM `#__usergroups`;
```

### `#__users`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__users`;
```

**Data query**

```sql
SELECT * FROM `#__users`;
```

### `#__user_usergroup_map`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_usergroup_map`;
```

**Data query**

```sql
SELECT * FROM `#__user_usergroup_map`;
```

### `#__viewlevels`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__viewlevels`;
```

**Data query**

```sql
SELECT * FROM `#__viewlevels`;
```

### `#__user_profiles`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_profiles`;
```

**Data query**

```sql
SELECT * FROM `#__user_profiles`;
```

---

<a id="j3-g2"></a>

## G2 — Taxonomy and Shared Definitions

**Tables in this group:** 7

| # | Table | Handling |
|---:|---|---|
| 1 | `#__assets` | `REBUILD` |
| 2 | `#__categories` | `TRANSFORM` |
| 3 | `#__tags` | `TRANSFORM` |
| 4 | `#__content_types` | `REFERENCE_ONLY` |
| 5 | `#__fields_groups` | `TRANSFORM` |
| 6 | `#__fields` | `TRANSFORM` |
| 7 | `#__fields_categories` | `TRANSFORM` |

### `#__assets`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__assets`;
```

**Data query**

```sql
SELECT * FROM `#__assets`;
```

### `#__categories`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__categories`;
```

**Data query**

```sql
SELECT * FROM `#__categories`;
```

### `#__tags`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__tags`;
```

**Data query**

```sql
SELECT * FROM `#__tags`;
```

### `#__content_types`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content_types`;
```

**Data query**

```sql
SELECT * FROM `#__content_types`;
```

### `#__fields_groups`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields_groups`;
```

**Data query**

```sql
SELECT * FROM `#__fields_groups`;
```

### `#__fields`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields`;
```

**Data query**

```sql
SELECT * FROM `#__fields`;
```

### `#__fields_categories`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields_categories`;
```

**Data query**

```sql
SELECT * FROM `#__fields_categories`;
```

---

<a id="j3-g3"></a>

## G3 — Main Content

**Tables in this group:** 3

| # | Table | Handling |
|---:|---|---|
| 1 | `#__content` | `TRANSFORM` |
| 2 | `#__content_frontpage` | `TRANSFORM` |
| 3 | `#__content_rating` | `TRANSFORM` |

### `#__content`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content`;
```

**Data query**

```sql
SELECT * FROM `#__content`;
```

### `#__content_frontpage`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content_frontpage`;
```

**Data query**

```sql
SELECT * FROM `#__content_frontpage`;
```

### `#__content_rating`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content_rating`;
```

**Data query**

```sql
SELECT * FROM `#__content_rating`;
```

---

<a id="j3-g4"></a>

## G4 — Content Relations

**Tables in this group:** 6

| # | Table | Handling |
|---:|---|---|
| 1 | `#__contentitem_tag_map` | `TRANSFORM` |
| 2 | `#__fields_values` | `TRANSFORM` |
| 3 | `#__associations` | `TRANSFORM` |
| 4 | `#__ucm_base` | `REBUILD` |
| 5 | `#__ucm_content` | `REBUILD` |
| 6 | `#__ucm_history` | `TRANSFORM → #__history` |

### `#__contentitem_tag_map`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__contentitem_tag_map`;
```

**Data query**

```sql
SELECT * FROM `#__contentitem_tag_map`;
```

### `#__fields_values`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields_values`;
```

**Data query**

```sql
SELECT * FROM `#__fields_values`;
```

### `#__associations`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__associations`;
```

**Data query**

```sql
SELECT * FROM `#__associations`;
```

### `#__ucm_base`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__ucm_base`;
```

**Data query**

```sql
SELECT * FROM `#__ucm_base`;
```

### `#__ucm_content`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__ucm_content`;
```

**Data query**

```sql
SELECT * FROM `#__ucm_content`;
```

### `#__ucm_history`

**Handling:** `TRANSFORM → #__history`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__ucm_history`;
```

**Data query**

```sql
SELECT * FROM `#__ucm_history`;
```

---

<a id="j3-g5"></a>

## G5 — Menu and Presentation

**Tables in this group:** 3

| # | Table | Handling |
|---:|---|---|
| 1 | `#__template_styles` | `TRANSFORM` |
| 2 | `#__menu_types` | `TRANSFORM` |
| 3 | `#__menu` | `TRANSFORM` |

### `#__template_styles`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__template_styles`;
```

**Data query**

```sql
SELECT * FROM `#__template_styles`;
```

### `#__menu_types`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__menu_types`;
```

**Data query**

```sql
SELECT * FROM `#__menu_types`;
```

### `#__menu`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__menu`;
```

**Data query**

```sql
SELECT * FROM `#__menu`;
```

---

<a id="j3-g6"></a>

## G6 — Modules

**Tables in this group:** 2

| # | Table | Handling |
|---:|---|---|
| 1 | `#__modules` | `TRANSFORM` |
| 2 | `#__modules_menu` | `TRANSFORM` |

### `#__modules`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__modules`;
```

**Data query**

```sql
SELECT * FROM `#__modules`;
```

### `#__modules_menu`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__modules_menu`;
```

**Data query**

```sql
SELECT * FROM `#__modules_menu`;
```

---

<a id="j3-g7"></a>

## G7 — Supporting Core Components

**Tables in this group:** 14

| # | Table | Handling |
|---:|---|---|
| 1 | `#__contact_details` | `TRANSFORM` |
| 2 | `#__newsfeeds` | `TRANSFORM` |
| 3 | `#__banners` | `TRANSFORM` |
| 4 | `#__banner_clients` | `TRANSFORM` |
| 5 | `#__banner_tracks` | `ARCHIVE` |
| 6 | `#__redirect_links` | `TRANSFORM` |
| 7 | `#__messages` | `TRANSFORM` |
| 8 | `#__messages_cfg` | `TRANSFORM` |
| 9 | `#__user_notes` | `TRANSFORM` |
| 10 | `#__privacy_requests` | `TRANSFORM` |
| 11 | `#__privacy_consents` | `TRANSFORM` |
| 12 | `#__action_logs_extensions` | `REFERENCE_ONLY` |
| 13 | `#__action_log_config` | `REFERENCE_ONLY` |
| 14 | `#__action_logs_users` | `TRANSFORM` |

### `#__contact_details`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__contact_details`;
```

**Data query**

```sql
SELECT * FROM `#__contact_details`;
```

### `#__newsfeeds`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__newsfeeds`;
```

**Data query**

```sql
SELECT * FROM `#__newsfeeds`;
```

### `#__banners`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__banners`;
```

**Data query**

```sql
SELECT * FROM `#__banners`;
```

### `#__banner_clients`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__banner_clients`;
```

**Data query**

```sql
SELECT * FROM `#__banner_clients`;
```

### `#__banner_tracks`

**Handling:** `ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__banner_tracks`;
```

**Data query**

```sql
SELECT * FROM `#__banner_tracks`;
```

### `#__redirect_links`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__redirect_links`;
```

**Data query**

```sql
SELECT * FROM `#__redirect_links`;
```

### `#__messages`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__messages`;
```

**Data query**

```sql
SELECT * FROM `#__messages`;
```

### `#__messages_cfg`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__messages_cfg`;
```

**Data query**

```sql
SELECT * FROM `#__messages_cfg`;
```

### `#__user_notes`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_notes`;
```

**Data query**

```sql
SELECT * FROM `#__user_notes`;
```

### `#__privacy_requests`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__privacy_requests`;
```

**Data query**

```sql
SELECT * FROM `#__privacy_requests`;
```

### `#__privacy_consents`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__privacy_consents`;
```

**Data query**

```sql
SELECT * FROM `#__privacy_consents`;
```

### `#__action_logs_extensions`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_logs_extensions`;
```

**Data query**

```sql
SELECT * FROM `#__action_logs_extensions`;
```

### `#__action_log_config`

**Handling:** `REFERENCE_ONLY`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_log_config`;
```

**Data query**

```sql
SELECT * FROM `#__action_log_config`;
```

### `#__action_logs_users`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_logs_users`;
```

**Data query**

```sql
SELECT * FROM `#__action_logs_users`;
```

---

<a id="j3-g8"></a>

## G8 — Runtime, Generated, Historical, and Excluded

**Tables in this group:** 32

| # | Table | Handling |
|---:|---|---|
| 1 | `#__session` | `IGNORE` |
| 2 | `#__user_keys` | `IGNORE` |
| 3 | `#__finder_filters` | `TRANSFORM` |
| 4 | `#__finder_links` | `REBUILD` |
| 5 | `#__finder_links_terms0` | `REBUILD → #__finder_links_terms` |
| 6 | `#__finder_links_terms1` | `REBUILD → #__finder_links_terms` |
| 7 | `#__finder_links_terms2` | `REBUILD → #__finder_links_terms` |
| 8 | `#__finder_links_terms3` | `REBUILD → #__finder_links_terms` |
| 9 | `#__finder_links_terms4` | `REBUILD → #__finder_links_terms` |
| 10 | `#__finder_links_terms5` | `REBUILD → #__finder_links_terms` |
| 11 | `#__finder_links_terms6` | `REBUILD → #__finder_links_terms` |
| 12 | `#__finder_links_terms7` | `REBUILD → #__finder_links_terms` |
| 13 | `#__finder_links_terms8` | `REBUILD → #__finder_links_terms` |
| 14 | `#__finder_links_terms9` | `REBUILD → #__finder_links_terms` |
| 15 | `#__finder_links_termsa` | `REBUILD → #__finder_links_terms` |
| 16 | `#__finder_links_termsb` | `REBUILD → #__finder_links_terms` |
| 17 | `#__finder_links_termsc` | `REBUILD → #__finder_links_terms` |
| 18 | `#__finder_links_termsd` | `REBUILD → #__finder_links_terms` |
| 19 | `#__finder_links_termse` | `REBUILD → #__finder_links_terms` |
| 20 | `#__finder_links_termsf` | `REBUILD → #__finder_links_terms` |
| 21 | `#__finder_taxonomy` | `REBUILD` |
| 22 | `#__finder_taxonomy_map` | `REBUILD` |
| 23 | `#__finder_terms` | `REBUILD` |
| 24 | `#__finder_terms_common` | `TRANSFORM (custom=1); built-ins target-owned` |
| 25 | `#__finder_tokens` | `REBUILD` |
| 26 | `#__finder_tokens_aggregate` | `REBUILD` |
| 27 | `#__finder_types` | `REBUILD` |
| 28 | `#__action_logs` | `ARCHIVE` |
| 29 | `#__core_log_searches` | `ARCHIVE` |
| 30 | `#__overrider` | `TRANSFORM` |
| 31 | `#__postinstall_messages` | `REBUILD` |
| 32 | `#__utf8_conversion` | `DERIVED` |

### `#__session`

**Handling:** `IGNORE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__session`;
```

**Data query**

```sql
SELECT * FROM `#__session`;
```

### `#__user_keys`

**Handling:** `IGNORE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_keys`;
```

**Data query**

```sql
SELECT * FROM `#__user_keys`;
```

### `#__finder_filters`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_filters`;
```

**Data query**

```sql
SELECT * FROM `#__finder_filters`;
```

### `#__finder_links`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links`;
```

### `#__finder_links_terms0`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms0`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms0`;
```

### `#__finder_links_terms1`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms1`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms1`;
```

### `#__finder_links_terms2`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms2`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms2`;
```

### `#__finder_links_terms3`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms3`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms3`;
```

### `#__finder_links_terms4`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms4`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms4`;
```

### `#__finder_links_terms5`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms5`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms5`;
```

### `#__finder_links_terms6`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms6`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms6`;
```

### `#__finder_links_terms7`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms7`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms7`;
```

### `#__finder_links_terms8`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms8`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms8`;
```

### `#__finder_links_terms9`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms9`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms9`;
```

### `#__finder_links_termsa`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsa`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_termsa`;
```

### `#__finder_links_termsb`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsb`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_termsb`;
```

### `#__finder_links_termsc`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsc`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_termsc`;
```

### `#__finder_links_termsd`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsd`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_termsd`;
```

### `#__finder_links_termse`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_termse`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_termse`;
```

### `#__finder_links_termsf`

**Handling:** `REBUILD → #__finder_links_terms`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_termsf`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_termsf`;
```

### `#__finder_taxonomy`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy`;
```

**Data query**

```sql
SELECT * FROM `#__finder_taxonomy`;
```

### `#__finder_taxonomy_map`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy_map`;
```

**Data query**

```sql
SELECT * FROM `#__finder_taxonomy_map`;
```

### `#__finder_terms`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_terms`;
```

**Data query**

```sql
SELECT * FROM `#__finder_terms`;
```

### `#__finder_terms_common`

**Handling:** `TRANSFORM (custom=1); built-ins target-owned`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_terms_common`;
```

**Data query**

```sql
SELECT * FROM `#__finder_terms_common`;
```

### `#__finder_tokens`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_tokens`;
```

**Data query**

```sql
SELECT * FROM `#__finder_tokens`;
```

### `#__finder_tokens_aggregate`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_tokens_aggregate`;
```

**Data query**

```sql
SELECT * FROM `#__finder_tokens_aggregate`;
```

### `#__finder_types`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_types`;
```

**Data query**

```sql
SELECT * FROM `#__finder_types`;
```

### `#__action_logs`

**Handling:** `ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_logs`;
```

**Data query**

```sql
SELECT * FROM `#__action_logs`;
```

### `#__core_log_searches`

**Handling:** `ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__core_log_searches`;
```

**Data query**

```sql
SELECT * FROM `#__core_log_searches`;
```

### `#__overrider`

**Handling:** `TRANSFORM`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__overrider`;
```

**Data query**

```sql
SELECT * FROM `#__overrider`;
```

### `#__postinstall_messages`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__postinstall_messages`;
```

**Data query**

```sql
SELECT * FROM `#__postinstall_messages`;
```

### `#__utf8_conversion`

**Handling:** `DERIVED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__utf8_conversion`;
```

**Data query**

```sql
SELECT * FROM `#__utf8_conversion`;
```

---

<a id="joomla-6"></a>

# Joomla 6 Queries

**Canonical baseline:** Joomla 6.1.2 — **76 core tables**.

<a id="j6-g0"></a>

## G0 — System Reference

**Tables in this group:** 6

| # | Table | Handling |
|---:|---|---|
| 1 | `#__extensions` | `REFERENCE_ONLY / TARGET_OWNED` |
| 2 | `#__schemas` | `REFERENCE_ONLY / TARGET_OWNED` |
| 3 | `#__update_sites` | `REFERENCE_ONLY / TARGET_OWNED` |
| 4 | `#__update_sites_extensions` | `REFERENCE_ONLY / TARGET_OWNED` |
| 5 | `#__updates` | `REFERENCE_ONLY / TARGET_OWNED` |
| 6 | `#__tuf_metadata` | `REFERENCE_ONLY / TARGET_OWNED` |

### `#__extensions`

**Handling:** `REFERENCE_ONLY / TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__extensions`;
```

**Data query**

```sql
SELECT * FROM `#__extensions`;
```

### `#__schemas`

**Handling:** `REFERENCE_ONLY / TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__schemas`;
```

**Data query**

```sql
SELECT * FROM `#__schemas`;
```

### `#__update_sites`

**Handling:** `REFERENCE_ONLY / TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__update_sites`;
```

**Data query**

```sql
SELECT * FROM `#__update_sites`;
```

### `#__update_sites_extensions`

**Handling:** `REFERENCE_ONLY / TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__update_sites_extensions`;
```

**Data query**

```sql
SELECT * FROM `#__update_sites_extensions`;
```

### `#__updates`

**Handling:** `REFERENCE_ONLY / TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__updates`;
```

**Data query**

```sql
SELECT * FROM `#__updates`;
```

### `#__tuf_metadata`

**Handling:** `REFERENCE_ONLY / TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__tuf_metadata`;
```

**Data query**

```sql
SELECT * FROM `#__tuf_metadata`;
```

---

<a id="j6-g1"></a>

## G1 — Users and Access Foundation

**Tables in this group:** 6

| # | Table | Handling |
|---:|---|---|
| 1 | `#__languages` | `MIGRATE / MAP` |
| 2 | `#__usergroups` | `MIGRATE / MAP` |
| 3 | `#__users` | `MIGRATE / MAP` |
| 4 | `#__user_usergroup_map` | `MIGRATE / MAP` |
| 5 | `#__viewlevels` | `MIGRATE / MAP` |
| 6 | `#__user_profiles` | `MIGRATE / MAP` |

### `#__languages`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__languages`;
```

**Data query**

```sql
SELECT * FROM `#__languages`;
```

### `#__usergroups`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__usergroups`;
```

**Data query**

```sql
SELECT * FROM `#__usergroups`;
```

### `#__users`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__users`;
```

**Data query**

```sql
SELECT * FROM `#__users`;
```

### `#__user_usergroup_map`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_usergroup_map`;
```

**Data query**

```sql
SELECT * FROM `#__user_usergroup_map`;
```

### `#__viewlevels`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__viewlevels`;
```

**Data query**

```sql
SELECT * FROM `#__viewlevels`;
```

### `#__user_profiles`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_profiles`;
```

**Data query**

```sql
SELECT * FROM `#__user_profiles`;
```

---

<a id="j6-g2"></a>

## G2 — Taxonomy and Shared Definitions

**Tables in this group:** 10

| # | Table | Handling |
|---:|---|---|
| 1 | `#__assets` | `REBUILD / RECONCILE` |
| 2 | `#__categories` | `MIGRATE / MAP` |
| 3 | `#__tags` | `MIGRATE / MAP` |
| 4 | `#__content_types` | `REFERENCE_ONLY / MAP` |
| 5 | `#__fields_groups` | `MIGRATE / MAP` |
| 6 | `#__fields` | `MIGRATE / MAP` |
| 7 | `#__fields_categories` | `MIGRATE / MAP` |
| 8 | `#__workflows` | `RECREATE / MAP` |
| 9 | `#__workflow_stages` | `RECREATE / MAP` |
| 10 | `#__workflow_transitions` | `RECREATE / MAP` |

### `#__assets`

**Handling:** `REBUILD / RECONCILE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__assets`;
```

**Data query**

```sql
SELECT * FROM `#__assets`;
```

### `#__categories`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__categories`;
```

**Data query**

```sql
SELECT * FROM `#__categories`;
```

### `#__tags`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__tags`;
```

**Data query**

```sql
SELECT * FROM `#__tags`;
```

### `#__content_types`

**Handling:** `REFERENCE_ONLY / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content_types`;
```

**Data query**

```sql
SELECT * FROM `#__content_types`;
```

### `#__fields_groups`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields_groups`;
```

**Data query**

```sql
SELECT * FROM `#__fields_groups`;
```

### `#__fields`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields`;
```

**Data query**

```sql
SELECT * FROM `#__fields`;
```

### `#__fields_categories`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields_categories`;
```

**Data query**

```sql
SELECT * FROM `#__fields_categories`;
```

### `#__workflows`

**Handling:** `RECREATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__workflows`;
```

**Data query**

```sql
SELECT * FROM `#__workflows`;
```

### `#__workflow_stages`

**Handling:** `RECREATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__workflow_stages`;
```

**Data query**

```sql
SELECT * FROM `#__workflow_stages`;
```

### `#__workflow_transitions`

**Handling:** `RECREATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__workflow_transitions`;
```

**Data query**

```sql
SELECT * FROM `#__workflow_transitions`;
```

---

<a id="j6-g3"></a>

## G3 — Main Content

**Tables in this group:** 3

| # | Table | Handling |
|---:|---|---|
| 1 | `#__content` | `MIGRATE / MAP` |
| 2 | `#__content_frontpage` | `MIGRATE / MAP` |
| 3 | `#__content_rating` | `MIGRATE / MAP` |

### `#__content`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content`;
```

**Data query**

```sql
SELECT * FROM `#__content`;
```

### `#__content_frontpage`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content_frontpage`;
```

**Data query**

```sql
SELECT * FROM `#__content_frontpage`;
```

### `#__content_rating`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__content_rating`;
```

**Data query**

```sql
SELECT * FROM `#__content_rating`;
```

---

<a id="j6-g4"></a>

## G4 — Content Relations

**Tables in this group:** 8

| # | Table | Handling |
|---:|---|---|
| 1 | `#__contentitem_tag_map` | `MIGRATE / MAP` |
| 2 | `#__fields_values` | `MIGRATE / MAP` |
| 3 | `#__associations` | `MIGRATE / MAP` |
| 4 | `#__ucm_base` | `REBUILD / VALIDATE` |
| 5 | `#__ucm_content` | `REBUILD / VALIDATE` |
| 6 | `#__history` | `ARCHIVE / OPTIONAL_MIGRATE` |
| 7 | `#__workflow_associations` | `GENERATE / MAP` |
| 8 | `#__schemaorg` | `MIGRATE / MAP` |

### `#__contentitem_tag_map`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__contentitem_tag_map`;
```

**Data query**

```sql
SELECT * FROM `#__contentitem_tag_map`;
```

### `#__fields_values`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__fields_values`;
```

**Data query**

```sql
SELECT * FROM `#__fields_values`;
```

### `#__associations`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__associations`;
```

**Data query**

```sql
SELECT * FROM `#__associations`;
```

### `#__ucm_base`

**Handling:** `REBUILD / VALIDATE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__ucm_base`;
```

**Data query**

```sql
SELECT * FROM `#__ucm_base`;
```

### `#__ucm_content`

**Handling:** `REBUILD / VALIDATE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__ucm_content`;
```

**Data query**

```sql
SELECT * FROM `#__ucm_content`;
```

### `#__history`

**Handling:** `ARCHIVE / OPTIONAL_MIGRATE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__history`;
```

**Data query**

```sql
SELECT * FROM `#__history`;
```

### `#__workflow_associations`

**Handling:** `GENERATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__workflow_associations`;
```

**Data query**

```sql
SELECT * FROM `#__workflow_associations`;
```

### `#__schemaorg`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__schemaorg`;
```

**Data query**

```sql
SELECT * FROM `#__schemaorg`;
```

---

<a id="j6-g5"></a>

## G5 — Menu and Presentation

**Tables in this group:** 4

| # | Table | Handling |
|---:|---|---|
| 1 | `#__template_styles` | `TRANSFORM / RECREATE` |
| 2 | `#__template_overrides` | `REBUILD / REVIEW` |
| 3 | `#__menu_types` | `MIGRATE / MAP` |
| 4 | `#__menu` | `MIGRATE / MAP` |

### `#__template_styles`

**Handling:** `TRANSFORM / RECREATE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__template_styles`;
```

**Data query**

```sql
SELECT * FROM `#__template_styles`;
```

### `#__template_overrides`

**Handling:** `REBUILD / REVIEW`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__template_overrides`;
```

**Data query**

```sql
SELECT * FROM `#__template_overrides`;
```

### `#__menu_types`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__menu_types`;
```

**Data query**

```sql
SELECT * FROM `#__menu_types`;
```

### `#__menu`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__menu`;
```

**Data query**

```sql
SELECT * FROM `#__menu`;
```

---

<a id="j6-g6"></a>

## G6 — Modules

**Tables in this group:** 2

| # | Table | Handling |
|---:|---|---|
| 1 | `#__modules` | `MIGRATE / MAP` |
| 2 | `#__modules_menu` | `MIGRATE / MAP` |

### `#__modules`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__modules`;
```

**Data query**

```sql
SELECT * FROM `#__modules`;
```

### `#__modules_menu`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__modules_menu`;
```

**Data query**

```sql
SELECT * FROM `#__modules_menu`;
```

---

<a id="j6-g7"></a>

## G7 — Supporting Core Components

**Tables in this group:** 16

| # | Table | Handling |
|---:|---|---|
| 1 | `#__contact_details` | `MIGRATE / MAP` |
| 2 | `#__newsfeeds` | `MIGRATE / MAP` |
| 3 | `#__banners` | `MIGRATE / MAP` |
| 4 | `#__banner_clients` | `MIGRATE / MAP` |
| 5 | `#__banner_tracks` | `ARCHIVE / OPTIONAL_MIGRATE` |
| 6 | `#__redirect_links` | `MIGRATE / MAP` |
| 7 | `#__messages` | `MIGRATE / OPTIONAL` |
| 8 | `#__messages_cfg` | `MIGRATE / OPTIONAL` |
| 9 | `#__user_notes` | `MIGRATE / MAP` |
| 10 | `#__privacy_requests` | `MIGRATE / ARCHIVE` |
| 11 | `#__privacy_consents` | `MIGRATE / ARCHIVE` |
| 12 | `#__mail_templates` | `MERGE / RECREATE` |
| 13 | `#__scheduler_tasks` | `RECREATE / SELECTIVE` |
| 14 | `#__action_logs_extensions` | `TARGET_OWNED / MERGE` |
| 15 | `#__action_log_config` | `TARGET_OWNED / MERGE` |
| 16 | `#__action_logs_users` | `MIGRATE / REVIEW` |

### `#__contact_details`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__contact_details`;
```

**Data query**

```sql
SELECT * FROM `#__contact_details`;
```

### `#__newsfeeds`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__newsfeeds`;
```

**Data query**

```sql
SELECT * FROM `#__newsfeeds`;
```

### `#__banners`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__banners`;
```

**Data query**

```sql
SELECT * FROM `#__banners`;
```

### `#__banner_clients`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__banner_clients`;
```

**Data query**

```sql
SELECT * FROM `#__banner_clients`;
```

### `#__banner_tracks`

**Handling:** `ARCHIVE / OPTIONAL_MIGRATE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__banner_tracks`;
```

**Data query**

```sql
SELECT * FROM `#__banner_tracks`;
```

### `#__redirect_links`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__redirect_links`;
```

**Data query**

```sql
SELECT * FROM `#__redirect_links`;
```

### `#__messages`

**Handling:** `MIGRATE / OPTIONAL`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__messages`;
```

**Data query**

```sql
SELECT * FROM `#__messages`;
```

### `#__messages_cfg`

**Handling:** `MIGRATE / OPTIONAL`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__messages_cfg`;
```

**Data query**

```sql
SELECT * FROM `#__messages_cfg`;
```

### `#__user_notes`

**Handling:** `MIGRATE / MAP`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_notes`;
```

**Data query**

```sql
SELECT * FROM `#__user_notes`;
```

### `#__privacy_requests`

**Handling:** `MIGRATE / ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__privacy_requests`;
```

**Data query**

```sql
SELECT * FROM `#__privacy_requests`;
```

### `#__privacy_consents`

**Handling:** `MIGRATE / ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__privacy_consents`;
```

**Data query**

```sql
SELECT * FROM `#__privacy_consents`;
```

### `#__mail_templates`

**Handling:** `MERGE / RECREATE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__mail_templates`;
```

**Data query**

```sql
SELECT * FROM `#__mail_templates`;
```

### `#__scheduler_tasks`

**Handling:** `RECREATE / SELECTIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__scheduler_tasks`;
```

**Data query**

```sql
SELECT * FROM `#__scheduler_tasks`;
```

### `#__action_logs_extensions`

**Handling:** `TARGET_OWNED / MERGE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_logs_extensions`;
```

**Data query**

```sql
SELECT * FROM `#__action_logs_extensions`;
```

### `#__action_log_config`

**Handling:** `TARGET_OWNED / MERGE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_log_config`;
```

**Data query**

```sql
SELECT * FROM `#__action_log_config`;
```

### `#__action_logs_users`

**Handling:** `MIGRATE / REVIEW`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_logs_users`;
```

**Data query**

```sql
SELECT * FROM `#__action_logs_users`;
```

---

<a id="j6-g8"></a>

## G8 — Runtime, Generated, and Target-Owned Data

**Tables in this group:** 21

| # | Table | Handling |
|---:|---|---|
| 1 | `#__session` | `IGNORE` |
| 2 | `#__user_keys` | `IGNORE` |
| 3 | `#__user_mfa` | `RECREATE / RE-ENROL` |
| 4 | `#__webauthn_credentials` | `RECREATE / RE-ENROL` |
| 5 | `#__scheduler_logs` | `IGNORE / ARCHIVE` |
| 6 | `#__action_logs` | `IGNORE / ARCHIVE` |
| 7 | `#__finder_filters` | `MIGRATE / RECREATE / REVIEW` |
| 8 | `#__finder_links` | `REBUILD` |
| 9 | `#__finder_links_terms` | `REBUILD` |
| 10 | `#__finder_logging` | `IGNORE / ARCHIVE` |
| 11 | `#__finder_taxonomy` | `REBUILD` |
| 12 | `#__finder_taxonomy_map` | `REBUILD` |
| 13 | `#__finder_terms` | `REBUILD` |
| 14 | `#__finder_terms_common` | `TARGET_OWNED / REVIEW` |
| 15 | `#__finder_tokens` | `REBUILD` |
| 16 | `#__finder_tokens_aggregate` | `REBUILD` |
| 17 | `#__finder_types` | `REBUILD` |
| 18 | `#__postinstall_messages` | `TARGET_OWNED` |
| 19 | `#__overrider` | `MIGRATE / RECREATE / REVIEW` |
| 20 | `#__guidedtours` | `TARGET_OWNED` |
| 21 | `#__guidedtour_steps` | `TARGET_OWNED` |

### `#__session`

**Handling:** `IGNORE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__session`;
```

**Data query**

```sql
SELECT * FROM `#__session`;
```

### `#__user_keys`

**Handling:** `IGNORE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_keys`;
```

**Data query**

```sql
SELECT * FROM `#__user_keys`;
```

### `#__user_mfa`

**Handling:** `RECREATE / RE-ENROL`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__user_mfa`;
```

**Data query**

```sql
SELECT * FROM `#__user_mfa`;
```

### `#__webauthn_credentials`

**Handling:** `RECREATE / RE-ENROL`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__webauthn_credentials`;
```

**Data query**

```sql
SELECT * FROM `#__webauthn_credentials`;
```

### `#__scheduler_logs`

**Handling:** `IGNORE / ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__scheduler_logs`;
```

**Data query**

```sql
SELECT * FROM `#__scheduler_logs`;
```

### `#__action_logs`

**Handling:** `IGNORE / ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__action_logs`;
```

**Data query**

```sql
SELECT * FROM `#__action_logs`;
```

### `#__finder_filters`

**Handling:** `MIGRATE / RECREATE / REVIEW`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_filters`;
```

**Data query**

```sql
SELECT * FROM `#__finder_filters`;
```

### `#__finder_links`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links`;
```

### `#__finder_links_terms`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_links_terms`;
```

**Data query**

```sql
SELECT * FROM `#__finder_links_terms`;
```

### `#__finder_logging`

**Handling:** `IGNORE / ARCHIVE`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_logging`;
```

**Data query**

```sql
SELECT * FROM `#__finder_logging`;
```

### `#__finder_taxonomy`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy`;
```

**Data query**

```sql
SELECT * FROM `#__finder_taxonomy`;
```

### `#__finder_taxonomy_map`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_taxonomy_map`;
```

**Data query**

```sql
SELECT * FROM `#__finder_taxonomy_map`;
```

### `#__finder_terms`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_terms`;
```

**Data query**

```sql
SELECT * FROM `#__finder_terms`;
```

### `#__finder_terms_common`

**Handling:** `TARGET_OWNED / REVIEW`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_terms_common`;
```

**Data query**

```sql
SELECT * FROM `#__finder_terms_common`;
```

### `#__finder_tokens`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_tokens`;
```

**Data query**

```sql
SELECT * FROM `#__finder_tokens`;
```

### `#__finder_tokens_aggregate`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_tokens_aggregate`;
```

**Data query**

```sql
SELECT * FROM `#__finder_tokens_aggregate`;
```

### `#__finder_types`

**Handling:** `REBUILD`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__finder_types`;
```

**Data query**

```sql
SELECT * FROM `#__finder_types`;
```

### `#__postinstall_messages`

**Handling:** `TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__postinstall_messages`;
```

**Data query**

```sql
SELECT * FROM `#__postinstall_messages`;
```

### `#__overrider`

**Handling:** `MIGRATE / RECREATE / REVIEW`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__overrider`;
```

**Data query**

```sql
SELECT * FROM `#__overrider`;
```

### `#__guidedtours`

**Handling:** `TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__guidedtours`;
```

**Data query**

```sql
SELECT * FROM `#__guidedtours`;
```

### `#__guidedtour_steps`

**Handling:** `TARGET_OWNED`

**Count query**

```sql
SELECT COUNT(*) AS row_count FROM `#__guidedtour_steps`;
```

**Data query**

```sql
SELECT * FROM `#__guidedtour_steps`;
```

---

<a id="coverage-verification"></a>

# Coverage Verification

This document is built directly from the canonical migration-group manifests and includes every explicitly classified core table.

## Joomla 3 coverage

| Group | Tables | Count queries | Data queries |
|---|---:|---:|---:|
| G0 — System Reference | 5 | 5 | 5 |
| G1 — Users and Access Foundation | 6 | 6 | 6 |
| G2 — Taxonomy and Shared Definitions | 7 | 7 | 7 |
| G3 — Main Content | 3 | 3 | 3 |
| G4 — Content Relations | 6 | 6 | 6 |
| G5 — Menu and Presentation | 3 | 3 | 3 |
| G6 — Modules | 2 | 2 | 2 |
| G7 — Supporting Core Components | 14 | 14 | 14 |
| G8 — Runtime, Generated, Historical, and Excluded | 32 | 32 | 32 |
| **Total** | **78** | **78** | **78** |

```text
Joomla 3 canonical tables = 78
Tables documented         = 78
COUNT queries              = 78
Data-list queries          = 78
Missing canonical tables   = 0
Duplicate table sections   = 0
Static query coverage      = 100%
```

## Joomla 6 coverage

| Group | Tables | Count queries | Data queries |
|---|---:|---:|---:|
| G0 — System Reference | 6 | 6 | 6 |
| G1 — Users and Access Foundation | 6 | 6 | 6 |
| G2 — Taxonomy and Shared Definitions | 10 | 10 | 10 |
| G3 — Main Content | 3 | 3 | 3 |
| G4 — Content Relations | 8 | 8 | 8 |
| G5 — Menu and Presentation | 4 | 4 | 4 |
| G6 — Modules | 2 | 2 | 2 |
| G7 — Supporting Core Components | 16 | 16 | 16 |
| G8 — Runtime, Generated, and Target-Owned Data | 21 | 21 | 21 |
| **Total** | **76** | **76** | **76** |

```text
Joomla 6 canonical tables = 76
Tables documented         = 76
COUNT queries              = 76
Data-list queries          = 76
Missing canonical tables   = 0
Duplicate table sections   = 0
Static query coverage      = 100%
```

## Combined coverage

```text
Canonical table sections   = 154
COUNT queries              = 154
Data-list queries          = 154
Total manual SQL queries   = 308
Static table coverage      = 100%
```

> [!IMPORTANT]
> Static coverage proves that this Markdown contains queries for every table in the two canonical manifests.  
> It does **not** prove that a particular production database physically contains every canonical table. Always reconcile the actual database inventory before final approval.

<a id="manual-acceptance-checklist"></a>

# Manual Acceptance Checklist

- [ ] The Joomla 3 table prefix was substituted correctly.
- [ ] The Joomla 6 table prefix was substituted correctly.
- [ ] Every physically present Joomla 3 core table was checked.
- [ ] Every Joomla 6 core table was checked.
- [ ] Every `MIGRATE` / `TRANSFORM` business record has an explained target disposition.
- [ ] ID differences were validated through the migration mapping instead of assuming source ID = target ID.
- [ ] `REBUILD` / `GENERATE` tables were checked after the required Joomla 6 rebuild operations.
- [ ] `TARGET_OWNED` tables were not judged by raw Joomla 3 row equality.
- [ ] `ARCHIVE` tables have preserved source evidence in the approved archive.
- [ ] `IGNORE` tables were intentionally excluded for a documented reason.
- [ ] Any canonical Joomla 3 table absent from the real source has explicit `ABSENT_SOURCE` evidence.
- [ ] No unexpected source table, row, or business record disappeared without an approved disposition.
- [ ] Manual exceptions are documented before migration acceptance.

---

## Related migration references

- [Joomla 3 core migration groups](./01-joomla-core-migration-groups-v3.md)
- [Joomla 6 core migration groups](./02-joomla-core-migration-groups-v6.md)
- [Joomla 3 core migration fields](./03-joomla-core-migration-fields-v3.md)
- [Joomla 6 core migration fields](./04-joomla-core-migration-fields-v6.md)
- [Joomla Core J3 → J6 migration contract](./05-joomla-core-j3-j6-migration-contract.md)
- [Joomla core table mapping migration](./06-joomla-core-table-mapping-migration.md)
- [Joomla core field mapping migration](./07-joomla-core-field-mapping-migration.md)
