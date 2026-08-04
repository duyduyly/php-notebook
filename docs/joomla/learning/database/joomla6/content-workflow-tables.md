# Joomla 6 Content and Workflow Tables

## Table of Contents

- [1. Content Model](#1-content-model)
- [2. `#__content`](#2-content)
- [3. `#__categories`](#3-categories)
- [4. Featured Content](#4-featured-content)
- [5. Tags](#5-tags)
- [6. Custom Fields](#6-custom-fields)
- [7. Associations and History](#7-associations-and-history)
- [8. Workflow Tables](#8-workflow-tables)
- [9. Migration Notes](#9-migration-notes)

## 1. Content Model

```text
Category → Article → Workflow stage
                   ├── Tags
                   ├── Custom fields
                   ├── Associations
                   └── History
```

## 2. `#__content`

Stores articles.

| Column | Meaning |
|---|---|
| `id` | Article primary key |
| `asset_id` | Related ACL asset |
| `title`, `alias` | Display title and URL alias |
| `introtext`, `fulltext` | Article body split by read-more |
| `state` | Publication state used by the content model |
| `catid` | Category ID |
| `created`, `modified` | Audit dates |
| `created_by`, `modified_by` | User IDs |
| `checked_out`, `checked_out_time` | Edit-lock information |
| `publish_up`, `publish_down` | Publishing window |
| `images`, `urls` | JSON media and link configuration |
| `attribs` | JSON article display options |
| `version` | Content version counter |
| `ordering` | Ordering inside the category |
| `metakey`, `metadesc`, `metadata` | SEO metadata |
| `access` | View-level ID |
| `hits` | View counter |
| `featured` | Featured flag |
| `language` | Language code or `*` |
| `note` | Administrator note |

Main logical relationships:

```text
#__content.catid       → #__categories.id
#__content.asset_id    → #__assets.id
#__content.created_by  → #__users.id
#__content.access      → #__viewlevels.id
```

## 3. `#__categories`

Shared category table for components such as content, contacts, banners, and newsfeeds.

| Column | Meaning |
|---|---|
| `id` | Category primary key |
| `asset_id` | ACL asset |
| `parent_id` | Parent category |
| `lft`, `rgt`, `level` | Nested-set tree values |
| `path` | Hierarchical alias path |
| `extension` | Owner, for example `com_content` |
| `title`, `alias` | Name and URL alias |
| `description` | Category content |
| `published` | Publication state |
| `checked_out`, `checked_out_time` | Edit lock |
| `access` | View-level ID |
| `params`, `metadata` | JSON settings |
| `created_user_id`, `modified_user_id` | Audit users |
| `language` | Language code |

Do not migrate `parent_id` alone. The nested-set values must also be valid.

## 4. Featured Content

`#__content_frontpage` stores featured ordering.

| Column | Meaning |
|---|---|
| `content_id` | Article ID |
| `ordering` | Featured ordering |

Validate both `#__content.featured` and this table.

## 5. Tags

### `#__tags`

Tag definitions with a nested-set tree.

Important columns:

```text
id, parent_id, lft, rgt, level, path, title, alias,
published, access, params, metadata, language
```

### `#__contentitem_tag_map`

Maps tags to content items.

| Column | Meaning |
|---|---|
| `type_alias` | Content type, such as `com_content.article` |
| `core_content_id` | UCM/core content reference |
| `content_item_id` | Actual article or item ID |
| `tag_id` | Tag ID |

Always remap `content_item_id` and `tag_id`.

## 6. Custom Fields

| Table | Purpose |
|---|---|
| `#__fields_groups` | Field groups |
| `#__fields` | Field definitions |
| `#__fields_values` | Values assigned to content items |
| `#__fields_categories` | Category restrictions for fields |

Important field columns:

| Column | Meaning |
|---|---|
| `context` | Content context, for example `com_content.article` |
| `group_id` | Field group |
| `type` | Field plugin type |
| `name`, `title` | Machine and display names |
| `state` | Enabled state |
| `required` | Required flag |
| `default_value` | Default field value |
| `fieldparams`, `params` | JSON field settings |
| `access`, `language` | Visibility constraints |

`#__fields_values.item_id` must be remapped to the target content ID.

## 7. Associations and History

### `#__associations`

Connects equivalent items across languages.

| Column | Meaning |
|---|---|
| `id` | Item ID |
| `context` | Item type/context |
| `key` | Shared association key |

### `#__contenthistory`

Stores saved content versions.

History is optional migration data. It is usually safer to migrate current content and let Joomla 6 create new history records.

### UCM tables

```text
#__ucm_base
#__ucm_content
```

These support Joomla's unified content model. Rebuild or validate them after primary content migration rather than assuming source IDs remain valid.

## 8. Workflow Tables

### `#__workflows`

Defines workflows for an extension.

| Column | Meaning |
|---|---|
| `id` | Workflow ID |
| `asset_id` | ACL asset |
| `title` | Workflow title |
| `extension` | Context, commonly `com_content.article` |
| `default` | Default workflow flag |
| `published` | Enabled state |
| `ordering` | Display order |
| `params` | JSON options |

### `#__workflow_stages`

Defines stages inside a workflow.

| Column | Meaning |
|---|---|
| `id` | Stage ID |
| `asset_id` | ACL asset |
| `workflow_id` | Parent workflow |
| `title` | Stage title |
| `published` | Enabled state |
| `default` | Default stage flag |
| `ordering` | Stage order |

### `#__workflow_transitions`

Defines allowed movement between stages.

| Column | Meaning |
|---|---|
| `id` | Transition ID |
| `asset_id` | ACL asset |
| `workflow_id` | Parent workflow |
| `from_stage_id` | Source stage; special values may represent any stage |
| `to_stage_id` | Destination stage |
| `title` | Transition title |
| `published` | Enabled state |
| `ordering` | Transition order |

### `#__workflow_associations`

Connects a content item to its current stage.

| Column | Meaning |
|---|---|
| `item_id` | Article/content ID |
| `stage_id` | Current workflow stage |
| `extension` | Content context |

## 9. Migration Notes

- Migrate categories before articles.
- Build category and article ID maps.
- Rewrite tag, field, association, and workflow references.
- Use Joomla 6 workflow/stage IDs from the target database.
- Do not copy Joomla 3 ACL asset IDs directly.
- Validate every JSON column.
- Rebuild history/UCM data when practical.
- Test publish, unpublish, archive, trash, feature, and edit actions in the backend.

[Back to Database Overview](./database-overview.md)
