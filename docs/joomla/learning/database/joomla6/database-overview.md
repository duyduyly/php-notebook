# Joomla 6 Database Overview

A practical map of the Joomla 6 core database for development, troubleshooting, and Joomla 3 to Joomla 6 migration work.

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Source of Truth](#2-source-of-truth)
- [3. Documentation Map](#3-documentation-map)
- [4. Database Prefix](#4-database-prefix)
- [5. Core Table Groups](#5-core-table-groups)
- [6. Important Architectural Concepts](#6-important-architectural-concepts)
- [7. Joomla 3 to Joomla 6 Mapping](#7-joomla-3-to-joomla-6-mapping)
- [8. Tables Not to Copy Directly](#8-tables-not-to-copy-directly)
- [9. Recommended Migration Order](#9-recommended-migration-order)
- [10. Validation Checklist](#10-validation-checklist)

## 1. Purpose

This documentation helps developers:

- understand the main Joomla 6 core tables;
- understand logical relationships not always enforced by foreign keys;
- identify workflow, ACL, menu, module, user, extension, scheduler, and system dependencies;
- prepare safe source-to-target mappings from Joomla 3;
- avoid overwriting version-owned system records.

## 2. Source of Truth

The final source of truth is the Joomla installation SQL for the exact version being used:

```text
installation/sql/mysql/base.sql
administrator/components/com_admin/sql/updates/mysql/
```

Use the installed project files when they differ from this guide.

## 3. Documentation Map

| Document | Scope |
|---|---|
| [Content and Workflow Tables](./content-workflow-tables.md) | Articles, categories, tags, fields, associations, history, and workflows |
| [Menu and Module Tables](./menu-module-tables.md) | Menu types, menu items, modules, assignments, and template styles |
| [User and ACL Tables](./user-acl-tables.md) | Users, groups, view levels, assets, MFA, profiles, tokens, and sessions |
| [Extension and System Tables](./extension-system-tables.md) | Extensions, updates, scheduler, logs, privacy, search, mail, and system data |
| [Complete ERD](./complete-erd.md) | Mermaid diagrams and migration flows |

## 4. Database Prefix

Joomla SQL uses `#__` as a placeholder:

```sql
SELECT * FROM `#__content`;
```

Joomla replaces it with the configured prefix from `configuration.php`:

```php
public $dbprefix = 'abc_';
```

## 5. Core Table Groups

```text
Joomla 6 Database
├── Content and Workflow
│   ├── #__content
│   ├── #__categories
│   ├── #__content_frontpage
│   ├── #__workflows
│   ├── #__workflow_stages
│   ├── #__workflow_transitions
│   └── #__workflow_associations
├── Tags and Fields
│   ├── #__tags
│   ├── #__contentitem_tag_map
│   ├── #__fields_groups
│   ├── #__fields
│   ├── #__fields_values
│   └── #__fields_categories
├── Menus and Modules
│   ├── #__menu_types
│   ├── #__menu
│   ├── #__modules
│   ├── #__modules_menu
│   └── #__template_styles
├── Users and ACL
│   ├── #__users
│   ├── #__usergroups
│   ├── #__user_usergroup_map
│   ├── #__viewlevels
│   ├── #__assets
│   ├── #__user_profiles
│   ├── #__user_notes
│   ├── #__user_keys
│   └── #__user_mfa
├── Extensions and Updates
│   ├── #__extensions
│   ├── #__schemas
│   ├── #__update_sites
│   ├── #__update_sites_extensions
│   └── #__updates
├── Scheduler and Logging
│   ├── #__scheduler_tasks
│   ├── #__scheduler_log
│   ├── #__action_logs
│   ├── #__action_logs_extensions
│   └── #__action_log_config
├── Privacy and Mail
│   ├── #__privacy_requests
│   ├── #__privacy_consents
│   ├── #__mail_templates
│   └── #__messages
├── Search and Language
│   ├── #__finder_*
│   ├── #__languages
│   └── #__associations
└── Runtime and System
    ├── #__session
    ├── #__redirect_links
    ├── #__postinstall_messages
    └── #__guidedtours / #__guidedtour_steps
```

## 6. Important Architectural Concepts

### Logical relationships

Joomla application code uses many relationships even when MySQL has no explicit foreign-key constraint.

```text
#__content.catid      → #__categories.id
#__content.asset_id   → #__assets.id
#__menu.component_id  → #__extensions.extension_id
```

### Nested-set trees

These tables use tree columns such as `parent_id`, `lft`, `rgt`, `level`, and sometimes `path`:

```text
#__assets
#__categories
#__menu
#__usergroups
#__tags
```

### JSON configuration

Common JSON fields include:

```text
params
metadata
images
urls
attribs
rules
manifest_cache
custom_data
```

Validate JSON shape against Joomla 6 expectations before insertion.

### Workflow

Joomla 6 content state can be connected to workflow stages and transitions. Migrating an article record alone may be insufficient when workflows are active.

## 7. Joomla 3 to Joomla 6 Mapping

| Joomla 3 | Joomla 6 | Handling |
|---|---|---|
| `#__content` | `#__content` | Transform and map IDs |
| `#__categories` | `#__categories` | Rebuild or validate tree |
| `#__menu_types` | `#__menu_types` | Usually migratable |
| `#__menu` | `#__menu` | Rewrite component and content IDs |
| `#__modules` | `#__modules` | Only after module code exists |
| `#__modules_menu` | `#__modules_menu` | Map module and menu IDs |
| `#__users` | `#__users` | Validate passwords and MFA policy |
| `#__viewlevels` | `#__viewlevels` | Remap group IDs in JSON |
| no equivalent requirement | workflow tables | Create valid Joomla 6 workflow associations |

## 8. Tables Not to Copy Directly

```text
#__assets
#__extensions
#__schemas
#__updates
#__update_sites
#__update_sites_extensions
#__session
#__finder_*
#__scheduler_tasks
#__scheduler_log
#__action_logs
#__privacy_*
#__user_mfa
```

These tables are version-owned, generated, security-sensitive, or installation-specific.

## 9. Recommended Migration Order

```text
1. Install Joomla 6 and compatible extensions
2. Prepare ID mapping tables
3. Migrate categories
4. Migrate articles
5. Create workflow associations
6. Migrate tags and custom fields
7. Migrate menu types and menu items
8. Migrate modules and assignments
9. Migrate selected users and groups
10. Rebuild ACL assets, trees, and search indexes
11. Validate frontend and backend behavior
```

## 10. Validation Checklist

- [ ] Target Joomla 6 database is fresh and healthy.
- [ ] Exact Joomla version schema was inspected.
- [ ] Compatible extension code is installed first.
- [ ] All source and target IDs are mapped.
- [ ] Nested-set trees are valid.
- [ ] Menu links contain target article/category IDs.
- [ ] Modules reference valid template positions.
- [ ] Workflow associations exist where required.
- [ ] ACL assets and view levels behave correctly.
- [ ] JSON fields are valid.
- [ ] Sessions, logs, search indexes, and update cache were not copied.
- [ ] Backend editing, routing, permissions, header, footer, and multilingual behavior were tested.
