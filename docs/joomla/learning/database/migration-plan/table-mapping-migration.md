# Joomla Core Table Mapping — Joomla 3.10.12 → Joomla 6.1.2

## Purpose

> **Every Joomla 3 core source table must appear exactly once and resolve to one final table-level migration decision.**

This file materializes the table-level portion of [`joomla-core-j3-j6-migration-contract.md`](./joomla-core-j3-j6-migration-contract.md) into seed-ready mapping rows. It is derived from the four canonical manifests and intentionally does not duplicate their DDL or field lists:

- [`joomla-core-migration-groups-v3.md`](./joomla-core-migration-groups-v3.md)
- [`joomla-core-migration-fields-v3.md`](./joomla-core-migration-fields-v3.md)
- [`joomla-core-migration-groups-v6.md`](./joomla-core-migration-groups-v6.md)
- [`joomla-core-migration-fields-v6.md`](./joomla-core-migration-fields-v6.md)

```text
Joomla 3 source tables       = 78
Mapping rows                 = 78
Unique source tables         = 78
Missing source tables        = 0
Duplicate source tables      = 0
Ambiguous final decisions    = 0
Wildcard source entries      = 0
Definition-level coverage    = 100%
```

> Production execution still requires reconciliation against the actual Joomla 3 and Joomla 6 databases before the final migration gate can pass.

---

## Canonical Decisions

Allowed final `Mapping Type` values:

```text
DIRECT
TRANSFORM
LOOKUP
REBUILD
GENERATED
RECREATE
REFERENCE_ONLY
TARGET_OWNED
ARCHIVE
IGNORE
```

The final table mapping must contain none of:

```text
UNKNOWN
PENDING
REVIEW
OPTIONAL
SELECTIVE
AMBIGUOUS
UNMAPPED
A / B
```

## ID Strategies

| Strategy | Meaning |
|---|---|
| `ID_MAP` | Source ID may change; persist source → target value in `value_mapping`. |
| `SEMANTIC_LOOKUP` | Resolve the target by stable semantic identity; persist the resolved value when required. |
| `GENERATED` | Joomla 6 generates/rebuilds the target identity/state. |
| `NONE` | This table does not produce an entity ID map. |

`value_mapping` is the runtime/design-time value/ID mapping store. This document does not introduce a separate contract or ID-map table.

## Verification Codes

| Code | Required result |
|---|---|
| `V_REF` | Every required source semantic identity resolves to exactly one target identity; missing/ambiguous = 0. |
| `V_XFORM` | Source rows are accounted and expected transformed target rows exist; duplicates/errors = 0. |
| `V_REL` | Required mapped references resolve; forbidden orphan count = 0. |
| `V_STRUCT` | Structured values parse/remap/reparse; invalid payloads and unresolved embedded IDs = 0. |
| `V_TREE` | Parent/root/cycle/level/path/nested-set invariants pass. |
| `V_REBUILD` | Source rows are accounted as REBUILD and regenerated target structures pass integrity checks. |
| `V_HISTORY` | Every preserved history row resolves type/item/user identity or is explicitly archived; silent loss = 0. |
| `V_FINDER` | Source search-index rows are accounted as REBUILD and Joomla 6 index rebuild passes integrity checks. |
| `V_ARCHIVE` | Archived row count = source row count and archive evidence contains source identity/reason. |
| `V_IGNORE` | Ignored row count = source row count and the non-business/runtime/install-state reason is explicit. |

---

# Source Table Mapping — 78/78

## G0 — System Reference

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `#__extensions` | `#__extensions` | `REFERENCE_ONLY` | `SEMANTIC_LOOKUP` | `type + element + folder + client_id` | J6 extensions installed | `EXTENSION` | — | `G0-01` | `V_REF` | Target extension identities own numeric IDs. |
| 2 | `#__schemas` | `#__schemas` | `REFERENCE_ONLY` | `SEMANTIC_LOOKUP` | extension identity + version | `EXTENSION` | — | `EXTENSION` | `G0-02` | `V_REF` | Target installation schema state wins. |
| 3 | `#__update_sites` | `#__update_sites` | `REFERENCE_ONLY` | `SEMANTIC_LOOKUP` | type + location + extension context | `EXTENSION` | `UPDATE_SITE` | `EXTENSION` | `G0-03` | `V_REF` | Target update-site configuration owns active rows. |
| 4 | `#__update_sites_extensions` | `#__update_sites_extensions` | `REFERENCE_ONLY` | `NONE` | update-site + extension semantic pair | `UPDATE_SITE`, `EXTENSION` | — | `UPDATE_SITE`, `EXTENSION` | `G0-04` | `V_REF+V_REL` | Resolve both sides against target-owned identities. |
| 5 | `#__updates` | `#__updates` | `REFERENCE_ONLY` | `NONE` | update/cache identity | `UPDATE_SITE`, `EXTENSION` | — | `UPDATE_SITE`, `EXTENSION` | `G0-05` | `V_REF` | Transient update cache is refreshed by Joomla 6. |

## G1 — Users and Access Foundation

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 6 | `#__languages` | `#__languages` | `TRANSFORM` | `SEMANTIC_LOOKUP` | `lang_code` | `VIEWLEVEL`, asset strategy | `LANGUAGE` | `VIEWLEVEL`, `ASSET` | `G1-01` | `V_XFORM+V_REL` | Preserve language identity; remap access/asset references. |
| 7 | `#__usergroups` | `#__usergroups` | `TRANSFORM` | `ID_MAP` | source ID; parent/title only for collision review | — | `USERGROUP` | `USERGROUP` | `G1-02` | `V_XFORM+V_TREE` | Rebuild/validate group tree and persist ID mapping. |
| 8 | `#__users` | `#__users` | `TRANSFORM` | `ID_MAP` | source ID; username/email only for collision checks | — | `USER` | — | `G1-03` | `V_XFORM` | Preserve user data and compatible password hashes; normalize dates. |
| 9 | `#__user_usergroup_map` | `#__user_usergroup_map` | `TRANSFORM` | `NONE` | `user_id + group_id` | `USER`, `USERGROUP` | — | `USER`, `USERGROUP` | `G1-04` | `V_XFORM+V_REL` | Both IDs must be remapped. |
| 10 | `#__viewlevels` | `#__viewlevels` | `TRANSFORM` | `ID_MAP` | source ID; title only for collision review | `USERGROUP` | `VIEWLEVEL` | `USERGROUP` | `G1-05` | `V_XFORM+V_STRUCT+V_REL` | Remap group IDs embedded in rules JSON. |
| 11 | `#__user_profiles` | `#__user_profiles` | `TRANSFORM` | `NONE` | `user_id + profile_key` | `USER` | — | `USER` | `G1-06` | `V_XFORM+V_REL` | Remap user ID and validate key-dependent values. |

## G2 — Taxonomy and Shared Definitions

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 12 | `#__assets` | `#__assets` | `REBUILD` | `GENERATED` | asset name/entity identity | `USERGROUP`, migrated entities | `ASSET` | `USERGROUP`, entity maps | `G2-PHASED` | `V_REBUILD+V_TREE+V_REL` | ACL asset IDs/tree are generated/reconciled; final reconcile runs after dependent entities. |
| 13 | `#__categories` | `#__categories` | `TRANSFORM` | `ID_MAP` | source ID; extension + path/alias only for collision review | `USER`, `VIEWLEVEL`, `LANGUAGE`, asset strategy | `CATEGORY` | `USER`, `VIEWLEVEL`, `LANGUAGE`, `ASSET` | `G2-01` | `V_XFORM+V_TREE+V_REL+V_STRUCT` | Remap parent/user/access; rebuild tree/path; reconcile asset. |
| 14 | `#__tags` | `#__tags` | `TRANSFORM` | `ID_MAP` | source ID; path/alias only for collision review | `USER`, `VIEWLEVEL`, `LANGUAGE` | `TAG` | `USER`, `VIEWLEVEL`, `LANGUAGE` | `G2-02` | `V_XFORM+V_TREE+V_REL+V_STRUCT` | Remap hierarchy/users/access and structured media/config. |
| 15 | `#__content_types` | `#__content_types` | `REFERENCE_ONLY` | `SEMANTIC_LOOKUP` | `type_alias` | `EXTENSION` | `CONTENT_TYPE` | `EXTENSION` | `G2-03` | `V_REF` | Use Joomla 6 content-type definitions and stable type alias. |
| 16 | `#__fields_groups` | `#__fields_groups` | `TRANSFORM` | `ID_MAP` | source ID + context | `USER`, `VIEWLEVEL`, asset strategy | `FIELD_GROUP` | `USER`, `VIEWLEVEL`, `ASSET` | `G2-04` | `V_XFORM+V_REL+V_STRUCT` | Remap ACL/user/context and structured params. |
| 17 | `#__fields` | `#__fields` | `TRANSFORM` | `ID_MAP` | source ID + context + name | `FIELD_GROUP`, `USER`, `VIEWLEVEL`, asset strategy | `FIELD` | `FIELD_GROUP`, `USER`, `VIEWLEVEL`, `ASSET` | `G2-05` | `V_XFORM+V_REL+V_STRUCT` | Remap group/ACL/users/context and field configuration. |
| 18 | `#__fields_categories` | `#__fields_categories` | `TRANSFORM` | `NONE` | `field_id + category_id` | `FIELD`, `CATEGORY` | — | `FIELD`, `CATEGORY` | `G2-06` | `V_XFORM+V_REL` | Remap both relation IDs. |

## G3 — Main Content

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 19 | `#__content` | `#__content` | `TRANSFORM` | `ID_MAP` | source ID | `CATEGORY`, `USER`, `VIEWLEVEL`, `LANGUAGE`, asset strategy, target workflow definitions | `CONTENT` | `CATEGORY`, `USER`, `VIEWLEVEL`, `LANGUAGE`, `ASSET` | `G3-01` | `V_XFORM+V_REL+V_STRUCT` | Remap references; source-only `xreference` is archived; workflow association is generated later. |
| 20 | `#__content_frontpage` | `#__content_frontpage` | `TRANSFORM` | `NONE` | `content_id` | `CONTENT` | — | `CONTENT` | `G3-02` | `V_XFORM+V_REL` | Remap content ID and resolve target-only featured dates deterministically. |
| 21 | `#__content_rating` | `#__content_rating` | `TRANSFORM` | `NONE` | `content_id` | `CONTENT` | — | `CONTENT` | `G3-03` | `V_XFORM+V_REL` | Remap content ID while preserving rating aggregates. |

## G4 — Content Relations

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 22 | `#__contentitem_tag_map` | `#__contentitem_tag_map` | `TRANSFORM` | `NONE` | context + source item + tag | `CONTENT_TYPE`, `TAG`, entity maps | — | `CONTENT_TYPE`, `TAG`, entity maps | `G4-01` | `V_XFORM+V_REL` | Context-sensitive item/tag/content-type mapping. |
| 23 | `#__fields_values` | `#__fields_values` | `TRANSFORM` | `NONE` | field + item + value ordinal | `FIELD`, context entity maps | — | `FIELD`, entity maps | `G4-02` | `V_XFORM+V_REL+V_STRUCT` | Resolve field context and type-dependent values. |
| 24 | `#__associations` | `#__associations` | `TRANSFORM` | `NONE` | context + source item identity | context entity maps | — | entity maps | `G4-03` | `V_XFORM+V_REL` | Remap item IDs by context and recompute association identity when required. |
| 25 | `#__ucm_base` | `#__ucm_base` | `REBUILD` | `GENERATED` | content-type + migrated entity identity | `CONTENT_TYPE`, migrated entities | — | `CONTENT_TYPE`, entity maps | `G4-04` | `V_REBUILD+V_REL` | Derived UCM data is rebuilt/reconciled from target entities. |
| 26 | `#__ucm_content` | `#__ucm_content` | `REBUILD` | `GENERATED` | content-type + migrated entity identity | `CONTENT_TYPE`, migrated entities | — | `CONTENT_TYPE`, entity maps | `G4-05` | `V_REBUILD+V_REL` | Derived UCM content is rebuilt; source UCM IDs are not trusted. |
| 27 | `#__ucm_history` | `#__history` | `TRANSFORM` | `ID_MAP` | version + resolved type/item identity | `CONTENT_TYPE`, `USER`, entity maps | `HISTORY` | `CONTENT_TYPE`, `USER`, entity maps | `G4-06` | `V_HISTORY+V_REL+V_STRUCT` | Transform Joomla 3 UCM history into Joomla 6 history identity/state. |

## G5 — Menu and Presentation

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 28 | `#__template_styles` | `#__template_styles` | `TRANSFORM` | `SEMANTIC_LOOKUP` | target template identity + style purpose | `EXTENSION`, target template installed | `TEMPLATE_STYLE` | `EXTENSION` | `G5-01` | `V_XFORM+V_STRUCT` | Recreate/transform compatible style state; archive incompatible legacy-template payloads. |
| 29 | `#__menu_types` | `#__menu_types` | `TRANSFORM` | `SEMANTIC_LOOKUP` | `menutype` | asset strategy | `MENU_TYPE` | `ASSET` | `G5-02` | `V_XFORM+V_REL` | Preserve menu type identity and reconcile assets. |
| 30 | `#__menu` | `#__menu` | `TRANSFORM` | `ID_MAP` | source ID; menutype + path/alias only for collision review | `MENU_TYPE`, `EXTENSION`, `VIEWLEVEL`, `TEMPLATE_STYLE`, content/category maps | `MENU` | `MENU_TYPE`, `EXTENSION`, `VIEWLEVEL`, `TEMPLATE_STYLE`, `CONTENT`, `CATEGORY` | `G5-03` | `V_XFORM+V_TREE+V_REL+V_STRUCT` | Remap tree/component/access/style and embedded IDs in links/params. |

## G6 — Modules

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 31 | `#__modules` | `#__modules` | `TRANSFORM` | `ID_MAP` | source ID; module element/title/position only for collision review | `EXTENSION`, `VIEWLEVEL`, `LANGUAGE`, target module code installed, asset strategy | `MODULE` | `EXTENSION`, `VIEWLEVEL`, `LANGUAGE`, `ASSET` | `G6-01` | `V_XFORM+V_REL+V_STRUCT` | Only migrate instances whose Joomla 6 module code exists. |
| 32 | `#__modules_menu` | `#__modules_menu` | `TRANSFORM` | `NONE` | module + menu assignment | `MODULE`, `MENU` | — | `MODULE`, `MENU` | `G6-02` | `V_XFORM+V_REL` | Remap IDs while preserving `0=all` and negative exclusion semantics. |

## G7 — Supporting Core Components

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 33 | `#__contact_details` | `#__contact_details` | `TRANSFORM` | `ID_MAP` | source ID | `USER`, `CATEGORY`, `VIEWLEVEL`, `LANGUAGE`, asset strategy | `CONTACT` | `USER`, `CATEGORY`, `VIEWLEVEL`, `LANGUAGE`, `ASSET` | `G7-01` | `V_XFORM+V_REL+V_STRUCT` | Preserve contacts with remapped dependencies/config. |
| 34 | `#__newsfeeds` | `#__newsfeeds` | `TRANSFORM` | `ID_MAP` | source ID | `CATEGORY`, `USER`, `VIEWLEVEL`, `LANGUAGE` | `NEWSFEED` | `CATEGORY`, `USER`, `VIEWLEVEL`, `LANGUAGE` | `G7-02` | `V_XFORM+V_REL+V_STRUCT` | Preserve newsfeeds with remapped dependencies/config. |
| 35 | `#__banners` | `#__banners` | `TRANSFORM` | `ID_MAP` | source ID | `BANNER_CLIENT`, `CATEGORY`, `USER` | `BANNER` | `BANNER_CLIENT`, `CATEGORY`, `USER` | `G7-03` | `V_XFORM+V_REL+V_STRUCT` | Preserve banner business data and URLs/config. |
| 36 | `#__banner_clients` | `#__banner_clients` | `TRANSFORM` | `ID_MAP` | source ID | — | `BANNER_CLIENT` | — | `G7-04` | `V_XFORM` | Preserve client business records and produce client ID map. |
| 37 | `#__banner_tracks` | migration archive | `ARCHIVE` | `NONE` | source row business key | `BANNER` | — | `BANNER` | `G7-05` | `V_ARCHIVE` | Preserve historical tracking outside active Joomla 6 data. |
| 38 | `#__redirect_links` | `#__redirect_links` | `TRANSFORM` | `ID_MAP` | source ID; old URL only for collision review | — | `REDIRECT` | — | `G7-06` | `V_XFORM+V_STRUCT` | Preserve redirect intent; normalize URL/date semantics only when required. |
| 39 | `#__messages` | `#__messages` | `TRANSFORM` | `ID_MAP` | message ID | `USER` | `MESSAGE` | `USER` | `G7-07` | `V_XFORM+V_REL` | Remap sender and recipient users. |
| 40 | `#__messages_cfg` | `#__messages_cfg` | `TRANSFORM` | `NONE` | user + config name | `USER` | — | `USER` | `G7-08` | `V_XFORM+V_REL` | Remap user ID and preserve configuration values. |
| 41 | `#__user_notes` | `#__user_notes` | `TRANSFORM` | `ID_MAP` | source ID | `USER`, `CATEGORY`, `VIEWLEVEL`, asset strategy | `USER_NOTE` | `USER`, `CATEGORY`, `VIEWLEVEL`, `ASSET` | `G7-09` | `V_XFORM+V_REL` | Preserve notes with remapped dependencies. |
| 42 | `#__privacy_requests` | `#__privacy_requests` | `TRANSFORM` | `ID_MAP` | source ID | — | `PRIVACY_REQUEST` | — | `G7-10` | `V_XFORM` | Preserve compliance records and validate status/token/date semantics. |
| 43 | `#__privacy_consents` | `#__privacy_consents` | `TRANSFORM` | `ID_MAP` | source ID | `USER` | `PRIVACY_CONSENT` | `USER` | `G7-11` | `V_XFORM+V_REL+V_STRUCT` | Preserve consent evidence and remap user ID. |
| 44 | `#__action_logs_extensions` | `#__action_logs_extensions` | `REFERENCE_ONLY` | `SEMANTIC_LOOKUP` | extension string | `EXTENSION` | — | `EXTENSION` | `G7-12` | `V_REF` | Joomla 6 owns active action-log extension configuration. |
| 45 | `#__action_log_config` | `#__action_log_config` | `REFERENCE_ONLY` | `SEMANTIC_LOOKUP` | action/type configuration identity | `EXTENSION`, `CONTENT_TYPE` | — | `EXTENSION`, `CONTENT_TYPE` | `G7-13` | `V_REF` | Joomla 6 owns active action-log schema/configuration. |
| 46 | `#__action_logs_users` | `#__action_logs_users` | `TRANSFORM` | `NONE` | user ID | `USER`, `EXTENSION` | — | `USER`, `EXTENSION` | `G7-14` | `V_XFORM+V_REL+V_STRUCT` | Remap user and validate extension list. |

## G8 — Runtime, Generated, Historical, and Excluded

| # | Source | Target / Destination | Mapping Type | ID Strategy | Identity Key | Depends On | Produces | Consumes | Exec | Verify | Reason |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 47 | `#__session` | — | `IGNORE` | `NONE` | — | — | — | — | `G8-01` | `V_IGNORE` | Runtime sessions must not migrate. |
| 48 | `#__user_keys` | — | `IGNORE` | `NONE` | — | — | — | — | `G8-02` | `V_IGNORE` | Remember-me/authentication tokens must not migrate. |
| 49 | `#__finder_filters` | `#__finder_filters` | `TRANSFORM` | `ID_MAP` | source filter ID | `USER`, `VIEWLEVEL` | `FINDER_FILTER` | `USER`, `VIEWLEVEL` | `G8-03` | `V_XFORM+V_STRUCT+V_REL` | Preserve valid user-defined Smart Search filters. |
| 50 | `#__finder_links` | `#__finder_links` | `REBUILD` | `GENERATED` | — | migrated searchable content + finder plugins | — | entity maps | `G8-R01` | `V_FINDER` | Generated search index is rebuilt. |
| 51 | `#__finder_links_terms0` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R02` | `V_FINDER` | J3 partition 0 is accounted; J6 unified term links are rebuilt. |
| 52 | `#__finder_links_terms1` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R03` | `V_FINDER` | J3 partition 1 is accounted; J6 unified term links are rebuilt. |
| 53 | `#__finder_links_terms2` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R04` | `V_FINDER` | J3 partition 2 is accounted; J6 unified term links are rebuilt. |
| 54 | `#__finder_links_terms3` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R05` | `V_FINDER` | J3 partition 3 is accounted; J6 unified term links are rebuilt. |
| 55 | `#__finder_links_terms4` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R06` | `V_FINDER` | J3 partition 4 is accounted; J6 unified term links are rebuilt. |
| 56 | `#__finder_links_terms5` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R07` | `V_FINDER` | J3 partition 5 is accounted; J6 unified term links are rebuilt. |
| 57 | `#__finder_links_terms6` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R08` | `V_FINDER` | J3 partition 6 is accounted; J6 unified term links are rebuilt. |
| 58 | `#__finder_links_terms7` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R09` | `V_FINDER` | J3 partition 7 is accounted; J6 unified term links are rebuilt. |
| 59 | `#__finder_links_terms8` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R10` | `V_FINDER` | J3 partition 8 is accounted; J6 unified term links are rebuilt. |
| 60 | `#__finder_links_terms9` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R11` | `V_FINDER` | J3 partition 9 is accounted; J6 unified term links are rebuilt. |
| 61 | `#__finder_links_termsa` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R12` | `V_FINDER` | J3 partition a is accounted; J6 unified term links are rebuilt. |
| 62 | `#__finder_links_termsb` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R13` | `V_FINDER` | J3 partition b is accounted; J6 unified term links are rebuilt. |
| 63 | `#__finder_links_termsc` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R14` | `V_FINDER` | J3 partition c is accounted; J6 unified term links are rebuilt. |
| 64 | `#__finder_links_termsd` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R15` | `V_FINDER` | J3 partition d is accounted; J6 unified term links are rebuilt. |
| 65 | `#__finder_links_termse` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R16` | `V_FINDER` | J3 partition e is accounted; J6 unified term links are rebuilt. |
| 66 | `#__finder_links_termsf` | `#__finder_links_terms` | `REBUILD` | `GENERATED` | — | rebuilt finder links/terms | — | — | `G8-R17` | `V_FINDER` | J3 partition f is accounted; J6 unified term links are rebuilt. |
| 67 | `#__finder_taxonomy` | `#__finder_taxonomy` | `REBUILD` | `GENERATED` | — | migrated searchable content + finder plugins | — | — | `G8-R18` | `V_FINDER` | Generated finder taxonomy is rebuilt. |
| 68 | `#__finder_taxonomy_map` | `#__finder_taxonomy_map` | `REBUILD` | `GENERATED` | — | rebuilt finder links/taxonomy | — | — | `G8-R19` | `V_FINDER` | Generated finder taxonomy map is rebuilt. |
| 69 | `#__finder_terms` | `#__finder_terms` | `REBUILD` | `GENERATED` | — | migrated searchable content + finder plugins | — | — | `G8-R20` | `V_FINDER` | Generated finder terms are rebuilt. |
| 70 | `#__finder_terms_common` | `#__finder_terms_common` | `TRANSFORM` | `SEMANTIC_LOOKUP` | term + language | target common terms | — | `LANGUAGE` | `G8-04` | `V_XFORM` | Preserve source custom terms; built-in/common rows stay target-owned. |
| 71 | `#__finder_tokens` | `#__finder_tokens` | `REBUILD` | `GENERATED` | — | finder index job | — | — | `G8-R21` | `V_FINDER` | Transient search tokens are rebuilt. |
| 72 | `#__finder_tokens_aggregate` | `#__finder_tokens_aggregate` | `REBUILD` | `GENERATED` | — | finder index job | — | — | `G8-R22` | `V_FINDER` | Transient aggregate tokens are rebuilt. |
| 73 | `#__finder_types` | `#__finder_types` | `REBUILD` | `GENERATED` | — | Joomla 6 finder plugins/content | — | `EXTENSION` | `G8-R23` | `V_FINDER` | Finder type metadata is rebuilt. |
| 74 | `#__action_logs` | migration archive | `ARCHIVE` | `NONE` | source ID | `USER` + extension/action context | — | `USER` | `G8-A01` | `V_ARCHIVE` | Preserve historical audit evidence without activating legacy semantics. |
| 75 | `#__core_log_searches` | migration archive | `ARCHIVE` | `NONE` | search term | — | — | — | `G8-A02` | `V_ARCHIVE` | Obsolete historical search-log semantics are archived. |
| 76 | `#__overrider` | `#__overrider` | `TRANSFORM` | `ID_MAP` | source ID; constant + file identity only for collision review | target language/override context | `LANGUAGE_OVERRIDE` | — | `G8-05` | `V_XFORM+V_STRUCT` | Preserve intentional overrides only when target language/file identity is valid. |
| 77 | `#__postinstall_messages` | — | `IGNORE` | `NONE` | — | — | — | — | `G8-06` | `V_IGNORE` | Installation/version-specific messages are target-owned. |
| 78 | `#__utf8_conversion` | — | `IGNORE` | `NONE` | — | — | — | — | `G8-07` | `V_IGNORE` | Obsolete Joomla 3 UTF-8 conversion-state marker. |

---

# Target-Only / Target-Generated Joomla 6 Tables

These rows are **not** part of the 78 Joomla 3 source-row count. They are classified so target coverage is not left implicit.

| Group | Joomla 6 Target | Final Resolution | Rule |
|---|---|---|---|
| G0 | `#__tuf_metadata` | `TARGET_OWNED` | Fresh Joomla 6 secure-update metadata. |
| G2 | `#__workflows` | `TARGET_OWNED` | Use approved Joomla 6 workflow definitions. |
| G2 | `#__workflow_stages` | `TARGET_OWNED` | Use stages belonging to approved target workflows. |
| G2 | `#__workflow_transitions` | `TARGET_OWNED` | Use target workflow transitions. |
| G4 | `#__workflow_associations` | `GENERATED` | Generate after migrated content IDs and target stages are known. |
| G4 | `#__schemaorg` | `TARGET_OWNED` | No Joomla 3 core table maps directly; populate only via an explicit later application rule. |
| G5 | `#__template_overrides` | `RECREATE` | Recreate target-compatible override state; physical override files are outside this DB contract. |
| G7 | `#__mail_templates` | `TARGET_OWNED` | Keep Joomla 6 defaults unless a separate approved customization rule exists. |
| G7 | `#__scheduler_tasks` | `RECREATE` | Create only for installed Joomla 6 task plugins and approved schedules. |
| G8 | `#__user_mfa` | `RECREATE` | Users re-enrol MFA. |
| G8 | `#__webauthn_credentials` | `RECREATE` | Users re-enrol WebAuthn credentials. |
| G8 | `#__scheduler_logs` | `TARGET_OWNED` | Runtime/history generated by Joomla 6 scheduler. |
| G8 | `#__finder_logging` | `TARGET_OWNED` | Joomla 6 search logging; J3 `#__core_log_searches` remains archive data. |
| G8 | `#__guidedtours` | `TARGET_OWNED` | Joomla 6 target-owned guided-tour definitions. |
| G8 | `#__guidedtour_steps` | `TARGET_OWNED` | Joomla 6 target-owned guided-tour steps. |

Canonical workflow rule: definitions are `TARGET_OWNED`; only `#__workflow_associations` is `GENERATED` from migrated content and approved target stages. This removes the ambiguous `TARGET_OWNED / GENERATED` decision.

---

## Dependency and Map Rules

1. `Depends On` identifies data/state that must already be resolvable before execution.
2. `Produces` identifies source → target mapping domains that must be persisted in `value_mapping` when IDs/identities resolve.
3. `Consumes` identifies mapping domains required by a transform.
4. `asset strategy` means assets are generated/reconciled using the approved Joomla 6 ACL strategy; Joomla 3 numeric asset IDs are never assumed reusable.
5. `entity maps` means the exact context-specific map is resolved later by `field-mapping-migration.md`; polymorphic fields are not guessed here.
6. `#__assets` is a phased rebuild and receives a final reconciliation after dependent entities are migrated.

### Major Map Producers

| Mapping Domain | Producer |
|---|---|
| `EXTENSION` | `#__extensions` |
| `LANGUAGE` | `#__languages` |
| `USERGROUP` | `#__usergroups` |
| `USER` | `#__users` |
| `VIEWLEVEL` | `#__viewlevels` |
| `ASSET` | `#__assets` |
| `CATEGORY` | `#__categories` |
| `TAG` | `#__tags` |
| `CONTENT_TYPE` | `#__content_types` |
| `FIELD_GROUP` | `#__fields_groups` |
| `FIELD` | `#__fields` |
| `CONTENT` | `#__content` |
| `HISTORY` | `#__ucm_history` → `#__history` |
| `TEMPLATE_STYLE` | `#__template_styles` |
| `MENU_TYPE` | `#__menu_types` |
| `MENU` | `#__menu` |
| `MODULE` | `#__modules` |
| `CONTACT` | `#__contact_details` |
| `NEWSFEED` | `#__newsfeeds` |
| `BANNER_CLIENT` | `#__banner_clients` |
| `BANNER` | `#__banners` |

---

## Record Accounting Rule

Every production source row must end in exactly one accounting bucket compatible with the table decision:

```text
source_rows
= transformed/migrated_rows
+ rebuilt_source_rows
+ reference_only_rows
+ archived_rows
+ ignored_rows
+ error_rows
```

Final production PASS requires:

```text
error_rows       = 0
unaccounted_rows = 0
```

`REBUILD`, `REFERENCE_ONLY`, `ARCHIVE`, and `IGNORE` are valid explicit accounting outcomes; they are not silent data loss.

---

# Database Seed Contract

This Markdown table is designed to seed `migration_mapping.table_mapping`. Adapt column names to the physical schema while preserving these semantics:

```text
source_version      = 3.10.12
source_group        = group section
source_table        = Source
target_version      = 6.1.2
target_table        = Target / Destination
mapping_type        = Mapping Type
id_strategy         = ID Strategy
identity_key        = Identity Key
execution_order     = Exec
verification_rule   = Verify
reason              = Reason
```

Dependencies should continue to use the existing dependency/inventory structure rather than creating a second source of truth. Runtime ID/value pairs belong in `value_mapping`.

Recommended unique key:

```text
(source_version, source_table)
```

Seed QA:

```sql
SELECT
    COUNT(*) AS mapping_rows,
    COUNT(DISTINCT source_table) AS unique_source_tables
FROM migration_mapping.table_mapping
WHERE source_version = '3.10.12';
```

Expected:

```text
mapping_rows         = 78
unique_source_tables = 78
```

---

# 100% Mapping Checklist

## Source Coverage

- [x] Joomla 3 official baseline = 78 tables
- [x] 78/78 source tables explicitly listed
- [x] Every source table occurs exactly once
- [x] Wildcard source entries = 0
- [x] Missing source tables = 0
- [x] Duplicate source tables = 0

## Target Resolution

- [x] Every non-ignored source table has an explicit target/destination
- [x] Same-name tables still have an explicit semantic decision
- [x] Renamed/restructured tables are explicit (`#__ucm_history` → `#__history`)
- [x] Many-to-one Finder mapping is explicit and uses `REBUILD`
- [x] Removed/runtime tables are explicitly `ARCHIVE` or `IGNORE`
- [x] Target-only Joomla 6 tables are classified

## Decision Quality

- [x] Exactly one final decision per source table
- [x] `UNKNOWN = 0`
- [x] `REVIEW = 0`
- [x] `PENDING = 0`
- [x] `OPTIONAL = 0`
- [x] `AMBIGUOUS = 0`
- [x] Slash decisions `A / B = 0`

## ID Strategy

- [x] Every source table has an ID strategy
- [x] Numeric ID equality is never assumed by default
- [x] ID-map producers are identified
- [x] Map consumers are identified
- [x] Stable semantic identities are documented where used
- [x] Runtime source → target IDs are assigned to `value_mapping`

## Dependencies

- [x] Every source table row has dependency information
- [x] Core mapping dependencies are named
- [x] Polymorphic dependencies are explicitly deferred to field mapping instead of guessed
- [x] Asset rebuild is marked phased
- [x] G0 → G8 execution order remains derivable

## Record Accounting

- [x] Every source table has an explicit record strategy through its mapping type
- [x] `TRANSFORM`, `REBUILD`, `REFERENCE_ONLY`, `ARCHIVE`, and `IGNORE` are accounted outcomes
- [x] Silent source-row drop is prohibited
- [x] `unaccounted_rows = 0` is required for production PASS

## Verification

- [x] Every source mapping row has at least one verification code
- [x] Reference-only verification is defined
- [x] Transform verification is defined
- [x] Rebuild verification is defined
- [x] Archive verification is defined
- [x] Ignore verification is defined
- [x] Tree/relationship/structured special verification is assigned where applicable

## Database Seed Readiness

- [x] Canonical enum values are standardized
- [x] Source unique key is defined
- [x] 78 seed-ready source rows are present
- [x] `value_mapping` is the ID/value store
- [x] No additional contract table is required
- [x] Seed QA query and expected result are documented

---

# Final QA Gate

```text
SOURCE
--------------------------------------
Official J3 tables              = 78
Mapping rows                    = 78
Unique source tables            = 78
Missing                        = 0
Duplicate                      = 0
Wildcard                       = 0

TARGET
--------------------------------------
Non-ignored destinations        = 100% resolved
Target-only J6 tables           = 100% classified

DECISIONS
--------------------------------------
Final source decisions          = 78 / 78
Unknown                        = 0
Review                         = 0
Pending                        = 0
Optional                       = 0
Ambiguous                      = 0
Slash decisions                = 0

ID / DEPENDENCY
--------------------------------------
ID strategies                  = 78 / 78
Dependency information         = 78 / 78
Map producers/consumers        = explicitly classified

ACCOUNTING / VERIFICATION
--------------------------------------
Record strategies              = 78 / 78
Verification strategies        = 78 / 78
Unverifiable mappings          = 0

DATABASE SEED
--------------------------------------
Seed-ready source rows          = 78 / 78
Unique DB source keys           = 78 / 78

======================================
TABLE MAPPING CONTRACT          = PASS
======================================
```

> This is a **definition-level PASS** against the official Joomla 3.10.12 / Joomla 6.1.2 baselines. Production PASS still requires actual-schema reconciliation, runtime `value_mapping`, record accounting, and zero verification errors.
