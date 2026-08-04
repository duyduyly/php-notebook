# Joomla 3 to Joomla 6 Database Migration Checklist

A practical checklist for auditing, scripting, migrating, rebuilding, and validating all required content when moving a Joomla 3.10.x project to Joomla 6.

> **Recommended core upgrade path:** Joomla 3.10.x → Joomla 4.x → Joomla 5.4.x → Joomla 6.x.
>
> For a clean Joomla 6 rebuild, do not import the complete Joomla 3 database directly. Create the target schema using Joomla 6 and compatible extensions, then migrate selected business data through controlled scripts.

## Table of Contents

- [1. Migration principles](#1-migration-principles)
- [2. Migration project structure](#2-migration-project-structure)
- [3. Data scope](#3-data-scope)
- [4. Scripts to write](#4-scripts-to-write)
- [5. Required mapping tables](#5-required-mapping-tables)
- [6. Required behavior for every script](#6-required-behavior-for-every-script)
- [7. Recommended execution order](#7-recommended-execution-order)
- [8. Validation and acceptance](#8-validation-and-acceptance)
- [9. Report templates](#9-report-templates)
- [10. Final rules](#10-final-rules)

---

## 1. Migration principles

- [ ] Upgrade the source site to the latest Joomla 3.10.x release before migration.
- [ ] Create complete database, source-code, media, and configuration backups.
- [ ] Perform all cleanup and migration work on staging copies first.
- [ ] Prefer the official sequential upgrade path for Joomla core data when practical.
- [ ] Treat custom and third-party extension data as separate workstreams.
- [ ] Do not assume matching table names mean matching schemas.
- [ ] Do not copy Joomla 3 core extension registry rows into Joomla 6.
- [ ] Preserve business IDs when practical, especially user, category, article, and external integration IDs.
- [ ] Create explicit source-to-target ID mappings when IDs change.
- [ ] Rebuild generated structures such as Smart Search indexes instead of migrating them.
- [ ] Run at least two complete migration rehearsals before production cutover.
- [ ] Define rollback before executing production migration.

## 2. Migration project structure

```text
migration/
├── config/
│   ├── database.php
│   └── migration.php
├── sql/
│   ├── 00-backup/
│   ├── 01-audit/
│   ├── 02-cleanup/
│   ├── 03-staging/
│   ├── 04-mapping/
│   ├── 05-core-data/
│   ├── 06-relations/
│   ├── 07-extensions/
│   ├── 08-rebuild/
│   ├── 09-validation/
│   └── 10-rollback/
├── src/
│   ├── Command/
│   ├── Migrator/
│   ├── Mapper/
│   ├── Validator/
│   └── Logger/
├── reports/
│   ├── audit/
│   ├── exceptions/
│   └── reconciliation/
└── migrate.php
```

Recommended implementation:

- Use SQL for inventory, cleanup, bulk transforms, and reconciliation.
- Use PHP CLI for batch processing, JSON conversion, ID mapping, error handling, resume, and business rules.
- Use Joomla CLI or Joomla APIs for tree rebuilds, ACL repair, cache clearing, and Smart Search indexing where supported.

## 3. Data scope

### 3.1 Core content data to migrate

- [ ] `#__content`
- [ ] `#__categories`
- [ ] `#__content_frontpage`
- [ ] `#__content_rating` when ratings must be retained
- [ ] `#__tags`
- [ ] `#__contentitem_tag_map`
- [ ] `#__fields`
- [ ] `#__fields_groups`
- [ ] `#__fields_values`
- [ ] `#__associations` when multilingual associations are used
- [ ] Joomla 6 content workflow associations

### 3.2 Website structure data to migrate

- [ ] Frontend `#__menu_types`
- [ ] Frontend records from `#__menu`
- [ ] In-use frontend records from `#__modules`
- [ ] `#__modules_menu`
- [ ] Compatible template-style configuration
- [ ] URL redirects required to preserve legacy routes

### 3.3 User and ACL data to migrate

- [ ] `#__users`
- [ ] `#__usergroups`
- [ ] `#__user_usergroup_map`
- [ ] `#__viewlevels`
- [ ] Required `#__user_profiles`
- [ ] Content ownership references
- [ ] Custom and third-party user references
- [ ] Relevant ACL rules and rebuilt asset references

### 3.4 Custom and third-party business data

For every extension family:

- [ ] Identify owned tables.
- [ ] Identify primary keys and logical foreign keys.
- [ ] Identify user, article, category, menu, module, asset, and extension references.
- [ ] Identify JSON, serialized, encrypted, and file-path columns.
- [ ] Identify related files and media.
- [ ] Identify external IDs and API references.
- [ ] Confirm a Joomla 6-compatible extension or replacement exists.
- [ ] Install the target extension before importing business data.
- [ ] Follow vendor migration guidance where available.

### 3.5 Data not to copy directly

| Table or group | Action | Reason |
|---|---|---|
| `#__session` | Recreate | Existing sessions are invalid and unsafe |
| `#__extensions` | Reinstall extensions | Registry, IDs, manifests, and core records differ |
| `#__schemas` | Let installers create/update | Must reflect the actual installed schema |
| `#__updates` | Recreate | Generated update-discovery data |
| `#__update_sites` | Recreate during installation | URLs and mappings may change |
| `#__update_sites_extensions` | Recreate | Depends on new extension IDs |
| `#__finder_*` index data | Re-index | Generated search data |
| Cache tables | Recreate | Temporary data |
| Joomla 3 administrator menu | Keep Joomla 6 defaults | Administrator structure changed |
| Joomla 3 administrator modules | Keep Joomla 6 defaults | Dashboard and module types changed |
| Password reset tokens | Do not migrate | Security and compatibility risk |
| Remember-me/session keys | Do not migrate | Temporary authentication data |
| Post-install messages | Recreate | Version-specific data |
| Old action logs | Optional | Usually not required for operation |
| Privacy requests | Conditional | Migrate only when legally required |

## 4. Scripts to write

### Phase 0 — Backup and migration control

#### `00_backup_source_database.sh`

- [ ] Dump complete Joomla 3 database.
- [ ] Dump schema separately.
- [ ] Dump data separately.
- [ ] Include triggers, views, routines, and events when present.
- [ ] Record database version, charset, and collation.
- [ ] Generate backup checksum.
- [ ] Test restoring the backup.

#### `01_backup_target_database.sh`

- [ ] Snapshot the Joomla 6 database before every migration run.
- [ ] Store backups using a migration run ID and timestamp.
- [ ] Never overwrite previous snapshots.

#### `02_create_migration_run.sql`

- [ ] Create `migration_runs` tracking table.
- [ ] Store run UUID, source version, target version, start/end time, status, code commit, and error summary.
- [ ] Support statuses such as `running`, `failed`, `completed`, and `rolled_back`.

### Phase 1 — Source audit

#### `10_inventory_tables.sql`

- [ ] List every table.
- [ ] Record row count, size, engine, charset, and collation.
- [ ] Classify each table as `Core`, `Custom`, `Third-party`, `Temporary`, or `Unknown`.
- [ ] Record owner extension and migration decision.

#### `11_inventory_columns.sql`

- [ ] Export columns, data types, nullability, defaults, keys, and indexes.
- [ ] Identify columns containing logical references such as `user_id`, `created_by`, `catid`, `asset_id`, `menuid`, `extension_id`, `access`, and `language`.

#### `12_detect_zero_dates.sql`

- [ ] Scan core, custom, and vendor tables for zero dates.
- [ ] Produce an exception report by table and column.

#### `13_detect_invalid_json.sql`

- [ ] Validate known JSON fields such as `params`, `attribs`, `metadata`, `images`, `urls`, `rules`, `manifest_cache`, and `custom_data`.
- [ ] Do not assume every text configuration field uses JSON.

#### `14_detect_orphan_records.sql`

- [ ] Detect articles without categories.
- [ ] Detect content without authors, access levels, or assets.
- [ ] Detect categories, menus, tags, and user groups with missing parents.
- [ ] Detect broken module-menu assignments.
- [ ] Detect broken user-group mappings.
- [ ] Detect broken tag and custom-field mappings.
- [ ] Detect custom/third-party orphan records.

#### `15_detect_duplicate_aliases.sql`

- [ ] Check article aliases within category/language scope.
- [ ] Check category aliases within parent/extension scope.
- [ ] Check menu and tag aliases within parent/language scope.

#### `16_validate_nested_sets.sql`

Validate:

- [ ] `#__assets`
- [ ] `#__categories`
- [ ] `#__menu`
- [ ] `#__tags`
- [ ] `#__usergroups`
- [ ] `lft < rgt`
- [ ] No duplicated left/right boundaries.
- [ ] Parents exist.
- [ ] Levels and paths are consistent.
- [ ] No cycles exist.

#### `17_audit_content_embedded_plugins.php`

- [ ] Scan article and module HTML for content plugin syntax and shortcodes.
- [ ] Group tags by plugin or extension owner.
- [ ] Record whether a Joomla 6-compatible handler exists.
- [ ] Report content that may display raw or incomplete after migration.

#### `18_audit_media_references.php`

- [ ] Parse article HTML and JSON image fields.
- [ ] Parse module content and custom-field values.
- [ ] Extract local files, absolute URLs, CDN URLs, and extension upload paths.
- [ ] Check whether files physically exist.
- [ ] Produce a broken-media report.

### Phase 2 — Source cleanup on staging clone

#### `20_normalize_dates.sql`

- [ ] Convert optional zero dates to `NULL`.
- [ ] Set valid fallback values for required dates using documented rules.
- [ ] Record every changed row.

#### `21_normalize_encoding.php`

- [ ] Detect mixed encodings and mojibake.
- [ ] Normalize data to UTF-8/utf8mb4.
- [ ] Validate Vietnamese text, emoji, and four-byte characters.
- [ ] Prevent double conversion.

#### `22_repair_json.php`

- [ ] Repair known JSON errors when deterministic.
- [ ] Convert empty values to `{}` or `[]` only when semantically correct.
- [ ] Send uncertain records to an exception report instead of guessing.

#### `23_resolve_orphans.php`

- [ ] Map orphan records to approved targets.
- [ ] Use explicit fallback records when required.
- [ ] Do not silently delete records.
- [ ] Record reason, source ID, and resolution.

#### `24_normalize_aliases.php`

- [ ] Generate valid aliases when missing.
- [ ] Resolve duplicate aliases.
- [ ] Store old and new alias values.
- [ ] Feed changed aliases into redirect generation.

### Phase 3 — Staging and extraction

#### `30_create_staging_schema.sql`

Create staging tables for:

- [ ] Users and user groups.
- [ ] Access levels.
- [ ] Categories and articles.
- [ ] Tags and custom fields.
- [ ] Menus and modules.
- [ ] Custom and third-party extension data.

Each staging table should include:

- [ ] `source_id`
- [ ] `source_table`
- [ ] `migration_run_id`
- [ ] `migration_status`
- [ ] `migration_error`
- [ ] `target_id`
- [ ] `source_hash`
- [ ] `target_hash`

#### `31_extract_source_data.php`

- [ ] Extract by entity and batch.
- [ ] Avoid loading entire large tables into memory.
- [ ] Support `--dry-run`, `--entity`, `--batch-size`, `--limit`, and resume.
- [ ] Log rejected rows without stopping unrelated entities.

#### `32_generate_source_hashes.php`

- [ ] Generate hashes for important business fields.
- [ ] Canonicalize JSON before hashing.
- [ ] Document fields excluded from hash comparison.

### Phase 4 — ID and value mapping

#### `40_map_users.php`

- [ ] Prefer source ID preservation where safe.
- [ ] Fall back to matching by email and username.
- [ ] Detect duplicate accounts.
- [ ] Create `migration_user_map`.

#### `41_map_usergroups.php`

- [ ] Map Joomla core groups by logical identity, not raw ID.
- [ ] Create custom groups parent-first.
- [ ] Create `migration_usergroup_map`.

#### `42_map_viewlevels.php`

- [ ] Map access levels by title and rules.
- [ ] Remap group IDs inside access-level rules.
- [ ] Create `migration_viewlevel_map`.

#### `43_map_categories.php`

- [ ] Map by source ID or `extension + path`.
- [ ] Separate categories by owning component.
- [ ] Create `migration_category_map`.

#### `44_map_extensions.php`

Map using:

```text
type + element + folder + client_id
```

- [ ] Do not map using `extension_id` alone.
- [ ] Verify the target extension is installed.
- [ ] Create `migration_extension_map`.

#### `45_map_menu_items.php`

- [ ] Map menu type, parent, component, access, language, and template style.
- [ ] Create `migration_menu_map`.

#### `46_map_modules.php`

- [ ] Map module type and instance.
- [ ] Map template position, access level, language, and menu assignments.
- [ ] Create `migration_module_map`.

#### `47_map_template_styles.php`

- [ ] Map source template/style to compatible Joomla 6 template/style.
- [ ] Do not copy incompatible template parameters blindly.
- [ ] Create `migration_template_style_map`.

#### `48_map_tags_fields.php`

- [ ] Map tags parent-first.
- [ ] Map field groups, fields, contexts, categories, and plugin field types.
- [ ] Create tag, field-group, and field mapping tables.

### Phase 5 — Users and ACL

#### `50_migrate_users.php`

- [ ] Migrate account identity, status, dates, password hash, activation, and required parameters.
- [ ] Verify Joomla 3 password hashes are accepted or flag accounts for reset.
- [ ] Never log password hashes.
- [ ] Do not migrate sessions, remember-me keys, or temporary tokens.

#### `51_migrate_user_groups.php`

- [ ] Preserve hierarchy.
- [ ] Keep Joomla 6 core groups intact.
- [ ] Rebuild group nested-set values.

#### `52_migrate_user_group_map.php`

- [ ] Remap both user and group IDs.
- [ ] Avoid duplicates.
- [ ] Ensure every migrated user has an approved group.

#### `53_migrate_viewlevels.php`

- [ ] Remap group IDs inside JSON rules.
- [ ] Validate Public, Guest, Registered, and Special access behavior.

#### `54_migrate_user_profiles.php`

- [ ] Migrate only approved profile namespaces.
- [ ] Exclude obsolete plugin data.
- [ ] Review privacy and retention requirements.

#### `55_rebuild_acl_assets.php`

- [ ] Keep Joomla 6 core assets.
- [ ] Create/remap assets for migrated categories, articles, and custom components.
- [ ] Reassign `asset_id` values.
- [ ] Validate permission inheritance.

### Phase 6 — Core content

#### `60_migrate_categories.php`

- [ ] Import parent-first.
- [ ] Map component, parent, access, language, and creator.
- [ ] Transform parameters.
- [ ] Do not copy invalid nested-set boundaries.
- [ ] Record target IDs.

#### `61_migrate_content.php`

Migrate and validate:

- [ ] `id`
- [ ] `asset_id`
- [ ] `title`
- [ ] `alias`
- [ ] `introtext`
- [ ] `fulltext`
- [ ] `state`
- [ ] `catid`
- [ ] `created`, `created_by`, and `created_by_alias`
- [ ] `modified` and `modified_by`
- [ ] `publish_up` and `publish_down`
- [ ] `images`
- [ ] `urls`
- [ ] `attribs`
- [ ] `version`
- [ ] `ordering`
- [ ] `metakey`, `metadesc`, and `metadata`
- [ ] `access`
- [ ] `hits`
- [ ] `featured`
- [ ] `language`
- [ ] `note`

Script requirements:

- [ ] Validate category, author, access, and language mappings.
- [ ] Preserve article HTML without destructive sanitization.
- [ ] Validate JSON fields.
- [ ] Save source and target hashes.

#### `62_migrate_featured_content.php`

- [ ] Migrate `#__content_frontpage`.
- [ ] Remap article IDs.
- [ ] Preserve ordering and supported featured dates.
- [ ] Keep `#__content.featured` consistent.

#### `63_migrate_content_ratings.php`

- [ ] Run only when ratings must be retained.
- [ ] Map article IDs.
- [ ] Validate rating totals and counts.
- [ ] Review whether IP-related data should be retained.

#### `64_migrate_content_workflows.php`

- [ ] Detect Joomla 6 default workflow and stages.
- [ ] Map Joomla 3 published states to Joomla 6 workflow stages.
- [ ] Create workflow associations for every migrated article.
- [ ] Validate published, unpublished, archived, and trashed states.

### Phase 7 — Tags and custom fields

#### `70_migrate_tags.php`

- [ ] Import parent-first.
- [ ] Map access and language.
- [ ] Rebuild tag tree.

#### `71_migrate_content_tag_map.php`

- [ ] Map content and tag IDs.
- [ ] Map content type aliases.
- [ ] Prevent orphan and duplicate mappings.

#### `72_migrate_field_groups.php`

- [ ] Map context, access, language, category restrictions, and ordering.

#### `73_migrate_fields.php`

- [ ] Confirm each field type/plugin exists on Joomla 6.
- [ ] Map group, context, categories, access, and language.
- [ ] Transform `params` and `fieldparams`.

#### `74_migrate_field_values.php`

- [ ] Map field and item IDs.
- [ ] Preserve multi-value formats.
- [ ] Skip and report values whose field migration failed.

### Phase 8 — Languages and associations

#### `80_migrate_languages.php`

- [ ] Migrate content-language definitions without overwriting installed language packages.
- [ ] Validate language code, access, home/default settings, and installed package.

#### `81_migrate_associations.php`

- [ ] Remap associated item IDs.
- [ ] Preserve association groups by context.
- [ ] Prevent incomplete association groups when one item failed.

### Phase 9 — Menus and routing

#### `90_migrate_menu_types.php`

- [ ] Migrate frontend menu types only.
- [ ] Resolve duplicate menu type identifiers.
- [ ] Do not copy Joomla 3 administrator menu types.

#### `91_migrate_menu_items.php`

- [ ] Import parent-first.
- [ ] Map menu type, parent, component, access, language, and template style.
- [ ] Transform links and parameters.
- [ ] Preserve aliases and paths where practical.
- [ ] Verify every component target is installed.

#### `92_rewrite_menu_links.php`

- [ ] Remap article, category, and custom component IDs inside links.
- [ ] Replace renamed component/view/task values.
- [ ] Preserve external links.
- [ ] Report unsupported links.

#### `93_rebuild_menu_tree.php`

- [ ] Rebuild `lft`, `rgt`, `level`, and `path`.
- [ ] Validate one default homepage per required language.
- [ ] Detect cycles and broken parents.

#### `94_generate_redirects.php`

- [ ] Compare old and new URLs.
- [ ] Generate redirects for changed aliases, paths, menu IDs, and components.
- [ ] Prevent redirect chains and loops.

### Phase 10 — Modules

#### `100_migrate_modules.php`

- [ ] Migrate only approved frontend module instances.
- [ ] Confirm compatible module extension is installed.
- [ ] Map type, position, access, language, creator, state, ordering, and params.
- [ ] Preserve custom HTML.
- [ ] Do not copy Joomla 3 administrator modules.

#### `101_migrate_module_menu_assignments.php`

- [ ] Map module and menu IDs.
- [ ] Preserve include/exclude/all-pages semantics.
- [ ] Prevent orphan assignments.

#### `102_replace_module_positions.php`

- [ ] Inventory old and new template positions.
- [ ] Apply approved position mapping.
- [ ] Report modules without a target position.

### Phase 11 — Template and presentation

#### `110_migrate_template_styles.php`

- [ ] Install Joomla 6-compatible template first.
- [ ] Create target template styles.
- [ ] Transform only compatible parameters.
- [ ] Map menu assignments and default style.
- [ ] Do not overwrite Joomla 6 administrator template settings.

#### `111_audit_template_overrides.php`

- [ ] Inventory Joomla 3 template overrides.
- [ ] Compare each override with Joomla 6 layouts.
- [ ] Rewrite required overrides as source-code tasks.
- [ ] Test article, category, contact, menu, and module layouts.

### Phase 12 — Media and files

#### `120_copy_media_files.php`

- [ ] Copy `images/`, approved `media/` content, custom upload folders, and extension documents.
- [ ] Do not overwrite Joomla 6 core media.
- [ ] Preserve filename case and Unicode.
- [ ] Validate file checksums.

#### `121_rewrite_media_paths.php`

- [ ] Map old paths and domains to target paths.
- [ ] Handle absolute URLs, spaces, Unicode, and CDN URLs.
- [ ] Avoid rewriting external URLs accidentally.

#### `122_validate_media.php`

- [ ] Confirm every referenced local image and document exists.
- [ ] Detect case-sensitive mismatches.
- [ ] Validate MIME type where important.
- [ ] Produce a broken-media exception report.

### Phase 13 — Custom extensions

#### `130_install_custom_extension_schema.sql`

- [ ] Create Joomla 6-compatible install SQL.
- [ ] Create versioned update SQL.
- [ ] Use `#__` prefixes, InnoDB, and utf8mb4.
- [ ] Add required indexes and constraints.
- [ ] Do not reuse Joomla 3 schema blindly.

#### `131_transform_custom_extension_data.php`

- [ ] Map primary and foreign keys.
- [ ] Map users, categories, articles, menus, access levels, and assets.
- [ ] Convert statuses, dates, JSON, serialized values, and file paths.
- [ ] Populate new required columns.
- [ ] Drop deprecated columns only after validation.

#### `132_migrate_custom_extension_relations.php`

- [ ] Migrate parent-child and many-to-many relations.
- [ ] Migrate ownership, taxonomy, tags, fields, ACL, and workflow integration.
- [ ] Validate extension business rules.

### Phase 14 — Third-party extensions

#### `140_install_vendor_extensions.sh`

- [ ] Install Joomla 6-compatible packages.
- [ ] Let installers create registry and schema records.
- [ ] Run vendor update/migration tools.
- [ ] Confirm schema versions in `#__schemas`.

#### `141_export_vendor_data.php`

- [ ] Export business data only.
- [ ] Exclude cache, temporary, log, and index data unless required.
- [ ] Record source extension version and row counts.

#### `142_transform_vendor_data.php`

- [ ] Follow vendor-supported schema mapping.
- [ ] Map foreign keys and changed enum/status values.
- [ ] Report unsupported records instead of guessing.

#### `143_import_vendor_data.php`

- [ ] Import dependency-first and in batches.
- [ ] Support transactions, resume, idempotency, and dry-run.
- [ ] Validate the extension through functional tests after import.

### Phase 15 — Skip and rebuild generated data

#### `150_skip_rebuildable_tables.php`

- [ ] Maintain an explicit skip list and reason.
- [ ] Include sessions, updates, update sites, search indexes, caches, core admin records, and temporary logs.

#### `151_rebuild_search_index.php`

- [ ] Enable required Smart Search plugins.
- [ ] Clear target index.
- [ ] Re-index migrated content.
- [ ] Validate indexed counts and Vietnamese search behavior.

### Phase 16 — Rebuild and repair

#### `160_rebuild_categories.php`

- [ ] Rebuild category nested-set values, paths, and levels.

#### `161_rebuild_menu.php`

- [ ] Rebuild menu hierarchy and validate homepage routes.

#### `162_rebuild_tags.php`

- [ ] Rebuild tag hierarchy and validate item mappings.

#### `163_rebuild_usergroups.php`

- [ ] Rebuild user-group hierarchy and permission inheritance.

#### `164_rebuild_assets.php`

- [ ] Validate root, component, category, article, and custom extension assets.
- [ ] Detect duplicate asset names and broken parents.

#### `165_clear_runtime_data.sh`

- [ ] Clear Joomla cache, expired sessions, generated autoload cache, and temporary files.
- [ ] Do not delete migrated media.

### Phase 17 — Validation

#### `170_compare_row_counts.sql`

- [ ] Compare row counts by entity and state.
- [ ] Include articles, categories, users, tags, fields, menus, modules, and extension business records.

#### `171_compare_content_hashes.php`

- [ ] Compare canonical hashes for article title, body, metadata, and configuration.
- [ ] Report exact field differences.

#### `172_validate_relationships.sql`

Validate:

- [ ] Article-category
- [ ] Article-user
- [ ] Article-access
- [ ] Article-asset
- [ ] Content-tag
- [ ] Field-item
- [ ] Module-menu
- [ ] Menu-component
- [ ] User-group
- [ ] Multilingual associations
- [ ] Custom and vendor relationships

#### `173_validate_content_workflow.sql`

- [ ] Confirm every article has a valid workflow association.
- [ ] Confirm Joomla state and workflow stage are consistent.

#### `174_validate_urls.php`

- [ ] Crawl important Joomla 3 URLs.
- [ ] Crawl matching Joomla 6 URLs.
- [ ] Detect 404, redirect chains, loops, and multilingual route problems.

#### `175_validate_rendered_content.php`

- [ ] Confirm article HTML renders correctly.
- [ ] Confirm no unsupported shortcode appears as raw text.
- [ ] Confirm modules, fields, tags, images, menus, and layouts render correctly.

#### `176_validate_security.php`

- [ ] Test administrator and frontend login.
- [ ] Test password reset.
- [ ] Test ACL for each important role.
- [ ] Confirm sessions and temporary tokens were not imported.
- [ ] Confirm secrets and password hashes are absent from logs.

#### `177_generate_reconciliation_report.php`

Produce:

| Entity | Source | Migrated | Failed | Skipped | Match rate | Status |
|---|---:|---:|---:|---:|---:|---|
| Articles |  |  |  |  |  |  |
| Categories |  |  |  |  |  |  |
| Users |  |  |  |  |  |  |
| Menus |  |  |  |  |  |  |
| Modules |  |  |  |  |  |  |
| Custom data |  |  |  |  |  |  |
| Vendor data |  |  |  |  |  |  |

### Phase 18 — Rollback

#### `180_rollback_migration_run.php`

- [ ] Roll back by migration run ID.
- [ ] Delete child records before parent records.
- [ ] Never delete Joomla 6 core records.
- [ ] Support dry-run and rollback reporting.

#### `181_restore_target_database.sh`

- [ ] Restore the target snapshot.
- [ ] Verify backup checksum.
- [ ] Clear caches and verify Joomla boots.

#### `182_archive_mapping_tables.sql`

- [ ] Keep mappings until migration sign-off.
- [ ] Archive mappings and reconciliation reports for audit.
- [ ] Delete temporary staging data only after approval.

## 5. Required mapping tables

At minimum create:

- [ ] `migration_user_map`
- [ ] `migration_usergroup_map`
- [ ] `migration_viewlevel_map`
- [ ] `migration_category_map`
- [ ] `migration_content_map`
- [ ] `migration_tag_map`
- [ ] `migration_field_group_map`
- [ ] `migration_field_map`
- [ ] `migration_extension_map`
- [ ] `migration_menu_map`
- [ ] `migration_module_map`
- [ ] `migration_template_style_map`
- [ ] Custom and vendor entity mappings

Recommended columns:

```text
source_id
target_id
migration_run_id
match_strategy
source_key
target_key
status
error_message
created_at
```

Example dependency mapping:

| Source | Target | Transformation | Validation |
|---|---|---|---|
| `j3_content.id` | `j6_content.id` | Preserve or map | Unique and referenced |
| `j3_content.state` | Joomla 6 stage/state | Status mapping | Count by state |
| `j3_content.catid` | `j6_content.catid` | Category map | Category exists |
| `j3_menu.component_id` | `j6_menu.component_id` | Extension map | Component installed |
| `j3_modules.position` | Joomla 6 position | Position map | Correct frontend rendering |

## 6. Required behavior for every script

- [ ] Idempotent: rerunning must not create duplicates.
- [ ] Support `--dry-run`.
- [ ] Use transactions where practical.
- [ ] Process large tables in batches.
- [ ] Support checkpoint and resume.
- [ ] Use structured logging.
- [ ] Record migration run ID.
- [ ] Record source ID and target ID.
- [ ] Store failed records in an exception table/report.
- [ ] Never silently skip errors.
- [ ] Never hardcode the Joomla table prefix.
- [ ] Never assume core IDs match between Joomla 3 and Joomla 6.
- [ ] Never hardcode extension IDs, access IDs, group IDs, or template style IDs.
- [ ] Never log passwords, password hashes, API keys, or secrets.
- [ ] Validate dependencies before importing an entity.
- [ ] Produce row counts before and after execution.
- [ ] Return a non-zero exit code on unrecoverable failure.
- [ ] Provide a documented rollback action.

## 7. Recommended execution order

```text
1. Backup Joomla 3 source and Joomla 6 target
2. Create migration run
3. Inventory schema, tables, columns, and extension ownership
4. Audit invalid dates, JSON, aliases, nested sets, and orphan records
5. Audit embedded plugin tags and media references
6. Clean source data on staging clone
7. Create staging and mapping tables
8. Extract and hash source data
9. Install Joomla 6-compatible template and extensions
10. Map users, groups, access levels, extensions, categories, and styles
11. Migrate users, user groups, view levels, and profiles
12. Rebuild or remap ACL assets
13. Migrate categories
14. Migrate articles
15. Create Joomla 6 workflow associations
16. Migrate featured records and ratings
17. Migrate tags and custom fields
18. Migrate languages and associations
19. Migrate frontend menu types and menu items
20. Rewrite links and generate redirects
21. Migrate template styles
22. Migrate modules and module-menu assignments
23. Copy and rewrite media paths
24. Migrate custom extension data
25. Migrate third-party extension data
26. Rebuild category, menu, tag, user-group, and asset trees
27. Re-index Smart Search
28. Clear runtime cache and temporary data
29. Run row-count, hash, relation, URL, rendering, and security validation
30. Generate reconciliation report
31. Sign off or roll back
```

## 8. Validation and acceptance

### 8.1 Database reconciliation

- [ ] 100% of approved source articles have a target mapping.
- [ ] Published, unpublished, archived, and trashed article counts match expected results.
- [ ] Article title and body hashes match, excluding approved transformations.
- [ ] Category counts and hierarchy match.
- [ ] User and user-group mappings match.
- [ ] Tags and custom-field values match.
- [ ] Frontend menus and in-use modules match the approved inventory.
- [ ] Custom and vendor business row counts match expected values.
- [ ] No unexpected orphan records remain.
- [ ] No invalid required JSON or dates remain.

### 8.2 Functional validation

- [ ] Administrator and frontend login work.
- [ ] Password reset works.
- [ ] Each user role has correct permissions.
- [ ] Homepage and key landing pages render correctly.
- [ ] Menus generate expected URLs.
- [ ] Legacy URLs redirect correctly.
- [ ] Articles, categories, tags, and custom fields display correctly.
- [ ] Modules appear on correct pages.
- [ ] Multilingual switching and associations work.
- [ ] Search returns expected content.
- [ ] Forms, emails, scheduled tasks, APIs, and webhooks work.
- [ ] Custom and third-party extension workflows work.
- [ ] Media, images, and downloads are accessible.
- [ ] Logs contain no unresolved migration errors.

### 8.3 Security validation

- [ ] Old sessions and temporary tokens were not imported.
- [ ] Super User and obsolete accounts were reviewed.
- [ ] API login and extension permissions were reviewed.
- [ ] MFA/WebAuthn re-enrollment strategy was defined.
- [ ] Secrets were not committed or written to logs.
- [ ] Database and external-service credentials were rotated when required.

### 8.4 Acceptance target

Use this as a planning target, not an unconditional pre-audit guarantee:

- Core article text and metadata: target `99–100%`.
- Approved categories and relationships: target `100%`.
- Required users and ownership references: target `100%`.
- Approved menus, modules, fields, tags, and multilingual data: target `95–100%`.
- Custom and third-party business data: define an explicit target per extension family.
- Every exception must be documented and approved before production sign-off.

## 9. Report templates

### 9.1 Script tracker

| Script | Phase | Owner | Dependency | Dry run | Rollback | Status | Notes |
|---|---|---|---|---|---|---|---|
| `61_migrate_content.php` | Core content |  | Categories, users, access | Yes | Run-based |  |  |
| `64_migrate_content_workflows.php` | Workflow |  | Articles | Yes | Run-based |  |  |
| `171_compare_content_hashes.php` | Validation |  | Articles migrated | N/A | N/A |  |  |

### 9.2 Table inventory

| Table | Owner | Classification | In Use | Migrate | Method | Risk | Notes |
|---|---|---|---|---|---|---|---|
| `#__content` | Joomla Core | Content | Yes | Yes | Core upgrade or ETL | High | Preserve author/category references |
| `#__session` | Joomla Core | Temporary | Yes | No | Recreate | Low | Do not import sessions |
| `#__vendor_*` | Vendor | Third-party | TBD | Conditional | Vendor migration | High | Verify Joomla 6 support |
| `#__custom_*` | Internal | Custom | Yes | Yes | Custom scripts | High | Document schema and dependencies |

### 9.3 Reconciliation report

| Entity | Joomla 3 | Joomla 6 | Difference | Expected? | Status | Notes |
|---|---:|---:|---:|---|---|---|
| Published articles |  |  |  |  |  |  |
| Categories |  |  |  |  |  |  |
| Enabled users |  |  |  |  |  |  |
| Frontend menu items |  |  |  |  |  |  |
| In-use modules |  |  |  |  |  |  |
| Custom business records |  |  |  |  |  |  |

### 9.4 Migration decision summary

| Area | Decision | Reason | Owner | Status |
|---|---|---|---|---|
| Joomla core database | Sequential upgrade or controlled ETL | Use target schema and official migrations |  |  |
| Custom extensions | Rebuild schema and migrate business data | Joomla 3 code/schema may be incompatible |  |  |
| Third-party extensions | Install compatible release first | Vendor owns target schema |  |  |
| Smart Search | Re-index | Generated data |  |  |
| Sessions and tokens | Do not migrate | Security and compatibility risk |  |  |

## 10. Final rules

Database migration from Joomla 3 to Joomla 6 is not a full database copy. It is a controlled process:

```text
Inventory
→ audit
→ clean
→ prepare Joomla 6 schemas
→ extract and stage
→ map IDs
→ transform business data
→ migrate dependencies in order
→ rebuild generated structures
→ reconcile counts and hashes
→ run functional and security tests
→ sign off or roll back
```

The minimum script set required to preserve complete project content is:

```text
migrate_users.php
migrate_user_groups.php
migrate_user_group_map.php
migrate_viewlevels.php
migrate_categories.php
migrate_content.php
migrate_content_workflows.php
migrate_featured_content.php
migrate_tags.php
migrate_content_tag_map.php
migrate_field_groups.php
migrate_fields.php
migrate_field_values.php
migrate_languages.php
migrate_associations.php
migrate_menu_types.php
migrate_menu_items.php
migrate_modules.php
migrate_module_menu_assignments.php
migrate_template_styles.php
copy_media_files.php
rewrite_media_paths.php
migrate_custom_extension_data.php
migrate_vendor_extension_data.php
rebuild_assets.php
rebuild_nested_sets.php
validate_relationships.php
compare_content_hashes.php
generate_reconciliation_report.php
rollback_migration_run.php
```
