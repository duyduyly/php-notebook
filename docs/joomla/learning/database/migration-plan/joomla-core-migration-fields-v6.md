# Joomla Core Migration Field Inventory — Joomla 6

## Inventory Rule

> **Inventory = YES**  
> **Field inventory = 100%**  
> **Mapping decision = required before migration**

Source of truth: Joomla CMS `6.1.2` official MySQL fresh-install DDL:

- `installation/sql/mysql/base.sql`
- `installation/sql/mysql/extensions.sql`
- `installation/sql/mysql/supports.sql`

Companion: [`joomla-core-migration-groups-v6.md`](./joomla-core-migration-groups-v6.md)

```text
Core tables = 76
Physical fields = 832
Unique (table, field) = 832
Duplicates = 0
Missing official tables = 0
Missing official fields = 0
Baseline physical field coverage = 100%
```

> `100%` is the official Joomla 6.1.2 fresh-install baseline. Production must still be reconciled with `information_schema.COLUMNS`.

## Metadata Contract

For every table this file preserves the ordered field list and exact official `CREATE TABLE` DDL. The DDL preserves data type, full type, length/precision/scale, nullability, default, auto-increment/extra attributes, charset/collation, comments, generated/runtime expressions, exact indexes/keys, engine, table collation, and table comment where present.

Migration policy is separate from the physical schema definition.

## G0 — System Reference

**Tables:** 6 · **Fields:** 55

### `#__extensions`

**Fields (20):** `extension_id`, `package_id`, `name`, `type`, `element`, `changelogurl`, `folder`, `client_id`, `enabled`, `access`, `protected`, `locked`, `manifest_cache`, `params`, `custom_data`, `checked_out`, `checked_out_time`, `ordering`, `state`, `note`

**Policy:** `REFERENCE_ONLY / TARGET_OWNED`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__extensions` (
  `extension_id` int NOT NULL AUTO_INCREMENT,
  `package_id` int NOT NULL DEFAULT 0 COMMENT 'Parent package ID for extensions installed as a package.',
  `name` varchar(100) NOT NULL,
  `type` varchar(20) NOT NULL,
  `element` varchar(100) NOT NULL,
  `changelogurl` text,
  `folder` varchar(100) NOT NULL,
  `client_id` tinyint NOT NULL,
  `enabled` tinyint NOT NULL DEFAULT 0,
  `access` int unsigned NOT NULL DEFAULT 1,
  `protected` tinyint NOT NULL DEFAULT 0 COMMENT 'Flag to indicate if the extension is protected. Protected extensions cannot be disabled.',
  `locked` tinyint NOT NULL DEFAULT 0 COMMENT 'Flag to indicate if the extension is locked. Locked extensions cannot be uninstalled.',
  `manifest_cache` text NOT NULL,
  `params` text NOT NULL,
  `custom_data` text NOT NULL,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `ordering` int DEFAULT 0,
  `state` int DEFAULT 0,
  `note` varchar(255),
  PRIMARY KEY (`extension_id`),
  KEY `element_clientid` (`element`,`client_id`),
  KEY `element_folder_clientid` (`element`,`folder`,`client_id`),
  KEY `extension` (`type`,`element`,`folder`,`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__schemas`

**Fields (2):** `extension_id`, `version_id`

**Policy:** `REFERENCE_ONLY / TARGET_OWNED`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__schemas` (
  `extension_id` int NOT NULL,
  `version_id` varchar(20) NOT NULL,
  PRIMARY KEY (`extension_id`,`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__update_sites`

**Fields (9):** `update_site_id`, `name`, `type`, `location`, `enabled`, `last_check_timestamp`, `extra_query`, `checked_out`, `checked_out_time`

**Policy:** `REFERENCE_ONLY / TARGET_OWNED`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__update_sites` (
  `update_site_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT '',
  `type` varchar(20) DEFAULT '',
  `location` text NOT NULL,
  `enabled` int DEFAULT 0,
  `last_check_timestamp` bigint DEFAULT 0,
  `extra_query` varchar(1000) DEFAULT '',
  `checked_out` int unsigned,
  `checked_out_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`update_site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Update Sites';
```

### `#__update_sites_extensions`

**Fields (2):** `update_site_id`, `extension_id`

**Policy:** `REFERENCE_ONLY / TARGET_OWNED`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__update_sites_extensions` (
  `update_site_id` int NOT NULL DEFAULT 0,
  `extension_id` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`update_site_id`,`extension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Links extensions to update sites';
```

### `#__updates`

**Fields (15):** `update_id`, `update_site_id`, `extension_id`, `name`, `description`, `element`, `type`, `folder`, `client_id`, `version`, `data`, `detailsurl`, `infourl`, `changelogurl`, `extra_query`

**Policy:** `REFERENCE_ONLY / TARGET_OWNED`  
**Official source:** `base.sql`

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
  `changelogurl` text,
  `extra_query` varchar(1000) DEFAULT '',
  PRIMARY KEY (`update_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Available Updates';
```

### `#__tuf_metadata`

**Fields (7):** `id`, `update_site_id`, `root`, `targets`, `snapshot`, `timestamp`, `mirrors`

**Policy:** `REFERENCE_ONLY / TARGET_OWNED`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__tuf_metadata` (
  `id` int NOT NULL AUTO_INCREMENT,
  `update_site_id` int DEFAULT 0,
  `root` text DEFAULT NULL,
  `targets` text DEFAULT NULL,
  `snapshot` text DEFAULT NULL,
  `timestamp` text DEFAULT NULL,
  `mirrors` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Secure TUF Updates';
```

---

## G1 — Users and Access Foundation

**Tables:** 6 · **Fields:** 46

### `#__languages`

**Fields (14):** `lang_id`, `asset_id`, `lang_code`, `title`, `title_native`, `sef`, `image`, `description`, `metakey`, `metadesc`, `sitename`, `published`, `access`, `ordering`

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

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
  `metakey` text,
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(400) NOT NULL DEFAULT '',
  `username` varchar(150) NOT NULL DEFAULT '',
  `email` varchar(100) NOT NULL DEFAULT '',
  `password` varchar(100) NOT NULL DEFAULT '',
  `block` tinyint NOT NULL DEFAULT 0,
  `sendEmail` tinyint DEFAULT 0,
  `registerDate` datetime NOT NULL,
  `lastvisitDate` datetime,
  `activation` varchar(100) NOT NULL DEFAULT '',
  `params` text NOT NULL,
  `lastResetTime` datetime COMMENT 'Date of last password reset',
  `resetCount` int NOT NULL DEFAULT 0 COMMENT 'Count of password resets since lastResetTime',
  `otpKey` varchar(1000) NOT NULL DEFAULT '' COMMENT 'Two factor authentication encrypted keys',
  `otep` varchar(1000) NOT NULL DEFAULT '' COMMENT 'Backup Codes',
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__user_usergroup_map` (
  `user_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Foreign Key to #__users.id',
  `group_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Foreign Key to #__usergroups.id',
  PRIMARY KEY (`user_id`,`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__viewlevels`

**Fields (4):** `id`, `title`, `ordering`, `rules`

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__user_profiles` (
  `user_id` int NOT NULL,
  `profile_key` varchar(100) NOT NULL,
  `profile_value` text NOT NULL,
  `ordering` int NOT NULL DEFAULT 0,
  UNIQUE KEY `idx_user_id_profile_key` (`user_id`,`profile_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Simple user profile storage table';
```

---

## G2 — Taxonomy and Shared Definitions

**Tables:** 10 · **Fields:** 154

### `#__assets`

**Fields (8):** `id`, `parent_id`, `lft`, `rgt`, `level`, `name`, `title`, `rules`

**Policy:** `REBUILD / RECONCILE`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__assets` (
  `id` int unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `parent_id` int NOT NULL DEFAULT 0 COMMENT 'Nested set parent.',
  `lft` int NOT NULL DEFAULT 0 COMMENT 'Nested set lft.',
  `rgt` int NOT NULL DEFAULT 0 COMMENT 'Nested set rgt.',
  `level` int unsigned NOT NULL COMMENT 'The cached level in the nested tree.',
  `name` varchar(50) NOT NULL COMMENT 'The unique name for the asset.',
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

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
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `access` int unsigned NOT NULL DEFAULT 0,
  `params` text,
  `metadesc` varchar(1024) NOT NULL DEFAULT '' COMMENT 'The meta description for the page.',
  `metakey` varchar(1024) NOT NULL DEFAULT '' COMMENT 'The keywords for the page.',
  `metadata` varchar(2048) NOT NULL DEFAULT '' COMMENT 'JSON encoded metadata properties.',
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `created_time` datetime NOT NULL,
  `modified_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL,
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

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
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `access` int unsigned NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `metadesc` varchar(1024) NOT NULL COMMENT 'The meta description for the page.',
  `metakey` varchar(1024) NOT NULL DEFAULT '' COMMENT 'The keywords for the page.',
  `metadata` varchar(2048) NOT NULL COMMENT 'JSON encoded metadata properties.',
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `created_time` datetime NOT NULL,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL,
  `images` text NOT NULL,
  `urls` text NOT NULL,
  `hits` int unsigned NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL,
  `version` int unsigned NOT NULL DEFAULT 1,
  `publish_up` datetime,
  `publish_down` datetime,
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

**Policy:** `REFERENCE_ONLY / MAP`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__content_types` (
  `type_id` int unsigned NOT NULL AUTO_INCREMENT,
  `type_title` varchar(255) NOT NULL DEFAULT '',
  `type_alias` varchar(400) NOT NULL DEFAULT '',
  `table` varchar(2048) NOT NULL DEFAULT '',
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__fields_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0,
  `context` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `ordering` int NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `language` char(7) NOT NULL DEFAULT '',
  `created` datetime NOT NULL,
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `modified` datetime NOT NULL,
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

**Fields (25):** `id`, `asset_id`, `context`, `group_id`, `title`, `name`, `label`, `default_value`, `type`, `note`, `description`, `state`, `required`, `only_use_in_subform`, `checked_out`, `checked_out_time`, `ordering`, `params`, `fieldparams`, `language`, `created_time`, `created_user_id`, `modified_time`, `modified_by`, `access`

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

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
  `only_use_in_subform` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `ordering` int NOT NULL DEFAULT 0,
  `params` text NOT NULL,
  `fieldparams` mediumtext NOT NULL,
  `language` char(7) NOT NULL DEFAULT '',
  `created_time` datetime NOT NULL,
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL,
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__fields_categories` (
  `field_id` int NOT NULL DEFAULT 0,
  `category_id` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`field_id`,`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__workflows`

**Fields (14):** `id`, `asset_id`, `published`, `title`, `description`, `extension`, `default`, `ordering`, `created`, `created_by`, `modified`, `modified_by`, `checked_out_time`, `checked_out`

**Policy:** `RECREATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__workflows` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int DEFAULT 0,
  `published` tinyint NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `extension` varchar(50) NOT NULL,
  `default` tinyint NOT NULL  DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  `created` datetime NOT NULL,
  `created_by` int NOT NULL DEFAULT 0,
  `modified` datetime NOT NULL,
  `modified_by` int NOT NULL DEFAULT 0,
  `checked_out_time` datetime,
  `checked_out` int unsigned,
  PRIMARY KEY (`id`),
  KEY `idx_asset_id` (`asset_id`),
  KEY `idx_title` (`title`(191)),
  KEY `idx_extension` (`extension`),
  KEY `idx_default` (`default`),
  KEY `idx_created` (`created`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_modified` (`modified`),
  KEY `idx_modified_by` (`modified_by`),
  KEY `idx_checked_out` (`checked_out`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__workflow_stages`

**Fields (11):** `id`, `asset_id`, `ordering`, `workflow_id`, `published`, `title`, `description`, `default`, `position`, `checked_out_time`, `checked_out`

**Policy:** `RECREATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__workflow_stages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  `workflow_id` int NOT NULL,
  `published` tinyint NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `default` tinyint NOT NULL DEFAULT 0,
  `position` text,
  `checked_out_time` datetime,
  `checked_out` int unsigned,
  PRIMARY KEY (`id`),
  KEY `idx_workflow_id` (`workflow_id`),
  KEY `idx_checked_out` (`checked_out`),
  KEY `idx_title` (`title`(191)),
  KEY `idx_asset_id` (`asset_id`),
  KEY `idx_default` (`default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__workflow_transitions`

**Fields (12):** `id`, `asset_id`, `ordering`, `workflow_id`, `published`, `title`, `description`, `from_stage_id`, `to_stage_id`, `options`, `checked_out_time`, `checked_out`

**Policy:** `RECREATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__workflow_transitions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  `workflow_id` int NOT NULL,
  `published` tinyint NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `from_stage_id` int NOT NULL,
  `to_stage_id` int NOT NULL,
  `options` text NOT NULL,
  `checked_out_time` datetime,
  `checked_out` int unsigned,
  PRIMARY KEY (`id`),
  KEY `idx_title` (`title`(191)),
  KEY `idx_asset_id` (`asset_id`),
  KEY `idx_checked_out` (`checked_out`),
  KEY `idx_from_stage_id` (`from_stage_id`),
  KEY `idx_to_stage_id` (`to_stage_id`),
  KEY `idx_workflow_id` (`workflow_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

---

## G3 — Main Content

**Tables:** 3 · **Fields:** 38

### `#__content`

**Fields (30):** `id`, `asset_id`, `title`, `alias`, `introtext`, `fulltext`, `state`, `catid`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `checked_out`, `checked_out_time`, `publish_up`, `publish_down`, `images`, `urls`, `attribs`, `version`, `ordering`, `metakey`, `metadesc`, `access`, `hits`, `metadata`, `featured`, `language`, `note`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

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
  `created` datetime NOT NULL,
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL,
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime NULL DEFAULT NULL,
  `publish_up` datetime NULL DEFAULT NULL,
  `publish_down` datetime NULL DEFAULT NULL,
  `images` text NOT NULL,
  `urls` text NOT NULL,
  `attribs` varchar(5120) NOT NULL,
  `version` int unsigned NOT NULL DEFAULT 1,
  `ordering` int NOT NULL DEFAULT 0,
  `metakey` text,
  `metadesc` text NOT NULL,
  `access` int unsigned NOT NULL DEFAULT 0,
  `hits` int unsigned NOT NULL DEFAULT 0,
  `metadata` text NOT NULL,
  `featured` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'Set if article is featured.',
  `language` char(7) NOT NULL COMMENT 'The language code for the article.',
  `note` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`state`),
  KEY `idx_catid` (`catid`),
  KEY `idx_createdby` (`created_by`),
  KEY `idx_featured_catid` (`featured`,`catid`),
  KEY `idx_language` (`language`),
  KEY `idx_alias` (`alias`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__content_frontpage`

**Fields (4):** `content_id`, `ordering`, `featured_up`, `featured_down`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__content_frontpage` (
  `content_id` int NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  `featured_up` datetime,
  `featured_down` datetime,
  PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__content_rating`

**Fields (4):** `content_id`, `rating_sum`, `rating_count`, `lastip`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__content_rating` (
  `content_id` int NOT NULL DEFAULT 0,
  `rating_sum` int unsigned NOT NULL DEFAULT 0,
  `rating_count` int unsigned NOT NULL DEFAULT 0,
  `lastip` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

---

## G4 — Content Relations

**Tables:** 8 · **Fields:** 66

### `#__contentitem_tag_map`

**Fields (6):** `type_alias`, `core_content_id`, `content_item_id`, `tag_id`, `tag_date`, `type_id`

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

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

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__fields_values` (
  `field_id` int unsigned NOT NULL,
  `item_id` varchar(255) NOT NULL COMMENT 'Allow references to items which have strings as ids, eg. none db systems.',
  `value` mediumtext,
  KEY `idx_field_id` (`field_id`),
  KEY `idx_item_id` (`item_id`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__associations`

**Fields (3):** `id`, `context`, `key`

**Policy:** `MIGRATE / MAP`  
**Official source:** `supports.sql`

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

**Policy:** `REBUILD / VALIDATE`  
**Official source:** `supports.sql`

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

**Fields (31):** `core_content_id`, `core_type_alias`, `core_title`, `core_alias`, `core_body`, `core_state`, `core_checked_out_time`, `core_checked_out_user_id`, `core_access`, `core_params`, `core_featured`, `core_metadata`, `core_created_user_id`, `core_created_by_alias`, `core_created_time`, `core_modified_user_id`, `core_modified_time`, `core_language`, `core_publish_up`, `core_publish_down`, `core_content_item_id`, `asset_id`, `core_images`, `core_urls`, `core_hits`, `core_version`, `core_ordering`, `core_metakey`, `core_metadesc`, `core_catid`, `core_type_id`

**Policy:** `REBUILD / VALIDATE`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__ucm_content` (
  `core_content_id` int unsigned NOT NULL AUTO_INCREMENT,
  `core_type_alias` varchar(400) NOT NULL DEFAULT '' COMMENT 'FK to the content types table',
  `core_title` varchar(400) NOT NULL DEFAULT '',
  `core_alias` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `core_body` mediumtext,
  `core_state` tinyint NOT NULL DEFAULT 0,
  `core_checked_out_time` datetime,
  `core_checked_out_user_id` int unsigned,
  `core_access` int unsigned NOT NULL DEFAULT 0,
  `core_params` text,
  `core_featured` tinyint unsigned NOT NULL DEFAULT 0,
  `core_metadata` varchar(2048) NOT NULL DEFAULT '' COMMENT 'JSON encoded metadata properties.',
  `core_created_user_id` int unsigned NOT NULL DEFAULT 0,
  `core_created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `core_created_time` datetime NOT NULL,
  `core_modified_user_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'Most recent user that modified',
  `core_modified_time` datetime NOT NULL,
  `core_language` char(7) NOT NULL DEFAULT '',
  `core_publish_up` datetime,
  `core_publish_down` datetime,
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

### `#__history`

**Fields (11):** `version_id`, `item_id`, `version_note`, `save_date`, `editor_user_id`, `character_count`, `sha1_hash`, `version_data`, `keep_forever`, `is_current`, `is_legacy`

**Policy:** `ARCHIVE / OPTIONAL_MIGRATE`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__history` (
  `version_id` int unsigned NOT NULL AUTO_INCREMENT,
  `item_id` VARCHAR(50) NOT NULL,
  `version_note` varchar(255) NOT NULL DEFAULT '' COMMENT 'Optional version name',
  `save_date` datetime NOT NULL,
  `editor_user_id` int unsigned NOT NULL DEFAULT 0,
  `character_count` int unsigned NOT NULL DEFAULT 0 COMMENT 'Number of characters in this version.',
  `sha1_hash` varchar(50) NOT NULL DEFAULT '' COMMENT 'SHA1 hash of the version_data column.',
  `version_data` mediumtext NOT NULL COMMENT 'json-encoded string of version data',
  `keep_forever` tinyint NOT NULL DEFAULT 0 COMMENT '0=auto delete; 1=keep',
  `is_current` tinyint NOT NULL DEFAULT 0,
  `is_legacy` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`version_id`),
  KEY `idx_ucm_item_id` (`item_id`),
  KEY `idx_save_date` (`save_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__workflow_associations`

**Fields (3):** `item_id`, `stage_id`, `extension`

**Policy:** `GENERATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__workflow_associations` (
  `item_id` int NOT NULL DEFAULT 0 COMMENT 'Extension table id value',
  `stage_id` int NOT NULL COMMENT 'Foreign Key to #__workflow_stages.id',
  `extension` varchar(50) NOT NULL,
  PRIMARY KEY (`item_id`, `extension`),
  KEY `idx_item_stage_extension` (`item_id`, `stage_id`, `extension`),
  KEY `idx_item_id` (`item_id`),
  KEY `idx_stage_id` (`stage_id`),
  KEY `idx_extension` (`extension`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__schemaorg`

**Fields (5):** `id`, `itemId`, `context`, `schemaType`, `schema`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__schemaorg` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `itemId` int unsigned,
  `context` varchar(100),
  `schemaType` varchar(100),
  `schema` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

---

## G5 — Menu and Presentation

**Tables:** 4 · **Fields:** 50

### `#__template_styles`

**Fields (8):** `id`, `template`, `client_id`, `home`, `title`, `inheritable`, `parent`, `params`

**Policy:** `TRANSFORM / RECREATE`  
**Official source:** `base.sql`

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

### `#__template_overrides`

**Fields (9):** `id`, `template`, `hash_id`, `extension_id`, `state`, `action`, `client_id`, `created_date`, `modified_date`

**Policy:** `REBUILD / REVIEW`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__template_overrides` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `template` varchar(50) NOT NULL DEFAULT '',
  `hash_id` varchar(255) NOT NULL DEFAULT '',
  `extension_id` int DEFAULT 0,
  `state` tinyint NOT NULL DEFAULT 0,
  `action` varchar(50) NOT NULL DEFAULT '',
  `client_id` tinyint unsigned NOT NULL DEFAULT 0,
  `created_date` datetime NOT NULL,
  `modified_date` datetime,
  PRIMARY KEY (`id`),
  KEY `idx_template` (`template`),
  KEY `idx_extension_id` (`extension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__menu_types`

**Fields (7):** `id`, `asset_id`, `menutype`, `title`, `description`, `client_id`, `ordering`

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__menu_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0,
  `menutype` varchar(24) NOT NULL,
  `title` varchar(48) NOT NULL,
  `description` varchar(255) NOT NULL DEFAULT '',
  `client_id` int NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_menutype` (`menutype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__menu`

**Fields (26):** `id`, `menutype`, `title`, `alias`, `note`, `path`, `link`, `type`, `published`, `parent_id`, `level`, `component_id`, `checked_out`, `checked_out_time`, `browserNav`, `access`, `img`, `template_style_id`, `params`, `lft`, `rgt`, `home`, `language`, `client_id`, `publish_up`, `publish_down`

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

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
  `checked_out` int unsigned COMMENT 'FK to #__users.id',
  `checked_out_time` datetime COMMENT 'The time the menu item was checked out.',
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
  `publish_up` datetime,
  `publish_down` datetime,
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

---

## G6 — Modules

**Tables:** 2 · **Fields:** 20

### `#__modules`

**Fields (18):** `id`, `asset_id`, `title`, `note`, `content`, `ordering`, `position`, `checked_out`, `checked_out_time`, `publish_up`, `publish_down`, `published`, `module`, `access`, `showtitle`, `params`, `client_id`, `language`

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__modules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to the #__assets table.',
  `title` varchar(100) NOT NULL DEFAULT '',
  `note` varchar(255) NOT NULL DEFAULT '',
  `content` text,
  `ordering` int NOT NULL DEFAULT 0,
  `position` varchar(50) NOT NULL DEFAULT '',
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `publish_up` datetime,
  `publish_down` datetime,
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__modules_menu` (
  `moduleid` int NOT NULL DEFAULT 0,
  `menuid` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`moduleid`,`menuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

---

## G7 — Supporting Core Components

**Tables:** 16 · **Fields:** 217

### `#__contact_details`

**Fields (42):** `id`, `name`, `alias`, `con_position`, `address`, `suburb`, `state`, `country`, `postcode`, `telephone`, `fax`, `misc`, `image`, `email_to`, `default_con`, `published`, `checked_out`, `checked_out_time`, `ordering`, `params`, `user_id`, `catid`, `access`, `mobile`, `webpage`, `sortname1`, `sortname2`, `sortname3`, `language`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `metakey`, `metadesc`, `metadata`, `featured`, `publish_up`, `publish_down`, `version`, `hits`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

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
  `checked_out` int unsigned,
  `checked_out_time` datetime,
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
  `created` datetime NOT NULL,
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL,
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `metakey` text,
  `metadesc` text NOT NULL,
  `metadata` text NOT NULL,
  `featured` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'Set if contact is featured.',
  `publish_up` datetime,
  `publish_down` datetime,
  `version` int unsigned NOT NULL DEFAULT 1,
  `hits` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_access` (`access`),
  KEY `idx_checkout` (`checked_out`),
  KEY `idx_state` (`published`),
  KEY `idx_catid` (`catid`),
  KEY `idx_createdby` (`created_by`),
  KEY `idx_featured_catid` (`featured`,`catid`),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__newsfeeds`

**Fields (29):** `catid`, `id`, `name`, `alias`, `link`, `published`, `numarticles`, `cache_time`, `checked_out`, `checked_out_time`, `ordering`, `rtl`, `access`, `language`, `params`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `metakey`, `metadesc`, `metadata`, `publish_up`, `publish_down`, `description`, `version`, `hits`, `images`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

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
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `ordering` int NOT NULL DEFAULT 0,
  `rtl` tinyint NOT NULL DEFAULT 0,
  `access` int unsigned NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL DEFAULT '',
  `params` text NOT NULL,
  `created` datetime NOT NULL,
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL,
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `metakey` text,
  `metadesc` text NOT NULL,
  `metadata` text NOT NULL,
  `publish_up` datetime,
  `publish_down` datetime,
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
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__banners`

**Fields (34):** `id`, `cid`, `type`, `name`, `alias`, `imptotal`, `impmade`, `clicks`, `clickurl`, `state`, `catid`, `description`, `custombannercode`, `sticky`, `ordering`, `metakey`, `params`, `own_prefix`, `metakey_prefix`, `purchase_type`, `track_clicks`, `track_impressions`, `checked_out`, `checked_out_time`, `publish_up`, `publish_down`, `reset`, `created`, `language`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `version`

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

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
  `clickurl` varchar(2048) NOT NULL DEFAULT '',
  `state` tinyint NOT NULL DEFAULT 0,
  `catid` int unsigned NOT NULL DEFAULT 0,
  `description` text NOT NULL,
  `custombannercode` varchar(2048) NOT NULL,
  `sticky` tinyint unsigned NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0,
  `metakey` text,
  `params` text NOT NULL,
  `own_prefix` tinyint NOT NULL DEFAULT 0,
  `metakey_prefix` varchar(400) NOT NULL DEFAULT '',
  `purchase_type` tinyint NOT NULL DEFAULT -1,
  `track_clicks` tinyint NOT NULL DEFAULT -1,
  `track_impressions` tinyint NOT NULL DEFAULT -1,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `publish_up` datetime,
  `publish_down` datetime,
  `reset` datetime,
  `created` datetime NOT NULL,
  `language` char(7) NOT NULL DEFAULT '',
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL,
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

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__banner_clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `contact` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `extrainfo` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `metakey` text,
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

**Policy:** `ARCHIVE / OPTIONAL_MIGRATE`  
**Official source:** `extensions.sql`

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

**Policy:** `MIGRATE / MAP`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__redirect_links` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `old_url` varchar(2048) NOT NULL,
  `new_url` varchar(2048),
  `referer` varchar(2048) NOT NULL,
  `comment` varchar(255) NOT NULL DEFAULT '',
  `hits` int unsigned NOT NULL DEFAULT 0,
  `published` tinyint NOT NULL,
  `created_date` datetime NOT NULL,
  `modified_date` datetime NOT NULL,
  `header` smallint NOT NULL DEFAULT 301,
  PRIMARY KEY (`id`),
  KEY `idx_old_url` (`old_url`(100)),
  KEY `idx_link_modified` (`modified_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__messages`

**Fields (9):** `message_id`, `user_id_from`, `user_id_to`, `folder_id`, `date_time`, `state`, `priority`, `subject`, `message`

**Policy:** `MIGRATE / OPTIONAL`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__messages` (
  `message_id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id_from` int unsigned NOT NULL DEFAULT 0,
  `user_id_to` int unsigned NOT NULL DEFAULT 0,
  `folder_id` tinyint unsigned NOT NULL DEFAULT 0,
  `date_time` datetime NOT NULL,
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

**Policy:** `MIGRATE / OPTIONAL`  
**Official source:** `extensions.sql`

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

**Policy:** `MIGRATE / MAP`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__user_notes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT 0,
  `catid` int unsigned NOT NULL DEFAULT 0,
  `subject` varchar(100) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `state` tinyint NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `created_user_id` int unsigned NOT NULL DEFAULT 0,
  `created_time` datetime NOT NULL,
  `modified_user_id` int unsigned NOT NULL DEFAULT 0,
  `modified_time` datetime NOT NULL,
  `review_time` datetime,
  `publish_up` datetime,
  `publish_down` datetime,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_category_id` (`catid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__privacy_requests`

**Fields (7):** `id`, `email`, `requested_at`, `status`, `request_type`, `confirm_token`, `confirm_token_created_at`

**Policy:** `MIGRATE / ARCHIVE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__privacy_requests` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL DEFAULT '',
  `requested_at` datetime NOT NULL,
  `status` tinyint NOT NULL DEFAULT 0,
  `request_type` varchar(25) NOT NULL DEFAULT '',
  `confirm_token` varchar(100) NOT NULL DEFAULT '',
  `confirm_token_created_at` datetime,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__privacy_consents`

**Fields (8):** `id`, `user_id`, `state`, `created`, `subject`, `body`, `remind`, `token`

**Policy:** `MIGRATE / ARCHIVE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__privacy_consents` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL DEFAULT 0,
  `state` int NOT NULL DEFAULT 1,
  `created` datetime NOT NULL,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `body` text NOT NULL,
  `remind` tinyint NOT NULL DEFAULT 0,
  `token` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__mail_templates`

**Fields (8):** `template_id`, `extension`, `language`, `subject`, `body`, `htmlbody`, `attachments`, `params`

**Policy:** `MERGE / RECREATE`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__mail_templates` (
  `template_id` VARCHAR(127) NOT NULL DEFAULT '',
  `extension` VARCHAR(127) NOT NULL DEFAULT '',
  `language` char(7) NOT NULL DEFAULT '',
  `subject` VARCHAR(255) NOT NULL DEFAULT '',
  `body` TEXT NOT NULL,
  `htmlbody` MEDIUMTEXT NOT NULL,
  `attachments` TEXT NOT NULL,
  `params` TEXT NOT NULL,
  PRIMARY KEY (`template_id`, `language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__scheduler_tasks`

**Fields (22):** `id`, `asset_id`, `title`, `type`, `execution_rules`, `cron_rules`, `state`, `last_exit_code`, `last_execution`, `next_execution`, `times_executed`, `times_failed`, `locked`, `priority`, `ordering`, `cli_exclusive`, `params`, `note`, `created`, `created_by`, `checked_out`, `checked_out_time`

**Policy:** `RECREATE / SELECTIVE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__scheduler_tasks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `asset_id` int unsigned NOT NULL DEFAULT 0 COMMENT 'FK to the #__assets table.',
  `title` varchar(255) NOT NULL DEFAULT '',
  `type` varchar(128) NOT NULL COMMENT 'unique identifier for job defined by plugin',
  `execution_rules` text COMMENT 'Execution Rules, Unprocessed',
  `cron_rules` text COMMENT 'Processed execution rules, crontab-like JSON form',
  `state` tinyint NOT NULL DEFAULT FALSE,
  `last_exit_code` int NOT NULL DEFAULT 0 COMMENT 'Exit code when job was last run',
  `last_execution` datetime COMMENT 'Timestamp of last run',
  `next_execution` datetime COMMENT 'Timestamp of next (planned) run, referred for execution on trigger',
  `times_executed` int DEFAULT 0 COMMENT 'Count of successful triggers',
  `times_failed` int DEFAULT 0 COMMENT 'Count of failures',
  `locked` datetime,
  `priority` smallint NOT NULL DEFAULT 0,
  `ordering` int NOT NULL DEFAULT 0 COMMENT 'Configurable list ordering',
  `cli_exclusive` smallint NOT NULL DEFAULT 0 COMMENT 'If 1, the task is only accessible via CLI',
  `params` text NOT NULL,
  `note` text,
  `created` datetime NOT NULL,
  `created_by` int UNSIGNED NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  PRIMARY KEY (id),
  KEY `idx_type` (`type`),
  KEY `idx_state` (`state`),
  KEY `idx_last_exit` (`last_exit_code`),
  KEY `idx_next_exec` (`next_execution`),
  KEY `idx_locked` (`locked`),
  KEY `idx_priority` (`priority`),
  KEY `idx_cli_exclusive` (`cli_exclusive`),
  KEY `idx_checked_out` (`checked_out`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 DEFAULT COLLATE = utf8mb4_unicode_ci;
```

### `#__action_logs_extensions`

**Fields (2):** `id`, `extension`

**Policy:** `TARGET_OWNED / MERGE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__action_logs_extensions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `extension` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__action_log_config`

**Fields (7):** `id`, `type_title`, `type_alias`, `id_holder`, `title_holder`, `table_name`, `text_prefix`

**Policy:** `TARGET_OWNED / MERGE`  
**Official source:** `extensions.sql`

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

**Policy:** `MIGRATE / REVIEW`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__action_logs_users` (
  `user_id` int UNSIGNED NOT NULL,
  `notify` tinyint UNSIGNED NOT NULL,
  `extensions` text NOT NULL,
  PRIMARY KEY (`user_id`),
  KEY `idx_notify` (`notify`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

---

## G8 — Runtime, Generated, and Target-Owned Data

**Tables:** 21 · **Fields:** 186

### `#__session`

**Fields (7):** `session_id`, `client_id`, `guest`, `time`, `data`, `userid`, `username`

**Policy:** `IGNORE`  
**Official source:** `base.sql`

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

**Fields (6):** `id`, `user_id`, `token`, `series`, `time`, `uastring`

**Policy:** `IGNORE`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__user_keys` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(150) NOT NULL,
  `token` varchar(255) NOT NULL,
  `series` varchar(191) NOT NULL,
  `time` varchar(200) NOT NULL,
  `uastring` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `series` (`series`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__user_mfa`

**Fields (10):** `id`, `user_id`, `title`, `method`, `default`, `options`, `created_on`, `last_used`, `tries`, `last_try`

**Policy:** `RECREATE / RE-ENROL`  
**Official source:** `base.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__user_mfa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT '',
  `method` varchar(100) NOT NULL,
  `default` tinyint NOT NULL DEFAULT 0,
  `options` mediumtext NOT NULL,
  `created_on` datetime NOT NULL,
  `last_used` datetime,
  `tries` int NOT NULL DEFAULT 0,
  `last_try` datetime,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci COMMENT='Multi-factor Authentication settings';
```

### `#__webauthn_credentials`

**Fields (4):** `id`, `user_id`, `label`, `credential`

**Policy:** `RECREATE / RE-ENROL`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__webauthn_credentials` (
    `id`         VARCHAR(1000)   NOT NULL COMMENT 'Credential ID',
    `user_id`    VARCHAR(128)    NOT NULL COMMENT 'User handle',
    `label`      VARCHAR(190)    NOT NULL COMMENT 'Human readable label',
    `credential` MEDIUMTEXT      NOT NULL COMMENT 'Credential source data, JSON format',
    PRIMARY KEY (`id`(100)),
    INDEX (`user_id`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__scheduler_logs`

**Fields (9):** `id`, `taskname`, `tasktype`, `duration`, `jobid`, `taskid`, `exitcode`, `lastdate`, `nextdate`

**Policy:** `IGNORE / ARCHIVE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__scheduler_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `taskname` varchar(255) NOT NULL DEFAULT '',
  `tasktype` varchar(128) NOT NULL COMMENT 'unique identifier for job defined by plugin',
  `duration` DECIMAL(5,3) NOT NULL,
  `jobid` int UNSIGNED NOT NULL,
  `taskid` int UNSIGNED NOT NULL,
  `exitcode` int NOT NULL,
  `lastdate` datetime COMMENT 'Timestamp of last run',
  `nextdate` datetime COMMENT 'Timestamp of next (planned) run, referred for execution on trigger',
  PRIMARY KEY (id),
  KEY `idx_taskname` (`taskname`),
  KEY `idx_tasktype` (`tasktype`),
  KEY `idx_lastdate` (`lastdate`),
  KEY `idx_nextdate` (`nextdate`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 DEFAULT COLLATE = utf8mb4_unicode_ci;
```

### `#__action_logs`

**Fields (8):** `id`, `message_language_key`, `message`, `log_date`, `extension`, `user_id`, `item_id`, `ip_address`

**Policy:** `IGNORE / ARCHIVE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__action_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `message_language_key` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `log_date` datetime NOT NULL,
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

### `#__finder_filters`

**Fields (14):** `filter_id`, `title`, `alias`, `state`, `created`, `created_by`, `created_by_alias`, `modified`, `modified_by`, `checked_out`, `checked_out_time`, `map_count`, `data`, `params`

**Policy:** `MIGRATE / RECREATE / REVIEW`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_filters` (
  `filter_id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `alias` varchar(255) NOT NULL,
  `state` tinyint NOT NULL DEFAULT 1,
  `created` datetime NOT NULL,
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `created_by_alias` varchar(255) NOT NULL DEFAULT '',
  `modified` datetime NOT NULL,
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `checked_out` int unsigned,
  `checked_out_time` datetime,
  `map_count` int unsigned NOT NULL DEFAULT 0,
  `data` text,
  `params` mediumtext,
  PRIMARY KEY (`filter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_links`

**Fields (19):** `link_id`, `url`, `route`, `title`, `description`, `indexdate`, `md5sum`, `published`, `state`, `access`, `language`, `publish_start_date`, `publish_end_date`, `start_date`, `end_date`, `list_price`, `sale_price`, `type_id`, `object`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links` (
  `link_id` int unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  `route` varchar(400) NOT NULL,
  `title` varchar(400) DEFAULT NULL,
  `description` text,
  `indexdate` datetime NOT NULL,
  `md5sum` varchar(32) DEFAULT NULL,
  `published` tinyint NOT NULL DEFAULT 1,
  `state` int NOT NULL DEFAULT 1,
  `access` int NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL DEFAULT '',
  `publish_start_date` datetime,
  `publish_end_date` datetime,
  `start_date` datetime,
  `end_date` datetime,
  `list_price` double unsigned NOT NULL DEFAULT 0,
  `sale_price` double unsigned NOT NULL DEFAULT 0,
  `type_id` int NOT NULL,
  `object` mediumblob,
  PRIMARY KEY (`link_id`),
  KEY `idx_type` (`type_id`),
  KEY `idx_title` (`title`(100)),
  KEY `idx_md5` (`md5sum`),
  KEY `idx_url` (`url`(75)),
  KEY `idx_language` (`language`),
  KEY `idx_published_list` (`published`,`state`,`access`,`publish_start_date`,`publish_end_date`,`list_price`),
  KEY `idx_published_sale` (`published`,`state`,`access`,`publish_start_date`,`publish_end_date`,`sale_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_links_terms`

**Fields (3):** `link_id`, `term_id`, `weight`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_links_terms` (
  `link_id` int unsigned NOT NULL,
  `term_id` int unsigned NOT NULL,
  `weight` float unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`link_id`,`term_id`),
  KEY `idx_term_weight` (`term_id`,`weight`),
  KEY `idx_link_term_weight` (`link_id`,`term_id`,`weight`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_logging`

**Fields (5):** `searchterm`, `md5sum`, `query`, `hits`, `results`

**Policy:** `IGNORE / ARCHIVE`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_logging` (
  `searchterm` VARCHAR(255) NOT NULL DEFAULT '',
  `md5sum` VARCHAR(32) NOT NULL DEFAULT '',
  `query` BLOB NOT NULL,
  `hits` int NOT NULL DEFAULT 1,
  `results` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`md5sum`),
  INDEX `searchterm` (`searchterm`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_taxonomy`

**Fields (11):** `id`, `parent_id`, `lft`, `rgt`, `level`, `path`, `title`, `alias`, `state`, `access`, `language`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_taxonomy` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `parent_id` int UNSIGNED NOT NULL DEFAULT '0',
  `lft` int NOT NULL DEFAULT '0',
  `rgt` int NOT NULL DEFAULT '0',
  `level` int UNSIGNED NOT NULL DEFAULT '0',
  `path` VARCHAR(400) NOT NULL DEFAULT '',
  `title` VARCHAR(255) NOT NULL DEFAULT '',
  `alias` VARCHAR(400) NOT NULL DEFAULT '',
  `state` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `access` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `language` CHAR(7) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  INDEX `idx_state` (`state`),
  INDEX `idx_access` (`access`),
  INDEX `idx_path` (`path`(100)),
  INDEX `idx_level` (`level`),
  INDEX `idx_left_right` (`lft`, `rgt`),
  INDEX `idx_alias` (`alias`(100)),
  INDEX `idx_language` (`language`),
  INDEX `idx_parent_published` (`parent_id`, `state`, `access`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_taxonomy_map`

**Fields (2):** `link_id`, `node_id`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_taxonomy_map` (
  `link_id` int unsigned NOT NULL,
  `node_id` int unsigned NOT NULL,
  PRIMARY KEY (`link_id`,`node_id`),
  KEY `link_id` (`link_id`),
  KEY `node_id` (`node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_terms`

**Fields (9):** `term_id`, `term`, `stem`, `common`, `phrase`, `weight`, `soundex`, `links`, `language`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_terms` (
  `term_id` int unsigned NOT NULL AUTO_INCREMENT,
  `term` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `stem` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `common` tinyint unsigned NOT NULL DEFAULT 0,
  `phrase` tinyint unsigned NOT NULL DEFAULT 0,
  `weight` float unsigned NOT NULL DEFAULT 0,
  `soundex` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `links` int NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL DEFAULT '',
  PRIMARY KEY (`term_id`),
  UNIQUE KEY `idx_term_language` (`term`,`language`),
  KEY `idx_stem` (`stem`),
  KEY `idx_term_phrase` (`term`,`phrase`),
  KEY `idx_stem_phrase` (`stem`,`phrase`),
  KEY `idx_soundex_phrase` (`soundex`,`phrase`),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_terms_common`

**Fields (3):** `term`, `language`, `custom`

**Policy:** `TARGET_OWNED / REVIEW`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_terms_common` (
  `term` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `language` char(7) NOT NULL DEFAULT '',
  `custom` int NOT NULL DEFAULT '0',
  UNIQUE KEY `idx_term_language` (`term`,`language`),
  KEY `idx_lang` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_tokens`

**Fields (7):** `term`, `stem`, `common`, `phrase`, `weight`, `context`, `language`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_tokens` (
  `term` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `stem` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `common` tinyint unsigned NOT NULL DEFAULT 0,
  `phrase` tinyint unsigned NOT NULL DEFAULT 0,
  `weight` float unsigned NOT NULL DEFAULT 1,
  `context` tinyint unsigned NOT NULL DEFAULT 2,
  `language` char(7) NOT NULL DEFAULT '',
  KEY `idx_word` (`term`),
  KEY `idx_stem` (`stem`),
  KEY `idx_context` (`context`),
  KEY `idx_language` (`language`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_tokens_aggregate`

**Fields (10):** `term_id`, `term`, `stem`, `common`, `phrase`, `term_weight`, `context`, `context_weight`, `total_weight`, `language`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_tokens_aggregate` (
  `term_id` int unsigned NOT NULL,
  `term` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `stem` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `common` tinyint unsigned NOT NULL DEFAULT 0,
  `phrase` tinyint unsigned NOT NULL DEFAULT 0,
  `term_weight` float unsigned NOT NULL DEFAULT 0,
  `context` tinyint unsigned NOT NULL DEFAULT 2,
  `context_weight` float unsigned NOT NULL DEFAULT 0,
  `total_weight` float unsigned NOT NULL DEFAULT 0,
  `language` char(7) NOT NULL DEFAULT '',
  KEY `token` (`term`),
  KEY `keyword_id` (`term_id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__finder_types`

**Fields (3):** `id`, `title`, `mime`

**Policy:** `REBUILD`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__finder_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `mime` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__postinstall_messages`

**Fields (14):** `postinstall_message_id`, `extension_id`, `title_key`, `description_key`, `action_key`, `language_extension`, `language_client_id`, `type`, `action_file`, `action`, `condition_file`, `condition_method`, `version_introduced`, `enabled`

**Policy:** `TARGET_OWNED`  
**Official source:** `supports.sql`

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

### `#__overrider`

**Fields (4):** `id`, `constant`, `string`, `file`

**Policy:** `MIGRATE / RECREATE / REVIEW`  
**Official source:** `supports.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__overrider` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `constant` varchar(255) NOT NULL,
  `string` text NOT NULL,
  `file` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__guidedtours`

**Fields (18):** `id`, `title`, `uid`, `description`, `ordering`, `extensions`, `url`, `created`, `created_by`, `modified`, `modified_by`, `checked_out_time`, `checked_out`, `published`, `language`, `note`, `access`, `autostart`

**Policy:** `TARGET_OWNED`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__guidedtours` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT '' NOT NULL,
  `uid` varchar(400) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `description` text NOT NULL,
  `ordering` int NOT NULL DEFAULT 0,
  `extensions` text NOT NULL,
  `url` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `created_by` int NOT NULL DEFAULT 0,
  `modified` datetime NOT NULL,
  `modified_by` int NOT NULL DEFAULT 0,
  `checked_out_time` datetime,
  `checked_out` int unsigned,
  `published` tinyint NOT NULL DEFAULT 0,
  `language` varchar(7) NOT NULL,
  `note` varchar(255) NOT NULL DEFAULT '',
  `access` int unsigned NOT NULL DEFAULT 0,
  `autostart` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_access` (`access`),
  KEY `idx_state` (`published`),
  KEY `idx_language` (`language`),
  KEY `idx_uid` (`uid`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

### `#__guidedtour_steps`

**Fields (20):** `id`, `tour_id`, `title`, `published`, `description`, `ordering`, `position`, `target`, `type`, `interactive_type`, `url`, `created`, `created_by`, `modified`, `modified_by`, `checked_out_time`, `checked_out`, `language`, `note`, `params`

**Policy:** `TARGET_OWNED`  
**Official source:** `extensions.sql`

```sql
CREATE TABLE IF NOT EXISTS `#__guidedtour_steps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tour_id` int NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `published` tinyint NOT NULL DEFAULT 0,
  `description` text NOT NULL,
  `ordering` int NOT NULL DEFAULT 0,
  `position` varchar(255) NOT NULL,
  `target` varchar(255) NOT NULL,
  `type` int NOT NULL,
  `interactive_type` int NOT NULL DEFAULT 1,
  `url` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `created_by` int unsigned NOT NULL DEFAULT 0,
  `modified` datetime NOT NULL,
  `modified_by` int unsigned NOT NULL DEFAULT 0,
  `checked_out_time` datetime,
  `checked_out` int unsigned,
  `language` varchar(7) NOT NULL,
  `note` varchar(255) NOT NULL DEFAULT '',
  `params` text,
  PRIMARY KEY (`id`),
  KEY `idx_tour` (`tour_id`),
  KEY `idx_state` (`published`),
  KEY `idx_language` (`language`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_ci;
```

---

## Coverage Reconciliation

| Check | Result |
|---|---:|
| Official physical tables | 76 |
| Documented tables | 76 |
| Official physical fields | 832 |
| Documented `(table, field)` pairs | 832 |
| Unique `(table, field)` pairs | 832 |
| Duplicate fields | 0 |
| Missing tables | 0 |
| Extra tables | 0 |
| Missing fields | 0 |
| Extra fields | 0 |
| Per-table field-count mismatches | 0 |
| **Baseline field coverage** | **100%** |

```text
Official tables                  = 76
Manifest tables                  = 76
Official (table, field) pairs    = 832
Manifest (table, field) pairs    = 832
Unique manifest pairs            = 832
Missing official tables          = 0
Unexpected manifest tables       = 0
Missing official fields          = 0
Unexpected manifest fields       = 0
Duplicate fields                 = 0
Per-table field-count mismatches = 0

JOOMLA 6.1.2 FIELD INVENTORY     = PASS
```

## Production Database Reconciliation

Before migration execution, compare the real Joomla 6 target to this official baseline:

```sql
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    ORDINAL_POSITION,
    COLUMN_DEFAULT,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    CHARACTER_OCTET_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    DATETIME_PRECISION,
    CHARACTER_SET_NAME,
    COLLATION_NAME,
    COLUMN_TYPE,
    COLUMN_KEY,
    EXTRA,
    PRIVILEGES,
    COLUMN_COMMENT,
    GENERATION_EXPRESSION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = '<JOOMLA6_DATABASE>'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

Production PASS requires:

```text
Actual target core tables inventoried = 100%
Actual target core fields inventoried = 100%
Missing expected core fields          = 0
Unexplained target-only fields        = 0
Duplicate inventory fields            = 0
Unclassified fields                   = 0
```
