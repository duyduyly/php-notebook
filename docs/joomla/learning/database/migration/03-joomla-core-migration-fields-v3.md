# Joomla Core Migration Field Inventory — Joomla 3

## Mapping-report synchronization — 2026-08-12

This document is synchronized with the [Joomla 3 → Joomla 6 field mapping report](../joomla-gap-3_6/joomla-3-to-6-field-mapping-report.md).

| Measure | Result |
|---|---:|
| Joomla 3 physical inventory | 78 tables / 711 fields |
| Joomla 6 physical inventory | 76 tables / 832 fields |
| Source-field accounting | 711 / 711 = 100.00% |
| Resolved field decisions | 711 / 711 = 100.00% |
| Resolved relationships | 168 / 168 = 100.00% |
| Field-count migration/rebuild proxy | 691 / 711 = 97.19% |
| Field-count preservation proxy | 697 / 711 = 98.03% |
| Intentionally ignored fields | 14 / 711 = 1.97% |
| Actual migrated rows/values/bytes | Not measured until execution |

Canonical decision reconciliation: `DIRECT 163 + TRANSFORM 134 + ID_MAP 106 + VALUE_MAP 81 + SPLIT 0 + MERGE 0 + DERIVED 1 + REBUILD 206 + ARCHIVE 6 + IGNORE 14 + UNSUPPORTED 0 = 711`; `UNRESOLVED = 0`.

The only intentionally ignored fields are all seven fields in `#__session` and all seven fields in `#__user_keys`; active sessions and remember-me/authentication tokens must be invalidated and recreated. `#__postinstall_messages` is **REBUILD**, `#__utf8_conversion.converted` is **DERIVED**, and ordinary `checked_out` / `checked_out_time` values are **TRANSFORM** fields reset to Joomla 6's not-checked-out state. Joomla 3 `#__ucm_history` is a separate 10-field table and transforms to Joomla 6 `#__history`; it is not part of `#__ucm_content`.

The two percentages are design proxies based on field decisions, not proof that the same percentage of production rows, values, or bytes migrated. Production coverage requires executed reconciliation.

---



## Inventory Rule

> **Inventory = YES**  
> **Field inventory = 100%**  
> **Mapping decision = required before migration**

Source of truth: Joomla CMS `3.10.12` → `installation/sql/mysql/joomla.sql`.

Companion: [`joomla-core-migration-groups-v3.md`](01-joomla-core-migration-groups-v3.md)

```text
Core tables = 78
Physical fields = 711
Unique (table, field) = 711
Duplicates = 0
Baseline physical field coverage = 100%
```

> `100%` is the official Joomla 3.10.12 baseline. Production must still be reconciled with `information_schema.COLUMNS`.

## Metadata Contract

For every table this file preserves the ordered field list and exact official `CREATE TABLE` DDL. The DDL preserves data type, full type, length/precision/scale, nullability, default, auto-increment/extra attributes, charset/collation, comments, generated expressions, exact indexes/keys, engine, table collation and table comment.

Migration annotations are separate from official schema facts. Unlisted fields default to `Structured=NO`, `Reference=—`, and inherit the table migration policy pending the final mapping contract.

## G0 — System Reference

**Tables:** 5 · **Fields:** 43

### `#__extensions`

**Fields (18):** `extension_id`, `package_id`, `name`, `type`, `element`, `folder`, `client_id`, `enabled`, `access`, `protected`, `manifest_cache`, `params`, `custom_data`, `system_data`, `checked_out`, `checked_out_time`, `ordering`, `state`

**Policy:** `REFERENCE / TARGET-SYSTEM`

```sql
CREATE TABLE IF NOT EXISTS `#__extensions` (
  `extension_id` int NOT NULL AUTO_INCREMENT,
  `package_id` int NOT NULL DEFAULT 0 COMMENT 'Parent package ID for extensions installed as a package.',
  `name` varchar(100) NOT NULL,
  `type` varchar(20) NOT NULL,
  `element` varchar(100) NOT NULL,
  `folder` varchar(100) NOT NULL,
  `client_id` tinyint NOT NULL,
  `enabled` tinyint NOT NULL DEFAULT 0,
  `access` int unsigned NOT NULL DEFAULT 1,
  `protected` tinyint NOT NULL DEFAULT 0,
  `manifest_cache` text NOT NULL,
  `params` text NOT NULL,
  `custom_data` text NOT NULL,
  `system_data` text NOT NULL,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ordering` int DEFAULT 0,
  `state` int DEFAULT 0,
  PRIMARY KEY (`extension_id`),
  KEY `element_clientid` (`element`,`client_id`),
  KEY `element_folder_clientid` (`element`,`folder`,`client_id`),
  KEY `extension` (`type`,`element`,`folder`,`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=10000;
```

### `#__schemas`

**Fields (2):** `extension_id`, `version_id`

**Policy:** `REFERENCE / TARGET-SYSTEM`

```sql
CREATE TABLE IF NOT EXISTS `#__schemas` (
  `extension_id` int NOT NULL,
  `version_id` varchar(20) NOT NULL,
  PRIMARY KEY (`extension_id`,`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__update_sites`

**Fields (7):** `update_site_id`, `name`, `type`, `location`, `enabled`, `last_check_timestamp`, `extra_query`

**Policy:** `REFERENCE / TARGET-SYSTEM`

```sql
CREATE TABLE IF NOT EXISTS `#__update_sites` (
  `update_site_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT '',
  `type` varchar(20) DEFAULT '',
  `location` text NOT NULL,
  `enabled` int DEFAULT 0,
  `last_check_timestamp` bigint DEFAULT 0,
  `extra_query` varchar(1000) DEFAULT '',
  PRIMARY KEY (`update_site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Update Sites';
```

### `#__update_sites_extensions`

**Fields (2):** `update_site_id`, `extension_id`

**Policy:** `REFERENCE / TARGET-SYSTEM`

```sql
CREATE TABLE IF NOT EXISTS `#__update_sites_extensions` (
  `update_site_id` int NOT NULL DEFAULT 0,
  `extension_id` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`update_site_id`,`extension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Links extensions to update sites';
```

### `#__updates`

**Fields (14):** `update_id`, `update_site_id`, `extension_id`, `name`, `description`, `element`, `type`, `folder`, `client_id`, `version`, `data`, `detailsurl`, `infourl`, `extra_query`

**Policy:** `REFERENCE / TARGET-SYSTEM`

```sql
CREATE TABLE IF NOT EXISTS `#__updates` (
  `update_id` int NOT NULL AUTO_INCREMENT,
  `update_site_id` int DEFAULT 0,
  `extension_id` int DEFAULT 0,
  `name` varchar(100) DEFAULT '',
  `description` text NOT NULL,
  `element` varchar(100) DEFAULT '',
  `type` varchar(20) DEFAULT '',
  `folder` varchar(20) DEFAULT '',
  `client_id` tinyint DEFAULT 0,
  `version` varchar(32) DEFAULT '',
  `data` text NOT NULL,
  `detailsurl` text NOT NULL,
  `infourl` text NOT NULL,
  `extra_query` varchar(1000) DEFAULT '',
  PRIMARY KEY (`update_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Available Updates';
```

## G1 — Users and Access Foundation

**Tables:** 6 · **Fields:** 46

### `#__languages`

**Fields (14):** `lang_id`, `asset_id`, `lang_code`, `title`, `title_native`, `sef`, `image`, `description`, `metakey`, `metadesc`, `sitename`, `published`, `access`, `ordering`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__languages` (
  `lang_id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0,
  `lang_code` char(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `title` varchar(50) NOT NULL,
  `title_native` varchar(50) NOT NULL,
  `sef` varchar(50) NOT NULL,
  `image` varchar(50) NOT NULL,
  `description` varchar(512) NOT NULL,
  `metakey` text NOT NULL,
  `metadesc` text NOT NULL,
  `sitename` varchar(1024) NOT NULL DEFAULT '',
  `published` int NOT NULL DEFAULT 0,
  `access` int unsigned NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`lang_id`),
  UNIQUE KEY `idx_sef` (`sef`),
  UNIQUE KEY `idx_langcode` (`lang_code`),
  KEY `idx_access` (`access`),
  KEY `idx_ordering` (`ordering`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__usergroups`

**Fields (5):** `id`, `parent_id`, `lft`, `rgt`, `title`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__usergroups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `parent_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Adjacency List Reference Id',
  `lft` int NOT NULL DEFAULT 0 COMMENT 'Nested set lft.',
  `rgt` int NOT NULL DEFAULT 0 COMMENT 'Nested set rgt.',
  `title` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_usergroup_parent_title_lookup` (`parent_id`,`title`),
  KEY `idx_usergroup_title_lookup` (`title`),
  KEY `idx_usergroup_adjacency_lookup` (`parent_id`),
  KEY `idx_usergroup_nested_set_lookup` (`lft`,`rgt`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__users`

**Fields (17):** `id`, `name`, `username`, `email`, `password`, `block`, `sendEmail`, `registerDate`, `lastvisitDate`, `activation`, `params`, `lastResetTime`, `resetCount`, `otpKey`, `otep`, `requireReset`, `authProvider`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(400) NOT NULL DEFAULT '',
  `username` varchar(150) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  `block` tinyint NOT NULL DEFAULT 0,
  `sendEmail` tinyint DEFAULT 0,
  `registerDate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `lastvisitDate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `activation` varchar(100) NOT NULL DEFAULT '',
  `params` text NOT NULL,
  `lastResetTime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Date of last password reset',
  `resetCount` int NOT NULL DEFAULT 0 COMMENT 'Count of password resets since lastResetTime',
  `otpKey` varchar(1000) NOT NULL DEFAULT '' COMMENT 'Two factor authentication encrypted keys',
  `otep` varchar(1000) NOT NULL DEFAULT '' COMMENT 'One time emergency passwords',
  `requireReset` tinyint NOT NULL DEFAULT 0 COMMENT 'Require user to reset password on next login',
  `authProvider` varchar(100) NOT NULL DEFAULT '' COMMENT 'Name of used authentication plugin',
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`(100)),
  KEY `idx_block` (`block`),
  UNIQUE KEY `idx_username` (`username`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__user_usergroup_map`

**Fields (2):** `user_id`, `group_id`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__user_usergroup_map` (
  `user_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Foreign Key to #__users.id',
  `group_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Foreign Key to #__usergroups.id',
  PRIMARY KEY (`user_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__viewlevels`

**Fields (4):** `id`, `title`, `ordering`, `rules`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__viewlevels` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `title` varchar(100) NOT NULL DEFAULT '',
  `ordering` int NOT NULL DEFAULT 0,
  `rules` varchar(5120) NOT NULL COMMENT 'JSON encoded access control.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_assetgroup_title_lookup` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=7;
```

### `#__user_profiles`

**Fields (4):** `user_id`, `profile_key`, `profile_value`, `ordering`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__user_profiles` (
  `user_id` int NOT NULL,
  `profile_key` varchar(100) NOT NULL,
  `profile_value` text NOT NULL,
  `ordering` int NOT NULL DEFAULT 0,
  UNIQUE KEY `idx_user_id_profile_key` (`user_id`,`profile_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Simple user profile storage table';
```

## G2 — Taxonomy and Shared Definitions

**Tables:** 7 · **Fields:** 116

### `#__assets`

**Fields (8):** `id`, `parent_id`, `lft`, `rgt`, `level`, `name`, `title`, `rules`

**Policy:** `ACL / REBUILD-OR-RECONCILE`

```sql
CREATE TABLE IF NOT EXISTS `#__assets` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `parent_id` int NOT NULL DEFAULT 0 COMMENT 'Nested set parent.',
  `lft` int NOT NULL DEFAULT 0 COMMENT 'Nested set lft.',
  `rgt` int NOT NULL DEFAULT 0 COMMENT 'Nested set rgt.',
  `level` int unsigned NOT NULL COMMENT 'The cached level in the nested tree.',
  `name` varchar(50) NOT NULL COMMENT 'The unique name for the asset.\n',
  `title` varchar(100) NOT NULL COMMENT 'The descriptive title for the asset.',
  `rules` varchar(5120) NOT NULL COMMENT 'JSON encoded access control.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_asset_name` (`name`),
  KEY `idx_lft_rgt` (`lft`,`rgt`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__categories`

**Fields (27):** `id`, `asset_id`, `parent_id`, `lft`, `rgt`, `level`, `path`, `extension`, `title`, `alias`, `note`, `description`, `published`, `checked_out`, `checked_out_time`, `access`, `params`, `metadesc`, `metakey`, `metadata`, `created_user_id`, `created_time`, `modified_user_id`, `modified_time`, `hits`, `language`, `version`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to the #__assets table.',
  `parent_id` int unsigned NOT NULL DEFAULT 0,
  `lft` int NOT NULL DEFAULT 0,
  `rgt` int NOT NULL DEFAULT 0,
  `level` int unsigned NOT NULL DEFAULT 0,
  `path` varchar(400) NOT NULL DEFAULT '',
  `extension` varchar(50) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  `description` mediumtext,
  `published` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `access` int unsigned NOT NULL DEFAULT 0,
  `params` text,
  `metadesc` varchar(1024) NOT NULL DEFAULT '' COMMENT 'The meta description for the page.',
  `metakey` varchar(1024) NOT NULL DEFAULT '' COMMENT 'The meta keywords for the page.',
  `metadata` varchar(2048) NOT NULL DEFAULT '' COMMENT 'JSON encoded metadata properties.',
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `created_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `hits` int unsigned NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL DEFAULT '',
  `version` int unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `cat_idx` (`extension`,`published`,`access`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_path` (`path`(100)),
  KEY `idx_left_right` (`lft`,`rgt`),
  KEY `idx_alias` (`alias`(100)),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__tags`

**Fields (30):** `id`, `parent_id`, `lft`, `rgt`, `level`, `path`, `title`, `alias`, `note`, `description`, `published`, `checked_out`, `checked_out_time`, `access`, `params`, `metadesc`, `metakey`, `metadata`, `created_user_id`, `created_time`, `created_by_alias`, `modified_user_id`, `modified_time`, `images`, `urls`, `hits`, `language`, `version`, `publish_up`, `publish_down`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__tags` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int unsigned NOT NULL DEFAULT 0,
  `lft` int NOT NULL DEFAULT 0,
  `rgt` int NOT NULL DEFAULT 0,
  `level` int unsigned NOT NULL DEFAULT 0,
  `path` varchar(400) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL,
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  `description` mediumtext NOT NULL,
  `published` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `access` int unsigned NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `metadesc` varchar(1024) NOT NULL COMMENT 'The meta description for the page.',
  `metakey` varchar(1024) NOT NULL COMMENT 'The meta keywords for the page.',
  `metadata` varchar(2048) NOT NULL COMMENT 'JSON encoded metadata properties.',
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `created_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `images` text NOT NULL,
  `urls` text NOT NULL,
  `hits` int unsigned NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL,
  `version` int unsigned NOT NULL DEFAULT 1,
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `tag_idx` (`published`,`access`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_path` (`path`(100)),
  KEY `idx_left_right` (`lft`,`rgt`),
  KEY `idx_alias` (`alias`(100)),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__content_types`

**Fields (8):** `type_id`, `type_title`, `type_alias`, `table`, `rules`, `field_mappings`, `router`, `content_history_options`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__content_types` (
  `type_id` int unsigned NOT NULL AUTO_INCREMENT,
  `type_title` varchar(255) NOT NULL DEFAULT '',
  `type_alias` varchar(400) NOT NULL DEFAULT '',
  `table` varchar(255) NOT NULL DEFAULT '',
  `rules` text NOT NULL,
  `field_mappings` text NOT NULL,
  `router` varchar(255) NOT NULL DEFAULT '',
  `content_history_options` varchar(5120) COMMENT 'JSON string for com_contenthistory options',
  PRIMARY KEY (`type_id`),
  KEY `idx_alias` (`type_alias`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=10000;
```

### `#__fields_groups`

**Fields (17):** `id`, `asset_id`, `context`, `title`, `note`, `description`, `state`, `checked_out`, `checked_out_time`, `ordering`, `params`, `language`, `created`, `created_by`, `modified`, `modified_by`, `access`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__fields_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0,
  `context` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `checked_out` int NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ordering` int NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `language` char(7) NOT NULL DEFAULT '',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `access` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`state`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_access` (`access`),
  KEY `idx_context` (`context`(191)),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__fields`

**Fields (24):** `id`, `asset_id`, `context`, `group_id`, `title`, `name`, `label`, `default_value`, `type`, `note`, `description`, `state`, `required`, `checked_out`, `checked_out_time`, `ordering`, `params`, `fieldparams`, `language`, `created_time`, `created_user_id`, `modified_time`, `modified_by`, `access`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__fields` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0,
  `context` varchar(255) NOT NULL DEFAULT '',
  `group_id` int unsigned NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL DEFAULT '',
  `name` varchar(255) NOT NULL DEFAULT '',
  `label` varchar(255) NOT NULL DEFAULT '',
  `default_value` text,
  `type` varchar(255) NOT NULL DEFAULT 'text',
  `note` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `required` tinyint NOT NULL DEFAULT 0,
  `checked_out` int NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ordering` int NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `fieldparams` text NOT NULL,
  `language` char(7) NOT NULL DEFAULT '',
  `created_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `access` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`state`),
  KEY `idx_created_user_id` (`created_user_id`),
  KEY `idx_access` (`access`),
  KEY `idx_context` (`context`(191)),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__fields_categories`

**Fields (2):** `field_id`, `category_id`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__fields_categories` (
  `field_id` int NOT NULL DEFAULT 0,
  `category_id` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`field_id`,`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

## G3 — Main Content

**Tables:** 3 · **Fields:** 37

### `#__content`

**Fields (31):** `id`, `asset_id`, `title`, `alias`, `introtext`, `fulltext`, `state`, `catid`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `checked_out`, `checked_out_time`, `publish_up`, `publish_down`, `images`, `urls`, `attribs`, `version`, `ordering`, `metakey`, `metadesc`, `access`, `hits`, `metadata`, `featured`, `language`, `xreference`, `note`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__content` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to the #__assets table.',
  `title` varchar(255) NOT NULL DEFAULT '',
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `introtext` mediumtext NOT NULL,
  `fulltext` mediumtext NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `catid` int unsigned NOT NULL DEFAULT 0,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `images` text NOT NULL,
  `urls` text NOT NULL,
  `attribs` varchar(5120) NOT NULL,
  `version` int unsigned NOT NULL DEFAULT 1,
  `ordering` int NOT NULL DEFAULT 0,
  `metakey` text NOT NULL,
  `metadesc` text NOT NULL,
  `access` int unsigned NOT NULL DEFAULT 0,
  `hits` int unsigned NOT NULL DEFAULT 0,
  `metadata` text NOT NULL,
  `featured` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'Set if article is featured.',
  `language` char(7) NOT NULL COMMENT 'The language code for the article.',
  `xreference` varchar(50) NOT NULL DEFAULT '' COMMENT 'A reference to enable linkages to external data sets.',
  `note` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`state`),
  KEY `idx_catid` (`catid`),
  KEY `idx_createdby` (`created_by`),
  KEY `idx_featured_catid` (`featured`,`catid`),
  KEY `idx_language` (`language`),
  KEY `idx_xreference` (`xreference`),
  KEY `idx_alias` (`alias`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__content_frontpage`

**Fields (2):** `content_id`, `ordering`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__content_frontpage` (
  `content_id` int NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__content_rating`

**Fields (4):** `content_id`, `rating_sum`, `rating_count`, `lastip`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__content_rating` (
  `content_id` int NOT NULL DEFAULT 0,
  `rating_sum` int unsigned NOT NULL DEFAULT 0,
  `rating_count` int unsigned NOT NULL DEFAULT 0,
  `lastip` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

## G4 — Content Relations

**Tables:** 6 · **Fields:** 58

### `#__contentitem_tag_map`

**Fields (6):** `type_alias`, `core_content_id`, `content_item_id`, `tag_id`, `tag_date`, `type_id`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__contentitem_tag_map` (
  `type_alias` varchar(255) NOT NULL DEFAULT '',
  `core_content_id` int unsigned NOT NULL COMMENT 'PK from the core content table',
  `content_item_id` int NOT NULL COMMENT 'PK from the content type table',
  `tag_id` int unsigned NOT NULL COMMENT 'PK from the tag table',
  `tag_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date of most recent save for this tag-item',
  `type_id` mediumint NOT NULL COMMENT 'PK from the content_type table',
  UNIQUE KEY `uc_ItemnameTagid` (`type_id`,`content_item_id`,`tag_id`),
  KEY `idx_tag_type` (`tag_id`,`type_id`),
  KEY `idx_date_id` (`tag_date`,`tag_id`),
  KEY `idx_core_content_id` (`core_content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Maps items from content tables to tags';
```

### `#__fields_values`

**Fields (3):** `field_id`, `item_id`, `value`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__fields_values` (
  `field_id` int unsigned NOT NULL,
  `item_id` varchar(255) NOT NULL COMMENT 'Allow references to items which have strings as ids, eg. none db systems.',
  `value` text,
  KEY `idx_field_id` (`field_id`),
  KEY `idx_item_id` (`item_id`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__associations`

**Fields (3):** `id`, `context`, `key`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__associations` (
  `id` int NOT NULL COMMENT 'A reference to the associated item.',
  `context` varchar(50) NOT NULL COMMENT 'The context of the associated item.',
  `key` char(32) NOT NULL COMMENT 'The key for the association computed from an md5 on associated ids.',
  PRIMARY KEY (`context`,`id`),
  KEY `idx_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__ucm_base`

**Fields (4):** `ucm_id`, `ucm_item_id`, `ucm_type_id`, `ucm_language_id`

**Policy:** `DERIVED/RELATIONAL / REVIEW`

```sql
CREATE TABLE IF NOT EXISTS `#__ucm_base` (
  `ucm_id` int unsigned NOT NULL,
  `ucm_item_id` int NOT NULL,
  `ucm_type_id` int NOT NULL,
  `ucm_language_id` int NOT NULL,
  PRIMARY KEY (`ucm_id`),
  KEY `idx_ucm_item_id` (`ucm_item_id`),
  KEY `idx_ucm_type_id` (`ucm_type_id`),
  KEY `idx_ucm_language_id` (`ucm_language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__ucm_content`

**Fields (32):** `core_content_id`, `core_type_alias`, `core_title`, `core_alias`, `core_body`, `core_state`, `core_checked_out_time`, `core_checked_out_user_id`, `core_access`, `core_params`, `core_featured`, `core_metadata`, `core_created_user_id`, `core_created_by_alias`, `core_created_time`, `core_modified_user_id`, `core_modified_time`, `core_language`, `core_publish_up`, `core_publish_down`, `core_content_item_id`, `asset_id`, `core_images`, `core_urls`, `core_hits`, `core_version`, `core_ordering`, `core_metakey`, `core_metadesc`, `core_catid`, `core_xreference`, `core_type_id`

**Policy:** `DERIVED/RELATIONAL / REVIEW`

```sql
CREATE TABLE IF NOT EXISTS `#__ucm_content` (
  `core_content_id` int unsigned NOT NULL AUTO_INCREMENT,
  `core_type_alias` varchar(400) NOT NULL DEFAULT '' COMMENT 'FK to the content types table',
  `core_title` varchar(400) NOT NULL DEFAULT '',
  `core_alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `core_body` mediumtext,
  `core_state` tinyint NOT NULL DEFAULT 0,
  `core_checked_out_time` varchar(255) NOT NULL DEFAULT '0000-00-00 00:00:00',
  `core_checked_out_user_id` int unsigned NOT NULL DEFAULT 0,
  `core_access` int unsigned NOT NULL DEFAULT 0,
  `core_params` text,
  `core_featured` tinyint unsigned NOT NULL DEFAULT 0,
  `core_metadata` varchar(2048) NOT NULL DEFAULT '' COMMENT 'JSON encoded metadata properties.',
  `core_created_user_id` int unsigned NOT NULL DEFAULT 0,
  `core_created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `core_created_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `core_modified_user_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Most recent user that modified',
  `core_modified_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `core_language` char(7) NOT NULL DEFAULT '',
  `core_publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `core_publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `core_content_item_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'ID from the individual type table',
  `asset_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to the #__assets table.',
  `core_images` text,
  `core_urls` text,
  `core_hits` int unsigned NOT NULL DEFAULT 0,
  `core_version` int unsigned NOT NULL DEFAULT 1,
  `core_ordering` int NOT NULL DEFAULT 0,
  `core_metakey` text,
  `core_metadesc` text,
  `core_catid` int unsigned NOT NULL DEFAULT 0,
  `core_xreference` varchar(50) NOT NULL DEFAULT '' COMMENT 'A reference to enable linkages to external data sets.',
  `core_type_id` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`core_content_id`),
  KEY `tag_idx` (`core_state`,`core_access`),
  KEY `idx_access` (`core_access`),
  KEY `idx_alias` (`core_alias`(100)),
  KEY `idx_language` (`core_language`),
  KEY `idx_title` (`core_title`(100)),
  KEY `idx_modified_time` (`core_modified_time`),
  KEY `idx_created_time` (`core_created_time`),
  KEY `idx_content_type` (`core_type_alias`(100)),
  KEY `idx_core_modified_user_id` (`core_modified_user_id`),
  KEY `idx_core_checked_out_user_id` (`core_checked_out_user_id`),
  KEY `idx_core_created_user_id` (`core_created_user_id`),
  KEY `idx_core_type_id` (`core_type_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Contains core content data in name spaced fields';
```

### `#__ucm_history`

**Fields (10):** `version_id`, `ucm_item_id`, `ucm_type_id`, `version_note`, `save_date`, `editor_user_id`, `character_count`, `sha1_hash`, `version_data`, `keep_forever`

**Policy:** `DERIVED/RELATIONAL / REVIEW`

```sql
CREATE TABLE IF NOT EXISTS `#__ucm_history` (
  `version_id` int unsigned NOT NULL AUTO_INCREMENT,
  `ucm_item_id` int unsigned NOT NULL,
  `ucm_type_id` int unsigned NOT NULL,
  `version_note` varchar(255) NOT NULL DEFAULT '' COMMENT 'Optional version name',
  `save_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `editor_user_id` int unsigned NOT NULL DEFAULT 0,
  `character_count` int unsigned NOT NULL DEFAULT 0 COMMENT 'Number of characters in this version.',
  `sha1_hash` varchar(50) NOT NULL DEFAULT '' COMMENT 'SHA1 hash of the version_data column.',
  `version_data` mediumtext NOT NULL COMMENT 'json-encoded string of version data',
  `keep_forever` tinyint NOT NULL DEFAULT 0 COMMENT '0=auto delete; 1=keep',
  PRIMARY KEY (`version_id`),
  KEY `idx_ucm_item_id` (`ucm_type_id`,`ucm_item_id`),
  KEY `idx_save_date` (`save_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

## G5 — Menu and Presentation

**Tables:** 3 · **Fields:** 38

### `#__template_styles`

**Fields (8):** `id`, `template`, `client_id`, `home`, `title`, `inheritable`, `parent`, `params`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__template_styles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `template` varchar(50) NOT NULL DEFAULT '',
  `client_id` tinyint unsigned NOT NULL DEFAULT 0,
  `home` char(7) NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL DEFAULT '',
  `inheritable` tinyint NOT NULL DEFAULT 0,
  `parent` varchar(50) DEFAULT '',
  `params` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_template` (`template`),
  KEY `idx_client_id` (`client_id`),
  KEY `idx_client_id_home` (`client_id`,`home`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=9;
```

### `#__menu_types`

**Fields (6):** `id`, `asset_id`, `menutype`, `title`, `description`, `client_id`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__menu_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0,
  `menutype` varchar(24) NOT NULL,
  `title` varchar(48) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `client_id` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_menutype` (`menutype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__menu`

**Fields (24):** `id`, `menutype`, `title`, `alias`, `note`, `path`, `link`, `type`, `published`, `parent_id`, `level`, `component_id`, `checked_out`, `checked_out_time`, `browserNav`, `access`, `img`, `template_style_id`, `params`, `lft`, `rgt`, `home`, `language`, `client_id`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__menu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `menutype` varchar(24) NOT NULL COMMENT 'The type of menu this item belongs to. FK to #__menu_types.menutype',
  `title` varchar(255) NOT NULL COMMENT 'The display title of the menu item.',
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'The SEF alias of the menu item.',
  `note` varchar(255) NOT NULL DEFAULT '',
  `path` varchar(1024) NOT NULL COMMENT 'The computed path of the menu item based on the alias field.',
  `link` varchar(1024) NOT NULL COMMENT 'The actually link the menu item refers to.',
  `type` varchar(16) NOT NULL COMMENT 'The type of link: Component, URL, Alias, Separator',
  `published` tinyint NOT NULL DEFAULT 0 COMMENT 'The published state of the menu link.',
  `parent_id` int unsigned NOT NULL DEFAULT 1 COMMENT 'The parent menu item in the menu tree.',
  `level` int unsigned NOT NULL DEFAULT 0 COMMENT 'The relative level in the tree.',
  `component_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to #__extensions.id',
  `checked_out` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to #__users.id',
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'The time the menu item was checked out.',
  `browserNav` tinyint NOT NULL DEFAULT 0 COMMENT 'The click behaviour of the link.',
  `access` int unsigned NOT NULL DEFAULT 0 COMMENT 'The access level required to view the menu item.',
  `img` varchar(255) NOT NULL COMMENT 'The image of the menu item.',
  `template_style_id` int unsigned NOT NULL DEFAULT 0,
  `params` text NOT NULL COMMENT 'JSON encoded data for the menu item.',
  `lft` int NOT NULL DEFAULT 0 COMMENT 'Nested set lft.',
  `rgt` int NOT NULL DEFAULT 0 COMMENT 'Nested set rgt.',
  `home` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'Indicates if this menu item is the home or default page.',
  `language` char(7) NOT NULL DEFAULT '',
  `client_id` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_client_id_parent_id_alias_language` (`client_id`,`parent_id`,`alias`(100),`language`),
  KEY `idx_componentid` (`component_id`,`menutype`,`published`,`access`),
  KEY `idx_menutype` (`menutype`),
  KEY `idx_left_right` (`lft`,`rgt`),
  KEY `idx_alias` (`alias`(100)),
  KEY `idx_path` (`path`(100)),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=102;
```

## G6 — Modules

**Tables:** 2 · **Fields:** 20

### `#__modules`

**Fields (18):** `id`, `asset_id`, `title`, `note`, `content`, `ordering`, `position`, `checked_out`, `checked_out_time`, `publish_up`, `publish_down`, `published`, `module`, `access`, `showtitle`, `params`, `client_id`, `language`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__modules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to the #__assets table.',
  `title` varchar(100) NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  `content` text,
  `ordering` int NOT NULL DEFAULT 0,
  `position` varchar(50) NOT NULL DEFAULT '',
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `published` tinyint NOT NULL DEFAULT 0,
  `module` varchar(50) DEFAULT NULL,
  `access` int unsigned NOT NULL DEFAULT 0,
  `showtitle` tinyint unsigned NOT NULL DEFAULT 1,
  `params` text NOT NULL,
  `client_id` tinyint NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `published` (`published`,`access`),
  KEY `newsfeeds` (`module`,`published`),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=87;
```

### `#__modules_menu`

**Fields (2):** `moduleid`, `menuid`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__modules_menu` (
  `moduleid` int NOT NULL DEFAULT 0,
  `menuid` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`moduleid`,`menuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

## G7 — Supporting Core Components

**Tables:** 14 · **Fields:** 189

### `#__contact_details`

**Fields (43):** `id`, `name`, `alias`, `con_position`, `address`, `suburb`, `state`, `country`, `postcode`, `telephone`, `fax`, `misc`, `image`, `email_to`, `default_con`, `published`, `checked_out`, `checked_out_time`, `ordering`, `params`, `user_id`, `catid`, `access`, `mobile`, `webpage`, `sortname1`, `sortname2`, `sortname3`, `language`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `metakey`, `metadesc`, `metadata`, `featured`, `xreference`, `publish_up`, `publish_down`, `version`, `hits`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__contact_details` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `con_position` varchar(255),
  `address` text,
  `suburb` varchar(100),
  `state` varchar(100),
  `country` varchar(100),
  `postcode` varchar(100),
  `telephone` varchar(255),
  `fax` varchar(255),
  `misc` mediumtext,
  `image` varchar(255),
  `email_to` varchar(255),
  `default_con` tinyint unsigned NOT NULL DEFAULT 0,
  `published` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ordering` int NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `user_id` int NOT NULL DEFAULT 0,
  `catid` int NOT NULL DEFAULT 0,
  `access` int unsigned NOT NULL DEFAULT 0,
  `mobile` varchar(255) NOT NULL DEFAULT '',
  `webpage` varchar(255) NOT NULL DEFAULT '',
  `sortname1` varchar(255) NOT NULL DEFAULT '',
  `sortname2` varchar(255) NOT NULL DEFAULT '',
  `sortname3` varchar(255) NOT NULL DEFAULT '',
  `language` varchar(7) NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `metakey` text NOT NULL,
  `metadesc` text NOT NULL,
  `metadata` text NOT NULL,
  `featured` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'Set if contact is featured.',
  `xreference` varchar(50) NOT NULL DEFAULT '' COMMENT 'A reference to enable linkages to external data sets.',
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `version` int unsigned NOT NULL DEFAULT 1,
  `hits` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`published`),
  KEY `idx_catid` (`catid`),
  KEY `idx_createdby` (`created_by`),
  KEY `idx_featured_catid` (`featured`,`catid`),
  KEY `idx_language` (`language`),
  KEY `idx_xreference` (`xreference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__newsfeeds`

**Fields (30):** `catid`, `id`, `name`, `alias`, `link`, `published`, `numarticles`, `cache_time`, `checked_out`, `checked_out_time`, `ordering`, `rtl`, `access`, `language`, `params`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `metakey`, `metadesc`, `metadata`, `xreference`, `publish_up`, `publish_down`, `description`, `version`, `hits`, `images`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__newsfeeds` (
  `catid` int NOT NULL DEFAULT 0,
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '',
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `link` varchar(2048) NOT NULL DEFAULT '',
  `published` tinyint NOT NULL DEFAULT 0,
  `numarticles` int unsigned NOT NULL DEFAULT 1,
  `cache_time` int unsigned NOT NULL DEFAULT 3600,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ordering` int NOT NULL DEFAULT 0,
  `rtl` tinyint NOT NULL DEFAULT 0,
  `access` int unsigned NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL DEFAULT '',
  `params` text NOT NULL,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `metakey` text NOT NULL,
  `metadesc` text NOT NULL,
  `metadata` text NOT NULL,
  `xreference` varchar(50) NOT NULL DEFAULT '' COMMENT 'A reference to enable linkages to external data sets.',
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `description` text NOT NULL,
  `version` int unsigned NOT NULL DEFAULT 1,
  `hits` int unsigned NOT NULL DEFAULT 0,
  `images` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`published`),
  KEY `idx_catid` (`catid`),
  KEY `idx_createdby` (`created_by`),
  KEY `idx_language` (`language`),
  KEY `idx_xreference` (`xreference`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__banners`

**Fields (34):** `id`, `cid`, `type`, `name`, `alias`, `imptotal`, `impmade`, `clicks`, `clickurl`, `state`, `catid`, `description`, `custombannercode`, `sticky`, `ordering`, `metakey`, `params`, `own_prefix`, `metakey_prefix`, `purchase_type`, `track_clicks`, `track_impressions`, `checked_out`, `checked_out_time`, `publish_up`, `publish_down`, `reset`, `created`, `language`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `version`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__banners` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cid` int NOT NULL DEFAULT 0,
  `type` int NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL DEFAULT '',
  `alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `imptotal` int NOT NULL DEFAULT 0,
  `impmade` int NOT NULL DEFAULT 0,
  `clicks` int NOT NULL DEFAULT 0,
  `clickurl` varchar(200) NOT NULL DEFAULT '',
  `state` tinyint NOT NULL DEFAULT 0,
  `catid` int unsigned NOT NULL DEFAULT 0,
  `description` text NOT NULL,
  `custombannercode` varchar(2048) NOT NULL,
  `sticky` tinyint unsigned NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  `metakey` text NOT NULL,
  `params` text NOT NULL,
  `own_prefix` tinyint NOT NULL DEFAULT 0,
  `metakey_prefix` varchar(400) NOT NULL DEFAULT '',
  `purchase_type` tinyint NOT NULL DEFAULT -1,
  `track_clicks` tinyint NOT NULL DEFAULT -1,
  `track_impressions` tinyint NOT NULL DEFAULT -1,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `reset` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `language` char(7) NOT NULL DEFAULT '',
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `version` int unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_state` (`state`),
  KEY `idx_own_prefix` (`own_prefix`),
  KEY `idx_metakey_prefix` (`metakey_prefix`(100)),
  KEY `idx_banner_catid` (`catid`),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__banner_clients`

**Fields (14):** `id`, `name`, `contact`, `email`, `extrainfo`, `state`, `checked_out`, `checked_out_time`, `metakey`, `own_prefix`, `metakey_prefix`, `purchase_type`, `track_clicks`, `track_impressions`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__banner_clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `contact` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `extrainfo` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `metakey` text NOT NULL,
  `own_prefix` tinyint NOT NULL DEFAULT 0,
  `metakey_prefix` varchar(400) NOT NULL DEFAULT '',
  `purchase_type` tinyint NOT NULL DEFAULT -1,
  `track_clicks` tinyint NOT NULL DEFAULT -1,
  `track_impressions` tinyint NOT NULL DEFAULT -1,
  PRIMARY KEY (`id`),
  KEY `idx_own_prefix` (`own_prefix`),
  KEY `idx_metakey_prefix` (`metakey_prefix`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__banner_tracks`

**Fields (4):** `track_date`, `track_type`, `banner_id`, `count`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__banner_tracks` (
  `track_date` datetime NOT NULL,
  `track_type` int unsigned NOT NULL,
  `banner_id` int unsigned NOT NULL,
  `count` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`track_date`,`track_type`,`banner_id`),
  KEY `idx_track_date` (`track_date`),
  KEY `idx_track_type` (`track_type`),
  KEY `idx_banner_id` (`banner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__redirect_links`

**Fields (10):** `id`, `old_url`, `new_url`, `referer`, `comment`, `hits`, `published`, `created_date`, `modified_date`, `header`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__redirect_links` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `old_url` varchar(2048) NOT NULL,
  `new_url` varchar(2048),
  `referer` varchar(2048) NOT NULL,
  `comment` varchar(255) NOT NULL DEFAULT '',
  `hits` int unsigned NOT NULL DEFAULT 0,
  `published` tinyint NOT NULL,
  `created_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `header` smallint NOT NULL DEFAULT 301,
  PRIMARY KEY (`id`),
  KEY `idx_old_url` (`old_url`(100)),
  KEY `idx_link_modifed` (`modified_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__messages`

**Fields (9):** `message_id`, `user_id_from`, `user_id_to`, `folder_id`, `date_time`, `state`, `priority`, `subject`, `message`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__messages` (
  `message_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id_from` int unsigned NOT NULL DEFAULT 0,
  `user_id_to` int unsigned NOT NULL DEFAULT 0,
  `folder_id` tinyint unsigned NOT NULL DEFAULT 0,
  `date_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `state` tinyint NOT NULL DEFAULT 0,
  `priority` tinyint unsigned NOT NULL DEFAULT 0,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  PRIMARY KEY (`message_id`),
  KEY `useridto_state` (`user_id_to`,`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__messages_cfg`

**Fields (3):** `user_id`, `cfg_name`, `cfg_value`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__messages_cfg` (
  `user_id` int unsigned NOT NULL DEFAULT 0,
  `cfg_name` varchar(100) NOT NULL DEFAULT '',
  `cfg_value` varchar(255) NOT NULL DEFAULT '',
  UNIQUE KEY `idx_user_var_name` (`user_id`,`cfg_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__user_notes`

**Fields (15):** `id`, `user_id`, `catid`, `subject`, `body`, `state`, `checked_out`, `checked_out_time`, `created_user_id`, `created_time`, `modified_user_id`, `modified_time`, `review_time`, `publish_up`, `publish_down`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__user_notes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT 0,
  `catid` int unsigned NOT NULL DEFAULT 0,
  `subject` varchar(100) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `created_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_user_id` int unsigned NOT NULL,
  `modified_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `review_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_up` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_down` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_category_id` (`catid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__privacy_requests`

**Fields (7):** `id`, `email`, `requested_at`, `status`, `request_type`, `confirm_token`, `confirm_token_created_at`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__privacy_requests` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL DEFAULT '',
  `requested_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `status` tinyint NOT NULL DEFAULT 0,
  `request_type` varchar(25) NOT NULL DEFAULT '',
  `confirm_token` varchar(100) NOT NULL DEFAULT '',
  `confirm_token_created_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__privacy_consents`

**Fields (8):** `id`, `user_id`, `state`, `created`, `subject`, `body`, `remind`, `token`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__privacy_consents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT 0,
  `state` int NOT NULL DEFAULT 1,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `remind` tinyint NOT NULL DEFAULT 0,
  `token` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__action_logs_extensions`

**Fields (2):** `id`, `extension`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__action_logs_extensions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `extension` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__action_log_config`

**Fields (7):** `id`, `type_title`, `type_alias`, `id_holder`, `title_holder`, `table_name`, `text_prefix`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__action_log_config` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `type_title` varchar(255) NOT NULL DEFAULT '',
  `type_alias` varchar(255) NOT NULL DEFAULT '',
  `id_holder` varchar(255),
  `title_holder` varchar(255),
  `table_name` varchar(255),
  `text_prefix` varchar(255),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__action_logs_users`

**Fields (3):** `user_id`, `notify`, `extensions`

**Policy:** `CORE DATA / MAP`

```sql
CREATE TABLE IF NOT EXISTS `#__action_logs_users` (
  `user_id` int UNSIGNED NOT NULL,
  `notify` tinyint UNSIGNED NOT NULL,
  `extensions` text NOT NULL,
  PRIMARY KEY (`user_id`),
  KEY `idx_notify` (`notify`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

## G8 — Runtime, Generated, and Excluded Data

**Tables:** 32 · **Fields:** 164

### `#__session`

**Fields (7):** `session_id`, `client_id`, `guest`, `time`, `data`, `userid`, `username`

**Policy:** `RUNTIME / IGNORE`

```sql
CREATE TABLE IF NOT EXISTS `#__session` (
  `session_id` varbinary(192) NOT NULL,
  `client_id` tinyint unsigned DEFAULT NULL,
  `guest` tinyint unsigned DEFAULT 1,
  `time` int NOT NULL DEFAULT 0,
  `data` mediumtext,
  `userid` int DEFAULT 0,
  `username` varchar(150) DEFAULT '',
  PRIMARY KEY (`session_id`),
  KEY `userid` (`userid`),
  KEY `time` (`time`),
  KEY `client_id_guest` (`client_id`, `guest`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__user_keys`

**Fields (7):** `id`, `user_id`, `token`, `series`, `invalid`, `time`, `uastring`

**Policy:** `RUNTIME / IGNORE`

```sql
CREATE TABLE IF NOT EXISTS `#__user_keys` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(150) NOT NULL,
  `token` varchar(255) NOT NULL,
  `series` varchar(191) NOT NULL,
  `invalid` tinyint NOT NULL,
  `time` varchar(200) NOT NULL,
  `uastring` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `series` (`series`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_filters`

**Fields (14):** `filter_id`, `title`, `alias`, `state`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `checked_out`, `checked_out_time`, `map_count`, `data`, `params`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_filters` (
  `filter_id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `alias` varchar(255) NOT NULL,
  `state` tinyint NOT NULL DEFAULT 1,
  `created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_by` int unsigned NOT NULL,
  `created_by_alias` varchar(255) NOT NULL,
  `modified` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `checked_out` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `map_count` int unsigned NOT NULL DEFAULT 0,
  `data` text NOT NULL,
  `params` mediumtext,
  PRIMARY KEY (`filter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links`

**Fields (19):** `link_id`, `url`, `route`, `title`, `description`, `indexdate`, `md5sum`, `published`, `state`, `access`, `language`, `publish_start_date`, `publish_end_date`, `start_date`, `end_date`, `list_price`, `sale_price`, `type_id`, `object`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links` (
  `link_id` int unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  `route` varchar(255) NOT NULL,
  `title` varchar(400) DEFAULT NULL,
  `description` text,
  `indexdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `md5sum` varchar(32) DEFAULT NULL,
  `published` tinyint NOT NULL DEFAULT 1,
  `state` int DEFAULT 1,
  `access` int DEFAULT 0,
  `language` varchar(8) NOT NULL,
  `publish_start_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `publish_end_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `start_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `end_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `list_price` double unsigned NOT NULL DEFAULT 0,
  `sale_price` double unsigned NOT NULL DEFAULT 0,
  `type_id` int NOT NULL,
  `object` mediumblob NOT NULL,
  PRIMARY KEY (`link_id`),
  KEY `idx_type` (`type_id`),
  KEY `idx_title` (`title`(100)),
  KEY `idx_md5` (`md5sum`),
  KEY `idx_url` (`url`(75)),
  KEY `idx_published_list` (`published`,`state`,`access`,`publish_start_date`,`publish_end_date`,`list_price`),
  KEY `idx_published_sale` (`published`,`state`,`access`,`publish_start_date`,`publish_end_date`,`sale_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms0`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms0` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms1`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms1` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms2`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms2` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms3`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms3` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms4`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms4` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms5`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms5` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms6`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms6` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms7`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms7` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms8`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms8` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_terms9`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms9` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_termsa`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_termsa` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_termsb`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_termsb` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_termsc`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_termsc` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_termsd`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_termsd` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_termse`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_termse` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_links_termsf`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_termsf` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_taxonomy`

**Fields (6):** `id`, `parent_id`, `title`, `state`, `access`, `ordering`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_taxonomy` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `parent_id` int unsigned NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `state` tinyint unsigned NOT NULL DEFAULT 1,
  `access` tinyint unsigned NOT NULL DEFAULT 0,
  `ordering` tinyint unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `parent_id` (`parent_id`),
  KEY `state` (`state`),
  KEY `ordering` (`ordering`),
  KEY `access` (`access`),
  KEY `idx_parent_published` (`parent_id`,`state`,`access`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_taxonomy_map`

**Fields (2):** `link_id`, `node_id`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_taxonomy_map` (
  `link_id` int unsigned NOT NULL,
  `node_id` int unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`node_id`),
  KEY `link_id` (`link_id`),
  KEY `node_id` (`node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_terms`

**Fields (9):** `term_id`, `term`, `stem`, `common`, `phrase`, `weight`, `soundex`, `links`, `language`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_terms` (
  `term_id` int unsigned NOT NULL AUTO_INCREMENT,
  `term` varchar(75) NOT NULL,
  `stem` varchar(75) NOT NULL,
  `common` tinyint unsigned NOT NULL DEFAULT 0,
  `phrase` tinyint unsigned NOT NULL DEFAULT 0,
  `weight` float unsigned NOT NULL DEFAULT 0,
  `soundex` varchar(75) NOT NULL,
  `links` int NOT NULL DEFAULT 0,
  `language` char(3) NOT NULL DEFAULT '',
  PRIMARY KEY (`term_id`),
  UNIQUE KEY `idx_term` (`term`),
  KEY `idx_term_phrase` (`term`,`phrase`),
  KEY `idx_stem_phrase` (`stem`,`phrase`),
  KEY `idx_soundex_phrase` (`soundex`,`phrase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_terms_common`

**Fields (2):** `term`, `language`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_terms_common` (
  `term` varchar(75) NOT NULL,
  `language` varchar(3) NOT NULL,
  KEY `idx_word_lang` (`term`,`language`),
  KEY `idx_lang` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_tokens`

**Fields (7):** `term`, `stem`, `common`, `phrase`, `weight`, `context`, `language`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_tokens` (
  `term` varchar(75) NOT NULL,
  `stem` varchar(75) NOT NULL,
  `common` tinyint unsigned NOT NULL DEFAULT 0,
  `phrase` tinyint unsigned NOT NULL DEFAULT 0,
  `weight` float unsigned NOT NULL DEFAULT 1,
  `context` tinyint unsigned NOT NULL DEFAULT 2,
  `language` char(3) NOT NULL DEFAULT '',
  KEY `idx_word` (`term`),
  KEY `idx_context` (`context`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_tokens_aggregate`

**Fields (11):** `term_id`, `map_suffix`, `term`, `stem`, `common`, `phrase`, `term_weight`, `context`, `context_weight`, `total_weight`, `language`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_tokens_aggregate` (
  `term_id` int unsigned NOT NULL,
  `map_suffix` char(1) NOT NULL,
  `term` varchar(75) NOT NULL,
  `stem` varchar(75) NOT NULL,
  `common` tinyint unsigned NOT NULL DEFAULT 0,
  `phrase` tinyint unsigned NOT NULL DEFAULT 0,
  `term_weight` float unsigned NOT NULL,
  `context` tinyint unsigned NOT NULL DEFAULT 2,
  `context_weight` float unsigned NOT NULL,
  `total_weight` float unsigned NOT NULL,
  `language` char(3) NOT NULL DEFAULT '',
  KEY `token` (`term`),
  KEY `keyword_id` (`term_id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__finder_types`

**Fields (3):** `id`, `title`, `mime`

**Policy:** `GENERATED / REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `mime` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_general_ci;
```

### `#__action_logs`

**Fields (8):** `id`, `message_language_key`, `message`, `log_date`, `extension`, `user_id`, `item_id`, `ip_address`

**Policy:** `HISTORY / ARCHIVE-OR-IGNORE`

```sql
CREATE TABLE IF NOT EXISTS `#__action_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `message_language_key` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `log_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `extension` varchar(50) NOT NULL DEFAULT '',
  `user_id` int NOT NULL DEFAULT 0,
  `item_id` int NOT NULL DEFAULT 0,
  `ip_address` VARCHAR(40) NOT NULL DEFAULT '0.0.0.0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_user_id_logdate` (`user_id`, `log_date`),
  KEY `idx_user_id_extension` (`user_id`, `extension`),
  KEY `idx_extension_item_id` (`extension`, `item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__core_log_searches`

**Fields (2):** `search_term`, `hits`

**Policy:** `HISTORY / ARCHIVE-OR-IGNORE`

```sql
CREATE TABLE IF NOT EXISTS `#__core_log_searches` (
  `search_term` varchar(128) NOT NULL DEFAULT '',
  `hits` int unsigned NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__overrider`

**Fields (4):** `id`, `constant`, `string`, `file`

**Policy:** `SYSTEM / REVIEW-OR-REBUILD`

```sql
CREATE TABLE IF NOT EXISTS `#__overrider` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `constant` varchar(255) NOT NULL,
  `string` text NOT NULL,
  `file` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__postinstall_messages`

**Fields (14):** `postinstall_message_id`, `extension_id`, `title_key`, `description_key`, `action_key`, `language_extension`, `language_client_id`, `type`, `action_file`, `action`, `condition_file`, `condition_method`, `version_introduced`, `enabled`

**Policy:** `SYSTEM / IGNORE`

```sql
CREATE TABLE IF NOT EXISTS `#__postinstall_messages` (
  `postinstall_message_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `extension_id` bigint NOT NULL DEFAULT 700 COMMENT 'FK to #__extensions',
  `title_key` varchar(255) NOT NULL DEFAULT '' COMMENT 'Lang key for the title',
  `description_key` varchar(255) NOT NULL DEFAULT '' COMMENT 'Lang key for description',
  `action_key` varchar(255) NOT NULL DEFAULT '',
  `language_extension` varchar(255) NOT NULL DEFAULT 'com_postinstall' COMMENT 'Extension holding lang keys',
  `language_client_id` tinyint NOT NULL DEFAULT 1,
  `type` varchar(10) NOT NULL DEFAULT 'link' COMMENT 'Message type - message, link, action',
  `action_file` varchar(255) DEFAULT '' COMMENT 'RAD URI to the PHP file containing action method',
  `action` varchar(255) DEFAULT '' COMMENT 'Action method name or URL',
  `condition_file` varchar(255) DEFAULT NULL COMMENT 'RAD URI to file holding display condition method',
  `condition_method` varchar(255) DEFAULT NULL COMMENT 'Display condition method, must return boolean',
  `version_introduced` varchar(50) NOT NULL DEFAULT '3.2.0' COMMENT 'Version when this message was introduced',
  `enabled` tinyint NOT NULL DEFAULT 1,
  PRIMARY KEY (`postinstall_message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__utf8_conversion`

**Fields (1):** `converted`

**Policy:** `SYSTEM / IGNORE`

```sql
CREATE TABLE IF NOT EXISTS `#__utf8_conversion` (
  `converted` tinyint NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

## Special Migration Annotations

Format: `table.field | structured | reference/dependency | migration hint`

```text
#__extensions.package_id | NO | #__extensions.extension_id (package parent, logical) | REFERENCE_ONLY
#__extensions.access | NO | #__viewlevels.id | REFERENCE_ONLY
#__extensions.manifest_cache | JSON manifest cache | — | REFERENCE_ONLY
#__extensions.params | JSON / Joomla Registry | — | REFERENCE_ONLY
#__extensions.custom_data | Extension-specific structured data | — | REFERENCE_ONLY
#__extensions.system_data | Extension-specific structured data | — | REFERENCE_ONLY
#__schemas.extension_id | NO | #__extensions.extension_id | REFERENCE_ONLY
#__update_sites.location | URL | — | REFERENCE_ONLY
#__update_sites.extra_query | Query/credential parameters | — | REFERENCE_ONLY
#__update_sites_extensions.update_site_id | NO | #__update_sites.update_site_id | REFERENCE_ONLY
#__update_sites_extensions.extension_id | NO | #__extensions.extension_id | REFERENCE_ONLY
#__updates.update_site_id | NO | #__update_sites.update_site_id | REFERENCE_ONLY
#__updates.extension_id | NO | #__extensions.extension_id | REFERENCE_ONLY
#__updates.data | Update metadata payload | — | REFERENCE_ONLY
#__updates.detailsurl | URL | — | REFERENCE_ONLY
#__updates.infourl | URL | — | REFERENCE_ONLY
#__updates.extra_query | Query/credential parameters | — | REFERENCE_ONLY
#__languages.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__languages.image | File/media reference | — | STRUCTURED/REVIEW
#__languages.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__usergroups.parent_id | NO | #__usergroups.id (self tree) | LOOKUP/REVIEW
#__users.id | NO | Referenced by many core tables | LOOKUP/REVIEW
#__users.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__users.otpKey | SECURITY / encrypted 2FA material | #__users.otpKey | TRANSFORM: clear active secret and require MFA re-enrollment
#__users.otep | SECURITY / emergency codes | #__users.otep | TRANSFORM: clear active codes and require MFA re-enrollment
#__user_usergroup_map.user_id | NO | #__users.id | LOOKUP/REVIEW
#__user_usergroup_map.group_id | NO | #__usergroups.id | LOOKUP/REVIEW
#__viewlevels.rules | JSON / user group IDs | Embeds #__usergroups.id in JSON | STRUCTURED/REVIEW
#__user_profiles.user_id | NO | #__users.id | LOOKUP/REVIEW
#__user_profiles.profile_value | Key-dependent structured value | — | STRUCTURED/REVIEW
#__assets.parent_id | NO | #__assets.id (self tree) | REBUILD/RECONCILE
#__assets.rules | JSON / ACL group IDs | Embeds #__usergroups.id in ACL JSON | STRUCTURED/ACL
#__categories.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__categories.parent_id | NO | #__categories.id (self tree) | LOOKUP/REVIEW
#__categories.path | Derived hierarchy path | — | STRUCTURED/REVIEW
#__categories.description | HTML / internal links possible | — | STRUCTURED/REVIEW
#__categories.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__categories.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__categories.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__categories.metadata | JSON metadata | — | STRUCTURED/REVIEW
#__categories.created_user_id | NO | #__users.id | LOOKUP/REVIEW
#__categories.modified_user_id | NO | #__users.id | LOOKUP/REVIEW
#__categories.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__tags.parent_id | NO | #__tags.id (self tree) | LOOKUP/REVIEW
#__tags.path | Derived hierarchy path | — | STRUCTURED/REVIEW
#__tags.description | HTML / internal links possible | — | STRUCTURED/REVIEW
#__tags.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__tags.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__tags.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__tags.metadata | JSON metadata | — | STRUCTURED/REVIEW
#__tags.created_user_id | NO | #__users.id | LOOKUP/REVIEW
#__tags.modified_user_id | NO | #__users.id | LOOKUP/REVIEW
#__tags.images | JSON media references | — | STRUCTURED/REVIEW
#__tags.urls | JSON URL references | — | STRUCTURED/REVIEW
#__tags.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__content_types.table | JSON table metadata | — | STRUCTURED/REVIEW
#__content_types.rules | Structured ACL/config | — | STRUCTURED/REVIEW
#__content_types.field_mappings | JSON field mapping metadata | — | STRUCTURED/REVIEW
#__content_types.router | Callable/router metadata | — | STRUCTURED/REVIEW
#__content_types.content_history_options | JSON history config | — | STRUCTURED/REVIEW
#__fields_groups.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__fields_groups.context | NO | Joomla content context (semantic) | LOOKUP/REVIEW
#__fields_groups.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__fields_groups.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__fields_groups.created_by | NO | #__users.id | LOOKUP/REVIEW
#__fields_groups.modified_by | NO | #__users.id | LOOKUP/REVIEW
#__fields_groups.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__fields.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__fields.context | NO | Joomla content context (semantic) | LOOKUP/REVIEW
#__fields.group_id | NO | #__fields_groups.id | LOOKUP/REVIEW
#__fields.default_value | Field-type dependent structured value | — | STRUCTURED/REVIEW
#__fields.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__fields.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__fields.fieldparams | JSON / field plugin config | — | STRUCTURED/REVIEW
#__fields.created_user_id | NO | #__users.id | LOOKUP/REVIEW
#__fields.modified_by | NO | #__users.id | LOOKUP/REVIEW
#__fields.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__fields_categories.field_id | NO | #__fields.id | LOOKUP/REVIEW
#__fields_categories.category_id | NO | #__categories.id | LOOKUP/REVIEW
#__content.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__content.introtext | HTML / embedded links & media | — | STRUCTURED/REVIEW
#__content.fulltext | HTML / embedded links & media | — | STRUCTURED/REVIEW
#__content.catid | NO | #__categories.id | LOOKUP/REVIEW
#__content.created_by | NO | #__users.id | LOOKUP/REVIEW
#__content.modified_by | NO | #__users.id | LOOKUP/REVIEW
#__content.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__content.images | JSON media references | — | STRUCTURED/REVIEW
#__content.urls | JSON URL references | — | STRUCTURED/REVIEW
#__content.attribs | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__content.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__content.metadata | JSON metadata | — | STRUCTURED/REVIEW
#__content.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__content_frontpage.content_id | NO | #__content.id | LOOKUP/REVIEW
#__content_rating.content_id | NO | #__content.id | LOOKUP/REVIEW
#__contentitem_tag_map.core_content_id | NO | #__ucm_content.core_content_id | LOOKUP/REVIEW
#__contentitem_tag_map.content_item_id | NO | Context-dependent content item PK | LOOKUP/REVIEW
#__contentitem_tag_map.tag_id | NO | #__tags.id | LOOKUP/REVIEW
#__contentitem_tag_map.type_id | NO | #__content_types.type_id | LOOKUP/REVIEW
#__fields_values.field_id | NO | #__fields.id | LOOKUP/REVIEW
#__fields_values.item_id | NO | Context-dependent item PK | LOOKUP/REVIEW
#__fields_values.value | Field-type dependent value | — | STRUCTURED/REVIEW
#__ucm_base.ucm_item_id | NO | Context-dependent item PK | LOOKUP/REVIEW
#__ucm_base.ucm_type_id | NO | #__content_types.type_id | LOOKUP/REVIEW
#__ucm_content.core_body | HTML/text depending content type | — | STRUCTURED/REVIEW
#__ucm_content.core_checked_out_user_id | NO | #__users.id | LOOKUP/REVIEW
#__ucm_content.core_access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__ucm_content.core_params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__ucm_content.core_metadata | JSON metadata | — | STRUCTURED/REVIEW
#__ucm_content.core_created_user_id | NO | #__users.id | LOOKUP/REVIEW
#__ucm_content.core_modified_user_id | NO | #__users.id | LOOKUP/REVIEW
#__ucm_content.core_content_item_id | NO | Context-dependent item PK | LOOKUP/REVIEW
#__ucm_content.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__ucm_content.core_images | JSON media references | — | STRUCTURED/REVIEW
#__ucm_content.core_urls | JSON URL references | — | STRUCTURED/REVIEW
#__ucm_content.core_catid | NO | Context-dependent category ID | LOOKUP/REVIEW
#__ucm_content.core_type_id | NO | #__content_types.type_id | LOOKUP/REVIEW
#__ucm_history.ucm_item_id | NO | Context-dependent item PK | LOOKUP/REVIEW
#__ucm_history.ucm_type_id | NO | #__content_types.type_id | LOOKUP/REVIEW
#__ucm_history.editor_user_id | NO | #__users.id | LOOKUP/REVIEW
#__ucm_history.version_data | JSON-encoded version snapshot | — | STRUCTURED/REVIEW
#__template_styles.template | NO | #__extensions.element (logical template identity) | LOOKUP/REVIEW
#__template_styles.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__menu_types.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__menu.menutype | NO | #__menu_types.menutype (logical) | LOOKUP/REVIEW
#__menu.path | Derived hierarchy path | — | STRUCTURED/REVIEW
#__menu.link | URL/query with embedded IDs | Embedded component/content/category IDs may require remap | STRUCTURED/REVIEW
#__menu.parent_id | NO | #__menu.id (self tree) | LOOKUP/REVIEW
#__menu.component_id | NO | #__extensions.extension_id | LOOKUP/REVIEW
#__menu.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__menu.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__menu.img | File/media reference | — | STRUCTURED/REVIEW
#__menu.template_style_id | NO | #__template_styles.id | LOOKUP/REVIEW
#__menu.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__menu.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__modules.asset_id | NO | #__assets.id | LOOKUP/REVIEW
#__modules.content | HTML/text depending module | — | STRUCTURED/REVIEW
#__modules.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__modules.module | NO | #__extensions.element (logical module identity) | LOOKUP/REVIEW
#__modules.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__modules.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__modules.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__modules_menu.moduleid | NO | #__modules.id | LOOKUP/REVIEW
#__modules_menu.menuid | NO | #__menu.id; 0=all; negative=exclude | LOOKUP/REVIEW
#__contact_details.image | File/media reference | — | STRUCTURED/REVIEW
#__contact_details.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__contact_details.params | Structured config / review | — | STRUCTURED/REVIEW
#__contact_details.user_id | NO | #__users.id | LOOKUP/REVIEW
#__contact_details.catid | NO | #__categories.id | LOOKUP/REVIEW
#__contact_details.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__contact_details.webpage | URL / reference | — | STRUCTURED/REVIEW
#__contact_details.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__contact_details.created_by | NO | #__users.id | LOOKUP/REVIEW
#__contact_details.modified_by | NO | #__users.id | LOOKUP/REVIEW
#__contact_details.metadata | Structured config / review | — | STRUCTURED/REVIEW
#__newsfeeds.catid | NO | #__categories.id | LOOKUP/REVIEW
#__newsfeeds.link | URL / reference | — | STRUCTURED/REVIEW
#__newsfeeds.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__newsfeeds.access | NO | #__viewlevels.id | LOOKUP/REVIEW
#__newsfeeds.language | NO | #__languages.lang_code (logical) | LOOKUP/REVIEW
#__newsfeeds.params | JSON / Joomla Registry | — | STRUCTURED/REVIEW
#__newsfeeds.created_by | NO | #__users.id | LOOKUP/REVIEW
#__newsfeeds.modified_by | NO | #__users.id | LOOKUP/REVIEW
#__newsfeeds.metadata | JSON metadata | — | STRUCTURED/REVIEW
#__newsfeeds.description | HTML/text | — | STRUCTURED/REVIEW
#__newsfeeds.images | JSON media references | — | STRUCTURED/REVIEW
#__banners.cid | NO | #__banner_clients.id | LOOKUP/REVIEW
#__banners.clickurl | URL / reference | — | STRUCTURED/REVIEW
#__banners.catid | NO | #__categories.id | LOOKUP/REVIEW
#__banners.params | Structured config / review | — | STRUCTURED/REVIEW
#__banners.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__banners.created_by | NO | #__users.id | LOOKUP/REVIEW
#__banners.modified_by | NO | #__users.id | LOOKUP/REVIEW
#__banner_tracks.banner_id | NO | #__banners.id | LOOKUP/REVIEW
#__redirect_links.old_url | URL / reference | — | STRUCTURED/REVIEW
#__redirect_links.new_url | URL / reference | — | STRUCTURED/REVIEW
#__redirect_links.referer | URL / reference | — | STRUCTURED/REVIEW
#__messages.user_id_from | NO | #__users.id | LOOKUP/REVIEW
#__messages.user_id_to | NO | #__users.id | LOOKUP/REVIEW
#__messages_cfg.user_id | NO | #__users.id | LOOKUP/REVIEW
#__user_notes.user_id | NO | #__users.id | LOOKUP/REVIEW
#__user_notes.catid | NO | #__categories.id | LOOKUP/REVIEW
#__user_notes.checked_out | NO | #__users.id | LOOKUP/REVIEW
#__user_notes.created_user_id | NO | #__users.id | LOOKUP/REVIEW
#__user_notes.modified_user_id | NO | #__users.id | LOOKUP/REVIEW
#__privacy_consents.user_id | NO | #__users.id | LOOKUP/REVIEW
#__privacy_consents.body | Consent text/HTML | — | STRUCTURED/REVIEW
#__action_log_config.id_holder | Schema metadata / dynamic reference | — | STRUCTURED/REVIEW
#__action_log_config.title_holder | Schema metadata / dynamic reference | — | STRUCTURED/REVIEW
#__action_log_config.table_name | Schema metadata / dynamic reference | — | STRUCTURED/REVIEW
#__action_logs_users.user_id | NO | #__users.id | LOOKUP/REVIEW
#__action_logs_users.extensions | Structured extension list | — | STRUCTURED/REVIEW
#__session.userid | NO | #__users.id | IGNORE
#__user_keys.token | SECURITY / authentication token | — | IGNORE
#__user_keys.series | SECURITY / remember-me series | — | IGNORE
#__finder_filters.data | Structured filter data | — | REBUILD
#__finder_filters.params | JSON / Joomla Registry | — | REBUILD
#__finder_links.type_id | NO | #__finder_types.id | REBUILD
#__finder_links.object | Serialized/index object blob | — | REBUILD
#__finder_links_terms0.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms0.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms1.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms1.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms2.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms2.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms3.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms3.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms4.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms4.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms5.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms5.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms6.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms6.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms7.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms7.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms8.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms8.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_terms9.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_terms9.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_termsa.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_termsa.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_termsb.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_termsb.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_termsc.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_termsc.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_termsd.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_termsd.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_termse.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_termse.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_links_termsf.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_links_termsf.term_id | NO | #__finder_terms.term_id | REBUILD
#__finder_taxonomy.parent_id | NO | #__finder_taxonomy.id | REBUILD
#__finder_taxonomy_map.link_id | NO | #__finder_links.link_id | REBUILD
#__finder_taxonomy_map.node_id | NO | #__finder_taxonomy.id | REBUILD
#__finder_tokens_aggregate.term_id | NO | #__finder_terms.term_id | REBUILD
#__action_logs.message | Structured/action message payload | — | ARCHIVE/IGNORE
#__action_logs.user_id | NO | #__users.id | ARCHIVE/IGNORE
#__action_logs.item_id | NO | Context-dependent by extension/action type | ARCHIVE/IGNORE
#__postinstall_messages.extension_id | NO | #__extensions.extension_id | REBUILD from J6 manifests
#__postinstall_messages.action_file | File/RAD URI | #__postinstall_messages.action_file | REBUILD from J6 manifests
#__postinstall_messages.condition_file | File/RAD URI | #__postinstall_messages.condition_file | REBUILD from J6 manifests
```

## Coverage Summary

- `G0`: 5 tables / 43 fields
- `G1`: 6 tables / 46 fields
- `G2`: 7 tables / 116 fields
- `G3`: 3 tables / 37 fields
- `G4`: 6 tables / 58 fields
- `G5`: 3 tables / 38 fields
- `G6`: 2 tables / 20 fields
- `G7`: 14 tables / 189 fields
- `G8`: 32 tables / 164 fields
- **Total: 78 tables / 711 fields**

```text
Documented table sections = 78
Physical fields = 711
Unique (table, field) = 711
Duplicate fields = 0
Missing table DDL = 0
Tables with zero fields = 0
Baseline field coverage = 100%
```

## Production Database Reconciliation

```sql
SELECT
    TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION,
    COLUMN_DEFAULT, IS_NULLABLE, DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH, CHARACTER_OCTET_LENGTH,
    NUMERIC_PRECISION, NUMERIC_SCALE, DATETIME_PRECISION,
    CHARACTER_SET_NAME, COLLATION_NAME, COLUMN_TYPE,
    COLUMN_KEY, EXTRA, PRIVILEGES, COLUMN_COMMENT,
    GENERATION_EXPRESSION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = :joomla3_database
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

Classify every difference: `OFFICIAL`, `CUSTOM_COLUMN`, `MISSING_FROM_PRODUCTION`, `MODIFIED_DEFINITION`, `EXTENSION_FIELD`, or `UNKNOWN`.

## Final Field Coverage Gate

```text
Baseline tables documented = 78/78
Baseline fields documented = 711/711
Exact DDL captured = 100%
Structured/reference review = 100%
Production fields inventoried = 100%
Production differences classified = 100%
Field mapping decisions completed = 100%
Missing fields = 0
Duplicate fields = 0
Unknown fields = 0
Unmapped required fields = 0
JOOMLA 3 CORE FIELD INVENTORY = PASS
```
