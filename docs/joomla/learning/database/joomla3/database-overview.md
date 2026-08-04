# Joomla 3 Database Overview

A concise map of the Joomla 3 core database and the recommended reading order for the detailed documents in this folder.

## Table of Contents

- [1. Purpose](#1-purpose)
- [2. Documentation Map](#2-documentation-map)
- [3. Database Prefix](#3-database-prefix)
- [4. Core Table Groups](#4-core-table-groups)
- [5. Logical Relationships](#5-logical-relationships)
- [6. Tree-Based Tables](#6-tree-based-tables)
- [7. JSON and Serialized Configuration](#7-json-and-serialized-configuration)
- [8. Migration Guidance](#8-migration-guidance)
- [9. Validation Checklist](#9-validation-checklist)

## 1. Purpose

This documentation helps developers:

- understand the main Joomla 3 core tables;
- identify the logical relationships used by Joomla code;
- locate content, menu, module, user, ACL, extension, and system data;
- prepare a Joomla 3 to Joomla 6 migration;
- avoid copying version-sensitive records without transformation.

Joomla does not enforce every relationship with a MySQL foreign key. Many relationships are application-level relationships maintained by Joomla code.

## 2. Documentation Map

| Document | Scope |
|---|---|
| [Content Tables](./content-tables.md) | Articles, categories, featured articles, tags, custom fields, associations, UCM, contacts, newsfeeds, and banners |
| [Menu and Module Tables](./menu-module-tables.md) | Menu containers, menu items, modules, menu assignments, template styles, and routing-sensitive values |
| [User and ACL Tables](./user-acl-tables.md) | Users, user groups, view levels, assets, profiles, notes, authentication keys, and sessions |
| [Extension and System Tables](./extension-system-tables.md) | Extensions, plugins, templates, updates, schemas, redirects, messages, Finder, and other system tables |
| [Complete ERD](./complete-erd.md) | Mermaid diagrams for the main Joomla 3 logical relationships |

## 3. Database Prefix

Joomla uses a configurable prefix. Documentation and extension SQL use `#__` as a placeholder.

```sql
SELECT *
FROM `#__content`;
```

For a real prefix such as `abc_`, Joomla resolves the query to:

```sql
SELECT *
FROM `abc_content`;
```

The prefix is stored in `configuration.php`:

```php
public $dbprefix = 'abc_';
```

Do not hard-code a production prefix in reusable SQL scripts.

## 4. Core Table Groups

```text
Joomla 3 Database
├── Content
│   ├── #__content
│   ├── #__categories
│   ├── #__content_frontpage
│   ├── #__tags
│   ├── #__contentitem_tag_map
│   ├── #__fields_groups
│   ├── #__fields
│   ├── #__fields_values
│   ├── #__associations
│   └── #__ucm_*
├── Navigation and Presentation
│   ├── #__menu_types
│   ├── #__menu
│   ├── #__modules
│   ├── #__modules_menu
│   └── #__template_styles
├── Users and Access Control
│   ├── #__users
│   ├── #__usergroups
│   ├── #__user_usergroup_map
│   ├── #__viewlevels
│   ├── #__assets
│   ├── #__user_profiles
│   ├── #__user_notes
│   └── #__session
├── Extensions and Updates
│   ├── #__extensions
│   ├── #__schemas
│   ├── #__update_sites
│   ├── #__update_sites_extensions
│   └── #__updates
└── Supporting Components
    ├── #__redirect_links
    ├── #__messages
    ├── #__finder_*
    ├── #__contact_details
    ├── #__newsfeeds
    └── #__banners*
```

## 5. Logical Relationships

The most important relationships are:

```text
#__categories.id          → #__content.catid
#__users.id               → #__content.created_by
#__assets.id              → #__content.asset_id
#__viewlevels.id          → #__content.access
#__menu_types.menutype    → #__menu.menutype
#__extensions.extension_id→ #__menu.component_id
#__modules.id             → #__modules_menu.moduleid
#__menu.id                → #__modules_menu.menuid
#__users.id               → #__user_usergroup_map.user_id
#__usergroups.id          → #__user_usergroup_map.group_id
```

These are logical relationships. A Joomla 3 database may not declare them as physical foreign-key constraints.

## 6. Tree-Based Tables

The following tables use nested-set tree columns:

```text
#__assets
#__categories
#__menu
#__usergroups
#__tags
```

Typical tree columns:

| Column | Meaning |
|---|---|
| `parent_id` | Direct parent record |
| `lft` | Left boundary in the nested-set tree |
| `rgt` | Right boundary in the nested-set tree |
| `level` | Depth below the root |
| `path` | Hierarchical alias path where supported |

A correct `parent_id` is not enough. Invalid `lft` or `rgt` values can break ordering, inheritance, routing, and backend tree views.

## 7. JSON and Serialized Configuration

Common configuration columns include:

```text
params
attribs
metadata
images
urls
rules
manifest_cache
```

Migration scripts should:

1. Decode the value.
2. Validate the expected structure.
3. Remap embedded IDs or paths.
4. Re-encode valid JSON.
5. Avoid copying obsolete options into Joomla 6 without checking compatibility.

## 8. Migration Guidance

Recommended migration order:

```text
1. Install compatible extensions in Joomla 6
2. Users and required user groups
3. Categories
4. Articles
5. Tags and custom fields
6. Menu types
7. Menu items
8. Modules
9. Module-menu assignments
10. Rebuild ACL assets and tree values
11. Validate routing, permissions, and frontend output
```

Do not directly overwrite these Joomla 6 tables without a verified transformation plan:

```text
#__assets
#__extensions
#__schemas
#__update_sites
#__updates
#__session
```

## 9. Validation Checklist

- [ ] Verify the source and target table prefixes.
- [ ] Back up both databases.
- [ ] Confirm the exact Joomla 3 minor version.
- [ ] Identify all third-party and custom tables.
- [ ] Build source-to-target ID maps.
- [ ] Validate nested-set trees.
- [ ] Validate JSON fields.
- [ ] Rewrite menu links containing content IDs.
- [ ] Rebuild or validate ACL assets.
- [ ] Exclude session, cache, and temporary update data.
- [ ] Test backend editing, frontend routing, access levels, languages, modules, header, and footer.

[Back to Database Documentation](../)