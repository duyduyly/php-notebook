# Joomla 6 Extension and System Tables

## Table of Contents

- [1. `#__extensions`](#1-extensions)
- [2. Schema and Update Tables](#2-schema-and-update-tables)
- [3. Scheduler](#3-scheduler)
- [4. Action Logs](#4-action-logs)
- [5. Privacy](#5-privacy)
- [6. Smart Search](#6-smart-search)
- [7. Mail, Messages, Redirects, and Tours](#7-mail-messages-redirects-and-tours)
- [8. Language and Association Tables](#8-language-and-association-tables)
- [9. Runtime and Generated Data](#9-runtime-and-generated-data)
- [10. Migration Notes](#10-migration-notes)

## 1. `#__extensions`

Registers installed components, modules, plugins, templates, libraries, packages, files, and languages.

| Column | Meaning |
|---|---|
| `extension_id` | Extension primary key |
| `package_id` | Parent package ID |
| `name` | Extension name/language key |
| `type` | Component, module, plugin, template, library, package, file, or language |
| `element` | Machine identifier, such as `com_content` or `mod_menu` |
| `changelogurl` | Changelog feed URL |
| `folder` | Plugin group; empty for most non-plugins |
| `client_id` | Site or administrator client |
| `enabled` | Enabled state |
| `access` | Access level |
| `protected` | Cannot be disabled |
| `locked` | Cannot be uninstalled |
| `manifest_cache` | JSON manifest information |
| `params` | JSON extension parameters |
| `custom_data` | Extension-specific data |
| `checked_out`, `checked_out_time` | Edit lock |
| `ordering` | Ordering value |
| `state` | Record state |
| `note` | Administrator note |

`extension_id` is installation-specific. Map components by identity:

```text
type + element + folder + client_id
```

## 2. Schema and Update Tables

| Table | Purpose |
|---|---|
| `#__schemas` | Installed database schema version per extension |
| `#__update_sites` | Update feed definitions |
| `#__update_sites_extensions` | Links update sites to extensions |
| `#__updates` | Discovered update cache |

These tables belong to the target installation. Install extensions normally and let Joomla populate them.

## 3. Scheduler

### `#__scheduler_tasks`

Stores scheduled task definitions.

Important concepts:

```text
task type, execution rule, state, priority, last run,
next run, locked state, parameters, execution history
```

### `#__scheduler_log`

Stores scheduler execution results and timing information.

Do not copy Joomla 3 cron-related custom records into these tables without converting them to Joomla 6 scheduler task plugins.

## 4. Action Logs

| Table | Purpose |
|---|---|
| `#__action_logs` | Recorded user actions |
| `#__action_logs_extensions` | Components enabled for logging |
| `#__action_log_config` | Action-log message configuration |

Action logs are audit/runtime history. They are normally excluded from migration.

## 5. Privacy

| Table | Purpose |
|---|---|
| `#__privacy_requests` | Export/removal requests |
| `#__privacy_consents` | Recorded consent information |

Privacy records can contain personal and legal/audit data. Migrate only with an explicit business and compliance requirement.

## 6. Smart Search

The `#__finder_*` tables include links, terms, taxonomy, tokens, filters, and mapping tables.

Typical tables:

```text
#__finder_links
#__finder_terms
#__finder_taxonomy
#__finder_tokens
#__finder_filters
#__finder_links_terms*
#__finder_taxonomy_map
```

They are generated search indexes. Do not migrate them; rebuild the Smart Search index in Joomla 6.

## 7. Mail, Messages, Redirects, and Tours

| Table | Purpose | Migration guidance |
|---|---|---|
| `#__mail_templates` | Configurable core/extension email templates | Preserve target defaults; merge custom overrides carefully |
| `#__messages` | Private administrator messages | Usually optional |
| `#__messages_cfg` | Message configuration | Prefer target settings |
| `#__redirect_links` | Redirect history and destination URLs | Can be selectively migrated |
| `#__postinstall_messages` | Version/extension post-install notices | Do not migrate |
| `#__guidedtours` | Guided tour definitions | Keep Joomla 6 defaults |
| `#__guidedtour_steps` | Steps belonging to tours | Keep Joomla 6 defaults |

## 8. Language and Association Tables

### `#__languages`

Stores configured content languages.

Important columns generally represent:

```text
language code, title, native title, SEF code,
image prefix, published state, access, ordering
```

### `#__associations`

Links equivalent multilingual records by context and association key.

Language records should exist before multilingual content, menus, and associations are migrated.

## 9. Runtime and Generated Data

Do not migrate these as business data:

```text
#__session
#__updates
#__finder_*
#__scheduler_log
#__action_logs
#__postinstall_messages
```

Cache data may be stored outside the database depending on the configured cache handler.

## 10. Migration Notes

- Install Joomla 6 core and third-party extensions before moving extension-owned configuration.
- Identify extensions using stable identity fields, not `extension_id`.
- Never overwrite target `#__schemas` with Joomla 3 values.
- Rebuild Smart Search indexes.
- Recreate scheduler tasks only when their Joomla 6 task plugins exist.
- Preserve target privacy, guided-tour, mail-template, update, and post-install defaults unless a specific customization must be ported.
- Review all migrated data for secrets, tokens, personal data, and obsolete endpoints.

[Back to Database Overview](./database-overview.md)
