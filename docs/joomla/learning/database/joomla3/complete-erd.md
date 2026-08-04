# Joomla 3 Complete Database ERD

This document provides logical Mermaid diagrams for the main Joomla 3 core database areas. Joomla does not enforce every relationship with physical MySQL foreign keys, so the diagrams describe application-level relationships.

## Table of Contents

- [1. Core ERD](#1-core-erd)
- [2. Content ERD](#2-content-erd)
- [3. Menu and Module ERD](#3-menu-and-module-erd)
- [4. User and ACL ERD](#4-user-and-acl-erd)
- [5. Extension and System ERD](#5-extension-and-system-erd)
- [6. Migration Flow](#6-migration-flow)
- [7. Diagram Limitations](#7-diagram-limitations)

## 1. Core ERD

```mermaid
erDiagram
    ASSETS {
        int id PK
        int parent_id
        int lft
        int rgt
        int level
        varchar name
        varchar title
        text rules
    }
    CATEGORIES {
        int id PK
        int asset_id
        int parent_id
        int lft
        int rgt
        int level
        varchar extension
        varchar title
        varchar alias
        int access
        varchar language
    }
    CONTENT {
        int id PK
        int asset_id
        int catid
        int created_by
        int modified_by
        varchar title
        varchar alias
        tinyint state
        int access
        tinyint featured
        varchar language
    }
    CONTENT_FRONTPAGE {
        int content_id PK
        int ordering
    }
    MENU_TYPES {
        int id PK
        varchar menutype UK
        varchar title
    }
    MENU {
        int id PK
        varchar menutype
        int parent_id
        int component_id
        int template_style_id
        varchar title
        text link
        varchar type
        int access
        varchar language
    }
    MODULES {
        int id PK
        int asset_id
        varchar module
        varchar position
        int access
        tinyint client_id
        varchar language
    }
    MODULES_MENU {
        int moduleid PK
        int menuid PK
    }
    USERS {
        int id PK
        varchar username
        varchar email
        tinyint block
    }
    USERGROUPS {
        int id PK
        int parent_id
        int lft
        int rgt
        varchar title
    }
    USER_GROUP_MAP {
        int user_id PK
        int group_id PK
    }
    VIEWLEVELS {
        int id PK
        varchar title
        text rules
    }
    EXTENSIONS {
        int extension_id PK
        varchar type
        varchar element
        varchar folder
        tinyint client_id
        tinyint enabled
    }
    TEMPLATE_STYLES {
        int id PK
        varchar template
        tinyint client_id
        tinyint home
    }

    ASSETS ||--o{ ASSETS : parent
    ASSETS ||--o| CATEGORIES : controls
    ASSETS ||--o| CONTENT : controls
    ASSETS ||--o| MODULES : controls
    CATEGORIES ||--o{ CATEGORIES : parent
    CATEGORIES ||--o{ CONTENT : contains
    USERS ||--o{ CONTENT : creates
    USERS ||--o{ CONTENT : modifies
    CONTENT ||--o| CONTENT_FRONTPAGE : featured_as
    MENU_TYPES ||--o{ MENU : contains
    MENU ||--o{ MENU : parent
    EXTENSIONS ||--o{ MENU : handles
    TEMPLATE_STYLES ||--o{ MENU : overrides
    MODULES ||--o{ MODULES_MENU : assigned_by
    MENU ||--o{ MODULES_MENU : receives
    USERS ||--o{ USER_GROUP_MAP : belongs_through
    USERGROUPS ||--o{ USER_GROUP_MAP : contains
    USERGROUPS ||--o{ USERGROUPS : parent
    VIEWLEVELS ||--o{ CONTENT : restricts
    VIEWLEVELS ||--o{ CATEGORIES : restricts
    VIEWLEVELS ||--o{ MENU : restricts
    VIEWLEVELS ||--o{ MODULES : restricts
```

## 2. Content ERD

```mermaid
erDiagram
    CONTENT {
        int id PK
        int asset_id FK
        int catid FK
        int created_by FK
        int modified_by FK
        int access FK
        varchar language
    }
    CATEGORIES {
        int id PK
        int asset_id FK
        int parent_id FK
        int access FK
        varchar extension
    }
    CONTENT_FRONTPAGE {
        int content_id PK
        int ordering
    }
    TAGS {
        int id PK
        int parent_id FK
        int access FK
    }
    TAG_MAP {
        varchar type_alias PK
        int core_content_id PK
        int content_item_id
        int tag_id PK
    }
    FIELD_GROUPS {
        int id PK
        int asset_id FK
        varchar context
    }
    FIELDS {
        int id PK
        int asset_id FK
        int group_id FK
        varchar context
    }
    FIELD_VALUES {
        int field_id PK
        int item_id PK
        text value
    }
    USERS {
        int id PK
    }
    ASSETS {
        int id PK
    }
    VIEWLEVELS {
        int id PK
    }

    CATEGORIES ||--o{ CATEGORIES : parent
    CATEGORIES ||--o{ CONTENT : contains
    USERS ||--o{ CONTENT : creates
    USERS ||--o{ CONTENT : modifies
    ASSETS ||--o| CONTENT : controls
    ASSETS ||--o| CATEGORIES : controls
    VIEWLEVELS ||--o{ CONTENT : restricts
    VIEWLEVELS ||--o{ CATEGORIES : restricts
    CONTENT ||--o| CONTENT_FRONTPAGE : featured_as
    CONTENT ||--o{ TAG_MAP : tagged_through
    TAGS ||--o{ TAG_MAP : maps
    TAGS ||--o{ TAGS : parent
    FIELD_GROUPS ||--o{ FIELDS : contains
    FIELDS ||--o{ FIELD_VALUES : stores
```

Note: `#__fields_values.item_id` is context-dependent and is not a universal foreign key to `#__content.id`.

## 3. Menu and Module ERD

```mermaid
erDiagram
    MENU_TYPES {
        int id PK
        varchar menutype UK
    }
    MENU {
        int id PK
        varchar menutype FK
        int parent_id FK
        int component_id FK
        int template_style_id FK
        int access FK
        text link
    }
    MODULES {
        int id PK
        int asset_id FK
        varchar module
        varchar position
        int access FK
    }
    MODULES_MENU {
        int moduleid PK
        int menuid PK
    }
    EXTENSIONS {
        int extension_id PK
        varchar element
        varchar type
    }
    TEMPLATE_STYLES {
        int id PK
        varchar template
    }
    VIEWLEVELS {
        int id PK
    }
    ASSETS {
        int id PK
    }

    MENU_TYPES ||--o{ MENU : contains
    MENU ||--o{ MENU : parent
    EXTENSIONS ||--o{ MENU : handles
    TEMPLATE_STYLES ||--o{ MENU : overrides
    MODULES ||--o{ MODULES_MENU : assigned_by
    MENU ||--o{ MODULES_MENU : receives
    VIEWLEVELS ||--o{ MENU : restricts
    VIEWLEVELS ||--o{ MODULES : restricts
    ASSETS ||--o| MODULES : controls
```

`MODULES_MENU.menuid` has special semantics: `0` means all pages and a negative value means exclusion.

## 4. User and ACL ERD

```mermaid
erDiagram
    USERS {
        int id PK
        varchar username
        varchar email
    }
    USERGROUPS {
        int id PK
        int parent_id FK
        int lft
        int rgt
        varchar title
    }
    USER_GROUP_MAP {
        int user_id PK
        int group_id PK
    }
    VIEWLEVELS {
        int id PK
        varchar title
        text rules
    }
    ASSETS {
        int id PK
        int parent_id FK
        int lft
        int rgt
        int level
        varchar name
        text rules
    }
    USER_PROFILES {
        int user_id PK
        varchar profile_key PK
        text profile_value
    }
    USER_KEYS {
        varchar user_id PK
        varchar series PK
        int time
    }
    SESSION {
        varchar session_id PK
        int userid FK
        tinyint client_id
    }

    USERS ||--o{ USER_GROUP_MAP : belongs_through
    USERGROUPS ||--o{ USER_GROUP_MAP : contains
    USERGROUPS ||--o{ USERGROUPS : parent
    USERS ||--o{ USER_PROFILES : owns
    USERS ||--o{ USER_KEYS : authenticates_with
    USERS ||--o{ SESSION : owns
    ASSETS ||--o{ ASSETS : parent
```

`VIEWLEVELS.rules` and `ASSETS.rules` contain user-group IDs inside JSON, so their relationship to `USERGROUPS` is logical rather than a direct SQL foreign key.

## 5. Extension and System ERD

```mermaid
erDiagram
    EXTENSIONS {
        int extension_id PK
        int package_id FK
        varchar type
        varchar element
        varchar folder
        tinyint client_id
    }
    SCHEMAS {
        int extension_id PK
        varchar version_id
    }
    UPDATE_SITES {
        int update_site_id PK
        varchar name
        text location
    }
    UPDATE_SITE_MAP {
        int update_site_id PK
        int extension_id PK
    }
    UPDATES {
        int update_id PK
        int update_site_id FK
        int extension_id FK
        varchar version
    }
    REDIRECT_LINKS {
        int id PK
        text old_url
        text new_url
    }
    FINDER_LINKS {
        int link_id PK
        text url
        varchar title
    }
    FINDER_TERMS {
        int term_id PK
        varchar term
    }
    FINDER_TAXONOMY {
        int id PK
        int parent_id FK
        varchar title
    }

    EXTENSIONS ||--o| SCHEMAS : versioned_by
    EXTENSIONS ||--o{ UPDATE_SITE_MAP : updated_through
    UPDATE_SITES ||--o{ UPDATE_SITE_MAP : serves
    UPDATE_SITES ||--o{ UPDATES : discovers
    EXTENSIONS ||--o{ UPDATES : identifies
    FINDER_TAXONOMY ||--o{ FINDER_TAXONOMY : parent
```

Finder contains additional partitioned mapping and token tables that are intentionally simplified here because they are generated indexes.

## 6. Migration Flow

```mermaid
flowchart TD
    S["Joomla 3 source database"] --> I["Inventory tables and extensions"]
    I --> B["Back up source and target"]
    B --> E["Install compatible Joomla 6 extensions"]
    E --> U["Map users, groups, and access levels"]
    U --> C["Migrate categories"]
    C --> A["Migrate articles and related content"]
    A --> M["Migrate menu types and menu items"]
    M --> MOD["Migrate modules and assignments"]
    MOD --> ACL["Rebuild ACL assets and nested-set trees"]
    ACL --> IDX["Rebuild search indexes and caches"]
    IDX --> V["Validate frontend, backend, routing, and permissions"]
```

## 7. Diagram Limitations

1. The diagrams focus on core logical relationships, not every column.
2. Joomla 3 minor versions may contain schema differences.
3. Third-party extensions add independent tables and relationships.
4. JSON-based relationships cannot be shown as ordinary foreign keys.
5. Generated tables such as Finder indexes should normally be rebuilt rather than migrated.
6. Use `SHOW CREATE TABLE` and Joomla's installation SQL files to confirm the exact physical source schema.

[Database Overview](./database-overview.md) · [Content Tables](./content-tables.md) · [Menu and Module Tables](./menu-module-tables.md) · [User and ACL Tables](./user-acl-tables.md) · [Extension and System Tables](./extension-system-tables.md)