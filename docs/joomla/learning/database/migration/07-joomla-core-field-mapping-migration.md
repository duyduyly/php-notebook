# Joomla Core Field Mapping — Joomla 3.10.12 → Joomla 6.1.2

> **Workflow authority:** This is a static field-decision reference. A new release cannot freeze from these rows alone; executable compilation, reporting, and PASS rules are governed by [`../migration-workflow.md`](../migration-workflow.md) and the 2026-08-14 overlay below.

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

## Canonical executable-contract overlay — 2026-08-14

This file is the static field-decision reference. [`../migration-workflow.md`](../migration-workflow.md) is authoritative for Step 3 materialization/compilation, Step 4 execution/reporting, and Step 5 independent no-data-loss validation. The 711/832/168/206 figures below remain reference-manifest observations; a new workflow uses the denominators derived from its frozen physical scope and may not claim PASS from these documentation counts.

Step 3 must expand each active included source-field decision into a complete executable contract bound to the actual DRAFT release and persisted mapping IDs. Every executable field defines the exact source/target fields and SQL expression, dependency, named runtime-map domain and persistence point where applicable, FK/reference rewrite, NULL/default/reset behavior, archive/defer/rebuild/target-owned disposition, row/cell accounting, and post-write verification. It must also bind every external Joomla rebuild to the validated reusable operator command, workflow/release/hash/target/domain inputs, expected effects, reset behavior, and continuation verifier.

The release remains DRAFT until all relevant gates are zero:

```text
GENERIC_COPY_TEMPLATES = 0
GENERIC_RUNTIME_MAP_TEMPLATES = 0
UNQUALIFIED_RUNTIME_MAP_TEMPLATES = 0
UNRESOLVED_CONTRACT_TABLE_MARKERS = 0
UNBOUND_PSEUDO_CALLS = 0
MISSING_FIELD_SQL_EXPRESSIONS = 0
MISSING_NAMED_MAP_LOOKUPS = 0
MISSING_FK_REWRITES = 0
MISSING_VALUE_MAP_IMPLEMENTATIONS = 0
MISSING_NEUTRAL_USER_IMPLEMENTATIONS = 0
MISSING_ARCHIVE_IMPLEMENTATIONS = 0
MISSING_NO_WRITE_ACCOUNTING = 0
MISSING_EXTERNAL_REBUILD_BINDINGS = 0
ARCHIVE_SQL_PLACEHOLDERS = 0
ARCHIVE_SQL_PARSE_ERRORS = 0
EXECUTABLE_ARCHIVE_PRODUCERS = REQUIRED / REQUIRED
ARCHIVE_CONTRACT_GAPS = 0
RUNTIME_COMPILATION_ERRORS = 0
AMBIGUOUS_WRITER_SEMANTICS = 0
```

Every archive mapping must persist a complete Step 4 `INSERT ... SELECT` contract with physical columns/expressions, deterministic source identity, workflow/release binding, reason, payload/value hash, duplicate prevention, accounting, read-back, and hash verification. Step 3 parses the exact persisted SQL without executing the archive write. Step 4 executes it and embeds the resulting disposition evidence in its plan. Step 5 independently reads it back and rehashes it.

`field_status = SKIP` in the legacy readiness vocabulary below means an explicitly justified no-active-copy physical-field state; it is not a workflow waiver. `field_status = MISSING` describes schema-side absence; it does not authorize missing migration evidence. At workflow accounting level, `MISSING_EXPECTED` and unexplained skips are blocking failures. Approved no-write outcomes must use the frozen `TARGET_OWNED`, `REBUILD`, `ARCHIVE`, `DEFERRED_OUT_OF_SCOPE`, `INTENTIONAL_IGNORE`, or snapshot-proven `SKIP_ABSENT_SOURCE` disposition and must appear in the Step 4 Migration Disposition Report and Step 5 Post-Migration No-Data-Loss Tutorial.

---



> **Source field accounting = 711/711 (100%)**  
> **Target physical inventory = 76/76 tables and 832/832 fields (100%)**  
> **Missing / ambiguous / silently dropped source fields = 0 required**  
> **Production execution is blocked until actual-schema reconciliation and materialized mapping QA pass**

This document is the Joomla Core specialization of [`templates/database-migration-field-mapping-template.md`](templates/database-migration-field-mapping-template.md). The canonical V3/V6 field inventories remain the physical DDL/type source of truth; this document remains the field-level migration-decision source of truth.

**Codes:** M=D direct, T transform, L lookup, S structured, G generated, Y derived, B rebuild, R reference-only, A archive, I ignore. X=lookup domain/parser/special rule: DT date/null, ASSET, TREE, PW password, 2FA, HID/HSN history, ML/MS menu, FI/FV fields, AI/AK associations, UCM, TAG, WF workflow, FT featured, FM Finder count, PT privacy. Row order is V3 ordinal. Target field is same-name in the mapped physical target table unless an explicit override below says otherwise.

Verification follows M+X: D schema-safe equality; T semantic conversion; L target exists/no orphan; S parse→remap→reparse; G deterministic; B integrity; R semantic identity; A archive count; I accounted reason. Same-name alone never permits D. IDs use `value_mapping`; sentinels and polymorphic context are resolved before lookup. Unknown/review/pending/optional/ambiguous/unmapped are forbidden.

---

# Template Conformance Contract

## Required inputs

| Artifact | Status |
|---|:---:|
| `01-joomla-core-migration-groups-v3.md` | REQUIRED |
| `03-joomla-core-migration-fields-v3.md` | REQUIRED |
| `02-joomla-core-migration-groups-v6.md` | REQUIRED |
| `04-joomla-core-migration-fields-v6.md` | REQUIRED |
| `06-joomla-core-table-mapping-migration.md` | REQUIRED |
| `05-joomla-core-j3-j6-migration-contract.md` | REQUIRED |

Hard prerequisite:

```text
Source table inventory             = 100%
Source field inventory             = 100%
Target table inventory             = 100%
Target field inventory             = 100%
Table mapping                      = PASS
Unknown schema objects             = 0
Unclassified schema deviations     = 0
```

## Field readiness status

`field_status` is **not** the migration action and must never be derived from `mapping_type` alone.

Allowed values are exactly:

| Field Status | Meaning |
|---|---|
| `READY` | Both physical sides exist and the final mapping/rebuild/reference rule plus verification are executable. |
| `SKIP` | Both physical sides exist, but the approved decision intentionally performs no active source→target field mapping/copy. Explicit reason is mandatory. |
| `MISSING` | Exactly one physical side is absent. The row still requires an explicit mapping/accounting decision and reason. |

Deterministic precedence:

```text
1. Exactly one physical side absent
   → MISSING

2. Both physical sides exist + approved decision intentionally performs no active mapping/copy
   → SKIP

3. Both physical sides exist + mapping/rebuild/reference rule and verification are final
   → READY

4. Anything else
   → CONTRACT ERROR
```

Important consequences:

```text
REBUILD does not automatically mean SKIP.
REFERENCE_ONLY does not automatically mean SKIP.
ARCHIVE does not automatically mean MISSING.
IGNORE does not automatically mean MISSING.
target_field = NULL must never be inferred only because the source decision is IGNORE/ARCHIVE/REFERENCE_ONLY.
physical target existence must come from the Joomla 6 field inventory.
```

For this Joomla Core contract:

```text
DIRECT / TRANSFORM / LOOKUP / STRUCTURED / GENERATED
+ both physical sides + executable rule
→ READY

REBUILD / REFERENCE_ONLY
+ both physical sides + executable reconciliation/rebuild rule
→ READY

ARCHIVE / IGNORE
+ both physical sides but active copy intentionally suppressed
→ SKIP

Any decision
+ exactly one physical side absent
→ MISSING
```

`mapping_type` remains the authoritative migration/accounting decision. `field_status` only describes physical/readiness state.

## Canonical mapping record

Materialization must expose at least:

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

Allowed `row_kind`:

```text
SOURCE_MAPPING
TARGET_RESOLUTION
```

Default cardinality for the compact rows below is `ONE_TO_ONE` unless an explicit grouped rule overrides it. Do not enforce uniqueness on only `(source_version, source_table, source_field)` when doing so would prevent a legitimate one-to-many/grouped mapping. Source coverage is counted by distinct source-field identity.

Known grouped rule:

```text
#__ucm_history.ucm_item_id
+ #__ucm_history.ucm_type_id
→ #__history.item_id
mapping_group_key = HISTORY_ITEM_ID
mapping_cardinality = MANY_TO_ONE
```

---

# Source rows — 711/711

## G0
### #__extensions
|Source|M|X|
|---|:-:|---|
|extension_id|R||
|package_id|R||
|name|R||
|type|R||
|element|R||
|folder|R||
|client_id|R||
|enabled|R||
|access|R||
|protected|R||
|manifest_cache|R||
|params|R||
|custom_data|R||
|system_data|A||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|ordering|R||
|state|R||
### #__schemas
|Source|M|X|
|---|:-:|---|
|extension_id|R||
|version_id|R||
### #__update_sites
|Source|M|X|
|---|:-:|---|
|update_site_id|R||
|name|R||
|type|R||
|location|R||
|enabled|R||
|last_check_timestamp|R||
|extra_query|R||
### #__update_sites_extensions
|Source|M|X|
|---|:-:|---|
|update_site_id|R||
|extension_id|R||
### #__updates
|Source|M|X|
|---|:-:|---|
|update_id|R||
|update_site_id|R||
|extension_id|R||
|name|R||
|description|R||
|element|R||
|type|R||
|folder|R||
|client_id|R||
|version|R||
|data|R||
|detailsurl|R||
|infourl|R||
|extra_query|R||
## G1
### #__languages
|Source|M|X|
|---|:-:|---|
|lang_id|L|LANGUAGE|
|asset_id|L|ASSET|
|lang_code|D||
|title|D||
|title_native|D||
|sef|D||
|image|S|MEDIA_PATH|
|description|D||
|metakey|D||
|metadesc|D||
|sitename|D||
|published|D||
|access|L|VIEWLEVEL|
|ordering|D||
### #__usergroups
|Source|M|X|
|---|:-:|---|
|id|L|USERGROUP|
|parent_id|L|USERGROUP|
|lft|G|TREE|
|rgt|G|TREE|
|title|D||
### #__users
|Source|M|X|
|---|:-:|---|
|id|L|USER|
|name|D||
|username|D||
|email|D||
|password|T|PW|
|block|D||
|sendEmail|D||
|registerDate|T|DT|
|lastvisitDate|T|DT|
|activation|D||
|params|S|JOOMLA_REGISTRY/JSON|
|lastResetTime|T|DT|
|resetCount|D||
|otpKey|T|2FA_RESET|
|otep|T|2FA_RESET|
|requireReset|D||
|authProvider|L|AUTH_PROVIDER_PLUGIN|
### #__user_usergroup_map
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|group_id|L|USERGROUP|
### #__viewlevels
|Source|M|X|
|---|:-:|---|
|id|L|VIEWLEVEL|
|title|D||
|ordering|D||
|rules|S|USERGROUP|
### #__user_profiles
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|profile_key|D||
|profile_value|S|KEY_DEPENDENT_VALUE|
|ordering|D||
## G2
### #__assets
|Source|M|X|
|---|:-:|---|
|id|B||
|parent_id|B||
|lft|B||
|rgt|B||
|level|B||
|name|B||
|title|B||
|rules|B||
### #__categories
|Source|M|X|
|---|:-:|---|
|id|L|CATEGORY|
|asset_id|L|ASSET|
|parent_id|L|CATEGORY|
|lft|G|TREE|
|rgt|G|TREE|
|level|G|TREE|
|path|G|TREE|
|extension|L|EXTENSION_ELEMENT|
|title|D||
|alias|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|published|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|access|L|VIEWLEVEL|
|params|S|JOOMLA_REGISTRY/JSON|
|metadesc|D||
|metakey|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|created_user_id|L|USER|
|created_time|T|DT|
|modified_user_id|L|USER|
|modified_time|T|DT|
|hits|D||
|language|L|LANGUAGE|
|version|D||
### #__tags
|Source|M|X|
|---|:-:|---|
|id|L|TAG|
|parent_id|L|TAG|
|lft|G|TREE|
|rgt|G|TREE|
|level|G|TREE|
|path|G|TREE|
|title|D||
|alias|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|published|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|access|L|VIEWLEVEL|
|params|S|JOOMLA_REGISTRY/JSON|
|metadesc|D||
|metakey|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|created_user_id|L|USER|
|created_time|T|DT|
|created_by_alias|D||
|modified_user_id|L|USER|
|modified_time|T|DT|
|images|S|MEDIA_URL_JSON|
|urls|S|MEDIA_URL_JSON|
|hits|D||
|language|L|LANGUAGE|
|version|D||
|publish_up|T|DT|
|publish_down|T|DT|
### #__content_types
|Source|M|X|
|---|:-:|---|
|type_id|R||
|type_title|R||
|type_alias|R||
|table|R||
|rules|R||
|field_mappings|R||
|router|R||
|content_history_options|R||
### #__fields_groups
|Source|M|X|
|---|:-:|---|
|id|L|FIELD_GROUP|
|asset_id|L|ASSET|
|context|L|CONTENT_CONTEXT|
|title|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|state|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|ordering|D||
|params|S|JOOMLA_REGISTRY/JSON|
|language|L|LANGUAGE|
|created|T|DT|
|created_by|L|USER|
|modified|T|DT|
|modified_by|L|USER|
|access|L|VIEWLEVEL|
### #__fields
|Source|M|X|
|---|:-:|---|
|id|L|FIELD|
|asset_id|L|ASSET|
|context|L|CONTENT_CONTEXT|
|group_id|L|FIELD_GROUP|
|title|D||
|name|D||
|label|D||
|default_value|S|FIELD_TYPE_VALUE|
|type|D||
|note|D||
|description|S|HTML_REFERENCE_SCAN|
|state|D||
|required|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|ordering|D||
|params|S|JOOMLA_REGISTRY/JSON|
|fieldparams|S|JOOMLA_REGISTRY/JSON|
|language|L|LANGUAGE|
|created_time|T|DT|
|created_user_id|L|USER|
|modified_time|T|DT|
|modified_by|L|USER|
|access|L|VIEWLEVEL|
### #__fields_categories
|Source|M|X|
|---|:-:|---|
|field_id|L|FIELD|
|category_id|L|CATEGORY|
## G3
### #__content
|Source|M|X|
|---|:-:|---|
|id|L|CONTENT|
|asset_id|L|ASSET|
|title|D||
|alias|D||
|introtext|S|HTML_REFERENCE_SCAN|
|fulltext|S|HTML_REFERENCE_SCAN|
|state|T|WF|
|catid|L|CATEGORY|
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|publish_up|T|DT|
|publish_down|T|DT|
|images|S|MEDIA_URL_JSON|
|urls|S|MEDIA_URL_JSON|
|attribs|S|JOOMLA_REGISTRY/JSON|
|version|D||
|ordering|D||
|metakey|D||
|metadesc|D||
|access|L|VIEWLEVEL|
|hits|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|featured|T|FT|
|language|L|LANGUAGE|
|xreference|A||
|note|D||
### #__content_frontpage
|Source|M|X|
|---|:-:|---|
|content_id|L|CONTENT|
|ordering|D||
### #__content_rating
|Source|M|X|
|---|:-:|---|
|content_id|L|CONTENT|
|rating_sum|D||
|rating_count|D||
|lastip|D||
## G4
### #__contentitem_tag_map
|Source|M|X|
|---|:-:|---|
|type_alias|L|CONTENT_TYPE_ALIAS|
|core_content_id|B|UCM|
|content_item_id|L|ENTITY_BY_TYPE_ALIAS|
|tag_id|L|TAG|
|tag_date|T|DT|
|type_id|L|CONTENT_TYPE|
### #__fields_values
|Source|M|X|
|---|:-:|---|
|field_id|L|FIELD|
|item_id|L|ENTITY_BY_FIELD_CONTEXT|
|value|S|FIELD_PLUGIN|
### #__associations
|Source|M|X|
|---|:-:|---|
|id|L|ENTITY_BY_ASSOCIATION_CONTEXT|
|context|L|CONTENT_CONTEXT|
|key|T|AK|
### #__ucm_base
|Source|M|X|
|---|:-:|---|
|ucm_id|B||
|ucm_item_id|B||
|ucm_type_id|B||
|ucm_language_id|B||
### #__ucm_content
|Source|M|X|
|---|:-:|---|
|core_content_id|B||
|core_type_alias|B||
|core_title|B||
|core_alias|B||
|core_body|B||
|core_state|B||
|core_checked_out_time|B||
|core_checked_out_user_id|B||
|core_access|B||
|core_params|B||
|core_featured|B||
|core_metadata|B||
|core_created_user_id|B||
|core_created_by_alias|B||
|core_created_time|B||
|core_modified_user_id|B||
|core_modified_time|B||
|core_language|B||
|core_publish_up|B||
|core_publish_down|B||
|core_content_item_id|B||
|asset_id|B||
|core_images|B||
|core_urls|B||
|core_hits|B||
|core_version|B||
|core_ordering|B||
|core_metakey|B||
|core_metadesc|B||
|core_catid|B||
|core_xreference|B||
|core_type_id|B||
### #__ucm_history
|Source|M|X|
|---|:-:|---|
|version_id|L|HISTORY_VERSION|
|ucm_item_id|T|HID|
|ucm_type_id|L|CONTENT_TYPE|
|version_note|D||
|save_date|T|DT|
|editor_user_id|L|USER|
|character_count|D||
|sha1_hash|T|HISTORY_HASH|
|version_data|S|HISTORY_SNAPSHOT|
|keep_forever|L|BOOLEAN_01|
## G5
### #__template_styles
|Source|M|X|
|---|:-:|---|
|id|L|TEMPLATE_STYLE|
|template|L|TEMPLATE_ELEMENT|
|client_id|D||
|home|D||
|title|D||
|inheritable|D||
|parent|D||
|params|S|JOOMLA_REGISTRY/JSON|
### #__menu_types
|Source|M|X|
|---|:-:|---|
|id|L|MENU_TYPE|
|asset_id|L|ASSET|
|menutype|D||
|title|D||
|description|D||
|client_id|D||
### #__menu
|Source|M|X|
|---|:-:|---|
|id|L|MENU|
|menutype|L|MENU_TYPE_KEY|
|title|D||
|alias|D||
|note|D||
|path|G|TREE|
|link|S|QUERY_STRING_WITH_IDS|
|type|D||
|published|D||
|parent_id|L|MENU|
|level|G|TREE|
|component_id|L|EXTENSION|
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|browserNav|D||
|access|L|VIEWLEVEL|
|img|S|MEDIA_PATH|
|template_style_id|L|TEMPLATE_STYLE|
|params|S|JOOMLA_REGISTRY/JSON|
|lft|G|TREE|
|rgt|G|TREE|
|home|D||
|language|L|LANGUAGE|
|client_id|D||
## G6
### #__modules
|Source|M|X|
|---|:-:|---|
|id|L|MODULE|
|asset_id|L|ASSET|
|title|D||
|note|D||
|content|S|HTML_REFERENCE_SCAN|
|ordering|D||
|position|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|publish_up|T|DT|
|publish_down|T|DT|
|published|D||
|module|L|EXTENSION_ELEMENT|
|access|L|VIEWLEVEL|
|showtitle|D||
|params|S|JOOMLA_REGISTRY/JSON|
|client_id|D||
|language|L|LANGUAGE|
### #__modules_menu
|Source|M|X|
|---|:-:|---|
|moduleid|L|MODULE|
|menuid|L|MENU_SENTINEL|
## G7
### #__contact_details
|Source|M|X|
|---|:-:|---|
|id|L|CONTACT|
|name|D||
|alias|D||
|con_position|D||
|address|D||
|suburb|D||
|state|D||
|country|D||
|postcode|D||
|telephone|D||
|fax|D||
|misc|S|HTML_REFERENCE_SCAN|
|image|S|MEDIA_PATH|
|email_to|D||
|default_con|D||
|published|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|ordering|D||
|params|S|JOOMLA_REGISTRY/JSON|
|user_id|L|USER|
|catid|L|CATEGORY|
|access|L|VIEWLEVEL|
|mobile|D||
|webpage|S|URL|
|sortname1|D||
|sortname2|D||
|sortname3|D||
|language|L|LANGUAGE|
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|metakey|D||
|metadesc|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|featured|D||
|xreference|A||
|publish_up|T|DT|
|publish_down|T|DT|
|version|D||
|hits|D||
### #__newsfeeds
|Source|M|X|
|---|:-:|---|
|catid|L|CATEGORY|
|id|L|NEWSFEED|
|name|D||
|alias|D||
|link|S|URL|
|published|D||
|numarticles|D||
|cache_time|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|ordering|D||
|rtl|D||
|access|L|VIEWLEVEL|
|language|L|LANGUAGE|
|params|S|JOOMLA_REGISTRY/JSON|
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|metakey|D||
|metadesc|D||
|metadata|S|JOOMLA_REGISTRY/JSON|
|xreference|A||
|publish_up|T|DT|
|publish_down|T|DT|
|description|S|HTML_REFERENCE_SCAN|
|version|D||
|hits|D||
|images|S|MEDIA_URL_JSON|
### #__banners
|Source|M|X|
|---|:-:|---|
|id|L|BANNER|
|cid|L|BANNER_CLIENT|
|type|D||
|name|D||
|alias|D||
|imptotal|D||
|impmade|D||
|clicks|D||
|clickurl|S|URL|
|state|D||
|catid|L|CATEGORY|
|description|S|HTML_REFERENCE_SCAN|
|custombannercode|S|HTML_REFERENCE_SCAN|
|sticky|D||
|ordering|D||
|metakey|D||
|params|S|JOOMLA_REGISTRY/JSON|
|own_prefix|D||
|metakey_prefix|D||
|purchase_type|D||
|track_clicks|D||
|track_impressions|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|publish_up|T|DT|
|publish_down|T|DT|
|reset|T|DT|
|created|T|DT|
|language|L|LANGUAGE|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|version|D||
### #__banner_clients
|Source|M|X|
|---|:-:|---|
|id|L|BANNER_CLIENT|
|name|D||
|contact|D||
|email|D||
|extrainfo|D||
|state|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|metakey|D||
|own_prefix|D||
|metakey_prefix|D||
|purchase_type|D||
|track_clicks|D||
|track_impressions|D||
### #__banner_tracks
|Source|M|X|
|---|:-:|---|
|track_date|A||
|track_type|A||
|banner_id|A||
|count|A||
### #__redirect_links
|Source|M|X|
|---|:-:|---|
|id|L|REDIRECT|
|old_url|S|URL|
|new_url|S|URL|
|referer|S|URL|
|comment|D||
|hits|D||
|published|D||
|created_date|T|DT|
|modified_date|T|DT|
|header|D||
### #__messages
|Source|M|X|
|---|:-:|---|
|message_id|L|MESSAGE|
|user_id_from|L|USER|
|user_id_to|L|USER|
|folder_id|D||
|date_time|T|DT|
|state|D||
|priority|D||
|subject|D||
|message|S|HTML_REFERENCE_SCAN|
### #__messages_cfg
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|cfg_name|D||
|cfg_value|S|KEY_DEPENDENT_VALUE|
### #__user_notes
|Source|M|X|
|---|:-:|---|
|id|L|USER_NOTE|
|user_id|L|USER|
|catid|L|CATEGORY|
|subject|D||
|body|S|HTML_REFERENCE_SCAN|
|state|D||
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|created_user_id|L|USER|
|created_time|T|DT|
|modified_user_id|L|USER|
|modified_time|T|DT|
|review_time|T|DT|
|publish_up|T|DT|
|publish_down|T|DT|
### #__privacy_requests
|Source|M|X|
|---|:-:|---|
|id|L|PRIVACY_REQUEST|
|email|D||
|requested_at|T|DT|
|status|D||
|request_type|D||
|confirm_token|T|PT|
|confirm_token_created_at|T|DT|
### #__privacy_consents
|Source|M|X|
|---|:-:|---|
|id|L|PRIVACY_CONSENT|
|user_id|L|USER|
|state|D||
|created|T|DT|
|subject|D||
|body|S|HTML_REFERENCE_SCAN|
|remind|D||
|token|T|PT|
### #__action_logs_extensions
|Source|M|X|
|---|:-:|---|
|id|R||
|extension|R||
### #__action_log_config
|Source|M|X|
|---|:-:|---|
|id|R||
|type_title|R||
|type_alias|R||
|id_holder|R||
|title_holder|R||
|table_name|R||
|text_prefix|R||
### #__action_logs_users
|Source|M|X|
|---|:-:|---|
|user_id|L|USER|
|notify|D||
|extensions|S|EXTENSION_LIST|
## G8
### #__session
|Source|M|X|
|---|:-:|---|
|session_id|I||
|client_id|I||
|guest|I||
|time|I||
|data|I||
|userid|I||
|username|I||
### #__user_keys
|Source|M|X|
|---|:-:|---|
|id|I||
|user_id|I||
|token|I||
|series|I||
|invalid|I||
|time|I||
|uastring|I||
### #__finder_filters
|Source|M|X|
|---|:-:|---|
|filter_id|L|FINDER_FILTER|
|title|D||
|alias|D||
|state|D||
|created|T|DT|
|created_by|L|USER|
|created_by_alias|D||
|modified|T|DT|
|modified_by|L|USER|
|checked_out|T|CHECKOUT_RESET|
|checked_out_time|T|CHECKOUT_RESET|
|map_count|G|FM|
|data|S|FINDER_FILTER_DATA|
|params|S|JOOMLA_REGISTRY/JSON|
### #__finder_links
|Source|M|X|
|---|:-:|---|
|link_id|B||
|url|B||
|route|B||
|title|B||
|description|B||
|indexdate|B||
|md5sum|B||
|published|B||
|state|B||
|access|B||
|language|B||
|publish_start_date|B||
|publish_end_date|B||
|start_date|B||
|end_date|B||
|list_price|B||
|sale_price|B||
|type_id|B||
|object|B||
### #__finder_links_terms0
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms1
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms2
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms3
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms4
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms5
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms6
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms7
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms8
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_terms9
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsa
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsb
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsc
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsd
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termse
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_links_termsf
|Source|M|X|
|---|:-:|---|
|link_id|B||
|term_id|B||
|weight|B||
### #__finder_taxonomy
|Source|M|X|
|---|:-:|---|
|id|B||
|parent_id|B||
|title|B||
|state|B||
|access|B||
|ordering|B||
### #__finder_taxonomy_map
|Source|M|X|
|---|:-:|---|
|link_id|B||
|node_id|B||
### #__finder_terms
|Source|M|X|
|---|:-:|---|
|term_id|B||
|term|B||
|stem|B||
|common|B||
|phrase|B||
|weight|B||
|soundex|B||
|links|B||
|language|B||
### #__finder_terms_common
|Source|M|X|
|---|:-:|---|
|term|D||
|language|L|LANGUAGE|
### #__finder_tokens
|Source|M|X|
|---|:-:|---|
|term|B||
|stem|B||
|common|B||
|phrase|B||
|weight|B||
|context|B||
|language|B||
### #__finder_tokens_aggregate
|Source|M|X|
|---|:-:|---|
|term_id|B||
|map_suffix|B||
|term|B||
|stem|B||
|common|B||
|phrase|B||
|term_weight|B||
|context|B||
|context_weight|B||
|total_weight|B||
|language|B||
### #__finder_types
|Source|M|X|
|---|:-:|---|
|id|B||
|title|B||
|mime|B||
### #__action_logs
|Source|M|X|
|---|:-:|---|
|id|A||
|message_language_key|A||
|message|A||
|log_date|A||
|extension|A||
|user_id|A||
|item_id|A||
|ip_address|A||
### #__core_log_searches
|Source|M|X|
|---|:-:|---|
|search_term|A||
|hits|A||
### #__overrider
|Source|M|X|
|---|:-:|---|
|id|L|LANGUAGE_OVERRIDE|
|constant|D||
|string|D||
|file|S|FILE_PATH|
### #__postinstall_messages
|Source|M|X|
|---|:-:|---|
|postinstall_message_id|B|POSTINSTALL|
|extension_id|B|POSTINSTALL|
|title_key|B|POSTINSTALL|
|description_key|B|POSTINSTALL|
|action_key|B|POSTINSTALL|
|language_extension|B|POSTINSTALL|
|language_client_id|B|POSTINSTALL|
|type|B|POSTINSTALL|
|action_file|B|POSTINSTALL|
|action|B|POSTINSTALL|
|condition_file|B|POSTINSTALL|
|condition_method|B|POSTINSTALL|
|version_introduced|B|POSTINSTALL|
|enabled|B|POSTINSTALL|
### #__utf8_conversion
|Source|M|X|
|---|:-:|---|
|converted|Y|UTF8_AUDIT|

---

# Physical Target Resolution and Field-Status Overrides

The target physical inventory is authoritative. The active table-level migration destination (`—`, migration archive, rebuild, target-owned) must **not** be confused with physical target-field existence.

## Corrected explicit overrides

| Source | Physical target counterpart | `field_status` | Final decision | Reason |
|---|---|---|---|---|
| `#__extensions.system_data` | — | `MISSING` | `ARCHIVE` | Source-only legacy extension state. |
| `#__users.otpKey` | `#__users.otpKey` | `READY` | `TRANSFORM` | Clear the active legacy secret, require target-side MFA re-enrollment, and retain only non-secret audit evidence. |
| `#__users.otep` | `#__users.otep` | `READY` | `TRANSFORM` | Clear legacy emergency codes, require target-side MFA re-enrollment, and retain only non-secret audit evidence. |
| `#__content.xreference` | — | `MISSING` | `ARCHIVE` | Source-only field. |
| `#__contact_details.xreference` | — | `MISSING` | `ARCHIVE` | Source-only field. |
| `#__newsfeeds.xreference` | — | `MISSING` | `ARCHIVE` | Source-only field. |
| `#__ucm_content.core_xreference` | — | `MISSING` | `REBUILD` | Source UCM derived state is rebuilt; this legacy physical field does not exist in the J6 target representation. |
| `#__finder_taxonomy.ordering` | — | `MISSING` | `REBUILD` | J6 Finder taxonomy no longer has this physical field; Finder is rebuilt. |
| `#__finder_tokens_aggregate.map_suffix` | — | `MISSING` | `REBUILD` | J6 aggregate token schema no longer has this field; Finder is rebuilt. |
| `#__user_keys.invalid` | — | `MISSING` | `IGNORE` | J6 `#__user_keys` no longer has the legacy `invalid` field and remember-me tokens are not migrated. |
| `#__core_log_searches.search_term` | — | `MISSING` | `ARCHIVE` | Legacy table is absent from J6 active schema; historical evidence is archived. |
| `#__core_log_searches.hits` | — | `MISSING` | `ARCHIVE` | Legacy table is absent from J6 active schema; historical evidence is archived. |
| `#__utf8_conversion.converted` | migration verification evidence | `READY` | `DERIVED` | Derive completion from successful Joomla 6 charset/collation verification; do not copy the marker. |

The previous shorthand `users.otpKey/otep → -` is invalid and must not be used by generators. Both fields physically exist in the declared Joomla 6.1.2 inventory.

## Same-name physical counterpart despite no active copy

When the J6 inventory contains the same physical field, materialization must retain the physical counterpart for readiness classification even when the migration action is `IGNORE` or `ARCHIVE`.

Examples:

```text
#__session.*
    physical target exists
    mapping_type = IGNORE
    field_status = SKIP

#__postinstall_messages.*
    physical target exists
    mapping_type = REBUILD
    field_status = READY after Joomla 6 manifest rebuild

#__user_keys.id/user_id/token/series/time/uastring
    physical target exists
    mapping_type = IGNORE
    field_status = SKIP

#__banner_tracks.*
    physical target exists
    mapping_type = ARCHIVE
    field_status = SKIP

#__action_logs.*
    physical target exists
    mapping_type = ARCHIVE
    field_status = SKIP
```

For `REBUILD` or `REFERENCE_ONLY`, a same-name physical counterpart plus a final executable rebuild/reconciliation rule is `READY`, not `SKIP`.

Examples:

```text
#__assets.*                 → READY + REBUILD
#__finder_links.*           → READY + REBUILD
#__finder_terms.*           → READY + REBUILD
#__extensions.extension_id → READY + REFERENCE_ONLY
#__content_types.type_alias → READY + REFERENCE_ONLY
```

---

# Target Anti-Join Contract

QA against `04-joomla-core-migration-fields-v6.md` must resolve 76/76 target tables and 832/832 target fields. Target-only fields must be materialized as `row_kind = TARGET_RESOLUTION`; do not invent fake source fields.

Target-only rows use:

```text
field_status = MISSING
mapping_type = DEFAULT / GENERATED / TARGET_OWNED / RECREATE / LOOKUP / REBUILD / explicit NOT_REQUIRED_BY_SCOPE equivalent
reason       = mandatory
verification_rule = mandatory
```

The generator must compute the target anti-join from the J6 field inventory after source mappings are materialized. A source mapping can never claim target coverage merely because the source side is 100%.

Known source-field target exceptions are the explicit override table above. `#__ucm_history.ucm_item_id` and `#__ucm_history.ucm_type_id` jointly resolve `#__history.item_id` through the history identity rule.

---

# Case / Seed Gate

Covers IDs via `value_mapping`; sentinel and polymorphic references; JSON/Registry/ACL/HTML/URL/query/media/path/field values; zero-date/null/default; trees; PK/composite/unique/collision/truncation/range/signedness/collation; session/user_keys/password/legacy 2FA; UCM/Finder rebuild; menus; custom fields; associations/tags; privacy; workflow generation. Raw string ID replacement and secret logging are forbidden.

Source-only explicit outcomes include at minimum: `extensions.system_data`, content/contact/newsfeeds `xreference` = `ARCHIVE`; `ucm_content.core_xreference`, `finder_taxonomy.ordering`, `finder_tokens_aggregate.map_suffix` = `REBUILD`; `user_keys.invalid` = `IGNORE`; `utf8_conversion.converted` = `DERIVED`; `core_log_searches.*` = `ARCHIVE`.

Seed `migration_mapping.field_mapping` deterministically from this contract and the two physical field inventories. Do **not** reduce mapping identity to only `(source_version, source_table, source_field)` if grouped/one-to-many mappings are present. Count source coverage by distinct source-field key.

Required gates:

```text
J3 source fields accounted                     = 711 / 711
J3 distinct source fields                      = 711 / 711
Missing source mappings                        = 0
Duplicate/conflicting source decisions         = 0
Invalid mapping type                           = 0
Invalid/null field_status                      = 0
READY with a missing physical side             = 0
MISSING with both physical sides present       = 0
MISSING with both physical sides absent        = 0
SKIP without explicit reason                   = 0
SKIP + DIRECT                                  = 0
DIRECT with missing target physical field      = 0
L missing domain/context                       = 0
S missing parser                               = 0
Silent source drops                            = 0
J6 target tables inventoried                   = 76 / 76
J6 target fields inventoried                   = 832 / 832
Target-only fields classified                  = 100%
Unresolved required target fields              = 0
Unsafe DIRECT/truncation/collision/dependency  = 0
```

Definition-level gate:

```text
FIELD MAPPING CONTRACT = PASS
```

Production PASS additionally requires actual-schema reconciliation, real mapping materialization, runtime `value_mapping`, row accounting, target-resolution materialization, and zero migration/verification errors.

---

# Materialization QA Queries

Column names may be adapted to the physical schema, but the logical checks are mandatory.

## 1. Source coverage

```sql
SELECT
    COUNT(DISTINCT CONCAT(source_table, '.', source_field)) AS covered_source_fields
FROM migration_mapping.field_mapping
WHERE row_kind = 'SOURCE_MAPPING'
  AND source_version = '3.10.12';
```

Expected: `711`.

## 2. Allowed field status

```sql
SELECT *
FROM migration_mapping.field_mapping
WHERE field_status IS NULL
   OR field_status NOT IN ('READY', 'SKIP', 'MISSING');
```

Expected: `0 rows`.

## 3. READY requires both physical sides

Use inventory joins, not `mapping_type`, as the physical-existence authority:

```sql
SELECT fm.*
FROM migration_mapping.field_mapping AS fm
LEFT JOIN migration_inventory.field_inventory AS sf
  ON sf.database_role = 'SOURCE'
 AND sf.table_name = fm.source_table
 AND sf.field_name = fm.source_field
LEFT JOIN migration_inventory.field_inventory AS tf
  ON tf.database_role = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.field_name = fm.target_field
WHERE fm.row_kind = 'SOURCE_MAPPING'
  AND fm.field_status = 'READY'
  AND (sf.field_name IS NULL OR tf.field_name IS NULL);
```

Expected: `0 rows`.

## 4. MISSING means exactly one physical side absent

```sql
SELECT fm.*
FROM migration_mapping.field_mapping AS fm
LEFT JOIN migration_inventory.field_inventory AS sf
  ON sf.database_role = 'SOURCE'
 AND sf.table_name = fm.source_table
 AND sf.field_name = fm.source_field
LEFT JOIN migration_inventory.field_inventory AS tf
  ON tf.database_role = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.field_name = fm.target_field
WHERE fm.field_status = 'MISSING'
  AND (
       (sf.field_name IS NULL AND tf.field_name IS NULL)
    OR (sf.field_name IS NOT NULL AND tf.field_name IS NOT NULL)
  );
```

Expected: `0 rows`.

## 5. SKIP must be intentional and documented

```sql
SELECT *
FROM migration_mapping.field_mapping
WHERE field_status = 'SKIP'
  AND NULLIF(TRIM(reason), '') IS NULL;
```

Expected: `0 rows`.

## 6. Impossible semantic combination: SKIP + DIRECT

```sql
SELECT *
FROM migration_mapping.field_mapping
WHERE field_status = 'SKIP'
  AND mapping_type = 'DIRECT';
```

Expected: `0 rows`.

## 7. DIRECT requires a physical target and final verification

```sql
SELECT fm.*
FROM migration_mapping.field_mapping AS fm
LEFT JOIN migration_inventory.field_inventory AS tf
  ON tf.database_role = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.field_name = fm.target_field
WHERE fm.mapping_type = 'DIRECT'
  AND (
      tf.field_name IS NULL
      OR NULLIF(TRIM(fm.verification_rule), '') IS NULL
  );
```

Expected: `0 rows`.

## 8. Canonical decision preservation

The generator must preserve the explicit `M` decision in this file. It must not infer another `mapping_type` from field name, table policy, or `field_status`.

Known hard assertions:

```text
#__extensions.system_data       = ARCHIVE
#__users.otpKey                 = TRANSFORM
#__users.otep                   = TRANSFORM
#__content.xreference           = ARCHIVE
#__contact_details.xreference   = ARCHIVE
#__newsfeeds.xreference         = ARCHIVE
#__ucm_content.core_xreference  = REBUILD
#__finder_taxonomy.ordering     = REBUILD
#__finder_tokens_aggregate.map_suffix = REBUILD
#__user_keys.invalid            = IGNORE
```

Any materialized mismatch is a `SCRIPT_CONTRACT_GAP` and blocks `MAPPING_VERIFY`.

---

# Schema Metadata Overlay — Data Type, Keys, and References

The 711 compact mapping rows remain the canonical migration-decision layer. Exact SQL metadata is not duplicated manually into those rows because the two canonical field inventories already preserve exact DDL for all J3/J6 fields. The migration database must join that metadata so every mapping row is queryable with migration semantics and physical schema facts.

## Required schema metadata per mapping row

| Metadata | Required | Source of truth |
|---|---|---|
| `source_data_type` | YES | J3 `information_schema.COLUMNS.DATA_TYPE` / V3 manifest |
| `source_column_type` | YES | J3 `COLUMN_TYPE` including length, precision and unsigned |
| `source_nullable` | YES | J3 `IS_NULLABLE` |
| `source_default` | YES | J3 `COLUMN_DEFAULT` |
| `source_key_role` | YES | J3 `information_schema.STATISTICS` |
| `target_data_type` | YES when target field exists | J6 `information_schema.COLUMNS.DATA_TYPE` / V6 manifest |
| `target_column_type` | YES when target field exists | J6 `COLUMN_TYPE` |
| `target_nullable` | YES when target field exists | J6 `IS_NULLABLE` |
| `target_default` | YES when target field exists | J6 `COLUMN_DEFAULT` |
| `target_key_role` | YES when target field exists | J6 `information_schema.STATISTICS` |
| `physical_fk_target` | YES if declared | `information_schema.KEY_COLUMN_USAGE` |
| `reference_type` | YES | mapping semantics + physical FK metadata |
| `reference_domain` | YES for reference mappings | `X` / migration contract |

### Canonical key roles

```text
PK
COMPOSITE_PK
UNIQUE
INDEX
NONE
```

A field can participate in more than one secondary index, but the mapping view records the strongest role using this precedence:

```text
COMPOSITE_PK / PK > UNIQUE > INDEX > NONE
```

`COMPOSITE_PK` means the field is one member of a multi-column primary key. Composite identity must be verified as a tuple after ID remapping.

### Canonical reference types

```text
PHYSICAL_FK
LOGICAL_FK
POLYMORPHIC
EMBEDDED_REFERENCE
SEMANTIC_REFERENCE
NONE
```

Do **not** reduce Joomla references to a boolean `FK = YES/NO`.

Rules:

- declared SQL `FOREIGN KEY (...) REFERENCES ...` → `PHYSICAL_FK`;
- numeric/string field referencing another Joomla identity without a declared SQL FK → `LOGICAL_FK`;
- identity resolved by `context`, `type_alias`, field type, extension, or another discriminator → `POLYMORPHIC`;
- IDs/references inside JSON, Registry, ACL, URL/query, HTML, media or other structured payload → `EMBEDDED_REFERENCE`;
- stable identity metadata such as extension/type/template identity → `SEMANTIC_REFERENCE`;
- no reference semantics → `NONE`.

The official J3/J6 baseline DDL contains relationship comments and indexes but no declared `FOREIGN KEY (...) REFERENCES ...` constraints. Therefore production physical FKs must still be discovered from `information_schema.KEY_COLUMN_USAGE`; logical/polymorphic/embedded references remain mandatory even when `physical_fk_target` is NULL.

## Reference classification from the mapping layer

Use these default classifications unless an explicit field rule overrides them:

| Mapping pattern | `reference_type` |
|---|---|
| `M=L`, fixed entity domain such as `USER`, `CATEGORY`, `TAG`, `MENU`, `MODULE`, `VIEWLEVEL`, `ASSET` | `LOGICAL_FK` |
| `M=L`, context-dependent domain such as `ENTITY_BY_TYPE_ALIAS`, `ENTITY_BY_FIELD_CONTEXT`, `ENTITY_BY_ASSOCIATION_CONTEXT` | `POLYMORPHIC` |
| `M=S` and payload can contain IDs/references | `EMBEDDED_REFERENCE` |
| `M=R` and source is used to resolve a target-owned semantic identity | `SEMANTIC_REFERENCE` |
| primary identity field mapped through `value_mapping` | `NONE` + its `reference_domain` identifies the entity |
| `M=D/T/G/B/A/I` with no reference semantics | `NONE` |

Examples:

| Source | Source type | S.Key | Target | Target type | T.Key | Field Status | Ref | M | Domain/rule |
|---|---|---|---|---|---|---|---|:-:|---|
| `#__content.id` | `int unsigned` | PK | `#__content.id` | `int unsigned` | PK | `READY` | `NONE` | L | `CONTENT` identity map |
| `#__content.catid` | `int unsigned` | INDEX | `#__content.catid` | `int unsigned` | INDEX | `READY` | `LOGICAL_FK` | L | `CATEGORY` |
| `#__content.images` | `text` | NONE | `#__content.images` | `text` | NONE | `READY` | `EMBEDDED_REFERENCE` | S | `MEDIA_URL_JSON` |
| `#__content.xreference` | `varchar(50)` | INDEX | — | — | — | `MISSING` | `NONE` | A | source-only archive |
| `#__users.otpKey` | `varchar(1000)` | NONE | `#__users.otpKey` | `varchar(1000)` | NONE | `READY` | `NONE` | T | clear active secret; require MFA re-enrollment |
| `#__fields_values.item_id` | `varchar(255)` | INDEX | `#__fields_values.item_id` | `varchar(255)` | INDEX | `READY` | `POLYMORPHIC` | L | `ENTITY_BY_FIELD_CONTEXT` |
| `#__menu.link` | `varchar(1024)` | NONE | `#__menu.link` | `varchar(1024)` | NONE | `READY` | `EMBEDDED_REFERENCE` | S | query-string IDs |
| `#__modules_menu.menuid` | `int` | COMPOSITE_PK | `#__modules_menu.menuid` | `int` | COMPOSITE_PK | `READY` | `LOGICAL_FK` | L | `0=all`, negative=exclude, positive=`MENU` |

---

# Physical Schema Inventory Queries

## 1. Data type / nullability / default

Run for both source and target databases:

```sql
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    ORDINAL_POSITION,
    DATA_TYPE,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    CHARACTER_SET_NAME,
    COLLATION_NAME,
    COLUMN_KEY,
    EXTRA
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = :database_name
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

`DATA_TYPE` alone is insufficient. `COLUMN_TYPE` is mandatory because it preserves details such as `unsigned`, length and precision.

## 2. Key-role inventory

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

Fields absent from `information_schema.STATISTICS` are classified as `NONE` by the final mapping query.

## 3. Declared physical-FK inventory

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

A NULL result here does **not** mean the field has no Joomla dependency. It only means no physical FK was declared.

---

# Enriched Field-Mapping SELECT Contract

`field_inventory` stores physical facts and `field_mapping` stores migration decisions. Query them together instead of manually duplicating DDL.

Expected logical result shape:

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

If `field_inventory` stores both source and target inventories, the core query is:

```sql
SELECT
    fm.source_table,
    fm.source_field,
    sf.data_type          AS source_data_type,
    sf.column_type        AS source_column_type,
    sf.is_nullable        AS source_nullable,
    sf.column_default     AS source_default,
    sf.key_role           AS source_key_role,
    sf.physical_fk_target AS source_physical_fk_target,

    fm.target_table,
    fm.target_field,
    tf.data_type          AS target_data_type,
    tf.column_type        AS target_column_type,
    tf.is_nullable        AS target_nullable,
    tf.column_default     AS target_default,
    tf.key_role           AS target_key_role,
    tf.physical_fk_target AS target_physical_fk_target,

    fm.field_status,
    fm.mapping_cardinality,
    fm.mapping_type,
    fm.identity_strategy,
    fm.reference_type,
    fm.reference_domain,
    fm.parser_rule,
    fm.transform_rule,
    fm.verification_rule,
    fm.rule_origin,
    fm.evidence,
    fm.reason
FROM migration_mapping.field_mapping AS fm
LEFT JOIN migration_inventory.field_inventory AS sf
  ON sf.database_role = 'SOURCE'
 AND sf.table_name = fm.source_table
 AND sf.field_name = fm.source_field
LEFT JOIN migration_inventory.field_inventory AS tf
  ON tf.database_role = 'TARGET'
 AND tf.table_name = fm.target_table
 AND tf.field_name = fm.target_field
ORDER BY fm.row_kind, fm.source_table, sf.ordinal_position, fm.target_table, fm.target_field;
```

If the physical `field_inventory` column names differ, adapt only aliases/join column names; preserve the logical contract.

---

# Schema Compatibility Checks Required Before `DIRECT`

A `D` mapping may execute only when all applicable checks pass:

```text
source / target semantic meaning compatible
source value fits target COLUMN_TYPE
signedness compatible
length / precision / scale safe
NULL source values valid for target
zero-date conversion resolved
source default is not incorrectly substituted for data
collation/case changes do not create identity collisions
PK/UNIQUE constraints do not collide after ID/value remapping
```

Any failure changes the field from `DIRECT` to an explicit `TRANSFORM`, `LOOKUP`, `ARCHIVE`, or blocks migration. Silent truncation and implicit coercion are forbidden.

---

# 100% Field Mapping Checklist

## A. Baseline and inventory

- [x] Scope = Joomla Core
- [x] Source = Joomla 3.10.12
- [x] Target = Joomla 6.1.2
- [x] Source table inventory = 100%
- [x] Source field inventory = 711/711
- [x] Target table inventory = 76/76
- [x] Target field inventory = 832/832
- [x] Table mapping document identified
- [ ] Actual production source/target schemas reconciled before production execution

## B. Source coverage

- [x] Every declared J3 physical field has an explicit decision
- [x] Distinct source field coverage = 711/711
- [x] Unmapped source fields = 0 at definition level
- [x] Silent source drops forbidden
- [x] Source-only outcome rule explicit
- [ ] Materialized DB source coverage = 711/711 verified against actual inventory

## C. Target resolution

- [x] Target physical inventory = 832/832
- [x] Target anti-join rule defined
- [x] `TARGET_RESOLUTION` row kind required
- [x] `MISSING` required for exactly-one-side-absent target/source rows
- [x] `otpKey/otep` physical target existence corrected
- [ ] All target-only rows materialized and verified in `migration_mapping.field_mapping`
- [ ] Unresolved required target fields = 0 proven in the actual mapping DB

## D. Mapping decision quality

- [x] Allowed final `M` decisions only
- [x] Explicit decision overrides preserved
- [x] `field_status` separated from `mapping_type`
- [x] `SKIP + DIRECT` forbidden
- [x] Source-only explicit outcomes enumerated
- [x] Mapping cardinality/group semantics defined
- [ ] Materialized mapping-type mismatch count = 0

## E. Field readiness

- [x] Allowed field status = READY / SKIP / MISSING only
- [x] READY requires both physical sides + executable rule
- [x] SKIP requires intentional no-active-copy + explicit reason
- [x] MISSING requires exactly one physical side absent
- [x] REBUILD is not automatically SKIP
- [x] REFERENCE_ONLY is not automatically SKIP
- [x] IGNORE/ARCHIVE do not imply physical target absence
- [ ] Invalid/null materialized field-status rows = 0

## F. Schema/type compatibility

- [x] Source/target raw and full types required
- [x] Length/precision/scale/signedness checks required
- [x] NULL/default rules required
- [x] Charset/collation checks required
- [x] Unsafe DIRECT forbidden
- [ ] Actual-data narrowing/truncation checks PASS

## G. Keys, identity, and references

- [x] PK/composite/unique/index roles defined
- [x] Runtime ID/value mapping stays in `value_mapping`
- [x] Logical/polymorphic/embedded/semantic references defined
- [x] Missing physical FK never suppresses logical dependency checking
- [ ] Actual production reference-domain/orphan checks PASS

## H. Structured and special values

- [x] Structured parser/remap/reparse contract retained
- [x] Raw string ID replacement forbidden
- [x] Legacy date/null/default/sentinel handling retained
- [x] Legacy 2FA values explicitly archived, not silently copied
- [ ] Actual structured payload validation PASS

## I. Database materialization

- [x] `field_inventory` remains physical schema source of truth
- [x] `field_mapping` remains static decision source of truth
- [x] `value_mapping` remains runtime/design-time translation store
- [x] `row_kind` requirement added
- [x] `mapping_cardinality` / `mapping_group_key` requirement added
- [x] One-column source uniqueness no longer treated as universally sufficient
- [ ] Materialized generator rerun/idempotency PASS

## J. Verification readiness

- [x] DIRECT verification rule defined
- [x] TRANSFORM verification rule defined
- [x] LOOKUP orphan/ambiguity verification defined
- [x] STRUCTURED parse/remap/reparse verification defined
- [x] GENERATED/REBUILD integrity verification defined
- [x] ARCHIVE accounting verification defined
- [x] IGNORE reason/accounting verification defined
- [x] Field-status hard-fail QA queries defined
- [ ] Materialized mapping QA returns zero failures

---

# Final Field Mapping Gate

Definition-level status after this document update:

```text
SOURCE COVERAGE
----------------------------------------------
J3 physical fields accounted          = 711 / 711
Unmapped source decisions             = 0
Silent source drops                   = 0

TARGET BASELINE
----------------------------------------------
J6 physical tables inventoried        = 76 / 76
J6 physical fields inventoried        = 832 / 832
Known otpKey/otep target-existence
metadata inconsistency                = CORRECTED

FIELD STATUS CONTRACT
----------------------------------------------
Allowed statuses                      = READY / SKIP / MISSING
Physical-existence precedence         = DEFINED
SKIP + DIRECT                         = FORBIDDEN
REBUILD auto-SKIP                     = FORBIDDEN
REFERENCE_ONLY auto-SKIP              = FORBIDDEN
mapping_type-driven target NULL       = FORBIDDEN

MATERIALIZATION / PRODUCTION
----------------------------------------------
Actual schema reconciliation          = REQUIRED
Materialized active source coverage   = active included / active included
Materialized target resolution        = REQUIRED
Invalid field status                  = MUST BE 0
Canonical-decision mismatches         = MUST BE 0

STEP 3 EXECUTABLE COMPILATION
----------------------------------------------
Generic/unqualified templates         = 0
Unbound pseudo-calls                  = 0
Missing exact field SQL               = 0
Missing named map/FK rewrites         = 0
Missing archive/no-write/rebuild bind = 0
Archive placeholders/parse errors     = 0
Executable archive producers          = required / required
Runtime compilation errors            = 0
Normalized executable hash recheck    = EQUAL

STEP 4 / STEP 5 PRODUCTION PROOF
----------------------------------------------
Persisted RUNTIME ID/value mappings   = required / required
Migration Disposition Report          = complete
Missing expected/unexplained skip     = 0
Archive/deferred evidence failures    = 0
Post-Migration No-Data-Loss Tutorial  = 11 / 11 PASS
Independent record/value verification = PASS
```

> **Definition-level field mapping coverage remains the 711/711 source and 832/832 target reference manifest. Production correctness must not be reported as 100% until the selected live scope is frozen, every active field is compiled into the executable Step 3 contract, Step 4 persists its runtime maps and complete disposition evidence, and Step 5 independently passes all no-data-loss gates.**
