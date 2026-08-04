# Joomla 3 vs Joomla 6 ERD Gap Diagrams

> A visual migration specification for comparing Joomla 3.10.x and Joomla 6.x database structures.

This document shows Joomla 3 and Joomla 6 tables next to each other so that column names, data types, references, and migration actions can be compared directly.

> [!IMPORTANT]
> The diagrams describe common Joomla core structures. Before writing migration SQL, verify the exact schemas from both installed projects:
>
> ```sql
> SHOW CREATE TABLE `your_j3_prefix_content`;
> SHOW CREATE TABLE `your_j6_prefix_content`;
> ```

---

## Quick Summary

| Area | Result | Default action |
|---|---|---|
| Content and categories | Same business entities, changed references and workflow dependency | Transform, remap, and migrate |
| Menus and modules | Same core entities, changed links, extension IDs, template positions, and tree values | Rewrite and rebuild |
| Users and ACL | Same account/group model, expanded ACL and security model | Selectively migrate and rebuild ACL |
| Extensions and schemas | Same purpose, but target installation owns IDs and schema records | Reinstall and map by identity |
| Workflow, scheduler, privacy, logs, MFA | New or expanded in Joomla 6 | Keep target records or configure explicitly |
| Sessions, Finder, cache, updates | Runtime or generated data | Skip and rebuild |

---

## Table of Contents

- [1. Diagram and Column Legend](#1-diagram-and-column-legend)
- [2. Table-to-Table Status Matrix](#2-table-to-table-status-matrix)
- [3. Side-by-Side Article Table Comparison](#3-side-by-side-article-table-comparison)
- [4. Side-by-Side Menu Table Comparison](#4-side-by-side-menu-table-comparison)
- [5. Content and Category Relationships](#5-content-and-category-relationships)
- [6. Workflow Gap](#6-workflow-gap)
- [7. Tags and Custom Fields Gap](#7-tags-and-custom-fields-gap)
- [8. Module and Template Gap](#8-module-and-template-gap)
- [9. User and ACL Gap](#9-user-and-acl-gap)
- [10. Extension and System Gap](#10-extension-and-system-gap)
- [11. Runtime and Generated Data](#11-runtime-and-generated-data)
- [12. End-to-End Article Migration Example](#12-end-to-end-article-migration-example)
- [13. Migration Decision Flow](#13-migration-decision-flow)
- [14. Validation Checklist](#14-validation-checklist)

---

## 1. Diagram and Column Legend

### Table-level statuses

```mermaid
flowchart TB
    ENTITY["Compared table or entity"]
    ENTITY --> SAME["Same concept"]
    ENTITY --> CHANGED["Changed schema or behavior"]
    ENTITY --> NEW["New in Joomla 6"]
    ENTITY --> REBUILD["Rebuild in Joomla 6"]
    ENTITY --> CONDITIONAL["Conditional migration"]
    ENTITY --> LEGACY["Legacy or review"]
```

| Status | Meaning | Default handling |
|---|---|---|
| **Same concept** | The business purpose remains | Still compare the physical columns |
| **Changed** | Columns, types, IDs, defaults, JSON, indexes, or behavior differ | Transform and remap |
| **New in Joomla 6** | New table, relationship, or subsystem | Keep or create valid target records |
| **Rebuild** | Generated, runtime, security-sensitive, or installation-owned | Do not copy source rows |
| **Conditional** | Depends on project usage or retention requirements | Migrate only after approval |
| **Legacy / Review** | Joomla 3 storage is obsolete or replaced | Review the target model |

### Column annotations used inside table diagrams

| Annotation | Meaning | Typical handling |
|---|---|---|
| `KEEP` | Same business value | Copy after validating type and size |
| `REMAP` | Foreign/logical reference changes | Replace using an ID mapping table |
| `TRANSFORM` | Value or format changes | Convert JSON, state, date, URL, path, or enum |
| `VERIFY` | Exact compatibility is uncertain | Compare both physical schemas |
| `REBUILD` | Joomla 6 should generate the value | Rebuild trees, assets, indexes, or relationships |
| `RESET` | Keep the row but clear temporary state | Use `NULL`, `0`, or target default |
| `SKIP` | Do not migrate | Exclude runtime or sensitive data |
| `NEW` | Column or relationship is target-only | Populate according to Joomla 6 rules |
| `TARGET` | Installer or Joomla 6 owns the value | Preserve the target value |

> [!NOTE]
> A column can require more than one action. For example, `images` can be `KEEP + TRANSFORM + VERIFY`: retain the image meaning, normalize the JSON, and verify the path.

---

## 2. Table-to-Table Status Matrix

| Joomla 3 | Joomla 6 | Status | Main action |
|---|---|---|---|
| `#__content` | `#__content` | **Changed** | Transform rows, remap IDs, add workflow association |
| `#__categories` | `#__categories` | **Changed** | Remap parents/assets/access and rebuild tree |
| `#__content_frontpage` | `#__content_frontpage` | **Changed** | Remap article IDs and verify scheduling columns |
| `#__tags` | `#__tags` | **Changed** | Remap references and rebuild tree |
| `#__contentitem_tag_map` | Same | **Changed** | Remap content, tag, and type IDs |
| `#__fields*` | Same family | **Changed** | Verify field plugins and remap IDs/context |
| `#__menu_types` | `#__menu_types` | **Changed** | Migrate frontend menus only |
| `#__menu` | `#__menu` | **Changed** | Rewrite links and rebuild tree |
| `#__modules` | `#__modules` | **Changed** | Install compatible code and map positions |
| `#__modules_menu` | Same | **Changed** | Remap both IDs |
| `#__template_styles` | Same | **Changed** | Recreate on compatible Joomla 6 template |
| `#__users` | `#__users` | **Changed** | Selectively migrate identity/security fields |
| `#__usergroups` | Same | **Changed** | Map by meaning and rebuild hierarchy |
| `#__viewlevels` | Same | **Changed** | Rewrite group IDs in JSON rules |
| `#__assets` | `#__assets` | **Rebuild** | Preserve target core tree; recreate object assets |
| `#__extensions` | `#__extensions` | **Rebuild** | Reinstall and map by extension identity |
| `#__schemas` | `#__schemas` | **Rebuild** | Let installers create rows |
| `#__finder_*` | `#__finder_*` | **Rebuild** | Re-index |
| `#__session` | `#__session` | **Rebuild** | Start empty |
| No equivalent | `#__workflows*` | **New** | Configure workflows and create associations |
| No equivalent | `#__scheduler_*` | **New** | Keep installer-created tasks and fresh logs |
| Joomla 3 OTP fields | `#__user_mfa` | **New / Changed** | Require MFA re-enrollment |

---

## 3. Side-by-Side Article Table Comparison

The two entities below are intentionally connected by a comparison relationship so Mermaid normally renders them close together.

```mermaid
erDiagram
    J3_CONTENT ||--|| J6_CONTENT : "compare"

    J3_CONTENT {
        int id PK "KEEP or MAP"
        int asset_id FK "REMAP or REBUILD"
        varchar title "KEEP"
        varchar alias "KEEP and VERIFY"
        text introtext "KEEP"
        text fulltext "KEEP"
        int state "TRANSFORM"
        int catid FK "REMAP"
        datetime created "KEEP"
        int created_by FK "REMAP"
        datetime modified "KEEP"
        int modified_by FK "REMAP"
        datetime publish_up "TRANSFORM date"
        datetime publish_down "TRANSFORM date"
        text images "TRANSFORM JSON"
        text urls "TRANSFORM JSON"
        text attribs "TRANSFORM JSON"
        int access FK "REMAP"
        int featured "VERIFY"
        varchar language "KEEP and VERIFY"
        int checked_out "RESET"
        datetime checked_out_time "RESET"
    }

    J6_CONTENT {
        int id PK "TARGET ID"
        int asset_id FK "TARGET asset"
        varchar title "FROM J3"
        varchar alias "FROM J3"
        text introtext "FROM J3"
        text fulltext "FROM J3"
        int state "MAPPED state"
        int catid FK "TARGET category"
        datetime created "NORMALIZED"
        int created_by FK "TARGET user"
        datetime modified "NORMALIZED"
        int modified_by FK "TARGET user"
        datetime publish_up "NULL or valid date"
        datetime publish_down "NULL or valid date"
        text images "VALID Joomla 6 JSON"
        text urls "VALID Joomla 6 JSON"
        text attribs "VALID Joomla 6 JSON"
        int access FK "TARGET viewlevel"
        int featured "CONSISTENT with frontpage"
        varchar language "INSTALLED language"
        int checked_out "RESET value"
        datetime checked_out_time "RESET value"
    }
```

### Article differences requiring special attention

| Joomla 3 column | Joomla 6 target | Action | Warning |
|---|---|---|---|
| `id` | `id` | Keep or map | Do not preserve when it collides with target rows |
| `catid` | `catid` | Remap | Category IDs are installation-specific |
| `created_by`, `modified_by` | Same names | Remap | User IDs may differ |
| `access` | `access` | Remap | Map view levels by meaning, not only ID |
| `asset_id` | `asset_id` | Rebuild/remap | Do not copy Joomla 3 core asset IDs blindly |
| `state` | `state` | Transform/verify | Must agree with the selected Joomla 6 workflow stage |
| `state` | `#__workflow_associations.stage_id` | New relationship | Create after target article insertion |
| `images`, `urls`, `attribs`, `metadata` | Same logical fields | Transform | Validate JSON and embedded IDs/paths |
| `publish_up`, `publish_down` | Same logical fields | Transform | Convert invalid zero dates to valid target values |
| `checked_out*` | Same logical fields | Reset | Prevent stale edit locks |

### New Joomla 6 article dependency

```mermaid
flowchart LR
    ARTICLE["Joomla 6 #__content"] -->|item_id| ASSOCIATION["#__workflow_associations"]
    STAGE["#__workflow_stages"] -->|stage_id| ASSOCIATION
    WORKFLOW["#__workflows"] -->|workflow_id| STAGE
```

---

## 4. Side-by-Side Menu Table Comparison

```mermaid
erDiagram
    J3_MENU ||--|| J6_MENU : "compare"

    J3_MENU {
        int id PK "KEEP or MAP"
        varchar menutype "KEEP"
        varchar title "KEEP"
        varchar alias "KEEP and VERIFY"
        varchar path "REBUILD"
        text link "TRANSFORM IDs and route"
        varchar type "VERIFY"
        int component_id FK "REMAP extension"
        int parent_id FK "REMAP"
        int lft "REBUILD"
        int rgt "REBUILD"
        int level "REBUILD"
        int published "VERIFY"
        int access FK "REMAP"
        text params "TRANSFORM JSON"
        int home "VERIFY"
        varchar language "KEEP and VERIFY"
        int template_style_id FK "REMAP"
        int client_id "FILTER frontend"
        int checked_out "RESET"
        datetime checked_out_time "RESET"
    }

    J6_MENU {
        int id PK "TARGET ID"
        varchar menutype "TARGET menu type"
        varchar title "FROM J3"
        varchar alias "VALID target alias"
        varchar path "REBUILT"
        text link "REWRITTEN target route"
        varchar type "SUPPORTED type"
        int component_id FK "TARGET extension"
        int parent_id FK "TARGET parent"
        int lft "REBUILT"
        int rgt "REBUILT"
        int level "REBUILT"
        int published "TARGET state"
        int access FK "TARGET viewlevel"
        text params "VALID Joomla 6 JSON"
        int home "VALID default"
        varchar language "INSTALLED language"
        int template_style_id FK "TARGET style"
        int client_id "SITE records only"
        int checked_out "RESET value"
        datetime checked_out_time "RESET value"
    }
```

### Menu differences requiring special attention

| Column | Required handling | Example |
|---|---|---|
| `component_id` | Map using `type + element + folder + client_id` | Joomla 3 extension ID `100` may become Joomla 6 ID `250` |
| `link` | Rewrite embedded content/category/custom IDs | `view=article&id=25` → mapped article ID |
| `parent_id` | Remap parent first | Import menu tree parent-first |
| `lft`, `rgt`, `level`, `path` | Rebuild | Do not trust source nested-set boundaries |
| `template_style_id` | Map to compatible Joomla 6 style | Protostar style cannot be copied as Cassiopeia style |
| `params` | Transform and validate JSON | Remove obsolete template/component options |
| `client_id` | Filter | Do not migrate Joomla 3 administrator menu rows |
| `home` | Validate | Ensure one valid default menu per required language |

---

## 5. Content and Category Relationships

```mermaid
flowchart LR
    J3CAT["J3 #__categories"] -->|id to catid| J3ART["J3 #__content"]
    J3USER["J3 #__users"] -->|id to created_by| J3ART
    J3VIEW["J3 #__viewlevels"] -->|id to access| J3ART

    J3CAT -->|category map| J6CAT["J6 #__categories"]
    J3USER -->|user map| J6USER["J6 #__users"]
    J3VIEW -->|viewlevel map| J6VIEW["J6 #__viewlevels"]
    J3ART -->|content transform| J6ART["J6 #__content"]

    J6CAT -->|id to catid| J6ART
    J6USER -->|id to created_by| J6ART
    J6VIEW -->|id to access| J6ART
```

### Category tree handling

```mermaid
flowchart LR
    SOURCE["J3 category"] --> PARENT["Remap parent_id"]
    SOURCE --> ACL["Rebuild asset_id and remap access"]
    SOURCE --> JSON["Transform params and metadata"]
    SOURCE --> TREE["Rebuild lft rgt level path"]

    PARENT --> TARGET["J6 category"]
    ACL --> TARGET
    JSON --> TARGET
    TREE --> TARGET
```

---

## 6. Workflow Gap

```mermaid
flowchart LR
    J3STATE["J3 #__content.state"] --> MAP["State-to-stage mapping"]
    MAP --> J6STATE["J6 #__content.state"]
    MAP --> STAGE["J6 #__workflow_stages.id"]
    J6ARTICLE["J6 #__content.id"] --> ASSOCIATION["#__workflow_associations.item_id"]
    STAGE --> ASSOCIATION
```

| Joomla 3 state | Typical Joomla 6 handling |
|---:|---|
| `1` | Published target state and published workflow stage |
| `0` | Unpublished target state and unpublished stage |
| `2` | Archived target state and archived stage |
| `-2` | Trashed target state and trashed stage |

> [!CAUTION]
> Do not hard-code workflow stage IDs. Resolve them from the target Joomla 6 workflow configuration.

---

## 7. Tags and Custom Fields Gap

```mermaid
flowchart LR
    J3CONTENT["J3 content"] --> CMAP["content ID map"] --> J6CONTENT["J6 content"]
    J3TAGS["J3 tags"] --> TMAP["tag ID map"] --> J6TAGS["J6 tags"]
    J3FIELDS["J3 fields"] --> FMAP["field ID map"] --> J6FIELDS["J6 fields"]

    J6CONTENT --> J6TAGMAP["J6 contentitem_tag_map"]
    J6TAGS --> J6TAGMAP
    J6CONTENT --> J6VALUES["J6 fields_values"]
    J6FIELDS --> J6VALUES
```

| Mapping table | Columns to remap |
|---|---|
| `#__contentitem_tag_map` | `content_item_id`, `core_content_id`, `tag_id`, content type reference |
| `#__fields_values` | `field_id`, `item_id` |
| `#__fields_categories` | `field_id`, `category_id` |

> [!IMPORTANT]
> `#__fields_values.item_id` is not self-describing. Its meaning depends on the field `context`.

---

## 8. Module and Template Gap

```mermaid
flowchart LR
    J3MODULE["J3 #__modules"] --> CODE["Install compatible Joomla 6 module"]
    CODE --> TYPE["Map module type"]
    J3MODULE --> POSITION["Map template position"]
    J3MODULE --> PARAMS["Transform params"]

    TYPE --> J6MODULE["J6 #__modules"]
    POSITION --> J6MODULE
    PARAMS --> J6MODULE

    J6MODULE --> ASSIGN["Rebuild #__modules_menu"]
    J6MENU["J6 #__menu"] --> ASSIGN
```

| Joomla 3 value | Joomla 6 handling |
|---|---|
| `module` | Target module extension must exist |
| `position` | Map old template position to target template position |
| `params` | Transform extension-specific JSON |
| `asset_id` | Assign target-created asset |
| `moduleid`, `menuid` | Remap both sides of `#__modules_menu` |

---

## 9. User and ACL Gap

```mermaid
flowchart LR
    J3GROUP["J3 usergroups"] --> GMAP["Map group by meaning"] --> J6GROUP["J6 usergroups"]
    J3VIEW["J3 viewlevels.rules"] --> RULEMAP["Rewrite group IDs in JSON"] --> J6VIEW["J6 viewlevels.rules"]
    J3ASSET["J3 assets"] -.-> REBUILD["Keep target core assets and rebuild object assets"] --> J6ASSET["J6 assets"]
    J3USER["J3 users"] --> USERMAP["Selective identity migration"] --> J6USER["J6 users"]
    J6USER --> MFA["Fresh #__user_mfa enrollment"]
```

| Data | Decision |
|---|---|
| User identity and compatible password hash | Migrate selectively |
| User-group assignments | Remap both IDs |
| View-level JSON rules | Rewrite group IDs |
| ACL asset IDs and tree boundaries | Rebuild |
| Sessions and remember-me keys | Skip |
| OTP/MFA secrets | Do not copy directly; require re-enrollment |

---

## 10. Extension and System Gap

```mermaid
flowchart LR
    J3EXT["J3 #__extensions"] --> IDENTITY["type + element + folder + client_id"]
    INSTALL["Install Joomla 6-compatible package"] --> J6EXT["J6 #__extensions"]
    IDENTITY --> MAP["extension ID map"] --> J6EXT

    INSTALL --> SCHEMA["J6 #__schemas"]
    INSTALL --> SITE["J6 #__update_sites"]
    SITE --> UPDATE["J6 #__updates discovery"]

    J3SCHEMA["J3 #__schemas"] -.->|do not copy| SCHEMA
    J3UPDATE["J3 #__updates"] -.->|rebuild| UPDATE
```

### New Joomla 6 subsystems

```mermaid
flowchart TB
    CORE["Joomla 6 and installed extensions"]
    CORE --> WF["Workflow"]
    CORE --> SCHED["Scheduler"]
    CORE --> LOG["Action logs"]
    CORE --> PRIV["Privacy"]
    CORE --> MAIL["Mail templates"]
    CORE --> TOUR["Guided tours"]
    USERS["Joomla 6 users"] --> MFA["MFA"]
```

---

## 11. Runtime and Generated Data

```mermaid
flowchart LR
    SESSION["J3 sessions"] -->|SKIP| NEWSESSION["Fresh J6 sessions"]
    FINDER["J3 Finder index"] -->|REBUILD| NEWFINDER["Re-indexed J6 Finder"]
    CACHE["J3 cache"] -->|SKIP| NEWCACHE["Fresh J6 cache"]
    UPDATES["J3 update discovery"] -->|REBUILD| NEWUPDATES["J6 update discovery"]
    KEYS["J3 auth keys"] -->|SKIP| NEWKEYS["Fresh J6 keys"]
```

---

## 12. End-to-End Article Migration Example

### Example source and target IDs

| Reference | Joomla 3 | Joomla 6 |
|---|---:|---:|
| Article | `25` | `125` |
| Category | `8` | `108` |
| Author | `42` | `242` |
| View level | `1` | `1` after validation |
| Asset | `300` | `900` |
| Workflow stage | Not applicable | `1` resolved from target |

```mermaid
flowchart LR
    SOURCE["J3 article 25"] --> CAT["Map category 8 to 108"]
    CAT --> USER["Map user 42 to 242"]
    USER --> ACCESS["Validate viewlevel"]
    ACCESS --> ASSET["Create target asset 900"]
    ASSET --> INSERT["Insert J6 article 125"]
    INSERT --> WF["Create workflow association article 125 to stage 1"]
    WF --> CHECK["Validate row JSON ACL URL and rendered page"]
```

---

## 13. Migration Decision Flow

```mermaid
flowchart TD
    SOURCE["Joomla 3 table or entity"] --> EXISTS{"Equivalent in Joomla 6"}
    EXISTS -->|No| NEW["Keep or configure new Joomla 6 subsystem"]
    EXISTS -->|Yes| GENERATED{"Runtime generated or security-sensitive"}
    GENERATED -->|Yes| REBUILD["Skip rows and rebuild"]
    GENERATED -->|No| BUSINESS{"Required business data"}
    BUSINESS -->|No| SKIP["Archive or skip"]
    BUSINESS -->|Yes| EXTENSION{"Extension-owned"}
    EXTENSION -->|Yes| INSTALL["Install compatible extension first"]
    EXTENSION -->|No| COMPARE["Compare physical schemas"]
    INSTALL --> COMPARE
    COMPARE --> SAFE{"Directly compatible"}
    SAFE -->|No| TRANSFORM["Transform remap and rebuild relationships"]
    SAFE -->|Yes| COPY["Copy selectively"]
    TRANSFORM --> TEST["Reconcile and functionally test"]
    COPY --> TEST
    NEW --> TEST
    REBUILD --> TEST
```

---

## 14. Validation Checklist

### Mermaid rendering

- [ ] Every Mermaid block renders on GitHub without a syntax error.
- [ ] ER entities use simple data types such as `int`, `varchar`, `text`, and `datetime`.
- [ ] Attribute annotations are enclosed in quotes.
- [ ] Table comparison diagrams contain exactly one Joomla 3 table and one Joomla 6 table connected by `compare`.
- [ ] Flowchart node IDs are unique within each block.

### Schema comparison

- [ ] Export `SHOW CREATE TABLE` for each compared table.
- [ ] Compare column names, types, lengths, unsigned flags, nullability, defaults, indexes, charset, and collation.
- [ ] Replace example annotations when the real project schema differs.

### Migration validation

- [ ] Build maps for users, groups, view levels, categories, content, assets, tags, fields, extensions, menus, modules, and styles.
- [ ] Rebuild category, tag, menu, user-group, and asset trees.
- [ ] Validate and transform all JSON fields.
- [ ] Rewrite IDs embedded in menu links and configuration.
- [ ] Create valid Joomla 6 workflow associations.
- [ ] Start sessions, cache, Finder, updates, scheduler logs, and MFA records fresh unless an approved exception exists.
- [ ] Compare row counts, content hashes, relationships, URLs, ACL behavior, and rendered pages.

---

## Related Documentation

- [Joomla 3 vs Joomla 6 Database Gap Analysis](./joomla3-vs-joomla6-database-gap.md)
- [Joomla 3 Database Overview](./joomla3/database-overview.md)
- [Joomla 3 Complete ERD](./joomla3/complete-erd.md)
- [Joomla 6 Database Overview](./joomla6/database-overview.md)
- [Joomla 6 Complete ERD](./joomla6/complete-erd.md)
- [Joomla 3 to Joomla 6 Database Migration Checklist](./joomla3-to-joomla6-database-migration-checklist.md)
