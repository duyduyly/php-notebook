# Joomla 5 Content Tables

This document explains Joomla 5.4 core tables used for articles, categories, featured content, workflows, tags, custom fields, multilingual associations, UCM/history, Schema.org structured data, contacts, newsfeeds, and banners.

> **Schema baseline:** Joomla 5.4.7.

## Table of Contents

- [1. Relationship Summary](#1-relationship-summary)
- [2. `#__content`](#2-content)
- [3. `#__categories`](#3-categories)
- [4. Featured Content and Rating](#4-featured-content-and-rating)
- [5. Content Workflows](#5-content-workflows)
- [6. Tags](#6-tags)
- [7. Custom Fields](#7-custom-fields)
- [8. Multilingual Associations](#8-multilingual-associations)
- [9. UCM and History](#9-ucm-and-history)
- [10. Schema.org Structured Data](#10-schemaorg-structured-data)
- [11. Contacts, Newsfeeds and Banners](#11-contacts-newsfeeds-and-banners)
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
context + item ID             → #__schemaorg.context + itemId
```

Joomla maintains many of these relationships in application code rather than physical MySQL FKs.

## 2. `#__content`

Stores Joomla articles.

| Column | Meaning |
|---|---|
| `id` | Article ID |
| `asset_id` | ACL asset ID |
| `title`, `alias` | Title and SEF alias |
| `introtext`, `fulltext` | Article body |
| `state` | Publication state |
| `catid` | Category ID |
| `created`, `created_by`, `created_by_alias` | Creation metadata |
| `modified`, `modified_by` | Modification metadata |
| `checked_out`, `checked_out_time` | Editing lock |
| `publish_up`, `publish_down` | Publication window |
| `images`, `urls` | JSON media/link configuration |
| `attribs` | Article display/configuration parameters |
| `version`, `ordering` | Version/order values |
| `metakey`, `metadesc`, `metadata` | Metadata |
| `access` | View level |
| `hits` | Counter |
| `featured` | Featured flag |
| `language` | Language code or `*` |
| `note` | Administrator note |

Common state values remain typically `1` published, `0` unpublished, `2` archived, and `-2` trashed.

The article's editorial position can also depend on its workflow association, so `state` alone is not a complete editorial model.

## 3. `#__categories`

Shared hierarchical categories.

Important fields:

```text
id
asset_id
parent_id / lft / rgt / level / path
extension
title / alias / note / description
published
access
params
metadesc / metakey / metadata
created_user_id / created_time
modified_user_id / modified_time
hits
language
version
```

For article categories, `params` can select a content workflow. Therefore category configuration is a dependency of workflow behavior.

## 4. Featured Content and Rating

### `#__content_frontpage`

| Column | Meaning |
|---|---|
| `content_id` | Article ID |
| `ordering` | Featured ordering |
| `featured_up` | Featured start time |
| `featured_down` | Featured end time |

Validate this table together with `#__content.featured`.

### `#__content_rating`

Stores `rating_sum`, `rating_count`, and last-voter IP metadata for an article. Migrate only when article voting history is in scope.

## 5. Content Workflows

Joomla 5 retains the Joomla 4 workflow architecture.

### `#__workflows`

Defines workflow containers with ACL asset, title/description, extension context, default flag, ordering and audit/edit metadata.

### `#__workflow_stages`

Defines stages belonging to a workflow.

Important fields:

```text
id
asset_id
workflow_id
ordering
published
title
description
default
checked_out / checked_out_time
```

### `#__workflow_transitions`

Defines transitions between stages.

Important fields:

```text
id
asset_id
workflow_id
from_stage_id
to_stage_id
published
title
description
options
ordering
```

`options` is structured text/JSON used for behavior such as publishing or featuring.

### `#__workflow_associations`

Maps an extension item to its current stage.

| Column | Meaning |
|---|---|
| `item_id` | Business record ID |
| `stage_id` | Current stage |
| `extension` | Context, e.g. article context |

The mapping is context-sensitive. Do not treat every `item_id` as `#__content.id`.

### ACL Dependency

Workflow assets participate in ACL and the `core.execute.transition` permission. Preserve equivalent behavior by mapping/rebuilding:

```text
workflow asset
stage assets
transition assets
rules containing group IDs
```

## 6. Tags

### `#__tags`

Stores a nested-set tag tree plus title/alias, publication state, access, params, metadata, media/URL configuration, language and audit fields.

### `#__contentitem_tag_map`

Links a tag to a business content item and UCM/content type context.

Key fields include `type_alias`, `core_content_id`, `content_item_id`, `tag_id`, and type/date metadata where present.

Map content type and business ID together.

## 7. Custom Fields

### `#__fields_groups`

Stores groups of fields by component context.

### `#__fields`

Stores field definitions including context, group, field type, machine name, label/default, state, required flag, ordering, parameters, language and access.

### `#__fields_values`

| Column | Meaning |
|---|---|
| `field_id` | Field definition ID |
| `item_id` | Context-dependent item identifier stored as `varchar(255)` |
| `value` | Stored field value |

### `#__fields_categories`

Maps fields to allowed categories.

Migration order:

```text
field groups → fields → field/category mappings → field values
```

Resolve the field `context` before changing `item_id`.

## 8. Multilingual Associations

### `#__associations`

Stores multilingual association groups using:

```text
id
context
key
```

The shared `key` identifies equivalent records. Recreate association groups with target IDs rather than assuming source IDs can be copied.

## 9. UCM and History

### `#__content_types`

Defines core content types, physical table/class mappings, field mappings, routers and content-history options.

Its JSON values are code/version-sensitive; do not blindly replace target core definitions.

### `#__ucm_content`

Normalized cross-content metadata including business item/type IDs, title, alias, body, state, ACL/access, params, metadata, creator/editor/timestamps, language, publish dates, images/URLs, hits, version, ordering and category.

### `#__ucm_base`

Maps UCM identity to item/type/language identity.

### `#__history`

Stores content-version snapshots (`version_id`, `item_id`, note, save date, editor, character count, hash, JSON `version_data`, retention flag).

Canonical records are the primary migration source. Move history only when required and after validating target payload compatibility.

## 10. Schema.org Structured Data

### `#__schemaorg`

Joomla 5.4 core schema stores structured-data configuration in this table.

| Column | Meaning |
|---|---|
| `id` | Row primary key |
| `itemId` | ID of the business item |
| `context` | Content/component context |
| `schemaType` | Schema.org type |
| `schema` | Structured-data configuration payload |

The critical identity is not `itemId` alone:

```text
context + itemId
```

A migration must:

1. identify the referenced component/content type from `context`;
2. map the source business item ID to the target ID;
3. validate that `schemaType` is supported by the target;
4. inspect/remap any IDs or URLs embedded inside `schema`;
5. verify rendered structured data on the frontend.

Do not assume Schema.org rows can be joined universally to `#__content`.

## 11. Contacts, Newsfeeds and Banners

### `#__contact_details`

Stores contact records with optional user link, category, communication/address information, publication/access/language state, metadata, params, timestamps and versioning.

### `#__newsfeeds`

Stores feed definitions with URL, category, count/cache settings, state, access, language, params, metadata, publication dates and images.

### Banner tables

| Table | Purpose |
|---|---|
| `#__banners` | Banner content/configuration |
| `#__banner_clients` | Client/advertiser data |
| `#__banner_tracks` | Impression/click tracking aggregates |

These component tables require category/user/access mappings where applicable.

## 12. Migration Notes

- Migrate/map users and access levels required by content first.
- Migrate categories before articles.
- Rebuild/validate category and tag trees.
- Map `asset_id`, `catid`, creator/editor and access IDs.
- Preserve article and featured publication windows.
- Map workflow/stage/transition identities before workflow associations.
- Rebuild workflow ACL assets and verify `core.execute.transition`.
- Migrate field groups/definitions before field values.
- Resolve custom-field context before remapping item IDs.
- Preserve multilingual groups using target IDs.
- Treat UCM/content-type/history payloads as version-sensitive.
- Migrate `#__schemaorg` by `context + itemId`, then verify generated structured data.
- Install compatible component/plugin code before moving component-owned data.
- Rebuild Finder indexes after canonical content is complete.

[Database Overview](./database-overview.md) · [Complete ERD](./complete-erd.md)