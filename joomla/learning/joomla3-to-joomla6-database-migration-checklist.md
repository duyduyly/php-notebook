# Joomla 3 to Joomla 6 Database Migration Checklist

A practical checklist for auditing, planning, migrating, and validating database data when moving a Joomla 3.10.x project to Joomla 6.

> **Recommended path:** Joomla 3.10.x → Joomla 4.x → Joomla 5.4.x → Joomla 6.x.
>
> Do not import a complete Joomla 3 database directly into a clean Joomla 6 database. Joomla core tables, extension metadata, workflows, administrator records, authentication data, and derived indexes are not fully compatible.

## Table of Contents

- [1. Migration principles](#1-migration-principles)
- [2. Main database differences](#2-main-database-differences)
- [3. Data that normally must be migrated](#3-data-that-normally-must-be-migrated)
- [4. Data that should not be copied directly](#4-data-that-should-not-be-copied-directly)
- [5. Required mapping tables](#5-required-mapping-tables)
- [6. Database migration checklist](#6-database-migration-checklist)
- [7. Recommended migration order](#7-recommended-migration-order)
- [8. Validation checklist](#8-validation-checklist)
- [9. Migration report templates](#9-migration-report-templates)

---

## 1. Migration principles

- [ ] Upgrade the source site to the latest Joomla 3.10.x release before migration.
- [ ] Create a complete database and source-code backup.
- [ ] Run migration only in a staging environment first.
- [ ] Prefer the sequential Joomla upgrade path for core data.
- [ ] Treat custom and third-party extension data as separate migration workstreams.
- [ ] Do not assume that matching table names mean matching schemas.
- [ ] Do not copy Joomla core extension registry records into Joomla 6.
- [ ] Preserve important business IDs where practical, especially user, category, and article IDs.
- [ ] Build explicit old-ID-to-new-ID mapping when IDs cannot be preserved.
- [ ] Rebuild derived data such as Smart Search indexes after migration.

## 2. Main database differences

| Area | Joomla 3 | Joomla 6 | Migration impact |
|---|---|---|---|
| Character set | May contain older `utf8` or mixed collations | Core schema normally uses `utf8mb4` | Audit charset, collation, indexes, and text data |
| Date values | Legacy zero dates may exist | Strict SQL handling expects `NULL` or valid dates | Clean invalid dates before migration |
| Content state | Mainly controlled by `#__content.state` | Uses workflow, stage, transition, and association records | Map articles into valid Joomla 6 workflow stages |
| Extension registry | Joomla 3 manifest metadata and extension IDs | Newer fields, indexes, schemas, and core extensions | Reinstall extensions instead of copying registry rows |
| Administrator UI | Joomla 3 admin menu and modules | Joomla 6 dashboards, admin modules, and guided tours | Do not copy core administrator menu/module records |
| Authentication | Joomla 3 sessions, keys, and older auth plugins | Newer MFA, WebAuthn, API login, and security mechanisms | Do not migrate sessions or temporary security tokens |
| Scheduled jobs | Usually cron or third-party plugins | Core Scheduled Tasks system | Recreate or convert scheduled processes |
| Smart Search | Joomla 3 Finder indexes | Newer Finder schema and generated index data | Re-index instead of importing generated search data |
| Privacy and logs | Limited or extension-dependent | Core privacy, consent, and action logging | Migrate only when required for audit or legal reasons |
| SQL behavior | Older custom queries may be permissive | Strict database mode is expected | Review custom SQL for strict-mode compatibility |

### Joomla 6 functional table groups that require special attention

- Content workflows:
  - `#__workflows`
  - `#__workflow_stages`
  - `#__workflow_transitions`
  - `#__workflow_associations`
- Scheduled tasks:
  - `#__scheduler_tasks`
- Privacy and logging:
  - `#__action_logs`
  - `#__action_logs_extensions`
  - `#__action_logs_users`
  - `#__privacy_requests`
  - `#__privacy_consents`
- Mail templates:
  - `#__mail_templates`
- Authentication and security:
  - MFA-related tables
  - WebAuthn credential tables

Exact tables may vary by Joomla 6 patch version and installed extensions.

## 3. Data that normally must be migrated

### 3.1 Content and taxonomy

- [ ] `#__content`
- [ ] `#__categories`
- [ ] `#__content_frontpage`
- [ ] `#__content_rating`, when ratings must be retained
- [ ] `#__tags`
- [ ] `#__contentitem_tag_map`
- [ ] `#__fields`
- [ ] `#__fields_groups`
- [ ] `#__fields_values`
- [ ] Multilingual associations, when used
- [ ] Article workflow associations in Joomla 6

### 3.2 Menus and page structure

- [ ] `#__menu_types`
- [ ] Frontend records from `#__menu`
- [ ] Parent-child menu relationships
- [ ] Menu aliases and paths
- [ ] Access levels and languages
- [ ] Component ID mapping
- [ ] Template style mapping

Do not blindly copy Joomla 3 administrator menu records.

### 3.3 Modules

- [ ] In-use frontend module instances from `#__modules`
- [ ] Module-to-menu assignments from `#__modules_menu`
- [ ] Module content and published state
- [ ] Ordering, access level, and language
- [ ] Joomla 6-compatible module parameters
- [ ] New template positions

Do not copy obsolete Joomla 3 administrator modules.

### 3.4 Users and ACL

- [ ] `#__users`
- [ ] `#__usergroups`
- [ ] `#__user_usergroup_map`
- [ ] `#__viewlevels`
- [ ] `#__user_profiles`
- [ ] Relevant ACL records from `#__assets`
- [ ] Content ownership references
- [ ] Custom and third-party user references

Preserve user IDs where possible because many records reference them.

### 3.5 Languages and presentation

- [ ] Installed content-language definitions
- [ ] Language codes used by content, menus, modules, categories, and extensions
- [ ] Multilingual associations
- [ ] Joomla 6-compatible template styles
- [ ] Template style parameters after the target template is installed

### 3.6 Custom extension data

For every custom component, module, or plugin:

- [ ] Identify all owned tables.
- [ ] Record primary keys.
- [ ] Record logical foreign keys.
- [ ] Identify user, category, article, menu, module, and extension references.
- [ ] Document enum and status mappings.
- [ ] Validate JSON or serialized columns.
- [ ] Identify related media files.
- [ ] Identify external service IDs.
- [ ] Create install SQL for the Joomla 6 schema.
- [ ] Create update or transformation scripts.
- [ ] Test rollback and rerun safety.

### 3.7 Third-party extension data

For every third-party extension family:

- [ ] Confirm a Joomla 6-compatible release exists.
- [ ] Obtain the official installation package.
- [ ] Review the vendor-supported upgrade path.
- [ ] Install the target extension before importing business data.
- [ ] Let the extension create its own schema and `#__extensions` records.
- [ ] Run vendor migration or update scripts.
- [ ] Migrate only documented business tables.
- [ ] Validate plugins, modules, menus, cron jobs, and integrations.
- [ ] Replace the extension when no supported Joomla 6 version exists.

## 4. Data that should not be copied directly

| Table or group | Recommended action | Reason |
|---|---|---|
| `#__session` | Recreate | Existing sessions are invalid and unsafe |
| `#__extensions` | Reinstall extensions | Registry structure, IDs, manifests, and core records differ |
| `#__schemas` | Let installers and update scripts create it | Must represent the actual installed schema version |
| `#__updates` | Recreate | Generated update-discovery data |
| `#__update_sites` | Recreate during installation | URLs and extension mappings may change |
| `#__update_sites_extensions` | Recreate | Depends on new extension IDs |
| `#__finder_*` index data | Rebuild | Search indexes are generated data |
| Cache data | Rebuild | Temporary data |
| Core administrator menu | Keep Joomla 6 defaults | Administrator structure changed |
| Core administrator modules | Keep Joomla 6 defaults | Dashboard and module types changed |
| Password reset tokens | Do not migrate | Security risk and compatibility concern |
| Remember-me/session keys | Do not migrate | Temporary authentication data |
| Joomla 3 core extension rows | Keep Joomla 6 records | Target installation owns them |
| Post-install messages | Recreate | Version-specific generated data |
| Old action logs | Optional | Usually not required for operation |
| Old privacy requests | Migrate only when legally required | Sensitive data and retention obligations |

## 5. Required mapping tables

### 5.1 ID mapping

| Entity | Joomla 3 ID | Joomla 6 ID | Preserve ID? | Used by |
|---|---:|---:|---|---|
| User |  |  | Prefer yes | Articles, ACL, extensions |
| Category |  |  | Prefer yes | Articles, contacts, menus |
| Article |  |  | Project decision | Tags, fields, history |
| Menu item |  |  | Optional | Modules and routing |
| Module |  |  | Optional | Menu assignment |
| Extension |  |  | No | Menu component IDs and configs |
| Template style |  |  | Usually no | Menu style assignment |
| View access level |  |  | Prefer controlled mapping | Content visibility |
| ACL asset |  |  | Usually rebuild or remap | Permissions |

### 5.2 Column transformation mapping

| Source | Target | Transformation | Validation |
|---|---|---|---|
| `j3_content.id` | `j6_content.id` | Preserve or map | Unique and referenced |
| `j3_content.state` | Joomla 6 state/workflow stage | Map status | Counts by state |
| `j3_content.catid` | `j6_content.catid` | Category ID map | Category exists |
| `j3_menu.component_id` | `j6_menu.component_id` | Extension ID map | Component installed |
| `j3_menu.template_style_id` | Joomla 6 style ID | Template style map | Style exists |
| `j3_modules.position` | Joomla 6 position | Position map | Rendered correctly |

## 6. Database migration checklist

### Phase 1 — Source inventory

- [ ] Record Joomla version.
- [ ] Record PHP version.
- [ ] Record MySQL or MariaDB version.
- [ ] Record database charset and collation.
- [ ] Export the complete table list.
- [ ] Classify every table as `Core`, `Custom`, `Third-party`, or `Temporary`.
- [ ] Identify the owner extension for every custom and vendor table.
- [ ] Mark whether each table is in use.
- [ ] Record row counts.
- [ ] Record table size.
- [ ] Record primary keys and indexes.
- [ ] Record logical foreign keys.
- [ ] Find database views, triggers, procedures, and events.
- [ ] Identify external databases and APIs.
- [ ] Document data-retention requirements.

### Phase 2 — Data quality audit

- [ ] Find invalid or zero datetime values.
- [ ] Find invalid JSON values.
- [ ] Find duplicate aliases and paths.
- [ ] Find orphan articles and categories.
- [ ] Find orphan menu and module assignments.
- [ ] Find orphan user-group mappings.
- [ ] Find invalid access-level references.
- [ ] Find invalid language codes.
- [ ] Check category nested-set integrity.
- [ ] Check menu nested-set integrity.
- [ ] Check tag nested-set integrity.
- [ ] Check user-group nested-set integrity.
- [ ] Check ACL asset-tree integrity.
- [ ] Remove unnecessary trashed or expired data after approval.

### Phase 3 — Target schema preparation

- [ ] Install a clean Joomla 6 environment or complete the sequential core upgrade.
- [ ] Confirm the Joomla 6 database schema passes the built-in database check.
- [ ] Install the Joomla 6-compatible template.
- [ ] Install all approved custom extensions.
- [ ] Install all approved third-party extensions.
- [ ] Confirm each extension creates its own tables.
- [ ] Confirm extension schema versions in `#__schemas`.
- [ ] Record new extension IDs.
- [ ] Record new template style IDs.
- [ ] Record new access-level IDs.
- [ ] Prepare data-transformation scripts.

### Phase 4 — Data migration

- [ ] Disable scheduled jobs, outgoing email, webhooks, and external side effects.
- [ ] Migrate language definitions.
- [ ] Migrate users.
- [ ] Migrate user groups and mappings.
- [ ] Migrate view access levels.
- [ ] Migrate categories.
- [ ] Migrate articles.
- [ ] Create Joomla 6 workflow associations.
- [ ] Migrate featured-article mappings.
- [ ] Migrate tags and tag mappings.
- [ ] Migrate custom fields and values.
- [ ] Migrate frontend menus.
- [ ] Remap component IDs.
- [ ] Migrate template styles when compatible.
- [ ] Migrate in-use modules.
- [ ] Remap module positions.
- [ ] Migrate module-menu assignments.
- [ ] Migrate contacts, banners, and newsfeeds when used.
- [ ] Migrate custom extension business data.
- [ ] Migrate third-party extension business data using vendor guidance.
- [ ] Migrate required media and document files.

### Phase 5 — Rebuild generated structures

- [ ] Rebuild category trees.
- [ ] Rebuild menu trees.
- [ ] Rebuild tag trees.
- [ ] Repair or rebuild ACL assets.
- [ ] Clear Joomla cache.
- [ ] Clear PHP opcode cache when relevant.
- [ ] Re-index Smart Search.
- [ ] Run Joomla database schema check and repair.
- [ ] Discover extensions when needed.
- [ ] Rebuild extension autoload information when applicable.
- [ ] Re-save global configuration.
- [ ] Re-save component options with changed schemas.
- [ ] Recreate scheduled tasks.

### Phase 6 — Cutover preparation

- [ ] Complete at least one full migration rehearsal.
- [ ] Measure migration duration.
- [ ] Freeze source content before final export.
- [ ] Create final source backup.
- [ ] Run the final data delta migration when required.
- [ ] Re-enable email, webhooks, and scheduled jobs only after validation.
- [ ] Keep a documented rollback procedure.

## 7. Recommended migration order

```text
Languages
→ Users
→ User groups and mappings
→ View access levels
→ Categories
→ Articles
→ Workflow associations
→ Featured articles
→ Tags
→ Custom fields
→ Frontend menus
→ Template styles
→ Modules
→ Module-menu assignments
→ Contacts, banners, and newsfeeds
→ Custom extension data
→ Third-party extension data
→ ACL repair
→ Search re-index
→ Final validation
```

Dependencies must be respected. For example, importing articles before categories or users can create broken references.

## 8. Validation checklist

### 8.1 Database reconciliation

- [ ] Compare total row counts for all migrated tables.
- [ ] Compare published, unpublished, archived, and trashed article counts.
- [ ] Compare category counts by extension.
- [ ] Compare users by enabled and blocked state.
- [ ] Compare user-group mappings.
- [ ] Compare frontend menu-item counts.
- [ ] Compare in-use module counts.
- [ ] Compare custom and third-party business record counts.
- [ ] Confirm no unexpected orphan records remain.
- [ ] Confirm important IDs are preserved or correctly mapped.
- [ ] Confirm all required JSON fields are valid.
- [ ] Confirm no invalid dates remain.

### 8.2 Functional validation

- [ ] Administrator login works.
- [ ] Frontend login works.
- [ ] Password reset works.
- [ ] Each user role has the correct permissions.
- [ ] Homepage renders correctly.
- [ ] Menus generate the expected URLs.
- [ ] Legacy URLs redirect correctly.
- [ ] Articles display correctly.
- [ ] Categories and blog layouts display correctly.
- [ ] Tags and custom fields display correctly.
- [ ] Modules appear on the correct pages.
- [ ] Multilingual switching works.
- [ ] Search returns expected content.
- [ ] Forms submit successfully.
- [ ] Email templates send correctly.
- [ ] Scheduled tasks run correctly.
- [ ] Custom extensions complete their key workflows.
- [ ] Third-party extensions complete their key workflows.
- [ ] External API and webhook integrations work.
- [ ] Media, images, and downloads are accessible.
- [ ] Application and PHP logs contain no unresolved migration errors.

### 8.3 Security validation

- [ ] Old sessions and temporary tokens were not imported.
- [ ] Super User accounts were reviewed.
- [ ] Disabled or obsolete accounts were reviewed.
- [ ] API login permissions were reviewed.
- [ ] MFA and WebAuthn enrollment strategy was defined.
- [ ] Extension permissions were reviewed.
- [ ] Sensitive configuration was not committed to source control.
- [ ] Database credentials were rotated when required.

## 9. Migration report templates

### 9.1 Table inventory

| Table | Owner | Classification | In Use | Migrate | Method | Risk | Notes |
|---|---|---|---|---|---|---|---|
| `#__content` | Joomla Core | Content | Yes | Yes | Core upgrade or ETL | High | Preserve author and category references |
| `#__session` | Joomla Core | Temporary | Yes | No | Recreate | Low | Do not import active sessions |
| `#__vendor_*` | Vendor | Third-party | TBD | Conditional | Vendor migration | High | Verify Joomla 6 support |
| `#__custom_*` | Internal | Custom | Yes | Yes | Custom script | High | Document schema and dependencies |

### 9.2 Reconciliation report

| Entity | Joomla 3 | Joomla 6 | Difference | Expected? | Status | Notes |
|---|---:|---:|---:|---|---|---|
| Published articles |  |  |  |  |  |  |
| Categories |  |  |  |  |  |  |
| Enabled users |  |  |  |  |  |  |
| Frontend menu items |  |  |  |  |  |  |
| In-use modules |  |  |  |  |  |  |
| Custom business records |  |  |  |  |  |  |

### 9.3 Migration decision summary

| Area | Decision | Reason | Owner | Status |
|---|---|---|---|---|
| Joomla core database | Sequential upgrade | Use official schema migration scripts |  |  |
| Custom extensions | Rebuild and migrate data | Joomla 3 code is not directly compatible |  |  |
| Third-party extensions | Install compatible release first | Vendor owns schema migration |  |  |
| Smart Search | Re-index | Generated data should not be copied |  |  |
| Sessions and tokens | Do not migrate | Security and compatibility risk |  |  |

---

## Final rule

Database migration from Joomla 3 to Joomla 6 is not a full database copy. It is a controlled process:

```text
Inventory
→ classify ownership
→ prepare Joomla 6 schemas
→ transform business data
→ remap relationships
→ rebuild generated data
→ reconcile counts
→ run functional and security tests
```
