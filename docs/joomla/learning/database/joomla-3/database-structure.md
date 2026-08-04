# Joomla 3 Database Structure

This document explains the main Joomla 3 core database tables, their responsibilities, and the relationships that matter most during maintenance and migration.

## Table of Contents

- [1. Database Prefix](#1-database-prefix)
- [2. Main Table Groups](#2-main-table-groups)
- [3. Content and Categories](#3-content-and-categories)
  - [3.1 `#__content`](#31-content)
  - [3.2 `#__categories`](#32-categories)
  - [3.3 Featured Articles](#33-featured-articles)
- [4. Menus](#4-menus)
  - [4.1 `#__menu_types`](#41-menu_types)
  - [4.2 `#__menu`](#42-menu)
- [5. Modules](#5-modules)
  - [5.1 `#__modules`](#51-modules)
  - [5.2 `#__modules_menu`](#52-modules_menu)
- [6. Users and Access Control](#6-users-and-access-control)
- [7. Extensions](#7-extensions)
- [8. Tags and Custom Fields](#8-tags-and-custom-fields)
- [9. Languages and Sessions](#9-languages-and-sessions)
- [10. Nested-Set Trees](#10-nested-set-trees)
- [11. Migration-Sensitive Tables](#11-migration-sensitive-tables)
- [12. Migration Checklist](#12-migration-checklist)

## 1. Database Prefix

Joomla uses a configurable table prefix. Documentation and extension SQL normally use `#__` as a placeholder.

```sql
SELECT *
FROM `#__content`;
```

At runtime, Joomla replaces `#__` with the configured prefix, for example:

```sql
SELECT *
FROM `abc_content`;
```

The prefix is stored in `configuration.php`:

```php
public $dbprefix = 'abc_';
```

## 2. Main Table Groups

| Area | Main Tables | Purpose |
|---|---|---|
| Content | `#__content`, `#__categories`, `#__content_frontpage` | Articles, categories, and featured ordering |
| Menus | `#__menu_types`, `#__menu` | Menu containers and menu items |
| Modules | `#__modules`, `#__modules_menu` | Module configuration and menu assignments |
| Users | `#__users`, `#__usergroups`, `#__user_usergroup_map` | Accounts and group membership |
| Access Control | `#__viewlevels`, `#__assets` | View access and action permissions |
| Extensions | `#__extensions` | Components, modules, plugins, templates, libraries, packages, and languages |
| Tags | `#__tags`, `#__contentitem_tag_map` | Tag definitions and content-to-tag mapping |
| Custom Fields | `#__fields`, `#__fields_groups`, `#__fields_values` | Field definitions, groups, and values |
| Languages | `#__languages` | Installed content languages |
| Runtime | `#__session` | Active frontend and administrator sessions |

## 3. Content and Categories

### 3.1 `#__content`

`#__content` stores Joomla articles.

| Column | Purpose |
|---|---|
| `id` | Primary key of the article |
| `asset_id` | Reference to the ACL asset in `#__assets` |
| `title` | Article title |
| `alias` | URL-friendly alias |
| `introtext` | Introductory article content |
| `fulltext` | Remaining article content after the read-more split |
| `state` | Published, unpublished, archived, or trashed state |
| `catid` | Category ID from `#__categories` |
| `created` | Creation date |
| `created_by` | User ID of the creator |
| `modified` | Last modification date |
| `modified_by` | User ID of the last editor |
| `publish_up` | Publishing start date |
| `publish_down` | Publishing end date |
| `images` | JSON image configuration |
| `urls` | JSON link configuration |
| `attribs` | JSON article display parameters |
| `access` | View level ID from `#__viewlevels` |
| `language` | Content language code or `*` for all languages |
| `metadata` | JSON metadata configuration |
| `metakey` | Meta keywords |
| `metadesc` | Meta description |
| `featured` | Featured status flag |
| `ordering` | Ordering value inside a category |

Primary relationships:

```text
#__categories.id  → #__content.catid
#__users.id       → #__content.created_by
#__users.id       → #__content.modified_by
#__assets.id      → #__content.asset_id
#__viewlevels.id  → #__content.access
```

### 3.2 `#__categories`

Joomla uses one shared category table for multiple components. The `extension` column identifies the owning component.

Example:

```text
extension = com_content
```

This indicates an article category.

Important columns:

| Column | Purpose |
|---|---|
| `id` | Category primary key |
| `asset_id` | ACL asset ID |
| `parent_id` | Parent category ID |
| `lft`, `rgt` | Nested-set boundaries |
| `level` | Tree depth |
| `path` | Hierarchical category path |
| `extension` | Owning component, such as `com_content` |
| `title` | Category title |
| `alias` | URL-friendly alias |
| `description` | Category description |
| `published` | Publication state |
| `access` | View level ID |
| `params` | JSON category options |
| `metadata` | JSON metadata |
| `language` | Content language |

### 3.3 Featured Articles

`#__content_frontpage` stores featured article ordering.

| Column | Purpose |
|---|---|
| `content_id` | Article ID |
| `ordering` | Featured ordering value |

The `featured` flag in `#__content` and the row in `#__content_frontpage` should be validated together during migration.

## 4. Menus

### 4.1 `#__menu_types`

This table defines menu containers such as Main Menu or Footer Menu.

| Column | Purpose |
|---|---|
| `id` | Primary key |
| `menutype` | Unique machine name, such as `mainmenu` |
| `title` | Display title |
| `description` | Menu description |

### 4.2 `#__menu`

This table stores individual frontend and administrator menu items.

| Column | Purpose |
|---|---|
| `id` | Menu item ID |
| `menutype` | Menu container key |
| `title` | Menu item title |
| `alias` | URL alias |
| `path` | Hierarchical menu path |
| `link` | Internal or external link |
| `type` | Component, URL, alias, separator, or heading |
| `component_id` | Related extension ID |
| `parent_id` | Parent menu item |
| `lft`, `rgt` | Nested-set boundaries |
| `level` | Tree depth |
| `published` | Publication state |
| `access` | View level ID |
| `params` | JSON menu configuration |
| `language` | Menu language |

Single Article example:

```text
index.php?option=com_content&view=article&id=25
```

Category Blog example:

```text
index.php?option=com_content&view=category&layout=blog&id=8
```

These links may contain source database IDs. They must be rewritten when IDs change during migration.

## 5. Modules

### 5.1 `#__modules`

`#__modules` stores module instances and their configuration.

| Column | Purpose |
|---|---|
| `id` | Module instance ID |
| `asset_id` | ACL asset ID |
| `title` | Module title |
| `content` | Content for modules such as `mod_custom` |
| `ordering` | Ordering in a template position |
| `position` | Template position name |
| `published` | Publication state |
| `module` | Module type, such as `mod_custom` |
| `access` | View level ID |
| `showtitle` | Whether the title is displayed |
| `params` | JSON module configuration |
| `client_id` | `0` for site and `1` for administrator |
| `language` | Module language |

### 5.2 `#__modules_menu`

This bridge table maps modules to menu items.

| Column | Purpose |
|---|---|
| `moduleid` | Module ID |
| `menuid` | Menu assignment value |

Common values:

| Value | Meaning |
|---|---|
| `0` | Display on all pages |
| Positive menu ID | Display on the selected menu item |
| Negative menu ID | Exclude the selected menu item |

## 6. Users and Access Control

Important tables:

| Table | Purpose |
|---|---|
| `#__users` | User accounts |
| `#__usergroups` | Hierarchical user groups |
| `#__user_usergroup_map` | Many-to-many mapping between users and groups |
| `#__viewlevels` | Defines who may view content |
| `#__assets` | Defines action permissions for components, categories, articles, modules, and other objects |

Typical user-group relationship:

```text
#__users.id
    ↓
#__user_usergroup_map.user_id
#__user_usergroup_map.group_id
    ↓
#__usergroups.id
```

`#__assets.rules` contains JSON ACL rules such as create, edit, delete, and publish permissions.

Example asset names:

```text
root.1
com_content
com_content.category.10
com_content.article.25
com_users
com_modules
```

`#__assets` is version-sensitive and should not be copied blindly into Joomla 6.

## 7. Extensions

`#__extensions` records installed Joomla extensions.

Important columns:

| Column | Purpose |
|---|---|
| `extension_id` | Extension primary key |
| `package_id` | Parent package ID |
| `name` | Extension name |
| `type` | Component, module, plugin, template, library, package, file, or language |
| `element` | Extension element, such as `com_content` |
| `folder` | Plugin group for plugins |
| `client_id` | Site or administrator client |
| `enabled` | Enabled state |
| `access` | Access level |
| `manifest_cache` | JSON manifest information |
| `params` | JSON extension parameters |
| `schema_version` | Installed schema version |

Extension IDs can differ between Joomla installations. Do not assume that `component_id` values in `#__menu` remain valid after migration.

## 8. Tags and Custom Fields

Tags use:

```text
#__tags
#__contentitem_tag_map
```

Custom fields use:

```text
#__fields_groups
#__fields
#__fields_values
```

`#__fields_values.item_id` references the content item in the field context. Because it is context-dependent, migration scripts must verify the field context before remapping IDs.

## 9. Languages and Sessions

`#__languages` stores configured content languages.

`#__session` stores temporary active sessions. Session data should not be migrated between Joomla installations.

## 10. Nested-Set Trees

The following Joomla 3 tables use hierarchical tree data:

```text
#__assets
#__categories
#__menu
#__usergroups
#__tags
```

Important columns include:

```text
parent_id
lft
rgt
level
path
```

A valid `parent_id` alone is not enough. Incorrect `lft` or `rgt` values can break tree ordering, backend lists, ACL inheritance, or menu/category navigation.

## 11. Migration-Sensitive Tables

Do not directly overwrite the Joomla 6 versions of these tables without a verified transformation plan:

```text
#__assets
#__extensions
#__schemas
#__update_sites
#__updates
#__session
```

Other records that require ID mapping include:

```text
#__content.catid
#__content.asset_id
#__menu.component_id
#__menu.parent_id
#__modules.asset_id
#__modules_menu.menuid
#__contentitem_tag_map.content_item_id
#__fields_values.item_id
```

## 12. Migration Checklist

- [ ] Start with a fresh and validated Joomla 6 database.
- [ ] Back up both source and target databases.
- [ ] Identify the real table prefix in both systems.
- [ ] Export only the required Joomla 3 records.
- [ ] Build source-to-target ID mapping tables.
- [ ] Migrate categories before articles.
- [ ] Rebuild or validate nested-set trees.
- [ ] Migrate articles and rewrite category, user, and asset references.
- [ ] Migrate menu types before menu items.
- [ ] Rewrite menu links containing article or category IDs.
- [ ] Install compatible module and component code before migrating their instances.
- [ ] Migrate modules and then module-menu assignments.
- [ ] Recreate or validate ACL assets instead of blindly copying them.
- [ ] Validate JSON fields against Joomla 6 expectations.
- [ ] Exclude sessions, updates, and temporary runtime data.
- [ ] Test backend editing, frontend routing, permissions, languages, header, footer, and module visibility.

[Back to Joomla 3 Database Overview](./README.md) · [View the ERD](./database-erd.md)
