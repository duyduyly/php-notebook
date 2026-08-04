# Joomla 3 Database Overview

This section provides a structured overview of the Joomla 3 core database and its most important relationships.

## Table of Contents

- [Purpose](#purpose)
- [Documents](#documents)
- [Core Database Areas](#core-database-areas)
- [Recommended Reading Order](#recommended-reading-order)
- [Migration Notes](#migration-notes)

## Purpose

The goal of this documentation is to help developers:

- understand the main Joomla 3 core tables;
- identify the relationships between content, categories, menus, modules, users, and ACL;
- prepare database mappings for Joomla 3 to Joomla 6 migration work;
- avoid copying version-dependent system tables without validation.

## Documents

| Document | Description |
|---|---|
| [Database Structure](./database-structure.md) | Explains the main table groups, important columns, prefixes, nested sets, and migration-sensitive tables. |
| [Database ERD](./database-erd.md) | Provides Mermaid ER diagrams and simplified relationship flows for the Joomla 3 core database. |

## Core Database Areas

```text
Joomla 3 Database
├── Content
│   ├── #__content
│   ├── #__categories
│   ├── #__content_frontpage
│   ├── #__tags
│   ├── #__contentitem_tag_map
│   ├── #__fields
│   └── #__fields_values
├── Navigation
│   ├── #__menu_types
│   └── #__menu
├── Modules
│   ├── #__modules
│   └── #__modules_menu
├── Users and Access Control
│   ├── #__users
│   ├── #__usergroups
│   ├── #__user_usergroup_map
│   ├── #__viewlevels
│   └── #__assets
├── Extensions
│   └── #__extensions
├── Languages
│   └── #__languages
└── Runtime Data
    └── #__session
```

## Recommended Reading Order

1. Review the table groups in [Database Structure](./database-structure.md#main-table-groups).
2. Study content and category relationships in [Database Structure](./database-structure.md#content-and-categories).
3. Review the full [High-Level ERD](./database-erd.md#high-level-erd).
4. Review the [Migration Relationship View](./database-erd.md#migration-relationship-view).
5. Use the [Migration Checklist](./database-structure.md#migration-checklist) before writing migration SQL or scripts.

## Migration Notes

A Joomla 3 database must not be copied directly over a fresh Joomla 6 database.

A safer migration flow is:

```text
Joomla 3 Database
        ↓
Extract and validate source records
        ↓
Map IDs and transform incompatible fields
        ↓
Insert records into a fresh Joomla 6 database
        ↓
Rebuild trees, ACL assets, and extension-dependent references
        ↓
Validate frontend and backend behavior
```

Important version-dependent areas include:

- `#__assets` and ACL rules;
- `#__extensions` and extension IDs;
- nested-set columns such as `lft`, `rgt`, and `level`;
- JSON configuration fields;
- menu links containing article or category IDs;
- module-to-menu assignments;
- third-party extension tables.

[Back to Database Documentation](../README.md)
