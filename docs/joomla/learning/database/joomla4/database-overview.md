# Joomla 4 Database Overview

A practical map of the Joomla 4 core database, based on the final Joomla 4 release line and organized to match the Joomla 3 database documentation in this repository.

> **Schema baseline:** Joomla **4.4.14**. Exact columns can differ in earlier 4.x releases, so always compare the real database with the installation/update SQL before migration.

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Documentation Map](#2-documentation-map)
- [3. Source Baseline](#3-source-baseline)
- [4. Database Prefix](#4-database-prefix)
- [5. Core Table Groups](#5-core-table-groups)
- [6. Major Changes from Joomla 3](#6-major-changes-from-joomla-3)
- [7. Logical Relationships](#7-logical-relationships)
- [8. Tree-Based Tables](#8-tree-based-tables)
- [9. JSON and Embedded Relationships](#9-json-and-embedded-relationships)
- [10. Migration Guidance](#10-migration-guidance)
- [11. Validation Checklist](#11-validation-checklist)

## 1. Purpose

This documentation helps developers:

- understand the main Joomla 4 core tables;
- identify application-level relationships that are not enforced as MySQL foreign keys;
- locate content, workflow, menu, module, user, ACL, extension, automation, search, privacy, and system data;
- prepare a Joomla 4 to Joomla 5/6 migration;
- decide which tables contain business data and which should normally be rebuilt.

Joomla relies heavily on logical relationships maintained by application code. A valid migration therefore requires more than matching table names.

## 2. Documentation Map

| Document | Scope |
|---|---|
| [Content Tables](./content-tables.md) | Articles, categories, featured content, tags, custom fields, associations, UCM/history, workflows, contacts, newsfeeds, banners |
| [Menu and Module Tables](./menu-module-tables.md) | Menu types, menu items, modules, assignments, template styles, routing and publication scheduling |
| [User and ACL Tables](./user-acl-tables.md) | Users, groups, view levels, assets, profiles, notes, MFA, WebAuthn, persistent keys, sessions |
| [Extension and System Tables](./extension-system-tables.md) | Extensions, updates, action logs, privacy, mail templates, scheduler, guided tours, Finder, redirects and other system data |
| [Complete ERD](./complete-erd.md) | Logical Mermaid ERDs for the main Joomla 4 database areas |

## 3. Source Baseline

The physical schema documented here is checked against Joomla 4.4.14 installation SQL:

- `installation/sql/mysql/base.sql`
- `installation/sql/mysql/extensions.sql`
- `installation/sql/mysql/supports.sql`

Official source tree:

`https://github.com/joomla/joomla-cms/tree/4.4.14/installation/sql/mysql`

For a real site, also inspect:

```sql
SHOW TABLES;
SHOW CREATE TABLE `yourprefix_content`;
SHOW CREATE TABLE `yourprefix_users`;
```

Installation SQL is the baseline; update SQL and installed extensions can alter a live schema.

## 4. Database Prefix

Joomla uses a configurable database prefix. Core SQL uses `#__` as the placeholder.

```sql
SELECT * FROM `#__content`;
```

With a real prefix such as `abc_`, Joomla resolves it to `abc_content`.

The configured prefix is stored in `configuration.php`:

```php
public $dbprefix = 'abc_';
```

Never hard-code a production prefix in reusable migration scripts.

## 5. Core Table Groups

```text
Joomla 4 Database
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
│   └── #__history
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

## 6. Major Changes from Joomla 3

Important Joomla 4 database concepts include:

| Area | Joomla 4 impact |
|---|---|
| Content Workflow | Articles can be associated with workflow stages through `#__workflow_*` tables |
| Featured scheduling | `#__content_frontpage` stores `featured_up` and `featured_down` |
| Authentication | Core schema includes `#__user_mfa`; WebAuthn credentials are stored separately |
| Mail customization | `#__mail_templates` stores editable mail template content and parameters |
| Scheduled Tasks | `#__scheduler_tasks` stores task definitions and execution state |
| Audit | `#__action_logs*` records selected user/admin actions |
| Privacy | `#__privacy_requests` and `#__privacy_consents` support privacy workflows |
| Guided Tours | `#__guidedtours` and `#__guidedtour_steps` store administrator tours |
| Content history | Core history is represented by `#__history`; do not assume old Joomla 3 history payloads are directly portable |
| Extensions | `#__extensions` includes version-sensitive system metadata such as locked/protected state and manifest data |

These differences are why direct table-copy migration from Joomla 3 is unsafe even when a table name is unchanged.

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
#__content.id                → #__workflow_associations.item_id (for com_content.article)
#__menu_types.menutype       → #__menu.menutype
#__extensions.extension_id   → #__menu.component_id
#__modules.id                → #__modules_menu.moduleid
#__menu.id                   → #__modules_menu.menuid
#__users.id                  → #__user_usergroup_map.user_id
#__usergroups.id             → #__user_usergroup_map.group_id
```

The workflow association is context-sensitive: use its `extension` value before treating `item_id` as an article ID.

## 8. Tree-Based Tables

The main nested-set trees are:

```text
#__assets
#__categories
#__menu
#__usergroups
#__tags
#__finder_taxonomy
```

Typical columns include `parent_id`, `lft`, `rgt`, `level`, and sometimes `path`.

Do not validate only `parent_id`. Corrupt `lft`/`rgt` values can break inheritance, ordering, routing, ACL evaluation, or administrator tree views.

## 9. JSON and Embedded Relationships

Common JSON/text configuration columns include:

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
```

IDs can be embedded in:

- menu `link` values;
- menu/module/template `params`;
- access rules and view-level rules;
- category workflow configuration;
- workflow transition `options`;
- UCM/content-type mappings;
- scheduler execution rules.

Migration code must decode, validate, remap, and re-encode these values rather than treating them as opaque strings.

## 10. Migration Guidance

Recommended dependency order when moving Joomla 4 business data into a newer Joomla installation:

```text
1. Inventory exact source version, tables and extensions
2. Install compatible target extensions
3. Map users, groups and view levels
4. Migrate categories and rebuild category trees
5. Migrate articles and related content
6. Migrate tags, custom fields and associations
7. Recreate/map workflows, stages and transitions
8. Map content to target workflow stages
9. Migrate menu types and menu items
10. Migrate modules and menu assignments
11. Rebuild/validate ACL assets
12. Rebuild Finder indexes and runtime caches
13. Recreate scheduler/security runtime state where required
14. Run DB, backend, frontend, routing and permission verification
```

Normally **do not copy** these tables wholesale between installations:

```text
#__assets
#__extensions
#__schemas
#__updates
#__update_sites
#__session
#__user_keys
#__user_mfa
#__webauthn_credentials
#__finder_tokens*
#__finder_links_terms
```

Use an explicit requirement before migrating audit logs, privacy requests, post-install messages, or scheduler state.

## 11. Validation Checklist

- [ ] Confirm the exact Joomla 4 minor version.
- [ ] Compare the live schema with Joomla 4.4.14 installation/update SQL.
- [ ] Inventory 100% of core and third-party tables.
- [ ] Inventory columns, indexes, row counts and table engines.
- [ ] Build source-to-target ID maps for users, groups, categories, content, tags, fields, menus, modules, assets and workflows.
- [ ] Validate category, menu, tag, user-group, asset and Finder taxonomy trees.
- [ ] Validate JSON/text configuration and embedded IDs.
- [ ] Validate featured scheduling and publication dates.
- [ ] Validate workflow associations and transition permissions.
- [ ] Exclude or deliberately recreate sessions, persistent auth keys, MFA/WebAuthn credentials and generated Finder data.
- [ ] Validate menu routing and positive/negative module assignments.
- [ ] Verify Super User access before cutover.
- [ ] Test backend save operations, frontend output, SEF URLs, access levels, languages, mail templates and scheduled tasks.

[Back to Database Documentation](../)