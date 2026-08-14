# Joomla Core J3 → J6 Migration Contract

> **Workflow authority:** This is a static reference contract. New workflow execution, live denominators, executable compilation, reporting, and PASS rules are governed by [`../migration-workflow.md`](../migration-workflow.md) and the 2026-08-14 overlay below.

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

## Canonical seven-step workflow overlay — 2026-08-14

This file is the static Joomla Core reference contract. [`../migration-workflow.md`](../migration-workflow.md) is authoritative for workflow order, artifact ownership, retry behavior, executable compilation, PASS gates, and current-workflow evidence. The reference counts above describe the documented Joomla 3.10.12/Joomla 6.1.2 manifests; they must not be copied into a new workflow as live PASS denominators. Each workflow freezes its own physical source/clean-target snapshots and derives all active denominators from its approved scope.

The seven-step ownership boundary is mandatory:

- Step 1 creates one DRAFT release before inserting table mappings bound to it. It records ownership, absent-source evidence, row baselines, dependencies, and the selected physical scope.
- Step 2 independently verifies only inventory and table-mapping outputs; it creates, inspects, or repairs no field contract.
- Step 3 materializes and compiles the complete executable migration contract against the actual DRAFT release/table/field mapping IDs. Generic copy rules, unqualified runtime-map lookups, pseudo-functions, abbreviated archive SQL, and unresolved producer semantics cannot freeze or PASS.
- Step 4 executes only the frozen contract, persists RUNTIME maps, performs canonical writes and archives, runs approved external rebuild handoffs, and embeds the complete Migration Disposition Report in its plan.
- Step 5 independently executes the Post-Migration No-Data-Loss Tutorial and reconciles every source identity without repair.

Every source table, field, row, and cell must have exactly one applicable disposition at its accounting grain: `MIGRATED`, `ARCHIVED`, `REBUILT`, `TARGET_OWNED`, `DEFERRED_OUT_OF_SCOPE`, `INTENTIONAL_IGNORE`, or `SKIP_ABSENT_SOURCE`. `ARCHIVED` requires payload/value read-back and hash equality. `DEFERRED_OUT_OF_SCOPE` requires preserved source evidence and a named later-workflow owner. `SKIP_ABSENT_SOURCE` requires the bound snapshot to prove physical absence and zero rows/fields. `MISSING_EXPECTED`, an unexplained skip, no disposition, or duplicate dispositions is a workflow failure and may not be converted to `IGNORE`, `ARCHIVE`, or `SKIP` merely to reach PASS.

Workflow-specific exceptions and business policies recorded below are evidence inputs only. A newer workflow must explicitly adopt and bind them; workflow/release IDs, hashes, commands, counts, and PASS results are never inherited automatically.

---



## Purpose and Guarantee

> **Inventory = 100%**  
> **Source decisions = 100% required**  
> **Target resolution = 100% required**  
> **Production execution is blocked until every gate in this document passes**

This document is the migration contract that connects the four schema manifests:

- [`joomla-core-migration-groups-v3.md`](01-joomla-core-migration-groups-v3.md)
- [`joomla-core-migration-fields-v3.md`](03-joomla-core-migration-fields-v3.md)
- [`joomla-core-migration-groups-v6.md`](02-joomla-core-migration-groups-v6.md)
- [`joomla-core-migration-fields-v6.md`](04-joomla-core-migration-fields-v6.md)

The contract does **not** define 100% migration as "copy every Joomla 3 row into Joomla 6". Runtime, generated, security-token, obsolete, and target-owned data must not be blindly copied.

The guarantee is:

> **100% of Joomla 3 core database objects, fields, and records in the declared migration scope must be accounted for by an explicit migration decision and verified against the Joomla 6 target contract.**

No source table, source field, source record, required target field, ID reference, structured value, or dependency is allowed to disappear silently.

---

## 1. Fixed Baseline

| Item | Baseline |
|---|---:|
| Source CMS | Joomla `3.10.12` |
| Source core tables | `78` |
| Source physical fields | `711` |
| Target CMS | Joomla `6.1.2` |
| Target core tables | `76` |
| Target physical fields | `832` |

Official source baselines are defined by the companion field manifests.

Before production execution, the real source and target databases must still be reconciled with `information_schema.TABLES` and `information_schema.COLUMNS`.

---

## 2. Allowed Final Decisions

A source object must resolve to exactly one final outcome.

| Decision | Meaning |
|---|---|
| `DIRECT` | Copy a scalar value to the mapped target field after compatibility validation. |
| `TRANSFORM` | Convert source value/record into the Joomla 6 representation. |
| `LOOKUP` | Resolve a target value through an identity/ID/value map. |
| `STRUCTURED` | Parse structured content, remap embedded references, validate, and serialize. |
| `DEFAULT` | Use the Joomla 6 DDL/application default. |
| `GENERATED` | Generate target data from target state or migrated entities. |
| `DERIVED` | Calculate migration evidence or a target value deterministically from source/target state. |
| `REBUILD` | Do not copy generated source data; rebuild it in Joomla 6. |
| `REFERENCE_ONLY` | Use source data only to identify/map target-owned records. |
| `ARCHIVE` | Preserve source data in migration archive; do not make it active Joomla 6 core data. |
| `IGNORE` | Intentionally do not migrate runtime/security/install-state data; reason is mandatory. |
| `TARGET_OWNED` | Preserve the fresh Joomla 6 value/record. |
| `RECREATE` | Reconfigure/recreate target state using Joomla 6 semantics/API. |

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

Any of the above blocks migration.

---

## 3. Global Mapping Precedence

### Selected-source exception — `honda_corp` Joomla 3.8 lineage

The canonical manifest remains a 78-table / 711-field Joomla 3.10.12 reference. The selected live source (`honda_corp`, `ty08n_`) is an earlier Joomla 3.8 lineage and has no physical `#__privacy_requests`, `#__privacy_consents`, `#__action_logs_extensions`, `#__action_log_config`, `#__action_logs_users`, or `#__action_logs` table. For workflow `JOOMLA_CORE` / `j3-to-j6-20260813-01`, those six declared rows were persisted as `SKIP_ABSENT_SOURCE`: zero source rows, zero source fields, no target writes, and no field mapping, migration, or validation obligation. That workflow's physical contract was therefore **72 tables / 672 fields**. This evidence does not automatically bind a later workflow: each new Step 1 must re-prove the same physical absences from its own snapshot. A present table must never be skipped.

Every one of the **711 Joomla 3 source fields** is assigned through the following deterministic precedence. The first matching rule wins.

```text
1. Source table = IGNORE       → every field = IGNORE
2. Source table = ARCHIVE      → every field = ARCHIVE
3. Source table = REBUILD      → every field = REBUILD
4. Explicit field rule exists  → use explicit field rule
5. Reference field             → LOOKUP
6. Structured field            → STRUCTURED
7. Same-name target field      → DIRECT + SQL_VALUE_NORMALIZE
8. Source-only operational field → ARCHIVE_SOURCE_ONLY + validation record
9. No rule matched             → CONTRACT ERROR; migration blocked
```

`DIRECT` never means "blind copy". It includes compatibility checks for type, nullability, length, collation where relevant, and valid Joomla 6 values.

### SQL value normalization

`SQL_VALUE_NORMALIZE` includes:

- normalize Joomla 3 zero-dates before insert;
- convert a zero-date to `NULL` only when the Joomla 6 field permits `NULL`;
- reject an invalid zero-date for a target `NOT NULL` field unless a field-specific transform is defined;
- preserve UTF-8 text while validating target length;
- preserve `NULL` vs empty-string semantics when they are materially different;
- never truncate silently.

---

# 4. Source Table Mapping Contract — 78/78

## G0 — System Reference

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 1 | `#__extensions` | `#__extensions` | `REFERENCE_ONLY` | map by `type + element + folder + client_id`; never reuse `extension_id` blindly |
| 2 | `#__schemas` | `#__schemas` | `REFERENCE_ONLY` | target install state wins |
| 3 | `#__update_sites` | `#__update_sites` | `REFERENCE_ONLY` | target-owned update sites; preserve source evidence for extension reconciliation |
| 4 | `#__update_sites_extensions` | `#__update_sites_extensions` | `REFERENCE_ONLY` | resolve both IDs through target extension/update-site identity |
| 5 | `#__updates` | `#__updates` | `REFERENCE_ONLY` | transient update cache; target refresh owns active data |

## G1 — Users and Access Foundation

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 6 | `#__languages` | `#__languages` | `TRANSFORM` | stable key `lang_code`; map `asset_id` and `access` |
| 7 | `#__usergroups` | `#__usergroups` | `TRANSFORM` | generate `USERGROUP` ID map; rebuild/validate tree |
| 8 | `#__users` | `#__users` | `TRANSFORM` | generate `USER` ID map; preserve compatible password hashes; normalize dates |
| 9 | `#__user_usergroup_map` | `#__user_usergroup_map` | `TRANSFORM` | remap `user_id` and `group_id` |
| 10 | `#__viewlevels` | `#__viewlevels` | `TRANSFORM` | generate `VIEWLEVEL` ID map; remap group IDs inside `rules` JSON |
| 11 | `#__user_profiles` | `#__user_profiles` | `TRANSFORM` | remap `user_id`; validate key-dependent values |

## G2 — Taxonomy and Shared Definitions

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 12 | `#__assets` | `#__assets` | `REBUILD` | target asset IDs/tree generated/reconciled from migrated target entities |
| 13 | `#__categories` | `#__categories` | `TRANSFORM` | generate `CATEGORY` ID map; remap parent/user/access; rebuild derived tree/path; reconcile assets |
| 14 | `#__tags` | `#__tags` | `TRANSFORM` | generate `TAG` ID map; remap parent/user/access; rebuild tree/path |
| 15 | `#__content_types` | `#__content_types` | `REFERENCE_ONLY` | map by `type_alias`; use Joomla 6 target definitions |
| 16 | `#__fields_groups` | `#__fields_groups` | `TRANSFORM` | generate `FIELD_GROUP` ID map; map ACL/user/context |
| 17 | `#__fields` | `#__fields` | `TRANSFORM` | generate `FIELD` ID map; map group/ACL/user/context; transform field config |
| 18 | `#__fields_categories` | `#__fields_categories` | `TRANSFORM` | remap `field_id` and `category_id` |

## G3 — Main Content

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 19 | `#__content` | `#__content` | `TRANSFORM` | generate `CONTENT` ID map; map category/user/access/asset; transform structured fields |
| 20 | `#__content_frontpage` | `#__content_frontpage` | `TRANSFORM` | remap `content_id`; populate Joomla 6 target-only featured dates by target defaults unless explicitly derived |
| 21 | `#__content_rating` | `#__content_rating` | `TRANSFORM` | remap `content_id`; preserve rating aggregates |

## G4 — Content Relations

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 22 | `#__contentitem_tag_map` | `#__contentitem_tag_map` | `TRANSFORM` | remap item/tag/content-type IDs by `type_alias` context |
| 23 | `#__fields_values` | `#__fields_values` | `TRANSFORM` | remap `field_id`; resolve `item_id` by field context; transform type-specific values |
| 24 | `#__associations` | `#__associations` | `TRANSFORM` | remap associated item IDs by `context`; recompute association key when IDs change |
| 25 | `#__ucm_base` | `#__ucm_base` | `REBUILD` | derive/reconcile UCM records from migrated entities and Joomla 6 content-type identities |
| 26 | `#__ucm_content` | `#__ucm_content` | `REBUILD` | derive/reconcile from migrated target entities; do not trust source UCM IDs |
| 27 | `#__ucm_history` | `#__history` | `TRANSFORM` | preserve history; map item/type identity into Joomla 6 `item_id`; add Joomla 6 history-state fields |

## G5 — Menu and Presentation

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 28 | `#__template_styles` | `#__template_styles` | `TRANSFORM` | map by target template identity; archive incompatible legacy-template style payloads; recreate equivalent target style where applicable |
| 29 | `#__menu_types` | `#__menu_types` | `TRANSFORM` | generate `MENU_TYPE` identity map; remap asset if applicable |
| 30 | `#__menu` | `#__menu` | `TRANSFORM` | generate `MENU` ID map; remap component/parent/access/template style; rewrite embedded IDs in links/params |

## G6 — Modules

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 31 | `#__modules` | `#__modules` | `TRANSFORM` | generate `MODULE` ID map; required Joomla 6 module code must exist; transform params/content/references |
| 32 | `#__modules_menu` | `#__modules_menu` | `TRANSFORM` | remap module and menu IDs; preserve `0=all` and negative exclusion semantics |

## G7 — Supporting Core Components

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 33 | `#__contact_details` | `#__contact_details` | `TRANSFORM` | generate `CONTACT` ID map; remap user/category/access/assets; transform params/metadata |
| 34 | `#__newsfeeds` | `#__newsfeeds` | `TRANSFORM` | generate `NEWSFEED` ID map; remap category/users/access; transform params/images |
| 35 | `#__banners` | `#__banners` | `TRANSFORM` | generate `BANNER` ID map; remap client/category/users; transform params/URLs |
| 36 | `#__banner_clients` | `#__banner_clients` | `TRANSFORM` | generate `BANNER_CLIENT` ID map; preserve business records |
| 37 | `#__banner_tracks` | migration archive | `ARCHIVE` | preserve historical tracking rows; not required for active Joomla 6 behavior |
| 38 | `#__redirect_links` | `#__redirect_links` | `TRANSFORM` | preserve redirect intent; normalize URLs/dates only as required |
| 39 | `#__messages` | `#__messages` | `TRANSFORM` | remap sender/recipient users; preserve message data |
| 40 | `#__messages_cfg` | `#__messages_cfg` | `TRANSFORM` | remap user ID; preserve config values |
| 41 | `#__user_notes` | `#__user_notes` | `TRANSFORM` | remap user/category/creator/modifier/access dependencies |
| 42 | `#__privacy_requests` | `#__privacy_requests` | `TRANSFORM` | preserve compliance records; validate statuses/tokens/dates |
| 43 | `#__privacy_consents` | `#__privacy_consents` | `TRANSFORM` | remap `user_id`; preserve consent evidence |
| 44 | `#__action_logs_extensions` | `#__action_logs_extensions` | `REFERENCE_ONLY` | Joomla 6 default extension log configuration owns active rows; map by extension string |
| 45 | `#__action_log_config` | `#__action_log_config` | `REFERENCE_ONLY` | Joomla 6 default action-log schema owns active rows; source retained for comparison |
| 46 | `#__action_logs_users` | `#__action_logs_users` | `TRANSFORM` | remap user ID; validate extension list against Joomla 6 extensions |

## G8 — Runtime, Generated, Historical, and Excluded

| # | Joomla 3 source | Joomla 6 target | Final decision | Identity / rule |
|---:|---|---|---|---|
| 47 | `#__session` | — | `IGNORE` | runtime session state must not be migrated |
| 48 | `#__user_keys` | — | `IGNORE` | remember-me/authentication tokens must not be migrated |
| 49 | `#__finder_filters` | `#__finder_filters` | `TRANSFORM` | preserve user-defined filters when valid; remap users/structured filter payload |
| 50 | `#__finder_links` | `#__finder_links` | `REBUILD` | rebuild Smart Search index from migrated content |
| 51 | `#__finder_links_terms0` | `#__finder_links_terms` | `REBUILD` | Joomla 3 partitioned index → Joomla 6 rebuilt unified index |
| 52 | `#__finder_links_terms1` | `#__finder_links_terms` | `REBUILD` | same rule |
| 53 | `#__finder_links_terms2` | `#__finder_links_terms` | `REBUILD` | same rule |
| 54 | `#__finder_links_terms3` | `#__finder_links_terms` | `REBUILD` | same rule |
| 55 | `#__finder_links_terms4` | `#__finder_links_terms` | `REBUILD` | same rule |
| 56 | `#__finder_links_terms5` | `#__finder_links_terms` | `REBUILD` | same rule |
| 57 | `#__finder_links_terms6` | `#__finder_links_terms` | `REBUILD` | same rule |
| 58 | `#__finder_links_terms7` | `#__finder_links_terms` | `REBUILD` | same rule |
| 59 | `#__finder_links_terms8` | `#__finder_links_terms` | `REBUILD` | same rule |
| 60 | `#__finder_links_terms9` | `#__finder_links_terms` | `REBUILD` | same rule |
| 61 | `#__finder_links_termsa` | `#__finder_links_terms` | `REBUILD` | same rule |
| 62 | `#__finder_links_termsb` | `#__finder_links_terms` | `REBUILD` | same rule |
| 63 | `#__finder_links_termsc` | `#__finder_links_terms` | `REBUILD` | same rule |
| 64 | `#__finder_links_termsd` | `#__finder_links_terms` | `REBUILD` | same rule |
| 65 | `#__finder_links_termse` | `#__finder_links_terms` | `REBUILD` | same rule |
| 66 | `#__finder_links_termsf` | `#__finder_links_terms` | `REBUILD` | same rule |
| 67 | `#__finder_taxonomy` | `#__finder_taxonomy` | `REBUILD` | rebuild index taxonomy |
| 68 | `#__finder_taxonomy_map` | `#__finder_taxonomy_map` | `REBUILD` | rebuild index taxonomy map |
| 69 | `#__finder_terms` | `#__finder_terms` | `REBUILD` | rebuild index terms |
| 70 | `#__finder_terms_common` | `#__finder_terms_common` | `TRANSFORM` | preserve source rows with `custom=1`; Joomla 6 built-in/common rows remain target-owned |
| 71 | `#__finder_tokens` | `#__finder_tokens` | `REBUILD` | transient generated search tokens |
| 72 | `#__finder_tokens_aggregate` | `#__finder_tokens_aggregate` | `REBUILD` | transient generated aggregate tokens |
| 73 | `#__finder_types` | `#__finder_types` | `REBUILD` | rebuild index type metadata from Joomla 6 finder plugins/content |
| 74 | `#__action_logs` | migration archive | `ARCHIVE` | preserve historical audit evidence without inserting legacy log semantics into active J6 log |
| 75 | `#__core_log_searches` | migration archive | `ARCHIVE` | obsolete historical search-log semantics; do not reinterpret as J6 finder logging |
| 76 | `#__overrider` | `#__overrider` | `TRANSFORM` | preserve intentional language overrides after validating target language/file identity |
| 77 | `#__postinstall_messages` | `#__postinstall_messages` | `REBUILD` | regenerate from Joomla 6 core/extension manifests; never copy version-specific source rows blindly |
| 78 | `#__utf8_conversion` | migration verification evidence | `DERIVED` | derive conversion completion from successful target charset/collation checks |

### Source table gate

```text
Joomla 3 source tables           = 78
Contract table decisions         = 78
Duplicate source table decisions = 0
Unmapped source tables           = 0
Ambiguous table decisions        = 0
TABLE CONTRACT                   = PASS
```

---

# 5. Target-Only / Target-Generated Joomla 6 Structures

These Joomla 6 structures do not receive a blind Joomla 3 table copy.

| Joomla 6 target | Resolution |
|---|---|
| `#__tuf_metadata` | `TARGET_OWNED` |
| `#__workflows` | `TARGET_OWNED / GENERATED` by the approved workflow strategy |
| `#__workflow_stages` | `TARGET_OWNED / GENERATED` |
| `#__workflow_transitions` | `TARGET_OWNED / GENERATED` |
| `#__workflow_associations` | `GENERATED` for migrated content after content IDs and target stages are known |
| `#__schemaorg` | `TARGET_OWNED` unless an explicit application-level Schema.org migration rule is approved |
| `#__template_overrides` | `RECREATE`; never copy Joomla 3 override state blindly |
| `#__mail_templates` | `TARGET_OWNED`; merge only intentional target-compatible customizations through a separate approved customization rule |
| `#__scheduler_tasks` | `RECREATE` only for installed Joomla 6 task plugins and approved schedules |
| `#__user_mfa` | `RECREATE`; users re-enrol MFA |
| `#__webauthn_credentials` | `RECREATE`; users re-enrol credentials |
| `#__scheduler_logs` | `TARGET_OWNED` runtime/history |
| `#__finder_logging` | `TARGET_OWNED` runtime search logging; J3 `#__core_log_searches` is archived, not coerced into it |
| `#__guidedtours` | `TARGET_OWNED` |
| `#__guidedtour_steps` | `TARGET_OWNED` |

For target-only **fields inside a mapped table**, resolution follows Section 9.

---

# 6. ID Mapping Contract

IDs must not be assumed equal between Joomla 3 and Joomla 6.

Required mapping entities:

```text
EXTENSION
USER
USERGROUP
VIEWLEVEL
CATEGORY
TAG
FIELD_GROUP
FIELD
CONTENT
CONTENT_TYPE
MENU_TYPE
MENU
MODULE
TEMPLATE_STYLE
CONTACT
NEWSFEED
BANNER_CLIENT
BANNER
USER_NOTE
```

Recommended persistent map:

```sql
CREATE TABLE migration_id_map (
    migration_run_id BIGINT NOT NULL,
    entity_type      VARCHAR(64) NOT NULL,
    source_table     VARCHAR(128) NOT NULL,
    source_id        VARCHAR(255) NOT NULL,
    target_table     VARCHAR(128) NOT NULL,
    target_id        VARCHAR(255) NOT NULL,
    identity_key     VARCHAR(1024) NULL,
    mapping_method   VARCHAR(32) NOT NULL,
    created_at       DATETIME NOT NULL,
    PRIMARY KEY (migration_run_id, entity_type, source_table, source_id),
    UNIQUE KEY uq_target_map
      (migration_run_id, entity_type, target_table, target_id)
);
```

### ID rules

1. Target-owned Joomla system rows use stable semantic identity, not source IDs.
2. Migrated entity IDs may be preserved only when collision checks explicitly pass; otherwise generate target IDs and record the mapping.
3. All logical references use the map, even when MySQL does not declare a foreign key.
4. Embedded IDs inside JSON, URLs, registry values, ACL rules, menu links, or field values must use the same map.
5. Missing required mappings are fatal.

### ID gate

```text
Required source IDs mapped          = 100%
Duplicate source mappings           = 0
Duplicate incompatible target maps  = 0
Missing referenced IDs              = 0
Ambiguous identity matches          = 0
```

---

# 7. Explicit Reference / Lookup Rules

At minimum, the following references must never be blindly copied when the referenced identity can change.

| Source field/pattern | Target lookup |
|---|---|
| `*.asset_id` | rebuilt/reconciled `#__assets.id` |
| `*.access` | `VIEWLEVEL` map |
| user creator/modifier/check-out fields | `USER` map |
| `#__content.catid` | `CATEGORY` map |
| `#__categories.parent_id` | `CATEGORY` map |
| `#__tags.parent_id` | `TAG` map |
| `#__fields.group_id` | `FIELD_GROUP` map |
| `#__fields_categories.field_id` | `FIELD` map |
| `#__fields_categories.category_id` | `CATEGORY` map |
| `#__content_frontpage.content_id` | `CONTENT` map |
| `#__content_rating.content_id` | `CONTENT` map |
| `#__contentitem_tag_map.content_item_id` | context/entity map |
| `#__contentitem_tag_map.tag_id` | `TAG` map |
| `#__contentitem_tag_map.type_id` | `CONTENT_TYPE` map |
| `#__fields_values.field_id` | `FIELD` map |
| `#__fields_values.item_id` | context/entity map |
| `#__menu.parent_id` | `MENU` map |
| `#__menu.component_id` | `EXTENSION` map |
| `#__menu.template_style_id` | `TEMPLATE_STYLE` map |
| `#__modules_menu.moduleid` | `MODULE` map |
| `#__modules_menu.menuid > 0` | `MENU` map |
| contact/newsfeed/banner/user-note category fields | `CATEGORY` map |
| `#__banners.cid` | `BANNER_CLIENT` map |
| private message user fields | `USER` map |
| privacy/action-log user fields | `USER` map |

Special values such as `0`, root IDs, all-menu assignment, or negative module-menu exclusions must be processed according to Joomla semantics before applying an ordinary lookup.

---

# 8. Structured Data Contract

A structured field must be parsed before transformation. String replacement is prohibited.

## Mandatory structured classes

### ACL

- `#__assets.rules`
- `#__viewlevels.rules`

Rule:

```text
parse JSON
→ identify embedded user-group IDs
→ map each group ID
→ validate every target group
→ canonical JSON encode
```

### Joomla Registry / JSON configuration

Includes, at minimum:

- `#__extensions.params`
- `#__extensions.manifest_cache`
- `#__users.params`
- category/tag/field/field-group `params` / `metadata`
- `#__fields.fieldparams`
- `#__content.attribs`
- `#__content.metadata`
- `#__menu.params`
- `#__modules.params`
- contact/newsfeed/banner configuration
- target-compatible scheduler/filter configuration when migrated

Rule:

```text
parse using the real format
→ preserve unknown keys unless the target explicitly rejects them
→ remap known embedded IDs
→ transform version-specific keys when a verified rule exists
→ serialize
→ parse again
→ semantic validation
```

### Media / URL structures

Includes:

- `#__content.images`
- `#__content.urls`
- `#__tags.images`
- `#__tags.urls`
- `#__newsfeeds.images`
- image/path fields in supporting components
- menu/module HTML that can contain internal URLs/media references

Database migration must preserve the database reference. Physical files are a separate filesystem migration dependency and are **not** proven by this DB-only contract.

### Menu links

`#__menu.link` may contain IDs in query parameters.

Rule:

```text
parse route/query
→ identify component + entity context
→ map embedded source IDs
→ rebuild query
→ verify target route resolves to the expected migrated entity
```

### Custom field values

`#__fields_values.value` is field-type-dependent.

Rule:

```text
resolve field definition/type
→ resolve item context
→ transform known structured value types
→ preserve scalar values
→ validate target field plugin accepts value
```

Repeatable legacy values must be treated as structured migration input, not opaque text.

### Structured-data gate

```text
Structured source fields discovered  = 100%
Structured fields with parser/rule   = 100%
Invalid structured payloads          = 0
Unresolved embedded IDs              = 0
Silent string replacement            = 0
```

---

# 9. Field Mapping Contract — 711/711 Coverage

The authoritative source-field universe is the **711 `(table, field)` pairs** in `joomla-core-migration-fields-v3.md`.

The authoritative target-field universe is the **832 `(table, field)` pairs** in `joomla-core-migration-fields-v6.md`.

This contract deliberately avoids duplicating 711 DDL rows. Instead, every source field is resolved by the deterministic precedence in Section 3 plus the explicit rules below. This prevents two independent field manifests from drifting.

## 9.1 Entity identity fields

Primary entity IDs on migrated tables use `LOOKUP/GENERATED_ID` semantics and must produce entries in `migration_id_map`.

The source ID remains part of audit evidence even when the target ID changes.

## 9.2 Derived tree fields

For hierarchical tables (`#__assets`, `#__usergroups`, `#__categories`, `#__tags`, `#__menu`):

- `parent_id` → `LOOKUP` after root/special-value handling;
- `lft`, `rgt`, `level` → `GENERATED/REBUILD` when the target tree is rebuilt;
- `path` → `GENERATED/REBUILD` where Joomla derives the path;
- validate one root, valid parent chains, no cycles, and consistent nested-set boundaries.

## 9.3 Source-only operational field rule

A source field that has no Joomla 6 target field may **never** be silently discarded.

Final rule:

```text
source value
→ migration archive (table, source_pk, field, value, reason)
→ mark ARCHIVE_SOURCE_ONLY
```

If production analysis shows that the source-only field is required by active business behavior, the migration is blocked until an explicit target representation is approved.

Known example:

- `#__content.xreference` → `ARCHIVE_SOURCE_ONLY`; if production uses it as an external integration key, an explicit preservation target is mandatory before PASS.
- Joomla 3 extension/install metadata fields removed in Joomla 6 → `REFERENCE_ONLY` or archive evidence according to G0 policy.

## 9.4 Target-only field rule

For every target field not populated from a source field:

```text
1. AUTO_INCREMENT / generated identity → GENERATED
2. target-owned table                 → TARGET_OWNED
3. nullable target field              → DEFAULT (normally NULL) unless semantic rule overrides
4. target DDL default exists          → DEFAULT
5. field belongs to generated J6 structure → GENERATED / RECREATE
6. required NOT NULL field with no valid value → CONTRACT ERROR
```

No required Joomla 6 target field may be invented silently.

## 9.5 Important schema-transition rules

### `#__content`

- identity/reference fields use ID maps;
- `introtext`, `fulltext`, `images`, `urls`, `attribs`, `metadata` use structured/content validation;
- `xreference` is source-only and archived unless production proves an active preservation requirement;
- target article workflow association is generated separately after the content row exists.

### `#__ucm_history` → `#__history`

Source fields:

```text
version_id
ucm_item_id
ucm_type_id
version_note
save_date
editor_user_id
character_count
sha1_hash
version_data
keep_forever
```

Target history stores a target `item_id` plus Joomla 6 history state fields. Migration must:

1. resolve `ucm_type_id` to its source content-type identity;
2. resolve `ucm_item_id` to the migrated target entity ID;
3. construct the Joomla 6 history item identity using the verified target history convention;
4. remap `editor_user_id`;
5. preserve/transform the JSON version snapshot;
6. set target-only history state flags using an explicit deterministic rule;
7. verify every history entry references a valid migrated entity.

If a history type cannot be resolved, the record is archived and the migration gate records a non-operational history exception; it must never disappear silently.

### Finder J3 partitions → Joomla 6 finder index

All fields in `#__finder_links_terms0` … `#__finder_links_termsf` inherit `REBUILD`.

They do not map row-for-row to `#__finder_links_terms`; the Joomla 6 Smart Search index is rebuilt from migrated target content.

## 9.6 Field coverage gate

```text
Official J3 source fields            = 711
Fields covered by table/field rules  = 711
Duplicate source field decisions     = 0
Unmapped source fields               = 0
Silent source-only drops             = 0
Required J6 fields unresolved        = 0
FIELD CONTRACT                       = PASS (definition-level)
```

Production execution must materialize one decision for every active included source field derived from the current workflow's frozen scope. The 711 reference decisions remain a document anti-join input; declared-absent rows contribute no physical fields, while any newly present or drifted field must be explicitly classified before Step 3 can freeze.

---

# 10. Value Mapping Contract

Value mapping is distinct from ID mapping.

| Domain | Rule |
|---|---|
| language | preserve valid language code / `*`; verify target language exists when language-specific |
| access | resolve through `VIEWLEVEL` identity map |
| user group ACL | remap all embedded group IDs |
| state/published | preserve semantic state only when Joomla 6 accepts the value; otherwise explicit transform |
| extension identity | map by `type + element + folder + client_id`, not numeric ID |
| content type | map by `type_alias` |
| template | map by installed Joomla 6 template identity; incompatible legacy template state is archived/recreated |
| module | module extension must exist and be Joomla 6 compatible before instance migration |
| workflow | Joomla 3 article state is migrated into article state plus an approved Joomla 6 workflow/stage association |
| special IDs | process `0`, root values, negative menu exclusions, and other semantic sentinels before normal lookup |

Every enumerated/semantic transform must record source value, target value, rule name, and run ID for audit.

---

# 11. Joomla 6 Workflow Contract

Joomla 3 does not provide the Joomla 6 workflow table model.

The target workflow definitions are target-owned/recreated first.

For every migrated article that requires a workflow association:

```text
migrated J6 content ID
→ determine target workflow from category/content policy
→ determine target stage from approved state→stage rule
→ insert/verify #__workflow_associations
```

Gate:

```text
Required content workflow associations = 100%
Missing workflow                        = 0
Missing stage                           = 0
Orphan workflow association             = 0
```

The contract must not infer a workflow stage merely from matching numeric IDs.

---

# 12. Execution Dependency Contract

```text
P0  Freeze scope + backups + production inventory
 ↓
G0  Target system/reference identities
 ↓
G1  Users / groups / view levels / languages
 ↓
G2  Categories / tags / fields + target workflow definitions
 ↓
G3  Main content
 ↓
G4  Tags / custom field values / associations / history / workflow associations / UCM rebuild
 ↓
G5  Menu / presentation
 ↓
G6  Modules + menu assignments
 ↓
G7  Supporting core components
 ↓
G8  Archive / ignore / target-owned / Smart Search rebuild
 ↓
P9  Full verification gate
```

A batch may run only when all ID maps and target dependencies it consumes already exist.

---

# 13. Record Accounting Contract

Schema coverage does not prove data coverage.

For every source table and every production migration run, record:

```text
source_rows
migrated_rows
archived_rows
rebuilt_rows
target_owned_rows
deferred_out_of_scope_rows
intentional_ignore_rows
rejected_rows

source_cells
migrated_cells
archived_cells
rebuilt_cells
target_owned_cells
deferred_out_of_scope_cells
intentional_ignore_cells
rejected_cells
```

Invariant:

```text
source_rows
=
migrated_rows
+ archived_rows
+ rebuilt_rows
+ target_owned_rows
+ deferred_out_of_scope_rows
+ intentional_ignore_rows
+ rejected_rows

source_cells
=
migrated_cells
+ archived_cells
+ rebuilt_cells
+ target_owned_cells
+ deferred_out_of_scope_cells
+ intentional_ignore_cells
+ rejected_cells
```

`TRANSFORM`, `ID_MAP`, and `VALUE_MAP` are migrated subtypes, not additional dispositions that may double-count a row/cell. `SKIP_ABSENT_SOURCE` is table-contract evidence with snapshot-proven zero physical rows/fields and contributes zero to source row/cell denominators.

Final PASS requires:

```text
rejected_rows = 0
rejected_cells = 0
unaccounted_rows = 0
unaccounted_cells = 0
missing_expected_rows = 0
missing_expected_fields = 0
unexplained_skips = 0
duplicate_dispositions = 0
missing_deferred_evidence = 0
```

Persist accounting in the existing workflow execution/result/evidence structures and render it as the Step 4 plan's Migration Disposition Report. Do not introduce a standalone accounting/attempt artifact or table merely to satisfy this document. Every evidence row is bound to the immutable workflow identity, release, contract hash, snapshots, source identity, disposition, and verification rule.

---

# 14. Migration Archive Contract

`ARCHIVE` is an explicit preservation outcome, not data deletion.

Archive at minimum:

- source table;
- deterministic source primary/business identity and identity hash;
- exact source field/value or complete recoverable record payload;
- workflow name/version, mapping-release ID, and normalized contract hash;
- archive decision and reason;
- payload/value SHA-256;
- duplicate-prevention identity;
- accounting contribution;
- persisted timestamp;
- read-back query and hash-verification rule.

This is mandatory for source-only values such as removed operational fields and historical tables intentionally not activated in Joomla 6.

Step 3 stores and parses the complete physical `INSERT ... SELECT` contract without executing it. Step 4 executes that exact frozen producer and verifies inserted counts, duplicate identities, read-back, and hashes. Step 5 independently derives the expected archive identities from the frozen source snapshot, reads the persisted evidence back, and recalculates every hash. An archive label without recoverable evidence is `MISSING_EXPECTED`, not preservation.

---

# 15. Verification Contract

Verification has five mandatory levels.

## 15.1 Record verification

For each table decision:

```text
expected target/archived/ignored/rebuilt accounting
=
actual accounting
```

Required:

```text
Missing expected records = 0
Unexpected records       = 0
Duplicate mappings       = 0
Unaccounted records      = 0
```

## 15.2 Field verification

For every migrated field use the transformed expected value, not raw source equality.

NULL-safe comparison concept:

```sql
expected_value <=> target_value
```

Required:

```text
Field mismatches = 0
Silent truncation = 0
Invalid target values = 0
```

## 15.3 Relationship verification

Required orphan checks include at minimum:

```text
content → category
content → user
content → viewlevel
category/tag/menu → parent
field → field group
field value → field + context item
tag map → tag + item + content type
menu → parent + extension + viewlevel + template style
module assignment → module + menu
supporting component → user/category/viewlevel
workflow association → content + stage
```

Required:

```text
Broken required relationships = 0
Orphans not explicitly allowed = 0
```

## 15.4 Structured verification

Required:

```text
JSON/Registry parse failures     = 0
Unresolved embedded IDs         = 0
Invalid menu entity references  = 0
Invalid ACL group references    = 0
Invalid field-type values       = 0
```

## 15.5 Disposition and no-data-loss verification

Step 5 executes the eleven-block Post-Migration No-Data-Loss Tutorial defined by the canonical workflow. It independently recalculates source denominators, reconciles every source identity to exactly one disposition, verifies full migrated values/hashes rather than samples, validates runtime maps/FK rewrites, reads back archives, verifies deferred/ignored/absent-source evidence, checks rebuild target state, and prints all table/field exceptions.

Required:

```text
Disposition coverage                  = frozen source identities / frozen source identities
Missing expected tables/fields/rows   = 0
Unexplained skips                     = 0
Duplicate source dispositions         = 0
Archive read-back/hash failures       = 0
Missing deferred evidence             = 0
Post-migration tutorial blocks PASS   = 11 / 11
Repairs performed during validation   = 0
```

---

# 16. Production Schema Reconciliation

The official manifests are baselines; production is the execution authority.

Before migration:

```sql
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    ORDINAL_POSITION,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    CHARACTER_SET_NAME,
    COLLATION_NAME,
    COLUMN_TYPE,
    COLUMN_KEY,
    EXTRA,
    COLUMN_COMMENT,
    GENERATION_EXPRESSION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = :database_name
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

Classify every deviation as one of:

```text
OFFICIAL
CUSTOM_COLUMN
MODIFIED_DEFINITION
MISSING_FROM_PRODUCTION
EXTENSION_OWNED
CUSTOM_OWNED
UNKNOWN
```

`UNKNOWN = 0` is mandatory before execution.

Third-party/custom tables and columns are not silently folded into this core contract. They must be routed to their own extension/custom migration contract.

---

# 17. Re-run / Idempotency Contract

Migration tooling must be safely re-runnable.

Required rules:

1. Every run has a unique `migration_run_id`.
2. ID maps are deterministic and persisted.
3. A rerun must not create duplicate target entities.
4. Generated/rebuilt data is regenerated from the current migrated target state.
5. Upsert is allowed only where an explicit natural/stable identity exists.
6. A failed batch must be restartable from a known checkpoint.
7. Verification is rerun after every retry.

Gate:

```text
Duplicate target entities after rerun = 0
Conflicting ID maps                   = 0
Non-repeatable transforms             = 0
```

---

# 18. Failure / Recovery Contract

Before execution:

- immutable source DB backup exists;
- target pre-migration snapshot exists;
- migration writes are isolated from source;
- batch boundaries are documented;
- failed batches stop dependent batches;
- errors are persisted with source table/key/field/rule/error;
- no error is converted to `IGNORE` automatically.

Rollback is target restoration or deterministic batch rollback/rebuild, not mutation of the Joomla 3 source.

---

# 19. Checklist Coverage Matrix

This section proves that the **document definition** covers every item from the approved planning checklist.

## A. Baseline

- [x] Source fixed at Joomla 3.10.12
- [x] Target fixed at Joomla 6.1.2
- [x] V3 official table baseline = 78
- [x] V3 official field baseline = 711
- [x] V6 official table baseline = 76
- [x] V6 official field baseline = 832
- [x] Production reconciliation required before execution

## B. Table Mapping

- [x] 78/78 Joomla 3 source tables explicitly listed
- [x] Every source table has one final table decision
- [x] Target table/destination defined where applicable
- [x] Source-only/obsolete tables explicitly handled
- [x] Target-only Joomla 6 structures explicitly handled
- [x] No wildcard source table decisions
- [x] No final `REVIEW`
- [x] No unresolved `A / B` decision
- [x] No `UNKNOWN` allowed at execution gate

## C. Field Mapping

- [x] Authoritative 711-field universe identified
- [x] Deterministic field-decision precedence defined for all 711 source fields
- [x] DIRECT compatibility rule defined
- [x] TRANSFORM rule defined
- [x] LOOKUP rule defined
- [x] STRUCTURED rule defined
- [x] IGNORE reason requirement defined
- [x] ARCHIVE preservation requirement defined
- [x] GENERATED rule defined
- [x] REBUILD rule defined
- [x] Source-only field rule prevents silent drop
- [x] Target-only field resolution rule prevents missing required values

## D. Joomla 6 Target Coverage

- [x] Target-only tables classified
- [x] Target-only field resolution precedence defined
- [x] Required `NOT NULL` unresolved field is a hard error
- [x] Defaults are accepted only when DDL/application semantics permit them
- [x] Target-owned values identified
- [x] Generated/recreated values identified

## E. ID Mapping

- [x] Users
- [x] User groups
- [x] View levels
- [x] Categories
- [x] Articles/content
- [x] Tags
- [x] Field groups/fields
- [x] Menus/menu types
- [x] Modules
- [x] Extensions
- [x] Content types
- [x] Template styles
- [x] Supporting core entities
- [x] Missing ID mapping = hard error

## F. Structured Data

- [x] JSON
- [x] Joomla Registry/config payloads
- [x] Legacy/repeatable custom-field structured values
- [x] Embedded IDs
- [x] URLs/query strings
- [x] Menu links
- [x] Media/file references
- [x] HTML/internal-link review requirement
- [x] ACL JSON
- [x] Field-type-dependent values
- [x] Invalid structured values = hard error
- [x] Unresolved embedded IDs = hard error

## G. New Joomla 6 Structures

- [x] Workflow definitions
- [x] Workflow stages
- [x] Workflow transitions
- [x] Workflow associations
- [x] Schema.org target policy
- [x] MFA handling
- [x] WebAuthn handling
- [x] Scheduler handling
- [x] Mail-template target policy
- [x] Template-override target policy
- [x] Guided-tour target policy
- [x] Finder target/rebuild policy

## H. Record Accounting

- [x] Source row count required per table
- [x] MIGRATE/TRANSFORM accounting defined
- [x] REBUILD accounting defined
- [x] ARCHIVE accounting defined
- [x] IGNORE accounting defined
- [x] ERROR accounting defined
- [x] Source accounting invariant defined
- [x] Unaccounted rows must equal 0

## I. Verification

- [x] Record verification
- [x] Field verification
- [x] ID-map verification
- [x] Relationship/orphan verification
- [x] Structured-data verification
- [x] Nested-tree verification
- [x] Workflow verification
- [x] Missing = 0
- [x] Unexpected = 0
- [x] Duplicate = 0
- [x] Field mismatch = 0
- [x] Broken required relationships = 0

## J. Operational Safety

- [x] Dependency execution order
- [x] Production schema reconciliation
- [x] Extension/custom ownership separation
- [x] Re-run/idempotency contract
- [x] Failure persistence
- [x] Backup/restore requirement
- [x] No source mutation requirement

```text
Checklist items defined by contract = 100%
Checklist items omitted             = 0
DOCUMENT CHECKLIST COVERAGE         = PASS
```

> `DOCUMENT CHECKLIST COVERAGE = PASS` does not mean a production migration has already passed. Production-dependent checks must be materialized against the actual Joomla 3/Joomla 6 databases.

---

# 20. Final Production Migration Gate

The migration runner must refuse execution or final acceptance unless all applicable values below pass.

```text
SOURCE INVENTORY
----------------------------------------------
Official J3 tables accounted             = 78 / 78
Official J3 fields accounted             = 711 / 711
Actual source core tables inventoried    = 100%
Actual source core fields inventoried    = 100%
Unknown source core objects              = 0

TABLE CONTRACT
----------------------------------------------
Source table decisions                   = 78 / 78
Unmapped source tables                   = 0
Ambiguous table decisions                = 0

FIELD CONTRACT
----------------------------------------------
Source field decisions                   = 100%
Unmapped source fields                   = 0
Silent source-only drops                 = 0

TARGET RESOLUTION
----------------------------------------------
Actual target core tables inventoried    = 100%
Actual target core fields inventoried    = 100%
Required J6 fields resolved              = 100%
Unresolved required target fields        = 0

ID / VALUE / STRUCTURED
----------------------------------------------
Required ID mappings                     = 100%
Required value mappings                  = 100%
Structured-field rules applied           = 100%
Missing referenced IDs                   = 0
Unresolved embedded IDs                  = 0
Invalid structured payloads              = 0

DECISION QUALITY
----------------------------------------------
UNKNOWN                                  = 0
PENDING                                  = 0
REVIEW                                   = 0
UNMAPPED                                 = 0
AMBIGUOUS                                = 0

DATA ACCOUNTING
----------------------------------------------
Source records accounted                 = 100%
Unaccounted source records               = 0
Execution errors                         = 0

VERIFICATION
----------------------------------------------
Missing expected records                 = 0
Unexpected records                       = 0
Duplicate mappings                       = 0
Field mismatches                         = 0
Broken required relationships            = 0
Invalid trees                            = 0
Invalid workflow associations            = 0

OPERATIONAL
----------------------------------------------
Rerun duplicate creation                = 0
Conflicting ID mappings                  = 0
Backup/restore evidence                  = PASS

================================================
J3 → J6 CORE MIGRATION CONTRACT          = PASS
================================================
```

Only after this final gate passes may the migration be described as:

> **100% of Joomla 3 core database data in the declared migration scope was accounted for and verified according to the approved Joomla 3 → Joomla 6 migration contract.**

---

## DB-Only Scope Boundary

This contract covers Joomla **core database data**.

A complete site migration still requires separate verification for:

- `configuration.php`;
- images/media/files and file paths;
- Joomla/template/extension source code;
- third-party extension tables/data;
- custom tables/columns/code;
- template overrides and physical override files;
- external services/APIs;
- runtime plugin/module behavior;
- URLs/SEO behavior at HTTP level;
- caches/generated filesystem artifacts.

Those items must not be counted as proven by the core DB contract.
