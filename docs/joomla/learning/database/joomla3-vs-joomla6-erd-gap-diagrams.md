# Joomla 3 vs Joomla 6 ERD Gap Diagrams

> A visual companion to the [Joomla 3 vs Joomla 6 Database Gap Analysis](./joomla3-vs-joomla6-database-gap.md).

This document uses Mermaid diagrams to show how Joomla 3 database entities map to Joomla 6, where relationships remain similar, where IDs must be remapped, and where Joomla 6 introduces new subsystems.

> [!IMPORTANT]
> These diagrams describe logical relationships used by Joomla application code. They are not a replacement for comparing the exact physical schemas with `SHOW CREATE TABLE` or `information_schema`.

---

## Table of Contents

- [1. Diagram Legend](#1-diagram-legend)
- [2. Whole-System Gap Overview](#2-whole-system-gap-overview)
- [3. Content and Category Gap](#3-content-and-category-gap)
- [4. Workflow Gap](#4-workflow-gap)
- [5. Tags and Custom Fields Gap](#5-tags-and-custom-fields-gap)
- [6. Menu, Module, and Template Gap](#6-menu-module-and-template-gap)
- [7. User and ACL Gap](#7-user-and-acl-gap)
- [8. Extension and System Gap](#8-extension-and-system-gap)
- [9. Search, Runtime, and Generated Data Gap](#9-search-runtime-and-generated-data-gap)
- [10. Migration Decision Flow](#10-migration-decision-flow)
- [11. Recommended Migration Dependency Order](#11-recommended-migration-dependency-order)
- [12. Key Conclusions](#12-key-conclusions)

---

## 1. Diagram Legend

```mermaid
flowchart LR
    SAME["Same concept"]
    CHANGED["Changed schema or behavior"]
    NEW["New in Joomla 6"]
    REBUILD["Rebuild in Joomla 6"]
    CONDITIONAL["Conditional migration"]

    SAME -->|validate| CHANGED
    CHANGED -->|transform and remap| NEW
    NEW -->|configure target| REBUILD
    REBUILD -->|regenerate| CONDITIONAL
```

| Visual label | Meaning |
|---|---|
| **Same concept** | The business purpose still exists in Joomla 6 |
| **Changed schema or behavior** | The table exists, but IDs, columns, defaults, JSON, or rules differ |
| **New in Joomla 6** | Joomla 6 introduces a new table or relationship |
| **Rebuild** | The target should generate the data instead of importing source rows |
| **Conditional** | Migrate only when project usage or retention requirements justify it |

---

## 2. Whole-System Gap Overview

```mermaid
flowchart LR
    subgraph J3["Joomla 3"]
        J3_CONTENT["Content and Categories"]
        J3_MENU["Menus and Modules"]
        J3_USERS["Users and ACL"]
        J3_EXT["Extensions and Updates"]
        J3_SEARCH["Finder and Runtime"]
    end

    subgraph SHARED["Shared concepts with changed schema"]
        CONTENT["#__content / #__categories"]
        MENU["#__menu / #__modules"]
        USERS["#__users / #__assets"]
        EXT["#__extensions / #__schemas"]
        SEARCH["#__finder_* / #__session"]
    end

    subgraph J6NEW["New or expanded in Joomla 6"]
        WORKFLOW["Workflow"]
        SCHEDULER["Scheduler"]
        LOGGING["Action Logs"]
        PRIVACY["Privacy"]
        MFA["MFA"]
        MAIL["Mail Templates"]
        TOURS["Guided Tours"]
    end

    J3_CONTENT --> CONTENT
    J3_MENU --> MENU
    J3_USERS --> USERS
    J3_EXT --> EXT
    J3_SEARCH --> SEARCH

    CONTENT --> WORKFLOW
    EXT --> SCHEDULER
    EXT --> LOGGING
    USERS --> PRIVACY
    USERS --> MFA
    EXT --> MAIL
    EXT --> TOURS

    SEARCH -->|rebuild| SEARCH_NEW["Joomla 6 generated data"]
```

### Main message

```text
Joomla 6 does not replace every Joomla 3 table.
It keeps many core entities, changes their schemas and references,
and adds new subsystems that must be created in the target database.
```

---

## 3. Content and Category Gap

### 3.1 Joomla 3 logical model

```mermaid
erDiagram
    CATEGORIES ||--o{ CONTENT : contains
    USERS ||--o{ CONTENT : creates
    VIEWLEVELS ||--o{ CONTENT : restricts
    ASSETS ||--o| CONTENT : controls
    CONTENT ||--o| CONTENT_FRONTPAGE : featured_as

    CATEGORIES {
        int id PK
        int parent_id
        int asset_id
        int access
        int lft
        int rgt
        int level
        varchar path
    }

    CONTENT {
        int id PK
        int catid
        int asset_id
        int created_by
        int access
        int state
        int featured
    }
```

### 3.2 Joomla 6 target model

```mermaid
erDiagram
    CATEGORIES ||--o{ CONTENT : contains
    USERS ||--o{ CONTENT : creates
    VIEWLEVELS ||--o{ CONTENT : restricts
    ASSETS ||--o| CONTENT : controls
    CONTENT ||--o| CONTENT_FRONTPAGE : featured_as
    CONTENT ||--o| WORKFLOW_ASSOCIATIONS : follows
    WORKFLOW_STAGES ||--o{ WORKFLOW_ASSOCIATIONS : current_stage

    CATEGORIES {
        int id PK
        int parent_id
        int asset_id
        int access
        int lft
        int rgt
        int level
        varchar path
    }

    CONTENT {
        int id PK
        int catid
        int asset_id
        int created_by
        int access
        int state
        int featured
    }

    WORKFLOW_ASSOCIATIONS {
        int item_id PK
        int stage_id
        varchar extension
    }
```

### 3.3 Column-level gap

```mermaid
flowchart TD
    J3ARTICLE["Joomla 3 #__content row"]

    KEEP["Keep\ntitle, alias, introtext, fulltext, metadata"]
    REMAP["Remap\ncatid, created_by, modified_by, access, asset_id"]
    TRANSFORM["Transform\nstate, featured, params, dates, JSON"]
    RESET["Reset\nchecked_out, checked_out_time"]
    ADD["Add relationship\nworkflow association"]

    J3ARTICLE --> KEEP
    J3ARTICLE --> REMAP
    J3ARTICLE --> TRANSFORM
    J3ARTICLE --> RESET
    J3ARTICLE --> ADD

    KEEP --> J6ARTICLE["Joomla 6 #__content row"]
    REMAP --> J6ARTICLE
    TRANSFORM --> J6ARTICLE
    RESET --> J6ARTICLE
    ADD --> J6WORKFLOW["#__workflow_associations"]
```

### Category tree gap

```mermaid
flowchart LR
    J3CAT["Joomla 3 category"]
    PARENT["Remap parent_id"]
    TREE["Rebuild lft, rgt, level, path"]
    ASSET["Rebuild or remap asset_id"]
    J6CAT["Joomla 6 category"]

    J3CAT --> PARENT --> J6CAT
    J3CAT --> TREE --> J6CAT
    J3CAT --> ASSET --> J6CAT
```

---

## 4. Workflow Gap

Joomla 3 article publication state is mainly represented by `#__content.state`. Joomla 6 keeps the state column but can additionally require a formal workflow association.

```mermaid
flowchart LR
    subgraph J3["Joomla 3"]
        J3CONTENT["#__content"]
        J3STATE["state\n1 published\n0 unpublished\n2 archived\n-2 trashed"]
        J3CONTENT --> J3STATE
    end

    subgraph J6["Joomla 6"]
        J6CONTENT["#__content"]
        ASSOC["#__workflow_associations"]
        STAGE["#__workflow_stages"]
        WORKFLOW["#__workflows"]
        TRANSITION["#__workflow_transitions"]

        J6CONTENT --> ASSOC
        ASSOC --> STAGE
        STAGE --> WORKFLOW
        WORKFLOW --> TRANSITION
    end

    J3STATE -->|state-to-stage mapping| STAGE
```

### Migration requirement

```mermaid
sequenceDiagram
    participant S as Joomla 3 Article
    participant M as State Mapping
    participant T as Joomla 6 Article
    participant W as Workflow Association

    S->>M: Read source state
    M->>T: Insert transformed article
    M->>W: Resolve target workflow stage
    W->>T: Link target article to stage
```

---

## 5. Tags and Custom Fields Gap

```mermaid
flowchart LR
    subgraph J3["Joomla 3"]
        J3CONTENT["#__content"]
        J3TAGMAP["#__contentitem_tag_map"]
        J3TAGS["#__tags"]
        J3FIELDS["#__fields"]
        J3VALUES["#__fields_values"]

        J3CONTENT --> J3TAGMAP
        J3TAGS --> J3TAGMAP
        J3CONTENT --> J3VALUES
        J3FIELDS --> J3VALUES
    end

    subgraph MAP["Required mappings"]
        CMAP["Content ID map"]
        TMAP["Tag ID map"]
        FMAP["Field ID map"]
        CONTEXT["Context and type-alias validation"]
    end

    subgraph J6["Joomla 6"]
        J6CONTENT["#__content"]
        J6TAGMAP["#__contentitem_tag_map"]
        J6TAGS["#__tags"]
        J6FIELDS["#__fields"]
        J6VALUES["#__fields_values"]
    end

    J3CONTENT --> CMAP --> J6CONTENT
    J3TAGS --> TMAP --> J6TAGS
    J3FIELDS --> FMAP --> J6FIELDS
    CONTEXT --> J6TAGMAP
    CONTEXT --> J6VALUES

    J6CONTENT --> J6TAGMAP
    J6TAGS --> J6TAGMAP
    J6CONTENT --> J6VALUES
    J6FIELDS --> J6VALUES
```

### Critical gap

```text
#__fields_values.item_id is not self-describing.
Its meaning depends on the field context, so both field IDs and item IDs must be remapped.
```

---

## 6. Menu, Module, and Template Gap

```mermaid
erDiagram
    MENU_TYPES ||--o{ MENU : contains
    EXTENSIONS ||--o{ MENU : handles
    TEMPLATE_STYLES ||--o{ MENU : overrides
    MODULES ||--o{ MODULES_MENU : assigned_by
    MENU ||--o{ MODULES_MENU : receives

    MENU {
        int id PK
        varchar menutype
        int component_id
        int parent_id
        int template_style_id
        text link
    }

    MODULES {
        int id PK
        varchar module
        varchar position
        int asset_id
        int access
    }
```

### Migration gaps

```mermaid
flowchart TD
    J3MENU["Joomla 3 menu item"]
    EXT_MAP["Map component_id by extension identity"]
    LINK_REWRITE["Rewrite article/category/custom IDs in link"]
    TREE_REBUILD["Rebuild parent_id, lft, rgt, level, path"]
    STYLE_MAP["Map template_style_id"]
    J6MENU["Joomla 6 menu item"]

    J3MENU --> EXT_MAP --> J6MENU
    J3MENU --> LINK_REWRITE --> J6MENU
    J3MENU --> TREE_REBUILD --> J6MENU
    J3MENU --> STYLE_MAP --> J6MENU
```

```mermaid
flowchart TD
    J3MODULE["Joomla 3 module instance"]
    CODE["Install compatible Joomla 6 module code"]
    TYPEMAP["Map module type"]
    POSITION["Map template position"]
    PARAMS["Transform params"]
    J6MODULE["Joomla 6 module instance"]
    ASSIGN["Rebuild #__modules_menu assignments"]

    J3MODULE --> CODE --> TYPEMAP --> J6MODULE
    J3MODULE --> POSITION --> J6MODULE
    J3MODULE --> PARAMS --> J6MODULE
    J6MODULE --> ASSIGN
```

### Important relationship gap

```text
The bridge table still exists, but both IDs can change:

Joomla 3 moduleid/menuid
→ migration maps
→ Joomla 6 moduleid/menuid
```

---

## 7. User and ACL Gap

### Shared relationship model

```mermaid
erDiagram
    USERS ||--o{ USER_USERGROUP_MAP : belongs_through
    USERGROUPS ||--o{ USER_USERGROUP_MAP : contains
    USERGROUPS ||--o{ VIEWLEVELS : referenced_in_rules
    ASSETS ||--o{ CONTENT : controls
    ASSETS ||--o{ CATEGORIES : controls
    VIEWLEVELS ||--o{ CONTENT : restricts
```

### Main ACL gap

```mermaid
flowchart LR
    subgraph J3["Joomla 3"]
        J3GROUPS["User groups"]
        J3VIEW["View levels"]
        J3ASSETS["ACL assets"]
    end

    subgraph MAP["Migration handling"]
        GROUPMAP["Map group IDs by meaning"]
        RULEMAP["Rewrite group IDs inside viewlevel.rules JSON"]
        ASSETREBUILD["Keep Joomla 6 core assets and rebuild migrated object assets"]
    end

    subgraph J6["Joomla 6"]
        J6GROUPS["User groups"]
        J6VIEW["View levels"]
        J6ASSETS["Expanded ACL asset tree"]
        J6NEW["Workflow, scheduler, privacy, log assets"]
    end

    J3GROUPS --> GROUPMAP --> J6GROUPS
    J3VIEW --> RULEMAP --> J6VIEW
    J3ASSETS --> ASSETREBUILD --> J6ASSETS
    J6ASSETS --> J6NEW
```

### Authentication gap

```mermaid
flowchart TD
    J3USER["Joomla 3 user"]
    IDENTITY["Keep identity and compatible password hash"]
    RESET["Reset temporary tokens"]
    SKIPKEYS["Skip user_keys and sessions"]
    MFA["Require MFA re-enrollment"]
    J6USER["Joomla 6 user"]

    J3USER --> IDENTITY --> J6USER
    J3USER --> RESET --> J6USER
    J3USER --> SKIPKEYS
    J3USER --> MFA --> J6USER
```

---

## 8. Extension and System Gap

```mermaid
flowchart LR
    subgraph J3["Joomla 3"]
        J3EXT["#__extensions"]
        J3SCHEMA["#__schemas"]
        J3SITES["#__update_sites"]
        J3UPDATES["#__updates"]
    end

    subgraph TARGET["Joomla 6 target ownership"]
        INSTALL["Install Joomla 6-compatible package"]
        EXTID["New extension_id"]
        SCHEMA["Installer-created schema version"]
        SITE["Installer-created update site"]
        DISCOVERY["Rediscovered updates"]
    end

    J3EXT -->|map by type + element + folder + client_id| EXTID
    INSTALL --> EXTID
    INSTALL --> SCHEMA
    INSTALL --> SITE
    SITE --> DISCOVERY

    J3SCHEMA -. do not copy .-> SCHEMA
    J3SITES -. do not copy .-> SITE
    J3UPDATES -. rebuild .-> DISCOVERY
```

### New Joomla 6 subsystems

```mermaid
flowchart TD
    EXTENSIONS["Installed Joomla 6 extensions"]

    EXTENSIONS --> SCHED["#__scheduler_tasks"]
    EXTENSIONS --> ACTION["#__action_logs_extensions"]
    EXTENSIONS --> MAIL["#__mail_templates"]
    EXTENSIONS --> TOURS["#__guidedtours"]

    USERS["#__users"] --> PRIVACY["#__privacy_requests / consents"]
    USERS --> MFA["#__user_mfa"]
    USERS --> LOGS["#__action_logs"]
```

---

## 9. Search, Runtime, and Generated Data Gap

```mermaid
flowchart LR
    subgraph J3["Joomla 3 source"]
        SESSION["#__session"]
        FINDER["#__finder_*"]
        UPDATES["#__updates"]
        KEYS["#__user_keys"]
        CACHE["Cache data"]
    end

    subgraph DECISION["Migration decision"]
        SKIP["Skip source rows"]
        REBUILD["Rebuild in Joomla 6"]
    end

    subgraph J6["Joomla 6 target"]
        NEWSESSION["Fresh sessions"]
        NEWINDEX["Rebuilt Smart Search"]
        NEWUPDATES["Rediscovered updates"]
        NEWKEYS["New auth keys"]
        NEWCACHE["Fresh cache"]
    end

    SESSION --> SKIP --> NEWSESSION
    FINDER --> REBUILD --> NEWINDEX
    UPDATES --> REBUILD --> NEWUPDATES
    KEYS --> SKIP --> NEWKEYS
    CACHE --> SKIP --> NEWCACHE
```

### Rule

```text
Generated, runtime, temporary, and security-sensitive data should normally start fresh in Joomla 6.
```

---

## 10. Migration Decision Flow

```mermaid
flowchart TD
    TABLE["Source Joomla 3 table or entity"]
    EXISTS{"Equivalent exists in Joomla 6?"}
    GENERATED{"Generated/runtime/security data?"}
    SAME{"Physical schema and behavior verified compatible?"}
    BUSINESS{"Required business data?"}
    EXTENSION{"Owned by an extension?"}

    TABLE --> EXISTS

    EXISTS -->|No| NEW["Keep/configure Joomla 6 subsystem"]
    EXISTS -->|Yes| GENERATED

    GENERATED -->|Yes| REBUILD["Skip source rows and rebuild"]
    GENERATED -->|No| BUSINESS

    BUSINESS -->|No| SKIP["Archive or skip"]
    BUSINESS -->|Yes| EXTENSION

    EXTENSION -->|Yes| INSTALL["Install compatible extension first"]
    EXTENSION -->|No| SAME

    INSTALL --> SAME

    SAME -->|Yes| VALIDATE["Copy selectively and validate"]
    SAME -->|No| TRANSFORM["Transform, remap IDs, rebuild relationships"]

    TRANSFORM --> TEST["Reconcile and functionally test"]
    VALIDATE --> TEST
    NEW --> TEST
    REBUILD --> TEST
```

---

## 11. Recommended Migration Dependency Order

```mermaid
flowchart TD
    INSTALL["1. Install Joomla 6 and compatible extensions"]
    MAPS["2. Prepare source-to-target mapping tables"]
    USERS["3. Users, groups, and view levels"]
    CATEGORIES["4. Categories"]
    CONTENT["5. Articles"]
    WORKFLOW["6. Workflow associations"]
    TAGS["7. Tags and custom fields"]
    MENUS["8. Menu types and menu items"]
    MODULES["9. Modules and assignments"]
    ACL["10. Rebuild ACL assets and trees"]
    SEARCH["11. Rebuild Finder, cache, and runtime data"]
    VALIDATE["12. Validate counts, URLs, ACL, and rendered output"]

    INSTALL --> MAPS --> USERS --> CATEGORIES --> CONTENT --> WORKFLOW
    WORKFLOW --> TAGS --> MENUS --> MODULES --> ACL --> SEARCH --> VALIDATE
```

> [!NOTE]
> The exact order can vary by project. For example, categories may need users first for creator references, while custom components may require extension installation and custom schema preparation before their business data can be migrated.

---

## 12. Key Conclusions

1. **Most core business entities still exist**, but their IDs, defaults, JSON, and relationships must be validated.
2. **Nested-set trees must be rebuilt or validated** for categories, menus, tags, user groups, and assets.
3. **Joomla 6 workflow associations are a new dependency** for migrated content when workflows are active.
4. **Extension registry and schema tables are target-owned**; install extensions instead of copying registry rows.
5. **Sessions, cache, Finder indexes, update discovery, authentication keys, and logs should normally start fresh.**
6. **A table-level match is not enough**; column-level actions must be classified as Keep, Remap, Transform, Verify, Rebuild, Reset, Skip, Target-owned, or Add relationship.

## Related Documentation

- [Joomla 3 vs Joomla 6 Database Gap Analysis](./joomla3-vs-joomla6-database-gap.md)
- [Joomla 3 Database Overview](./joomla3/database-overview.md)
- [Joomla 3 Complete ERD](./joomla3/complete-erd.md)
- [Joomla 6 Database Overview](./joomla6/database-overview.md)
- [Joomla 6 Complete ERD](./joomla6/complete-erd.md)
- [Joomla 3 to Joomla 6 Database Migration Checklist](./joomla3-to-joomla6-database-migration-checklist.md)
