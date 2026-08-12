# Joomla 5 Complete Database ERD

This document provides logical Mermaid diagrams for the main Joomla 5.4 core database areas. Joomla does not enforce every relationship with physical MySQL foreign keys, so the diagrams include important application-level relationships.

> **Schema baseline:** Joomla 5.4.7.

## Table of Contents

- [1. Core ERD](#1-core-erd)
- [2. Content, Workflow and Schema.org ERD](#2-content-workflow-and-schemaorg-erd)
- [3. Menu and Module ERD](#3-menu-and-module-erd)
- [4. User, ACL and Authentication ERD](#4-user-acl-and-authentication-erd)
- [5. Extension, Scheduler and System ERD](#5-extension-scheduler-and-system-erd)
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
        text rules
    }
    CATEGORIES {
        int id PK
        int asset_id
        int parent_id
        varchar extension
        varchar title
        int access
    }
    CONTENT {
        int id PK
        int asset_id
        int catid
        int created_by
        int modified_by
        int access
        tinyint featured
        varchar language
    }
    CONTENT_FRONTPAGE {
        int content_id PK
        int ordering
        datetime featured_up
        datetime featured_down
    }
    MENU_TYPES {
        int id PK
        int asset_id
        varchar menutype UK
        int client_id
        int ordering
    }
    MENU {
        int id PK
        varchar menutype
        int parent_id
        int component_id
        int template_style_id
        int access
        text link
    }
    MODULES {
        int id PK
        int asset_id
        varchar module
        varchar position
        int access
        tinyint client_id
    }
    MODULES_MENU {
        int moduleid PK
        int menuid PK
    }
    USERS {
        int id PK
        varchar username
        varchar email
    }
    USERGROUPS {
        int id PK
        int parent_id
        int lft
        int rgt
    }
    USER_GROUP_MAP {
        int user_id PK
        int group_id PK
    }
    VIEWLEVELS {
        int id PK
        text rules
    }
    EXTENSIONS {
        int extension_id PK
        varchar type
        varchar element
        varchar folder
        tinyint client_id
    }
    TEMPLATE_STYLES {
        int id PK
        varchar template
        tinyint client_id
    }

    ASSETS ||--o{ ASSETS : parent
    ASSETS ||--o| CATEGORIES : controls
    ASSETS ||--o| CONTENT : controls
    ASSETS ||--o| MENU_TYPES : controls
    ASSETS ||--o| MODULES : controls
    CATEGORIES ||--o{ CATEGORIES : parent
    CATEGORIES ||--o{ CONTENT : contains
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

## 2. Content, Workflow and Schema.org ERD

```mermaid
erDiagram
    CONTENT {
        int id PK
        int asset_id FK
        int catid FK
        int access FK
        int created_by FK
        tinyint featured
    }
    CATEGORIES {
        int id PK
        int asset_id FK
        int parent_id FK
        text params
    }
    CONTENT_FRONTPAGE {
        int content_id PK
        int ordering
        datetime featured_up
        datetime featured_down
    }
    WORKFLOWS {
        int id PK
        int asset_id FK
        varchar extension
        tinyint default
    }
    WORKFLOW_STAGES {
        int id PK
        int asset_id FK
        int workflow_id FK
        tinyint default
    }
    WORKFLOW_TRANSITIONS {
        int id PK
        int asset_id FK
        int workflow_id FK
        int from_stage_id
        int to_stage_id
        text options
    }
    WORKFLOW_ASSOCIATIONS {
        int item_id PK
        varchar extension PK
        int stage_id FK
    }
    SCHEMAORG {
        int id PK
        int itemId
        varchar context
        varchar schemaType
        text schema
    }
    TAGS {
        int id PK
        int parent_id FK
    }
    TAG_MAP {
        varchar type_alias PK
        int core_content_id PK
        int content_item_id
        int tag_id PK
    }
    FIELDS {
        int id PK
        int group_id
        varchar context
    }
    FIELD_VALUES {
        int field_id
        varchar item_id
        text value
    }
    ASSETS {
        int id PK
    }

    CATEGORIES ||--o{ CATEGORIES : parent
    CATEGORIES ||--o{ CONTENT : contains
    CONTENT ||--o| CONTENT_FRONTPAGE : featured_as
    WORKFLOWS ||--o{ WORKFLOW_STAGES : contains
    WORKFLOWS ||--o{ WORKFLOW_TRANSITIONS : contains
    WORKFLOW_STAGES ||--o{ WORKFLOW_ASSOCIATIONS : current_stage
    CONTENT ||--o| WORKFLOW_ASSOCIATIONS : article_context
    CONTENT ||--o{ SCHEMAORG : article_context
    TAGS ||--o{ TAG_MAP : maps
    CONTENT ||--o{ TAG_MAP : tagged_through
    FIELDS ||--o{ FIELD_VALUES : stores
    ASSETS ||--o| WORKFLOWS : controls
    ASSETS ||--o| WORKFLOW_STAGES : controls
    ASSETS ||--o| WORKFLOW_TRANSITIONS : controls
```

The arrows from `CONTENT` to `WORKFLOW_ASSOCIATIONS` and `SCHEMAORG` apply only when their context/extension identifies article content. Their item IDs are not universal SQL foreign keys.

## 3. Menu and Module ERD

```mermaid
erDiagram
    ASSETS {
        int id PK
    }
    MENU_TYPES {
        int id PK
        int asset_id FK
        varchar menutype UK
        int client_id
        int ordering
    }
    MENU {
        int id PK
        varchar menutype FK
        int parent_id FK
        int component_id FK
        int template_style_id FK
        int access FK
        datetime publish_up
        datetime publish_down
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

    ASSETS ||--o| MENU_TYPES : controls
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

`MODULES_MENU.menuid = 0` means all pages and negative menu IDs represent exclusions.

## 4. User, ACL and Authentication ERD

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
    }
    USER_GROUP_MAP {
        int user_id PK
        int group_id PK
    }
    VIEWLEVELS {
        int id PK
        text rules
    }
    ASSETS {
        int id PK
        int parent_id FK
        int lft
        int rgt
        text rules
    }
    USER_PROFILES {
        int user_id PK
        varchar profile_key PK
    }
    USER_MFA {
        int id PK
        int user_id
        varchar method
    }
    WEBAUTHN_CREDENTIALS {
        varchar id PK
        varchar user_id
        text credential
    }
    SESSION {
        varbinary session_id PK
        int userid
    }

    USERS ||--o{ USER_GROUP_MAP : belongs_through
    USERGROUPS ||--o{ USER_GROUP_MAP : contains
    USERGROUPS ||--o{ USERGROUPS : parent
    USERS ||--o{ USER_PROFILES : owns
    USERS ||--o{ USER_MFA : configures
    USERS ||--o{ WEBAUTHN_CREDENTIALS : registers
    USERS ||--o{ SESSION : may_own
    ASSETS ||--o{ ASSETS : parent
```

Group IDs embedded in `VIEWLEVELS.rules` and `ASSETS.rules` must be remapped explicitly.

## 5. Extension, Scheduler and System ERD

```mermaid
erDiagram
    EXTENSIONS {
        int extension_id PK
        int package_id
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
    ASSETS {
        int id PK
    }
    SCHEDULER_TASKS {
        int id PK
        int asset_id FK
        varchar type
        tinyint state
        datetime last_execution
        datetime next_execution
    }
    SCHEDULER_LOGS {
        int id PK
        int taskid
        int jobid
        varchar tasktype
        decimal duration
        int exitcode
    }
    ACTION_LOGS {
        int id PK
        int user_id
        int item_id
        varchar extension
    }
    PRIVACY_REQUESTS {
        int id PK
        varchar email
        varchar request_type
    }
    PRIVACY_CONSENTS {
        int id PK
        int user_id
    }
    MAIL_TEMPLATES {
        varchar template_id PK
        varchar language PK
        varchar extension
    }
    GUIDEDTOURS {
        int id PK
        varchar title
    }
    GUIDEDTOUR_STEPS {
        int id PK
        int tour_id FK
    }
    FINDER_TAXONOMY {
        int id PK
        int parent_id FK
    }

    EXTENSIONS ||--o| SCHEMAS : versioned_by
    EXTENSIONS ||--o{ UPDATE_SITE_MAP : updated_through
    UPDATE_SITES ||--o{ UPDATE_SITE_MAP : serves
    ASSETS ||--o| SCHEDULER_TASKS : controls
    SCHEDULER_TASKS ||--o{ SCHEDULER_LOGS : execution_history
    GUIDEDTOURS ||--o{ GUIDEDTOUR_STEPS : contains
    FINDER_TAXONOMY ||--o{ FINDER_TAXONOMY : parent
```

Finder link/term/token relationships are simplified because generated index rows should normally be rebuilt.

## 6. Migration Flow

```mermaid
flowchart TD
    S["Joomla 5 source database"] --> I["Inventory exact 5.x schema and extensions"]
    I --> B["Back up source and target"]
    B --> E["Install Joomla 6-compatible extensions/plugins"]
    E --> U["Map users, groups and view levels"]
    U --> C["Migrate categories"]
    C --> A["Migrate articles, fields, tags and associations"]
    A --> SD["Map Schema.org context/item structured data"]
    SD --> W["Recreate/map workflows, stages and transitions"]
    W --> WA["Map workflow associations"]
    WA --> M["Migrate menu types and menu items"]
    M --> MOD["Migrate modules and assignments"]
    MOD --> ACL["Rebuild/validate ACL assets and trees"]
    ACL --> SYS["Migrate selected redirects, mail, privacy and scheduler configuration"]
    SYS --> RUN["Reset scheduler runtime state"]
    RUN --> IDX["Rebuild Finder indexes"]
    IDX --> V["Verify DB, backend, frontend, routing, ACL, workflow, schema and tasks"]
```

## 7. Diagram Limitations

1. The baseline is Joomla 5.4.7; earlier Joomla 5 minor releases can differ.
2. Diagrams show logical relationships, not every physical column or index.
3. Third-party/custom extensions add independent tables and cross-table dependencies.
4. IDs inside JSON/text fields, menu links and rules require separate parsing.
5. `#__schemaorg.itemId`, custom-field `item_id`, and workflow association `item_id` are context-dependent.
6. `#__scheduler_logs` is history, while `#__scheduler_tasks` mixes persistent definition/configuration with runtime execution state.
7. Finder indexes are generated and intentionally simplified.
8. Authentication secret relationships are conceptual only and do not imply that credentials should be migrated.
9. Use `SHOW CREATE TABLE` plus Joomla installation/update SQL to verify the real physical source before migration.

[Database Overview](./database-overview.md) · [Content Tables](./content-tables.md) · [Menu and Module Tables](./menu-module-tables.md) · [User and ACL Tables](./user-acl-tables.md) · [Extension and System Tables](./extension-system-tables.md)