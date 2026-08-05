# Joomla 3 to Joomla 6 Full Data Migration Plan

A practical, implementation-focused plan for migrating required business data from Joomla 3.10.x to a fresh Joomla 6 installation.

> **Recommended approach:** use a hybrid migration model:
>
> - **MySQL scripts** for inventory, schema comparison, staging, bulk extraction, and reconciliation.
> - **PHP CLI scripts** for transformation, ID mapping, batching, logging, resume support, and business rules.
> - **Joomla APIs or CLI commands** for entity-aware saves, ACL assets, nested-set rebuilds, workflows, cache clearing, and search indexing.
> - **Joomla extension SQL update files** only for target extension schema management, not as the main cross-database migration engine.

---

## Table of Contents

- [1. Migration Objective](#1-migration-objective)
- [2. Recommended Migration Architecture](#2-recommended-migration-architecture)
- [3. Why a Hybrid Approach Is Required](#3-why-a-hybrid-approach-is-required)
- [4. Phase 1 — Audit and Scope Definition](#4-phase-1--audit-and-scope-definition)
- [5. Phase 2 — Prepare Joomla 6 and Target Extensions](#5-phase-2--prepare-joomla-6-and-target-extensions)
- [6. Phase 3 — Build Staging, Cleanup, and Mapping](#6-phase-3--build-staging-cleanup-and-mapping)
- [7. Phase 4 — Migrate Joomla Core Data](#7-phase-4--migrate-joomla-core-data)
- [8. Phase 5 — Migrate Custom, Third-Party, and Media Data](#8-phase-5--migrate-custom-third-party-and-media-data)
- [9. Phase 6 — Rebuild, Validate, Rehearse, and Cut Over](#9-phase-6--rebuild-validate-rehearse-and-cut-over)
- [10. Recommended Tool by Task](#10-recommended-tool-by-task)
- [11. Recommended Project Structure](#11-recommended-project-structure)
- [12. Migration Script Requirements](#12-migration-script-requirements)
- [13. Recommended Execution Order](#13-recommended-execution-order)
- [14. Initial Vertical Slice](#14-initial-vertical-slice)
- [15. Validation and Acceptance Criteria](#15-validation-and-acceptance-criteria)
- [16. Rollback Strategy](#16-rollback-strategy)
- [17. Definition of Done](#17-definition-of-done)
- [18. Final Recommendation](#18-final-recommendation)

---

## 1. Migration Objective

The goal is to migrate all approved business data from Joomla 3 to Joomla 6 while preserving both database integrity and application behavior.

A successful migration must preserve:

1. Required records.
2. Entity relationships.
3. Category, menu, tag, user-group, and ACL tree structures.
4. User identity and approved access behavior.
5. Article ownership, categories, publishing state, and metadata.
6. Frontend routing and important legacy URLs.
7. Module visibility and menu assignments.
8. Tags, custom fields, language associations, and workflows.
9. Custom and third-party extension business data.
10. Media and file references.
11. Repeatability, logging, reconciliation, and rollback capability.

The objective is not to copy the Joomla 3 database into Joomla 6. Joomla 6 must own its installation schema, extension registry, generated structures, and runtime data.

---

## 2. Recommended Migration Architecture

```mermaid
flowchart LR
    J3[Joomla 3 source database]
    AUDIT[Audit and cleanup]
    STAGING[Migration staging database]
    MAP[Mapping and transformation]
    J6[Joomla 6 fresh database]
    REBUILD[Joomla rebuild operations]
    VALIDATE[Reconciliation and functional validation]

    J3 --> AUDIT
    AUDIT --> STAGING
    STAGING --> MAP
    MAP --> J6
    J6 --> REBUILD
    REBUILD --> VALIDATE
```

Recommended databases:

```text
joomla3_source
joomla3_staging_clone
joomla6_target
joomla_migration
```

Responsibilities:

| Database | Responsibility |
|---|---|
| `joomla3_source` | Read-only source snapshot |
| `joomla3_staging_clone` | Cleanup and migration rehearsal source |
| `joomla6_target` | Fresh Joomla 6 installation and migrated target data |
| `joomla_migration` | Staging tables, mappings, run tracking, exceptions, and reports |

---

## 3. Why a Hybrid Approach Is Required

No single tool is sufficient for a complete Joomla 3 to Joomla 6 migration.

### 3.1 MySQL scripts

Best suited for:

- Table and column inventory.
- Schema comparison.
- Detecting zero dates, invalid references, and duplicates.
- Creating staging and mapping tables.
- Bulk extraction.
- Row-count reconciliation.
- Referential integrity reports.

Weaknesses:

- Complex JSON conversion is difficult to maintain.
- Parent-first tree migration is cumbersome.
- Resume and exception handling are limited.
- Joomla business rules are not automatically enforced.
- ACL asset and workflow generation should not be implemented with raw SQL alone.

### 3.2 PHP CLI migration scripts

Best suited for:

- Batch processing.
- ID mapping.
- JSON and serialized data transformation.
- Alias and URL rewriting.
- Business rule validation.
- Error handling and logging.
- Resume support.
- Per-entity migration logic.

This should be the primary migration engine.

### 3.3 Joomla APIs and CLI commands

Best suited for:

- Saving Joomla-aware entities when framework behavior is required.
- Creating or repairing ACL assets.
- Rebuilding nested-set trees.
- Creating workflow associations.
- Clearing cache.
- Re-indexing Smart Search.
- Running target database checks.

### 3.4 Joomla extension SQL update files

Best suited for:

- Creating target extension tables.
- Adding or changing columns.
- Adding indexes.
- Managing extension schema versions.

They should not be used as the main migration engine because they are not designed for:

- Cross-database source reads.
- Source-to-target ID mapping.
- Batch resume.
- Per-record exception handling.
- Reconciliation reports.
- Complex business transformation.

---

## 4. Phase 1 — Audit and Scope Definition

### 4.1 Goal

Create a complete migration inventory and assign one migration decision to every source table and business entity.

### 4.2 Required actions

1. Back up the Joomla 3 database, source code, media, and configuration.
2. Restore the source into a staging clone.
3. Inventory every table and column.
4. Classify each table.
5. Compare exact source and target schemas.
6. Detect invalid data and broken references.
7. Identify extension ownership.
8. Define approved migration scope.

### 4.3 Table classification

Each source table should be classified as one of the following:

| Classification | Description |
|---|---|
| Core | Joomla core business or structure data |
| Custom | Project-specific component, module, or plugin data |
| Third-party | Vendor extension data |
| Runtime | Sessions, cache, logs, generated indexes, or temporary data |
| Unknown | Owner or purpose has not yet been confirmed |

Each table must receive one migration action:

```text
MIGRATE
TRANSFORM
REBUILD
KEEP_TARGET
SKIP
ARCHIVE_ONLY
MANUAL_REVIEW
```

### 4.4 Suggested inventory query

```sql
SELECT
    TABLE_NAME,
    ENGINE,
    TABLE_ROWS,
    TABLE_COLLATION,
    DATA_LENGTH,
    INDEX_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'joomla3_source'
ORDER BY TABLE_NAME;
```

### 4.5 Required source data audits

Audit at least the following:

- Zero dates.
- Invalid JSON.
- Mixed character encoding.
- Orphan articles.
- Orphan categories.
- Missing users or access levels.
- Broken menu parent references.
- Broken module-menu assignments.
- Invalid tag mappings.
- Invalid field values.
- Duplicate aliases.
- Broken nested-set boundaries.
- Broken media references.
- Unsupported content plugin syntax and shortcodes.

Example orphan article query:

```sql
SELECT
    content.id,
    content.title,
    content.catid
FROM j3_content AS content
LEFT JOIN j3_categories AS category
    ON category.id = content.catid
WHERE category.id IS NULL;
```

### 4.6 Required output

Create a migration matrix with at least these columns:

```text
source_table
owner
business_purpose
row_count
target_table
migration_action
migration_order
required_extension
status
notes
```

### 4.7 Completion criteria

Phase 1 is complete when:

- Every source table has an owner or approved `MANUAL_REVIEW` status.
- Every table has a migration action.
- All known invalid data is reported.
- The extension and media scope is documented.
- No important table remains silently excluded.

---

## 5. Phase 2 — Prepare Joomla 6 and Target Extensions

### 5.1 Goal

Create a clean Joomla 6 target environment with all required extension schemas installed before business data is imported.

### 5.2 Required actions

1. Install Joomla 6 from a clean package or approved project source.
2. Do not import the Joomla 3 database.
3. Keep Joomla 6 core registry and system records.
4. Install the Joomla 6-compatible template.
5. Install compatible third-party extensions.
6. Install or discover migrated custom extensions.
7. Run extension schema updates.
8. Back up the clean target database.

### 5.3 Extension readiness checklist

For every custom or third-party extension:

- The Joomla 6-compatible version exists.
- Installation or discovery succeeds.
- Manifest files are valid.
- Required database tables exist.
- Required plugins and modules are enabled.
- Basic backend access works.
- Basic frontend behavior works.
- ACL rules exist where required.
- Media and upload paths are known.
- The source and target schemas have been compared.

### 5.4 Joomla extension SQL usage

Example extension update path:

```text
administrator/components/com_example/sql/install.mysql.utf8.sql
administrator/components/com_example/sql/updates/mysql/6.0.0.sql
administrator/components/com_example/sql/updates/mysql/6.1.0.sql
```

Example schema update:

```sql
ALTER TABLE `#__example_items`
    ADD COLUMN `migration_source_id` INT UNSIGNED NULL;

CREATE INDEX `idx_migration_source_id`
    ON `#__example_items` (`migration_source_id`);
```

Use these files to manage the target extension schema. Do not use them as the main cross-database content migration workflow.

### 5.5 Template position mapping

Create a mapping table before migrating modules:

| Joomla 3 position | Joomla 6 position | Action |
|---|---|---|
| `top` | `topbar` | Remap |
| `menu` | `menu` | Keep |
| `search` | `search` | Keep if supported |
| `footer` | `footer` | Keep or remap |
| Unknown custom position | Approved target position | Manual review |

### 5.6 Completion criteria

Phase 2 is complete when:

- Joomla 6 starts without installation errors.
- Required target tables exist.
- Required templates and extensions are installed.
- Custom extensions can be discovered or installed.
- A clean target baseline backup exists.

---

## 6. Phase 3 — Build Staging, Cleanup, and Mapping

### 6.1 Goal

Prepare normalized source data and explicit source-to-target mappings before inserting records into Joomla 6.

### 6.2 Migration control tables

Create a migration run table:

```sql
CREATE TABLE migration_runs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    run_uuid CHAR(36) NOT NULL UNIQUE,
    source_version VARCHAR(50) NOT NULL,
    target_version VARCHAR(50) NOT NULL,
    git_commit VARCHAR(64) NULL,
    started_at DATETIME NOT NULL,
    completed_at DATETIME NULL,
    status VARCHAR(30) NOT NULL,
    error_summary TEXT NULL
);
```

Create a generic mapping table or separate entity mapping tables:

```sql
CREATE TABLE migration_id_map (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    migration_run_id BIGINT UNSIGNED NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    source_id BIGINT NOT NULL,
    target_id BIGINT NULL,
    source_key VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    error_message TEXT NULL,
    UNIQUE KEY uq_entity_source (
        migration_run_id,
        entity_type,
        source_id
    )
);
```

Recommended dedicated maps:

```text
migration_user_map
migration_usergroup_map
migration_viewlevel_map
migration_category_map
migration_content_map
migration_extension_map
migration_menu_map
migration_module_map
migration_tag_map
migration_field_map
migration_template_style_map
```

### 6.3 Staging tables

Create staging tables for:

- Users.
- User groups.
- View access levels.
- Categories.
- Articles.
- Tags.
- Custom fields.
- Menus.
- Modules.
- Custom extensions.
- Third-party extensions.

Each staging row should include:

```text
source_id
source_table
migration_run_id
migration_status
migration_error
target_id
source_hash
target_hash
```

Example article staging table:

```sql
CREATE TABLE staging_content (
    source_id INT UNSIGNED NOT NULL,
    source_catid INT UNSIGNED NOT NULL,
    source_created_by INT UNSIGNED NULL,
    title VARCHAR(255) NOT NULL,
    alias VARCHAR(400) NOT NULL,
    introtext MEDIUMTEXT NULL,
    fulltext MEDIUMTEXT NULL,
    images LONGTEXT NULL,
    urls LONGTEXT NULL,
    attribs LONGTEXT NULL,
    metadata LONGTEXT NULL,
    migration_status VARCHAR(30) NOT NULL DEFAULT 'pending',
    target_id INT UNSIGNED NULL,
    migration_error TEXT NULL,
    PRIMARY KEY (source_id)
);
```

### 6.4 Bulk extraction

Use MySQL for predictable bulk extraction:

```sql
INSERT INTO joomla_migration.staging_content (
    source_id,
    source_catid,
    source_created_by,
    title,
    alias,
    introtext,
    fulltext,
    images,
    urls,
    attribs,
    metadata
)
SELECT
    id,
    catid,
    created_by,
    title,
    alias,
    introtext,
    fulltext,
    images,
    urls,
    attribs,
    metadata
FROM joomla3_source.j3_content
WHERE state <> -2;
```

### 6.5 Cleanup responsibilities

Use PHP CLI for:

- Validating and normalizing JSON.
- Converting approved zero dates to `NULL` or documented fallback values.
- Resolving aliases.
- Normalizing UTF-8 and `utf8mb4` content.
- Rewriting URLs and media paths.
- Resolving orphan records using approved fallback rules.
- Logging uncertain records for manual review.

Do not silently delete or guess business data.

### 6.6 Mapping rules

#### Users

Mapping priority:

1. Preserve the source ID when safe.
2. Match by normalized email.
3. Match by username.
4. Create a new target user.
5. Send duplicate or ambiguous users to manual review.

#### Extensions

Map by stable identity:

```text
type + element + folder + client_id
```

Do not map by raw `extension_id`.

#### View access levels

Map by:

- Business meaning.
- Title.
- Transformed group rules.

Do not assume the same raw access ID has the same meaning.

#### Categories

Map by:

- Source ID when intentionally preserved.
- Or `extension + path`.

#### Menus and modules

Map using target component, menu, template-style, position, and language relationships.

### 6.7 Completion criteria

Phase 3 is complete when:

- All approved source records are extracted.
- Invalid source records have documented decisions.
- Required mapping tables exist.
- Every reference has a mapping or approved fallback rule.
- The migration supports dry-run and restart behavior.

---

## 7. Phase 4 — Migrate Joomla Core Data

### 7.1 Goal

Migrate Joomla core data in dependency order while keeping Joomla 6 installation-owned structures intact.

### 7.2 Recommended dependency order

```text
Users and groups
    -> View access levels
    -> Categories
    -> Articles
    -> Tags and fields
    -> Languages and associations
    -> Template styles
    -> Menus
    -> Modules
    -> ACL assets and workflows
```

### 7.3 Users and access data

Migrate approved fields such as:

```text
name
username
email
password hash when compatible
block
sendEmail
registerDate
lastvisitDate
approved params
```

Do not migrate:

```text
sessions
remember-me keys
temporary reset tokens
legacy OTP secrets
temporary authentication data
```

Keep Joomla 6 core user groups. Map core groups by business meaning and create only required custom groups.

### 7.4 Categories

Import categories parent-first.

Keep or transform:

```text
extension
title
alias
description
state
access
language
params
metadata
creator and modifier references
```

Remap:

```text
parent_id
asset_id
access
created_user_id
modified_user_id
```

Do not copy raw tree values:

```text
lft
rgt
level
path
```

Rebuild the target tree after import.

### 7.5 Articles

Migrate approved article fields:

```text
title
alias
introtext
fulltext
state
catid
created
created_by
modified
modified_by
publish_up
publish_down
images
urls
attribs
ordering
metakey
metadesc
metadata
access
hits
language
```

Remap:

```text
catid
created_by
modified_by
access
asset_id
```

Reset:

```text
checked_out
checked_out_time
```

Validate or transform:

```text
state
featured
images JSON
urls JSON
attribs JSON
metadata JSON
dates
```

### 7.6 Example PHP article migrator

```php
<?php

declare(strict_types=1);

final class ArticleMigrator
{
    public function migrate(array $sourceArticle): int
    {
        $targetCategoryId = $this->categoryMap
            ->getTargetId((int) $sourceArticle['catid']);

        $targetAuthorId = $this->userMap
            ->getTargetIdOrFallback((int) $sourceArticle['created_by']);

        $targetAccessId = $this->viewLevelMap
            ->getTargetId((int) $sourceArticle['access']);

        $targetArticle = [
            'title'       => trim((string) $sourceArticle['title']),
            'alias'       => $this->normalizeAlias((string) $sourceArticle['alias']),
            'introtext'   => (string) $sourceArticle['introtext'],
            'fulltext'    => (string) $sourceArticle['fulltext'],
            'catid'       => $targetCategoryId,
            'created_by'  => $targetAuthorId,
            'access'      => $targetAccessId,
            'images'      => $this->normalizeJson((string) $sourceArticle['images']),
            'urls'        => $this->normalizeJson((string) $sourceArticle['urls']),
            'attribs'     => $this->normalizeJson((string) $sourceArticle['attribs']),
            'metadata'    => $this->normalizeJson((string) $sourceArticle['metadata']),
            'checked_out' => null,
        ];

        return $this->articleRepository->insert($targetArticle);
    }
}
```

The production implementation should include dependency injection, transaction boundaries, batch handling, logging, validation, and exception reporting.

### 7.7 Workflow associations

Joomla 3 does not provide the same workflow model as Joomla 6.

Required actions:

1. Keep the Joomla 6 Basic Workflow or create an approved target workflow.
2. Define source state to target workflow-stage mapping.
3. Create a valid workflow association for every migrated article when workflows are active.
4. Validate publish and unpublish behavior.

### 7.8 Featured content

Migrate featured mappings after articles exist.

- Remap article IDs.
- Preserve approved ordering.
- Keep article featured state and frontpage mapping consistent.

### 7.9 Tags and custom fields

Order:

1. Tag tree.
2. Field groups.
3. Fields.
4. Field-category assignments.
5. Field values.
6. Content-tag mappings.

Ensure required field plugins are installed before field definitions are imported.

### 7.10 Languages and associations

- Install required target languages first.
- Map by language tag, not raw ID.
- Recreate multilingual associations only after all associated target items exist.

### 7.11 Menus

Migrate frontend menu containers and items after referenced content exists.

Required transformations:

- Parent menu IDs.
- Component IDs.
- Article and category IDs embedded in links.
- Access levels.
- Languages.
- Template styles.
- Menu tree values.

Example source link:

```text
index.php?option=com_content&view=article&id=123
```

After mapping article `123` to target article `785`:

```text
index.php?option=com_content&view=article&id=785
```

Do not migrate Joomla 3 administrator menus.

### 7.12 Modules

Migrate frontend module instances only after:

- The module type is installed.
- The target template is installed.
- Position mapping is defined.
- Menu items have been migrated.

For `#__modules_menu`, preserve Joomla semantics:

```text
menuid = 0  -> all pages
menuid > 0  -> include selected page
menuid < 0  -> exclude selected page
```

When menu IDs change, remap the absolute ID and preserve the sign.

### 7.13 ACL assets

Do not copy raw Joomla 3 `asset_id` values.

Required actions:

- Keep Joomla 6 core assets.
- Create or rebuild assets for migrated categories, articles, modules, and custom entities.
- Reassign target asset IDs.
- Rebuild the asset tree.
- Validate permission inheritance.

### 7.14 Completion criteria

Phase 4 is complete when:

- Core record counts reconcile.
- No core target entity has broken required references.
- Articles render and can be edited.
- Menus route correctly.
- Modules display on the correct pages.
- ACL and workflow behavior is valid.

---

## 8. Phase 5 — Migrate Custom, Third-Party, and Media Data

### 8.1 Goal

Migrate extension-owned business data and related files without assuming source and target schemas are identical.

### 8.2 Custom extension migration

Create a dedicated migrator for each custom extension family.

Example structure:

```text
src/Migrator/
├── HondaMigrator.php
├── CarsMigrator.php
├── ImageSliderMigrator.php
└── CustomFormMigrator.php
```

For each extension, document:

```text
extension name
source version
target version
source tables
target tables
primary keys
logical foreign keys
user references
article references
category references
menu references
asset references
JSON columns
serialized columns
encrypted columns
file paths
external IDs
migration method
validation method
rollback method
```

Recommended process:

1. Install the Joomla 6 extension code.
2. Allow the installer to create the target schema.
3. Compare source and target schemas.
4. Extract source data into staging.
5. Transform values and references.
6. Import parent records before child records.
7. Copy related files.
8. Rebuild ACL assets if required.
9. Validate backend and frontend behavior.
10. Produce a separate reconciliation report.

### 8.3 Third-party extensions

Use this priority order:

1. Official vendor migration tool.
2. Extension export/import feature.
3. Supported sequential upgrade path.
4. Custom PHP migrator.

Do not blindly copy vendor tables because:

- Schemas may have changed.
- Extension IDs may differ.
- Configuration formats may differ.
- Data may be serialized or encrypted.
- New target tables or indexes may be required.

### 8.4 Suggested extension priority

#### Priority 1 — Frontend structure and rendering

- Custom Honda component.
- Cars component.
- Image slider.
- Header and footer modules.
- Page builder or shortcode dependencies.

#### Priority 2 — Business data

- Forms.
- Commerce data.
- Mailing lists.
- Leads and contacts.
- Other project-specific business components.

#### Priority 3 — Utility extensions

- Editors.
- Security tools.
- Cache and optimization tools.
- Cookie plugins.
- Module management utilities.

Utility extensions are usually safer to reinstall and reconfigure than to copy internally generated data.

### 8.5 Media and files

Migrate:

- `/images`.
- Custom upload directories.
- Extension media directories.
- Documents and PDFs.
- Slider images.
- Required form attachments.
- User-uploaded business files.

Do not copy:

- Cache directories.
- Temporary directories.
- Generated optimized CSS or JavaScript.
- JCH Optimize cache.
- Finder indexes.
- Old session files.
- Regenerable thumbnails unless required.

Example `rsync` command:

```bash
rsync -av \
  --exclude='cache/' \
  --exclude='tmp/' \
  /joomla3/images/ \
  /joomla6/images/
```

### 8.6 Media validation

Validate:

- File counts.
- Total sizes.
- Checksums for important files.
- Case-sensitive filenames.
- URL encoding.
- Vietnamese filenames.
- Absolute source-domain URLs.
- CDN URLs.
- File permissions.
- Broken references in HTML and JSON.

### 8.7 Completion criteria

Phase 5 is complete when:

- Each extension has an approved migration result.
- Required business records reconcile.
- Related files exist.
- Important frontend and backend workflows succeed.
- Unsupported records are documented instead of silently lost.

---

## 9. Phase 6 — Rebuild, Validate, Rehearse, and Cut Over

### 9.1 Goal

Regenerate Joomla-owned structures, prove migration completeness, perform repeatable rehearsals, and execute production cutover safely.

### 9.2 Structures to rebuild

Rebuild or regenerate:

```text
ACL assets
category nested sets
menu nested sets
tag nested sets
user-group nested sets
workflow associations
Smart Search indexes
cache
extension update sites
extension schema records
administrator menus
administrator modules
```

### 9.3 Data not to migrate directly

Do not directly import:

```text
#__session
#__extensions
#__schemas
#__updates
#__update_sites
#__update_sites_extensions
#__finder_*
cache tables
remember-me keys
temporary tokens
Joomla 3 administrator menu data
Joomla 3 administrator module data
```

These records are runtime-generated, installation-owned, version-specific, or security-sensitive.

### 9.4 Database reconciliation

Compare:

```text
source approved count
staging extracted count
target migrated count
intentionally skipped count
failed count
manual review count
```

Required reconciliation formula:

```text
Source approved records
=
Migrated
+ Intentionally skipped
+ Failed
+ Manual review
```

Example article count queries:

```sql
SELECT COUNT(*) AS source_articles
FROM joomla3_source.j3_content
WHERE state <> -2;

SELECT COUNT(*) AS migrated_articles
FROM joomla_migration.migration_content_map
WHERE status = 'migrated';

SELECT COUNT(*) AS failed_articles
FROM joomla_migration.migration_content_map
WHERE status = 'failed';
```

Example orphan target article query:

```sql
SELECT
    content.id,
    content.title,
    content.catid
FROM joomla6_target.j6_content AS content
LEFT JOIN joomla6_target.j6_categories AS category
    ON category.id = content.catid
WHERE category.id IS NULL;
```

Example broken module assignment query:

```sql
SELECT
    assignment.moduleid,
    assignment.menuid
FROM joomla6_target.j6_modules_menu AS assignment
LEFT JOIN joomla6_target.j6_modules AS module
    ON module.id = assignment.moduleid
LEFT JOIN joomla6_target.j6_menu AS menu
    ON menu.id = ABS(assignment.menuid)
WHERE module.id IS NULL
   OR (
       assignment.menuid <> 0
       AND menu.id IS NULL
   );
```

### 9.5 Hash comparison

Use hashes for important business fields after canonicalizing JSON.

Suggested hash inputs:

```text
Article: title + body + alias + mapped category
User: username + email + block state
Category: title + mapped parent + path meaning
Menu: title + rewritten link + mapped parent
Module: title + content + mapped position
```

Exclude Joomla-generated fields such as:

```text
asset_id
lft
rgt
checked_out
target-generated timestamps
```

### 9.6 Functional validation

#### Frontend

Test:

- Home page.
- Article pages.
- Category blog and list pages.
- Featured content.
- Menus and aliases.
- Header, footer, and sidebar modules.
- Tags and custom fields.
- Multilingual content.
- Media.
- Legacy redirects.
- Custom extension pages.

#### Backend

Test:

- User login.
- Article open and save.
- Article create and publish.
- Category edit.
- Menu edit.
- Module edit.
- Custom field edit.
- Workflow transitions.
- ACL create, edit, publish, and delete behavior.
- Custom extension CRUD.

#### Technical

Check:

- PHP logs.
- Joomla logs.
- Deprecated warnings.
- Missing classes.
- Slow queries.
- Missing indexes.
- Broken media paths.
- Cache behavior.
- Search indexing.

### 9.7 Rehearsals

Run at least two complete rehearsals.

#### Rehearsal 1

Focus on:

- Script completion.
- Missing mappings.
- Transformation gaps.
- Extension failures.
- Exception rules.

#### Rehearsal 2

Run from a fresh Joomla 6 target baseline and confirm:

- Repeatability.
- Resume behavior.
- Final runtime.
- Reconciliation.
- Rollback readiness.
- Regression-test success.

Record for every run:

```text
run UUID
source snapshot
target baseline
git commit
start time
end time
record counts
failed records
manual actions
validation result
rollback result
```

### 9.8 Production cutover

Recommended sequence:

1. Freeze migration code and extension versions.
2. Enable Joomla 3 maintenance or read-only mode.
3. Create final source database and media backups.
4. Restore the approved Joomla 6 clean baseline.
5. Run the migration with a new run UUID.
6. Copy final media delta.
7. Rebuild trees, ACL assets, workflow associations, cache, and search indexes.
8. Run database reconciliation.
9. Run smoke tests.
10. Switch traffic to Joomla 6.
11. Monitor logs, 404s, login errors, forms, email, and custom workflows.
12. Keep Joomla 3 available in read-only mode during the rollback window.

### 9.9 Completion criteria

Phase 6 is complete when:

- Reconciliation succeeds.
- Functional tests pass.
- The production migration is repeatable.
- Rollback has been tested.
- No critical exception remains unresolved.

---

## 10. Recommended Tool by Task

| Task | MySQL | PHP CLI | Joomla API/CLI | Extension SQL Update |
|---|---:|---:|---:|---:|
| Table inventory | Yes | Optional | No | No |
| Schema comparison | Yes | Optional | No | No |
| Invalid data detection | Yes | Yes | No | No |
| Staging tables | Yes | No | No | No |
| Bulk extraction | Yes | Optional | No | No |
| JSON transformation | Limited | Yes | Optional | No |
| ID mapping | Limited | Yes | Optional | No |
| Batch resume | No | Yes | Optional | No |
| Category parent-first import | Limited | Yes | Yes | No |
| Article migration | Limited | Yes | Yes | No |
| Menu-link rewriting | Limited | Yes | Optional | No |
| ACL asset creation | No | Optional | Yes | No |
| Nested-set rebuild | No | Optional | Yes | No |
| Workflow associations | Limited | Yes | Yes | No |
| Extension schema creation | Yes | No | Installer | Yes |
| Reconciliation | Yes | Yes | Optional | No |
| Cache clearing | No | No | Yes | No |
| Search re-indexing | No | No | Yes | No |

---

## 11. Recommended Project Structure

```text
migration/
├── config/
│   ├── database.php
│   └── migration.php
├── sql/
│   ├── 01-audit/
│   ├── 02-staging/
│   ├── 03-extract/
│   ├── 04-validation/
│   └── 05-rollback/
├── src/
│   ├── Command/
│   ├── Migrator/
│   ├── Mapper/
│   ├── Transformer/
│   ├── Validator/
│   ├── Repository/
│   └── Logger/
├── reports/
│   ├── audit/
│   ├── exceptions/
│   └── reconciliation/
├── tests/
├── migrate.php
└── README.md
```

Suggested SQL files:

```text
01_inventory_tables.sql
02_inventory_columns.sql
03_detect_zero_dates.sql
04_detect_invalid_json.sql
05_detect_orphans.sql
06_detect_duplicate_aliases.sql
07_create_migration_schema.sql
08_extract_users.sql
09_extract_categories.sql
10_extract_articles.sql
11_validate_core_relations.sql
12_reconcile_counts.sql
```

Suggested PHP commands:

```text
migrate:users
migrate:user-groups
migrate:view-levels
migrate:categories
migrate:articles
migrate:tags
migrate:fields
migrate:menus
migrate:modules
migrate:extensions
migrate:media-audit
migrate:rebuild
migrate:validate
```

---

## 12. Migration Script Requirements

Every migration command should support where applicable:

```text
--dry-run
--entity
--batch-size
--limit
--from-id
--run-id
--resume
--verbose
```

Every migrated record should use one status:

```text
pending
ready
migrated
skipped
failed
manual_review
```

Minimum implementation requirements:

- Use prepared statements.
- Use transactions at safe batch boundaries.
- Avoid loading entire large tables into memory.
- Log source ID, entity, stage, and error.
- Never log password hashes or sensitive tokens.
- Make repeated execution idempotent.
- Save mappings immediately after successful insert.
- Stop dependent entities when required mappings are missing.
- Continue unrelated records when one record fails.
- Generate machine-readable and human-readable reports.

---

## 13. Recommended Execution Order

```text
1. Install fresh Joomla 6
2. Install Joomla 6-compatible template
3. Install Joomla 6-compatible extensions
4. Create migration control and staging tables
5. Audit and clean source staging clone
6. Extract approved source data
7. Migrate custom user groups
8. Migrate users
9. Migrate user-group mappings
10. Migrate view access levels
11. Migrate categories
12. Rebuild category tree
13. Migrate articles
14. Create article workflow associations
15. Migrate featured mappings
16. Migrate tags and tag mappings
17. Migrate field groups, fields, and values
18. Migrate languages and associations
19. Create or map template styles
20. Migrate frontend menu types
21. Migrate frontend menu items
22. Rebuild menu tree
23. Migrate frontend modules
24. Migrate module-menu assignments
25. Migrate custom extension data
26. Migrate third-party extension data
27. Copy approved media and files
28. Rebuild ACL assets
29. Rebuild remaining trees
30. Clear cache
31. Re-index Smart Search
32. Run database reconciliation
33. Run functional validation
34. Execute rehearsal and rollback test
35. Execute production cutover
```

---

## 14. Initial Vertical Slice

Do not start by migrating the complete database.

First implement a small end-to-end migration containing:

```text
1 user
1 custom user group
1 access level
1 parent category
1 child category
5 articles
1 featured article
1 frontend menu type
2 menu items
1 header module
1 footer module
media referenced by the selected articles
```

The vertical slice must prove:

- User and group mapping works.
- Access-level mapping works.
- Category parent mapping works.
- Category tree rebuild works.
- Article transformation works.
- Workflow association works.
- Menu link rewriting works.
- Module assignment works.
- Template position mapping works.
- Media references work.
- Reconciliation reports work.
- The migration can be rerun without duplicates.

Recommended implementation sequence:

```text
01_inventory.sql
02_create_migration_schema.sql
03_extract_users.sql
04_extract_categories.sql
05_extract_articles.sql
06_migrate_users.php
07_migrate_categories.php
08_migrate_articles.php
09_migrate_menu.php
10_migrate_modules.php
11_rebuild.php
12_validate.sql
```

Only expand to the full dataset after the vertical slice passes database and functional validation.

---

## 15. Validation and Acceptance Criteria

### 15.1 Record completeness

Every approved source record must be accounted for as:

```text
migrated
intentionally skipped
failed
manual review
```

No record may disappear without a report entry.

### 15.2 Referential integrity

Validate at least:

- Article to category.
- Article to author and modifier.
- Article to view access level.
- Article to ACL asset.
- Article to workflow stage.
- Category to parent.
- Menu to parent and component.
- Menu to article, category, or custom entity.
- Module to module type.
- Module assignment to menu.
- Tag mapping to content and tag.
- Field value to field and item.
- Custom extension data to related users, articles, and categories.

### 15.3 Behavior preservation

Validate:

- Frontend pages render correctly.
- Backend entities open and save correctly.
- Published and unpublished behavior is correct.
- User roles see and edit the correct data.
- Menus route to the correct target entities.
- Modules appear on the intended pages.
- Important legacy URLs redirect correctly.
- Custom and third-party extension workflows remain operational.

### 15.4 Acceptance thresholds

Recommended thresholds:

- `100%` of tables classified.
- `100%` of approved records accounted for.
- `0` unexplained orphan records.
- `0` invalid required references.
- `0` critical frontend routes broken.
- `0` unresolved critical ACL defects.
- `0` unresolved critical extension data defects.
- At least two successful full rehearsals.
- Successful rollback test.

---

## 16. Rollback Strategy

### 16.1 Rollback triggers

Rollback when any of the following occurs:

- The migration cannot resume after failure.
- Reconciliation does not balance.
- Critical business data is missing or corrupted.
- Login or ACL behavior is critically broken.
- Main menu routes are unavailable.
- A critical custom extension is unusable.
- The cutover exceeds the approved maintenance window.

### 16.2 Rollback steps

1. Stop traffic to Joomla 6.
2. Switch traffic back to Joomla 3.
3. Restore the Joomla 3 database if source writes occurred.
4. Restore the source media snapshot if required.
5. Mark the migration run as `rolled_back`.
6. Preserve the failed Joomla 6 database and logs for analysis.
7. Do not repair the failed production target manually without reproducing and documenting the fix in migration code.

---

## 17. Definition of Done

The migration is complete only when:

- Every source table has a documented migration decision.
- Every approved record is reconciled.
- No unexplained orphan record remains.
- No invalid required target reference remains.
- Category, menu, tag, user-group, and ACL trees are valid.
- Users can log in using the approved authentication strategy.
- ACL is tested with representative user roles.
- Articles render and can be edited.
- Workflow associations are valid.
- Menus route correctly.
- Header, footer, and important modules display correctly.
- Tags, custom fields, languages, and associations work where used.
- Required custom and third-party extensions work.
- Required media files exist.
- Important legacy URLs are redirected.
- The migration can run again from a clean Joomla 6 baseline.
- At least two rehearsals have succeeded.
- Backup and rollback procedures have been tested.
- Final audit, exception, and reconciliation reports are available.

---

## 18. Final Recommendation

Use the following implementation model:

```text
MySQL scripts
    -> audit, staging, extraction, and reconciliation

PHP CLI migration engine
    -> cleanup, transformation, ID mapping, batching, logging, and resume

Joomla APIs and CLI
    -> Joomla-aware entity operations, ACL, nested sets, workflow, cache, and indexing

Joomla extension SQL updates
    -> target extension schema installation and version upgrades only
```

The first deliverable should be the vertical slice described in [Initial Vertical Slice](#14-initial-vertical-slice). Once that slice is repeatable and validated, expand the same framework to all Joomla core data, then custom extensions, third-party extensions, and media.
