# Joomla 4 Content Tables

This document explains Joomla 4.4 core tables used for articles, categories, featured content, workflows, tags, custom fields, multilingual associations, UCM/history, contacts, newsfeeds, and banners.

> **Schema baseline:** Joomla 4.4.14.

## Table of Contents

- [1. Relationship Summary](#1-relationship-summary)
- [2. `#__content`](#2-content)
- [3. `#__categories`](#3-categories)
- [4. Featured Content and Rating](#4-featured-content-and-rating)
- [5. Content Workflows](#5-content-workflows)
- [6. Tags](#6-tags)
- [7. Custom Fields](#7-custom-fields)
- [8. Multilingual Associations](#8-multilingual-associations)
- [9. UCM and Content History](#9-ucm-and-content-history)
- [10. Contacts and Newsfeeds](#10-contacts-and-newsfeeds)
- [11. Banners](#11-banners)
- [12. Migration Notes](#12-migration-notes)

## 1. Relationship Summary

```text
#__categories.id              → #__content.catid
#__assets.id                  → #__content.asset_id
#__users.id                   → #__content.created_by / modified_by
#__viewlevels.id              → #__content.access
#__content.id                 → #__content_frontpage.content_id
#__content.id                 → #__content_rating.content_id
#__workflows.id               → #__workflow_stages.workflow_id
#__workflows.id               → #__workflow_transitions.workflow_id
#__workflow_stages.id         → #__workflow_associations.stage_id
#__tags.id                    → #__contentitem_tag_map.tag_id
#__fields.id                  → #__fields_values.field_id
#__fields.id                  → #__fields_categories.field_id
```

Most of these are logical relationships rather than physical MySQL foreign keys.

## 2. `#__content`

Stores Joomla articles.

| Column | Meaning |
|---|---|
| `id` | Article primary key |
| `asset_id` | ACL asset ID |
| `title`, `alias` | Article title and SEF alias |
| `introtext`, `fulltext` | Article body split around the read-more boundary |
| `state` | Publication state |
| `catid` | Category ID |
| `created`, `created_by`, `created_by_alias` | Creation metadata |
| `modified`, `modified_by` | Modification metadata |
| `checked_out`, `checked_out_time` | Editing lock |
| `publish_up`, `publish_down` | Article publication window |
| `images` | JSON image configuration |
| `urls` | JSON link configuration |
| `attribs` | JSON/article display parameters |
| `version` | Content version counter |
| `ordering` | Ordering value |
| `metakey`, `metadesc`, `metadata` | Search/metadata values |
| `access` | View level ID |
| `hits` | View counter |
| `featured` | Featured flag |
| `language` | Language code or `*` |
| `note` | Administrator note |

Common state values:

| Value | Meaning |
|---:|---|
| `1` | Published |
| `0` | Unpublished |
| `2` | Archived |
| `-2` | Trashed |

Do not assume that `state` fully describes editorial workflow. Joomla 4 also tracks workflow stage associations.

## 3. `#__categories`

Stores shared categories for components that use Joomla's category system.

Important columns:

| Column | Meaning |
|---|---|
| `id` | Category ID |
| `asset_id` | ACL asset ID |
| `parent_id`, `lft`, `rgt`, `level`, `path` | Nested-set tree data |
| `extension` | Owner, e.g. `com_content` |
| `title`, `alias`, `note`, `description` | Category content |
| `published` | State |
| `access` | View level |
| `params` | JSON category configuration |
| `metadesc`, `metakey`, `metadata` | Metadata |
| `created_user_id`, `created_time` | Creation metadata |
| `modified_user_id`, `modified_time` | Modification metadata |
| `hits` | Counter where used |
| `language` | Language |
| `version` | Version counter |

For `com_content`, category `params` can contain workflow selection such as `workflow_id`. This makes category configuration part of the workflow migration scope.

## 4. Featured Content and Rating

### `#__content_frontpage`

Stores featured-article ordering and the featured scheduling window.

| Column | Meaning |
|---|---|
| `content_id` | Article ID |
| `ordering` | Featured ordering |
| `featured_up` | Start of featured state |
| `featured_down` | End of featured state |

Validate both `#__content.featured` and this table.

### `#__content_rating`

Stores article voting/rating aggregates.

| Column | Meaning |
|---|---|
| `content_id` | Article ID |
| `rating_sum` | Sum of rating values |
| `rating_count` | Number of ratings |
| `lastip` | Last recorded voter IP value |

Rating data is business data only if the site actually uses article voting.

## 5. Content Workflows

Joomla 4 introduces first-class editorial workflow tables.

### `#__workflows`

Defines workflows for an extension/context.

Important fields include:

```text
id
asset_id
published
title
description
extension
default
ordering
created / created_by
modified / modified_by
checked_out / checked_out_time
```

A typical core workflow uses the extension context `com_content.article`.

### `#__workflow_stages`

Defines stages inside a workflow.

| Column | Meaning |
|---|---|
| `id` | Stage ID |
| `asset_id` | ACL asset for stage actions |
| `workflow_id` | Parent workflow |
| `title`, `description` | Stage definition |
| `published` | Enabled state |
| `default` | Default stage flag |
| `ordering` | Stage ordering |

### `#__workflow_transitions`

Defines allowed stage transitions and transition behavior.

| Column | Meaning |
|---|---|
| `id` | Transition ID |
| `asset_id` | ACL asset |
| `workflow_id` | Parent workflow |
| `from_stage_id` | Source stage; special values can represent broad applicability |
| `to_stage_id` | Destination stage |
| `title`, `description` | Transition label/help |
| `published` | Enabled state |
| `options` | JSON transition actions such as publishing/featuring |
| `ordering` | Transition ordering |

Core ACL includes the `core.execute.transition` action. Permission migration must therefore include transition assets/rules, not just article edit permissions.

### `#__workflow_associations`

Maps a content item to its current workflow stage.

| Column | Meaning |
|---|---|
| `item_id` | ID in the extension's business table |
| `stage_id` | Current workflow stage |
| `extension` | Context identifying the business object |

For `com_content.article`, `item_id` refers logically to `#__content.id`. Do not apply that assumption to other extension contexts.

### Workflow Migration Rule

Use this dependency order:

```text
workflow
  → stages
  → transitions
  → ACL assets/rules
  → category workflow configuration
  → item-stage associations
```

Never migrate `stage_id` values before building the target stage mapping.

## 6. Tags

### `#__tags`

Stores hierarchical tags. Important columns include `id`, `parent_id`, `lft`, `rgt`, `level`, `path`, `title`, `alias`, `published`, `access`, `params`, metadata, image/link JSON, language and timestamps.

### `#__contentitem_tag_map`

Maps tags to content records.

| Column | Meaning |
|---|---|
| `type_alias` | Content type, e.g. `com_content.article` |
| `core_content_id` | Related UCM content ID |
| `content_item_id` | Actual business record ID |
| `tag_id` | Tag ID |
| `tag_date` | Mapping timestamp where present |
| `type_id` | Content type ID where present |

A safe migration maps both the business record and its content type; do not remap by numeric ID alone.

## 7. Custom Fields

### `#__fields_groups`

Stores field groups by context. Key fields include `id`, `asset_id`, `context`, title/description/note, state, ordering, params, language, timestamps and access.

### `#__fields`

Stores field definitions. Important fields include:

```text
id
asset_id
context
group_id
title
name
label
default_value
type
state
required
ordering
params
fieldparams
language
access
```

### `#__fields_values`

Stores values using:

| Column | Meaning |
|---|---|
| `field_id` | Field definition ID |
| `item_id` | Target record identifier; Joomla 4 stores this as `varchar(255)` |
| `value` | Field value |

`item_id` is context-dependent and is not universally an article ID.

### `#__fields_categories`

Restricts a field to selected categories.

| Column | Meaning |
|---|---|
| `field_id` | Field ID |
| `category_id` | Category ID |

## 8. Multilingual Associations

### `#__associations`

Links equivalent records in different languages.

| Column | Meaning |
|---|---|
| `id` | Item ID |
| `context` | Association context |
| `key` | Shared association key |

Rows with the same `key` and context belong to the same language association group. Recreate groups using target IDs.

## 9. UCM and Content History

### `#__content_types`

Defines shared content type metadata used by tags, UCM and history. Important columns:

```text
type_id
type_title
type_alias
table
rules
field_mappings
router
content_history_options
```

The JSON definitions contain class names, table names and mapping metadata and are version-sensitive.

### `#__ucm_content`

Stores normalized cross-content metadata including core title, alias, body, state, access, params, featured state, metadata, users/timestamps, language, publication dates, business item ID, asset ID, image/URL values, hits, version, ordering, meta values, category ID and type ID.

### `#__ucm_base`

Maps UCM identity to business item/type/language identity.

### `#__history`

Stores version snapshots.

Important columns:

| Column | Meaning |
|---|---|
| `version_id` | History row ID |
| `item_id` | Context-qualified/history item identifier |
| `version_note` | Optional version note |
| `save_date` | Snapshot time |
| `editor_user_id` | Editor |
| `character_count` | Snapshot size metadata |
| `sha1_hash` | Hash of stored snapshot |
| `version_data` | JSON-encoded snapshot payload |
| `keep_forever` | Retention flag |

History payloads are version-sensitive. Prefer migrating canonical business data first; migrate history only with explicit validation.

## 10. Contacts and Newsfeeds

### `#__contact_details`

Stores contacts and includes category, optional Joomla user link, address/communication fields, image, access, publication dates, language, metadata, params and versioning information.

Important relations:

```text
#__categories.id → #__contact_details.catid
#__users.id      → #__contact_details.user_id
#__viewlevels.id → #__contact_details.access
```

### `#__newsfeeds`

Stores external feed definitions including category, URL, item count, cache time, state, access, language, parameters, metadata, publication dates and images.

## 11. Banners

Main tables:

| Table | Purpose |
|---|---|
| `#__banners` | Banner content, category, publishing and tracking configuration |
| `#__banner_clients` | Advertiser/client records |
| `#__banner_tracks` | Aggregated impression/click tracking |

Banner rows reference categories and may contain URLs, HTML/custom code, tracking policy and publication windows. Treat custom HTML as content requiring security review when moving between sites.

## 12. Migration Notes

- Migrate users/view levels required by content before user-linked records.
- Migrate categories before articles.
- Rebuild category and tag nested-set trees.
- Map `asset_id`, `catid`, user IDs and access IDs.
- Preserve `featured_up`/`featured_down` if featured scheduling is required.
- Build workflow/stage/transition maps before importing `#__workflow_associations`.
- Map transition ACL assets and `core.execute.transition` rules.
- Validate field `context` before remapping `#__fields_values.item_id`.
- Preserve multilingual association groups with new target IDs.
- Treat `#__content_types`, UCM and history records as version-sensitive.
- Install compatible component code before importing component-owned records.
- Rebuild search/index data after canonical content is migrated.

[Database Overview](./database-overview.md) · [Complete ERD](./complete-erd.md)