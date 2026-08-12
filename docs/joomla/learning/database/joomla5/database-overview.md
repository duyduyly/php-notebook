# Joomla 5 Database Overview

A practical map of the Joomla 5 core database, organized to match the Joomla 3 and Joomla 4 documentation in this repository.

> **Schema baseline:** Joomla **5.4.7**. Exact columns can differ in earlier 5.x releases, so always compare the live database with the installation/update SQL before migration.

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Documentation Map](#2-documentation-map)
- [3. Source Baseline](#3-source-baseline)
- [4. Database Prefix](#4-database-prefix)
- [5. Core Table Groups](#5-core-table-groups)
- [6. Joomla 5 vs Joomla 4 Database Notes](#6-joomla-5-vs-joomla-4-database-notes)
- [7. Logical Relationships](#7-logical-relationships)
- [8. Tree-Based Tables](#8-tree-based-tables)
- [9. JSON and Embedded Relationships](#9-json-and-embedded-relationships)
- [10. Migration Guidance](#10-migration-guidance)
- [11. Validation Checklist](#11-validation-checklist)

## 1. Purpose

This documentation helps developers:

- understand the main Joomla 5 core tables;
- locate content, workflow, structured data, menus, modules, users, ACL, extensions, scheduled tasks, audit/privacy records and generated search data;
- distinguish persistent business/configuration data from runtime/rebuildable data;
- prepare a Joomla 5.4 to Joomla 6 migration;
- avoid assuming that unchanged table names imply unchanged schemas.

Joomla still relies heavily on application-level relationships and IDs embedded in JSON/text fields. Physical foreign keys alone cannot describe the full migration graph.

## 2. Documentation Map

| Document | Scope |
|---|---|
| [Content Tables](./content-tables.md) | Articles, categories, featured scheduling, workflows, tags, fields, multilingual associations, UCM/history, Schema.org, contacts, newsfeeds, banners |
| [Menu and Module Tables](./menu-module-tables.md) | Menu types, menu items, modules, assignments, template styles/overrides and routing-sensitive values |
| [User and ACL Tables](./user-acl-tables.md) | Users, groups, view levels, assets, profiles, notes, MFA, WebAuthn, persistent keys and sessions |
| [Extension and System Tables](./extension-system-tables.md) | Extensions, updates, scheduler/tasks/logs, action logs, privacy, mail templates, Finder, guided tours, redirects and system metadata |
| [Complete ERD](./complete-erd.md) | Logical Mermaid ERDs for the main Joomla 5 database areas |

## 3. Source Baseline

The physical schema documented here is checked against Joomla 5.4.7 installation SQL:

- `installation/sql/mysql/base.sql`
- `installation/sql/mysql/extensions.sql`
- `installation/sql/mysql/supports.sql`

Official source tree:

`https://github.com/joomla/joomla-cms/tree/5.4.7/installation/sql/mysql`

Always verify a real site with commands such as:

```sql
SHOW TABLES;
SHOW CREATE TABLE `yourprefix_content`;
SHOW CREATE TABLE `yourprefix_scheduler_tasks`;
SHOW CREATE TABLE `yourprefix_schemaorg`;
```

Also inspect `administrator/components/com_admin/sql/updates/mysql/` for version-to-version schema changes.

## 4. Database Prefix

Reusable Joomla SQL uses `#__` as the prefix placeholder.

```sql
SELECT * FROM `#__content`;
```

With `public $dbprefix = 'abc_';`, the real table is `abc_content`.

Never hard-code a production prefix in portable inventory or migration scripts.

## 5. Core Table Groups

```text
Joomla 5 Database
├── Content and Metadata
│   ├── #__content
│   ├── #__categories
│   ├── #__content_frontpage
│   ├── #__content_rating
│   ├── #__tags
│   ├── #__contentitem_tag_map
│   ├── #__fields
│   ├── #__fields_groups
│   ├── #__fields_categories
│   ├── #__fields_values
│   ├── #__associations
│   ├── #__content_types
│   ├── #__ucm_base
│   ├── #__ucm_content
│   ├── #__history
│   └── #__schemaorg
├── Workflow
│   ├── #__workflows
│   ├── #__workflow_stages
│   ├── #__workflow_transitions
│   └── #__workflow_associations
├── Navigation and Presentation
│   ├── #__menu_types
│   ├── #__menu
│   ├── #__modules
│   ├── #__modules_menu
│   ├── #__template_styles
│   └── #__template_overrides
├── Users, Authentication and ACL
│   ├── #__users
│   ├── #__usergroups
│   ├── #__user_usergroup_map
│   ├── #__viewlevels
│   ├── #__assets
│   ├── #__user_profiles
│   ├── #__user_notes
│   ├── #__user_keys
│   ├── #__user_mfa
│   ├── #__webauthn_credentials
│   └── #__session
├── Extensions and Updates
│   ├── #__extensions
│   ├── #__schemas
│   ├── #__update_sites
│   ├── #__update_sites_extensions
│   ├── #__updates
│   └── #__languages
├── Automation, Audit and Privacy
│   ├── #__scheduler_tasks
│   ├── #__scheduler_logs
│   ├── #__action_logs
│   ├── #__action_logs_extensions
│   ├── #__action_log_config
│   ├── #__action_logs_users
│   ├── #__privacy_requests
│   ├── #__privacy_consents
│   └── #__mail_templates
└── Supporting Components
    ├── #__contact_details
    ├── #__newsfeeds
    ├── #__banners / #__banner_clients / #__banner_tracks
    ├── #__redirect_links
    ├── #__messages / #__messages_cfg
    ├── #__finder_*
    ├── #__guidedtours / #__guidedtour_steps
    ├── #__overrider
    └── #__postinstall_messages
```

## 6. Joomla 5 vs Joomla 4 Database Notes

Joomla 5 preserves the major Joomla 4 database architecture, but it is not schema-identical.

Important verified Joomla 5.4 differences/additions include:

| Area | Joomla 5.4 note |
|---|---|
| Scheduler history | `#__scheduler_logs` stores scheduled-task execution history |
| Structured data | `#__schemaorg` stores per-item Schema.org structured-data configuration |
| Scheduler assets | Core scheduled tasks have ACL assets and task records that are integrated more visibly into the core asset tree |
| Menu types | Joomla 5.4 `#__menu_types` includes `asset_id`, `client_id`, and `ordering` in addition to menu identity/title metadata |
| Schema evolution | Minor Joomla 5 releases add/alter columns/indexes; use 5.4.7 SQL as baseline instead of copying a Joomla 4 schema definition |

Tables such as workflows, MFA, WebAuthn, mail templates, guided tours, action logs and privacy tables are inherited concepts from Joomla 4 and remain relevant.

## 7. Logical Relationships

```text
#__categories.id             → #__content.catid
#__assets.id                 → #__content.asset_id
#__users.id                  → #__content.created_by / modified_by
#__viewlevels.id             → #__content.access
#__content.id                → #__content_frontpage.content_id
#__workflows.id              → #__workflow_stages.workflow_id
#__workflows.id              → #__workflow_transitions.workflow_id
#__workflow_stages.id        → #__workflow_associations.stage_id
#__content.id                → #__workflow_associations.item_id (article context)
#__content.id                → #__schemaorg.itemId (when context identifies article content)
#__menu_types.menutype       → #__menu.menutype
#__extensions.extension_id   → #__menu.component_id
#__modules.id                → #__modules_menu.moduleid
#__menu.id                   → #__modules_menu.menuid
#__scheduler_tasks.id        → #__scheduler_logs.taskid
#__users.id                  → #__user_usergroup_map.user_id
#__usergroups.id             → #__user_usergroup_map.group_id
```

`#__schemaorg.itemId` is context-dependent. Resolve the `context` column before treating it as a foreign key to a specific component table.

## 8. Tree-Based Tables

Main nested-set/hierarchical tables include:

```text
#__assets
#__categories
#__menu
#__usergroups
#__tags
#__finder_taxonomy
```

Validate `parent_id`, `lft`, `rgt`, `level`, and `path` where present.

Joomla 5's asset tree also contains ACL objects for workflows, stages, transitions, modules, menus and scheduled tasks. A migration that changes IDs without rebuilding related assets can leave permissions inconsistent.

## 9. JSON and Embedded Relationships

Important JSON/text configuration fields include:

```text
params
attribs
metadata
images
urls
rules
manifest_cache
custom_data
options
execution_rules
cron_rules
schema
```

Embedded relationships occur in:

- menu `link` and `params`;
- module/template configuration;
- `#__viewlevels.rules` and `#__assets.rules`;
- category workflow selection;
- workflow transition `options`;
- UCM/content-type mapping JSON;
- scheduler rules/params;
- Schema.org `schema` payloads.

Treat these values as structured data during migration.

## 10. Migration Guidance

For Joomla 5 to Joomla 6, use a controlled version-aware migration/upgrade process. Before a major-version move, bring the Joomla 5 site to a supported 5.4.x baseline and validate extension compatibility.

Recommended database dependency order:

```text
1. Inventory exact Joomla 5 version, tables, columns and extensions
2. Back up source and target
3. Install compatible target extensions/plugins
4. Map users, groups and view levels
5. Migrate categories and canonical content
6. Migrate fields, tags, associations and structured data
7. Recreate/map workflows, stages and transitions
8. Map workflow associations
9. Migrate menu types/menu items
10. Migrate modules and assignments
11. Rebuild/validate ACL assets
12. Migrate selected mail/redirect/privacy/scheduler configuration
13. Reset runtime scheduler state and rebuild Finder indexes
14. Verify database, backend, frontend, routing, ACL, workflow and scheduled tasks
```

Normally do not bulk-copy:

```text
#__extensions
#__schemas
#__updates
#__session
#__user_keys
#__user_mfa
#__webauthn_credentials
#__finder_tokens*
#__finder_links_terms
stale scheduler locks/execution state
```

`#__scheduler_logs` is historical execution data; preserve it only if required for operations/audit history.

## 11. Validation Checklist

- [ ] Confirm exact source version; do not label an unknown 5.x database as 5.4.7.
- [ ] Compare `SHOW CREATE TABLE` output with Joomla 5.4.7 installation/update SQL.
- [ ] Inventory 100% of tables and columns, including third-party/custom tables.
- [ ] Capture row counts, indexes, engines and collations.
- [ ] Build source-to-target ID maps for all business and ACL entities.
- [ ] Validate category/menu/tag/user-group/asset/Finder taxonomy trees.
- [ ] Validate workflow definitions, associations and transition permissions.
- [ ] Validate `#__schemaorg` context + item mappings.
- [ ] Validate featured and menu publication windows.
- [ ] Validate JSON/configuration payloads after remapping.
- [ ] Rebuild Finder generated indexes.
- [ ] Reset/recalculate scheduler locks and next-run state; validate task plugins.
- [ ] Decide whether scheduler logs, action logs and privacy records are historical scope.
- [ ] Do not migrate sessions or authentication secrets blindly.
- [ ] Verify a Super User login and critical backend save operations.
- [ ] Test frontend routing, access, languages, mail templates, structured data and scheduled tasks.

[Back to Database Documentation](../)