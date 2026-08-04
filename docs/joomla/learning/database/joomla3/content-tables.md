# Joomla 3 Content Tables

This document explains the main Joomla 3 tables used for articles, categories, featured content, tags, custom fields, multilingual associations, contacts, newsfeeds, banners, and unified content metadata.

## Table of Contents

- [1. Relationship Summary](#1-relationship-summary)
- [2. `#__content`](#2-content)
- [3. `#__categories`](#3-categories)
- [4. `#__content_frontpage`](#4-content_frontpage)
- [5. Tags](#5-tags)
- [6. Custom Fields](#6-custom-fields)
- [7. Multilingual Associations](#7-multilingual-associations)
- [8. Unified Content Model](#8-unified-content-model)
- [9. Contacts and Newsfeeds](#9-contacts-and-newsfeeds)
- [10. Banners](#10-banners)
- [11. Common Values](#11-common-values)
- [12. Migration Notes](#12-migration-notes)

## 1. Relationship Summary

```text
#__categories.id          → #__content.catid
#__assets.id              → #__content.asset_id
#__users.id               → #__content.created_by / modified_by
#__viewlevels.id          → #__content.access
#__content.id             → #__content_frontpage.content_id
#__tags.id                → #__contentitem_tag_map.tag_id
#__fields.id              → #__fields_values.field_id
```

## 2. `#__content`

Stores Joomla articles.

| Column | Meaning |
|---|---|
| `id` | Article primary key |
| `asset_id` | ACL asset ID in `#__assets` |
| `title` | Article title |
| `alias` | URL-safe alias |
| `introtext` | Introductory content before a read-more break |
| `fulltext` | Remaining content after a read-more break |
| `state` | Publication state |
| `catid` | Category ID |
| `created` | Creation timestamp |
| `created_by` | Creator user ID |
| `created_by_alias` | Displayed author alias when not using the account name |
| `modified` | Last modification timestamp |
| `modified_by` | Last editor user ID |
| `checked_out` | User currently editing the article |
| `checked_out_time` | Checkout timestamp |
| `publish_up` | Publishing start time |
| `publish_down` | Publishing end time |
| `images` | JSON configuration for intro and full-text images |
| `urls` | JSON configuration for article links |
| `attribs` | JSON article display options |
| `version` | Content version number |
| `ordering` | Ordering inside the category |
| `metakey` | Meta keywords |
| `metadesc` | Meta description |
| `access` | View level ID |
| `hits` | View counter |
| `metadata` | JSON metadata options |
| `featured` | Featured flag |
| `language` | Language code or `*` |
| `xreference` | Optional external reference value |

Common `state` values:

| Value | Meaning |
|---:|---|
| `1` | Published |
| `0` | Unpublished |
| `2` | Archived |
| `-2` | Trashed |

Example `images` value:

```json
{
  "image_intro": "images/news/intro.jpg",
  "float_intro": "",
  "image_intro_alt": "News image",
  "image_intro_caption": "",
  "image_fulltext": "images/news/full.jpg",
  "float_fulltext": "",
  "image_fulltext_alt": "Full article image",
  "image_fulltext_caption": ""
}
```

## 3. `#__categories`

Stores categories shared by category-enabled components. The `extension` column identifies the owner, for example `com_content`.

| Column | Meaning |
|---|---|
| `id` | Category primary key |
| `asset_id` | ACL asset ID |
| `parent_id` | Parent category ID |
| `lft`, `rgt` | Nested-set boundaries |
| `level` | Tree depth |
| `path` | Hierarchical alias path |
| `extension` | Owning component |
| `title` | Category title |
| `alias` | URL-safe alias |
| `note` | Administrator note |
| `description` | Category description |
| `published` | Publication state |
| `checked_out` | User currently editing the category |
| `checked_out_time` | Checkout time |
| `access` | View level ID |
| `params` | JSON category options |
| `metadesc`, `metakey` | Search metadata |
| `metadata` | Additional JSON metadata |
| `created_user_id` | Creator user ID |
| `created_time` | Creation time |
| `modified_user_id` | Last editor user ID |
| `modified_time` | Last modification time |
| `hits` | View counter where used |
| `language` | Language code or `*` |
| `version` | Category version number |

Important rule: category tree values must remain internally consistent after migration.

## 4. `#__content_frontpage`

Stores featured article ordering.

| Column | Meaning |
|---|---|
| `content_id` | Article ID |
| `ordering` | Featured ordering |

Validate both `#__content.featured` and the related row in this table.

## 5. Tags

### `#__tags`

Stores hierarchical tags.

Important columns:

| Column | Meaning |
|---|---|
| `id` | Tag ID |
| `parent_id` | Parent tag |
| `lft`, `rgt`, `level`, `path` | Tree data |
| `title`, `alias` | Tag name and alias |
| `note`, `description` | Administrative and public text |
| `published` | Publication state |
| `checked_out`, `checked_out_time` | Editing lock |
| `access` | View level |
| `params` | JSON options |
| `metadesc`, `metakey`, `metadata` | Metadata |
| `created_user_id`, `created_time` | Creator details |
| `modified_user_id`, `modified_time` | Last editor details |
| `images` | JSON tag images |
| `urls` | JSON links |
| `hits` | View counter |
| `language` | Language |
| `version` | Version number |

### `#__contentitem_tag_map`

Maps tags to content items.

| Column | Meaning |
|---|---|
| `type_alias` | Content type alias, such as `com_content.article` |
| `core_content_id` | Related UCM content ID |
| `content_item_id` | Actual content record ID |
| `tag_id` | Tag ID |
| `tag_date` | Mapping timestamp where available |
| `type_id` | Content type ID where available |

Migration must preserve both the content context and the remapped content ID.

## 6. Custom Fields

Custom fields are available in later Joomla 3 releases.

### `#__fields_groups`

Stores field groups.

| Column | Meaning |
|---|---|
| `id` | Group ID |
| `asset_id` | ACL asset ID |
| `context` | Extension context, such as `com_content.article` |
| `title`, `note`, `description` | Group information |
| `state` | Publication state |
| `checked_out`, `checked_out_time` | Editing lock |
| `ordering` | Display order |
| `params` | JSON options |
| `language` | Language |
| `created`, `created_by` | Creation data |
| `modified`, `modified_by` | Modification data |
| `access` | View level |

### `#__fields`

Stores field definitions.

| Column | Meaning |
|---|---|
| `id` | Field ID |
| `asset_id` | ACL asset ID |
| `context` | Target extension context |
| `group_id` | Field group ID |
| `title` | Display label |
| `name` | Machine name |
| `label` | Form label where stored separately |
| `default_value` | Default field value |
| `type` | Field plugin type |
| `note`, `description` | Administrative/help text |
| `state` | Publication state |
| `required` | Required flag |
| `checked_out`, `checked_out_time` | Editing lock |
| `ordering` | Display order |
| `params` | Field-specific JSON options |
| `fieldparams` | Additional JSON field options |
| `language` | Language |
| `created`, `created_user_id` | Creation data |
| `modified`, `modified_by` | Modification data |
| `access` | View level |

### `#__fields_values`

Stores field values.

| Column | Meaning |
|---|---|
| `field_id` | Field definition ID |
| `item_id` | Target record ID in the field context |
| `value` | Stored value |

`item_id` is context-dependent. Never remap it without first checking `#__fields.context`.

### `#__fields_categories`

Where present, limits fields to selected categories.

| Column | Meaning |
|---|---|
| `field_id` | Field ID |
| `category_id` | Allowed category ID |

## 7. Multilingual Associations

### `#__associations`

Links equivalent records in different languages.

| Column | Meaning |
|---|---|
| `id` | Content item ID |
| `context` | Item context, such as a component view |
| `key` | Shared association key |

Records with the same `key` and context belong to one multilingual association group.

## 8. Unified Content Model

Joomla 3 uses UCM tables to provide shared metadata and history behavior across content types.

### `#__content_types`

Defines supported content types.

Important columns include `type_id`, `type_title`, `type_alias`, `table`, `rules`, `field_mappings`, `router`, and `content_history_options`.

### `#__ucm_content`

Stores normalized content metadata. Important columns include:

```text
core_content_id
core_type_alias
core_title
core_alias
core_body
core_state
core_checked_out_time
core_access
core_params
core_metadata
core_created_user_id
core_created_time
core_modified_user_id
core_modified_time
core_language
core_publish_up
core_publish_down
core_content_item_id
asset_id
```

### `#__ucm_base`

Maps a content item to its UCM type and UCM content record.

### `#__ucm_history`

Stores content version history snapshots. Do not assume history payloads are directly compatible with Joomla 6.

## 9. Contacts and Newsfeeds

### `#__contact_details`

Stores contacts. Important fields include identity, category, user link, address details, telephone fields, image, publish state, access, language, params, metadata, and timestamps.

### `#__newsfeeds`

Stores external feed definitions. Important fields include category, URL, cache time, number of items, ordering, access, language, params, and metadata.

## 10. Banners

Main tables:

| Table | Purpose |
|---|---|
| `#__banners` | Banner records and publication settings |
| `#__banner_clients` | Advertiser/client information |
| `#__banner_tracks` | Impression and click tracking |

Typical `#__banners` columns include `id`, `cid`, `type`, `name`, `alias`, `imptotal`, `impmade`, `clicks`, `clickurl`, `state`, `catid`, `description`, `custombannercode`, `sticky`, `ordering`, `metakey`, `params`, `own_prefix`, `metakey_prefix`, `purchase_type`, `track_clicks`, `track_impressions`, `checked_out`, `publish_up`, and `publish_down`.

## 11. Common Values

| Field | Common values |
|---|---|
| Publication state | `1` published, `0` unpublished, `2` archived, `-2` trashed |
| Language | `*` all languages or a language code such as `en-GB` |
| Access | ID from `#__viewlevels` |
| Checkout user | `0` means not checked out |

## 12. Migration Notes

- Migrate categories before articles.
- Remap `catid`, user IDs, access IDs, and asset IDs.
- Rebuild or validate category and tag trees.
- Rewrite IDs embedded in JSON or links.
- Validate custom-field contexts before remapping `item_id`.
- Preserve multilingual association groups using new target IDs.
- Treat UCM and history tables as version-sensitive.
- Install compatible component code before migrating component-specific content.

[Database Overview](./database-overview.md) · [Complete ERD](./complete-erd.md)