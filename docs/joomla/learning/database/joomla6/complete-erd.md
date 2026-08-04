# Joomla 6 Complete Database ERD

These diagrams show logical relationships used by Joomla application code. Not every relationship is implemented as a physical MySQL foreign key.

## Table of Contents

- [1. Core ERD](#1-core-erd)
- [2. Content and Workflow](#2-content-and-workflow)
- [3. Menu and Module](#3-menu-and-module)
- [4. User and ACL](#4-user-and-acl)
- [5. Extension and System](#5-extension-and-system)
- [6. Joomla 3 to Joomla 6 Migration Flow](#6-joomla-3-to-joomla-6-migration-flow)

## 1. Core ERD

```mermaid
erDiagram
    ASSETS {
        int id PK
        int parent_id
        int lft
        int rgt
        int level
        varchar name UK
        varchar title
        text rules
    }

    CATEGORIES {
        int id PK
        int asset_id
        int parent_id
        varchar extension
        varchar title
        varchar alias
        int published
        int access
        varchar language
    }

    CONTENT {
        int id PK
        int asset_id
        int catid
        varchar title
        varchar alias
        int state
        int created_by
        int modified_by
        int access
        int featured
        varchar language
    }

    WORKFLOWS {
        int id PK
        int asset_id
        varchar title
        varchar extension
        int published
    }

    WORKFLOW_STAGES {
        int id PK
        int asset_id
        int workflow_id
        varchar title
        int published
    }

    WORKFLOW_ASSOCIATIONS {
        int item_id PK
        int stage_id
        varchar extension
    }

    MENU_TYPES {
        int id PK
        varchar menutype UK
        varchar title
    }

    MENU {
        int id PK
        varchar menutype
        int component_id
        int parent_id
        varchar title
        text link
        int access
    }

    MODULES {
        int id PK
        int asset_id
        varchar title
        varchar module
        varchar position
        int access
    }

    MODULES_MENU {
        int moduleid PK
        int menuid PK
    }

    USERS {
        int id PK
        varchar username UK
        varchar email
        varchar password
    }

    USERGROUPS {
        int id PK
        int parent_id
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
        int client_id
        int enabled
    }

    CATEGORIES ||--o{ CONTENT : contains
    USERS ||--o{ CONTENT : creates
    ASSETS ||--o| CONTENT : controls
    ASSETS ||--o| CATEGORIES : controls
    VIEWLEVELS ||--o{ CONTENT : restricts
    VIEWLEVELS ||--o{ CATEGORIES : restricts

    WORKFLOWS ||--o{ WORKFLOW_STAGES : contains
    WORKFLOW_STAGES ||--o{ WORKFLOW_ASSOCIATIONS : current_stage
    CONTENT ||--o| WORKFLOW_ASSOCIATIONS : follows

    MENU_TYPES ||--o{ MENU : contains
    MENU ||--o{ MENU : parent
    EXTENSIONS ||--o{ MENU : handles
    MODULES ||--o{ MODULES_MENU : assigned
    MENU ||--o{ MODULES_MENU : receives

    USERS ||--o{ USER_GROUP_MAP : mapped
    USERGROUPS ||--o{ USER_GROUP_MAP : contains
    USERGROUPS ||--o{ USERGROUPS : parent
```

## 2. Content and Workflow

```mermaid
flowchart LR
    CAT["#__categories"] -->|catid| ART["#__content"]
    U["#__users"] -->|created_by / modified_by| ART
    A["#__assets"] -->|asset_id| ART
    V["#__viewlevels"] -->|access| ART
    ART --> F["#__content_frontpage"]
    ART --> TM["#__contentitem_tag_map"]
    T["#__tags"] --> TM
    ART --> FV["#__fields_values"]
    FD["#__fields"] --> FV
    ART --> WA["#__workflow_associations"]
    WS["#__workflow_stages"] --> WA
    W["#__workflows"] --> WS
    W --> WT["#__workflow_transitions"]
```

## 3. Menu and Module

```mermaid
flowchart LR
    MT["#__menu_types"] -->|menutype| M["#__menu"]
    M -->|parent_id| M
    E["#__extensions"] -->|component_id| M
    TS["#__template_styles"] -->|template_style_id| M
    MOD["#__modules"] -->|moduleid| MM["#__modules_menu"]
    M -->|menuid| MM
    MOD -->|position| POS["Template position"]
```

## 4. User and ACL

```mermaid
flowchart LR
    U["#__users"] --> MAP["#__user_usergroup_map"]
    G["#__usergroups"] --> MAP
    G -->|group IDs in JSON| V["#__viewlevels"]
    G -->|permission rules| A["#__assets"]
    A --> OBJ["Content / Categories / Modules / Workflows / Tasks"]
    V --> OBJ
    U --> P["#__user_profiles"]
    U --> MFA["#__user_mfa"]
    U --> S["#__session"]
```

## 5. Extension and System

```mermaid
flowchart LR
    E["#__extensions"] --> SC["#__schemas"]
    E --> USE["#__update_sites_extensions"]
    US["#__update_sites"] --> USE
    US --> UP["#__updates"]

    E --> ST["#__scheduler_tasks"]
    ST --> SL["#__scheduler_log"]

    U["#__users"] --> AL["#__action_logs"]
    E --> ALE["#__action_logs_extensions"]

    C["Content"] --> F["#__finder_*"]
    L["#__languages"] --> AS["#__associations"]
```

## 6. Joomla 3 to Joomla 6 Migration Flow

```mermaid
flowchart TD
    J3["Joomla 3 database"] --> EX["Extract selected business records"]
    EX --> VAL["Validate source data"]
    VAL --> MAP["Build source-to-target ID maps"]

    MAP --> CAT["Migrate categories"]
    CAT --> ART["Migrate articles"]
    ART --> WF["Create workflow associations"]
    WF --> TAX["Migrate tags and fields"]
    TAX --> MENU["Migrate menus"]
    MENU --> MOD["Migrate modules and assignments"]
    MOD --> USER["Migrate selected users and groups"]
    USER --> REBUILD["Rebuild ACL, nested sets, UCM, and search indexes"]
    REBUILD --> TEST["Validate backend and frontend behavior"]

    SYS["Joomla 6 fresh system tables"] --> REBUILD
```

## Key Rules

1. Treat the target Joomla 6 schema as authoritative.
2. Map IDs; do not assume equality between installations.
3. Preserve or rebuild nested-set trees.
4. Create valid workflow associations for migrated articles.
5. Install extension code before extension-owned data.
6. Do not copy sessions, search indexes, update cache, scheduler logs, action logs, or MFA secrets blindly.

[Back to Database Overview](./database-overview.md)
