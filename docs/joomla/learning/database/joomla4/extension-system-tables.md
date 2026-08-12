# Joomla 4 Extension and System Tables

This document explains Joomla 4.4 extension registration, database schema/update metadata, action logs, privacy, mail templates, scheduled tasks, redirects, messages, Smart Search, guided tours, and other core system tables.

> **Schema baseline:** Joomla 4.4.14.

## Table of Contents

- [1. Extension Registration](#1-extension-registration)
- [2. `#__extensions`](#2-extensions)
- [3. Schema and Update Tables](#3-schema-and-update-tables)
- [4. Action Logs](#4-action-logs)
- [5. Privacy Tables](#5-privacy-tables)
- [6. Mail Templates](#6-mail-templates)
- [7. Scheduled Tasks](#7-scheduled-tasks)
- [8. Redirects and Messages](#8-redirects-and-messages)
- [9. Smart Search](#9-smart-search)
- [10. Guided Tours](#10-guided-tours)
- [11. Other Supporting Tables](#11-other-supporting-tables)
- [12. Runtime/Rebuild Classification](#12-runtimerebuild-classification)
- [13. Migration Notes](#13-migration-notes)

## 1. Extension Registration

Joomla stores installed components, modules, plugins, templates, libraries, packages, files and languages in `#__extensions`.

The extension registration row is **not** the extension's business data. For example:

```text
#__extensions.element = com_content
```

describes the installed Content component, while articles live in `#__content`.

Third-party extensions can also store configuration in core tables and business data in their own tables, so both must be inventoried.

## 2. `#__extensions`

Important Joomla 4.4 columns include:

| Column | Meaning |
|---|---|
| `extension_id` | Installation-specific primary key |
| `package_id` | Parent package ID |
| `name` | Extension name/language key |
| `type` | component/module/plugin/template/library/package/file/language |
| `element` | Machine name |
| `changelogurl` | Changelog source where configured |
| `folder` | Plugin group, empty for many other types |
| `client_id` | Site/administrator client |
| `enabled` | Enabled state |
| `access` | Access where applicable |
| `protected` | Protected core-extension flag |
| `locked` | Uninstall lock flag |
| `manifest_cache` | Manifest metadata |
| `params` | JSON extension configuration |
| `custom_data` | Extension-specific data |
| `checked_out`, `checked_out_time` | Editing lock |
| `ordering` | Ordering, important for plugins |
| `state` | Internal state |
| `note` | Administrator note |

Map extensions by identity rather than ID:

```text
type + element + folder + client_id
```

Never assume a source `extension_id` equals the target ID.

## 3. Schema and Update Tables

### `#__schemas`

Tracks installed schema version per extension.

| Column | Meaning |
|---|---|
| `extension_id` | Extension ID |
| `version_id` | Installed schema version |

Do not copy core Joomla 4 schema rows into a Joomla 5/6 database. The target installer/updater owns those values.

### `#__update_sites`

Stores update source definitions and metadata such as source name, location, enabled state, update type, last check and optional query/download-key data.

### `#__update_sites_extensions`

Bridge between update sites and installed extensions.

### `#__updates`

Cache of discovered available updates. This is regenerated and should normally not be migrated.

### Migration Rule

For extensions:

```text
install target-compatible extension
  → let target create #__extensions / #__schemas / update-site rows
  → map source extension identity to target extension_id
  → migrate only reviewed configuration/business data
```

## 4. Action Logs

Joomla 4 includes a group of user-action logging tables.

### `#__action_logs`

Stores individual logged actions.

Important fields include:

```text
id
message_language_key
message
log_date
extension
user_id
item_id
ip_address
```

The `message` payload is structured/text data and may contain identifiers or labels relevant to the action.

### `#__action_logs_extensions`

Lists extensions participating in action logging.

### `#__action_log_config`

Defines content types/tables used by the action-log system to resolve item titles/IDs.

### `#__action_logs_users`

Stores per-user action-log notification/configuration settings.

Action logs are historical audit data. Decide explicitly whether regulatory/business requirements require preservation. They are not required for the target Joomla application to function.

## 5. Privacy Tables

### `#__privacy_requests`

Stores personal-data export/removal requests and confirmation state.

Important fields:

```text
id
email
requested_at
status
request_type
confirm_token
confirm_token_created_at
```

### `#__privacy_consents`

Stores consent records.

Important fields:

```text
id
user_id
state
created
subject
body
remind
token
```

Privacy rows may be legally significant. Unlike cache/runtime data, they must not be discarded automatically. Migration treatment should follow the site's privacy/compliance requirements.

## 6. Mail Templates

### `#__mail_templates`

Stores customizable Joomla mail templates.

| Column | Meaning |
|---|---|
| `template_id` | Template identifier such as a component mail event |
| `extension` | Owning extension |
| `language` | Language variant |
| `subject` | Subject text/language key |
| `body` | Plain-text body |
| `htmlbody` | HTML body |
| `attachments` | Attachment configuration |
| `params` | JSON parameters including supported replacement tags |

Mail templates can be customized business configuration. Compare source values with the target defaults before overwriting target rows because templates and supported tags can change by Joomla/extension version.

## 7. Scheduled Tasks

### `#__scheduler_tasks`

Stores Joomla Scheduled Tasks definitions and execution state.

Important fields include:

```text
id
asset_id
title
type
execution_rules
cron_rules
state
last_exit_code
last_execution
next_execution
times_executed
times_failed
locked
priority
ordering
cli_exclusive
params
note
created
created_by
checked_out
checked_out_time
```

The task `type` must be provided by an installed scheduler task plugin. Therefore a database row alone does not make a task runnable.

Classify scheduler data into two layers:

```text
Definition/configuration → may be migrated after compatible plugin installation
Execution state          → usually reset/recalculated on target
```

Do not copy stale `locked`, `next_execution`, counters, or failure state blindly.

## 8. Redirects and Messages

### `#__redirect_links`

Stores redirect records.

Important fields include old URL, new URL, referer, comment, hits, enabled state, created/modified timestamps and HTTP status header.

Normalize source domains and paths before migration. Verify the intended HTTP status code after import.

### `#__messages`

Stores private administrator messages. User IDs must be remapped if these historical messages are retained.

### `#__messages_cfg`

Stores per-user private-message configuration.

Administrator message history is optional for most content migrations.

## 9. Smart Search

Joomla Smart Search uses the `#__finder_*` family.

Core Joomla 4.4 tables include:

| Table | Purpose |
|---|---|
| `#__finder_filters` | Saved search filters |
| `#__finder_links` | Indexed objects |
| `#__finder_links_terms` | Link-to-term map |
| `#__finder_logging` | Search query logging |
| `#__finder_taxonomy` | Search taxonomy tree |
| `#__finder_taxonomy_map` | Link-to-taxonomy map |
| `#__finder_terms` | Indexed terms |
| `#__finder_terms_common` | Common/stop terms |
| `#__finder_tokens` | Temporary indexing tokens |
| `#__finder_tokens_aggregate` | Temporary aggregate tokens |
| `#__finder_types` | Indexed content types |

Recommended migration behavior:

1. Migrate canonical content.
2. Install/enable compatible Finder plugins.
3. Preserve only intentionally required saved filter/search-log configuration.
4. Clear generated index data.
5. Rebuild the index on the target.

Do not use the Finder index as the authoritative source of migrated content.

## 10. Guided Tours

### `#__guidedtours`

Stores administrator guided-tour definitions: title, description, ordering, extension scope, URL, state, language, access and audit/edit metadata.

### `#__guidedtour_steps`

Stores ordered steps belonging to a tour. Fields describe target selector, position, interaction type, URL, text and state.

Core/default tours are target-version data. Only migrate custom tours deliberately; do not overwrite newer core tours with Joomla 4 defaults.

## 11. Other Supporting Tables

### `#__languages`

Stores configured content languages, including language code, title/native title, SEF code, image, metadata, site name, state, access and ordering.

### `#__template_overrides`

Stores template override metadata/state. The database row must be reviewed with the actual override files.

### `#__overrider`

Supports language override search/index behavior. It is not the authoritative source file for all language overrides.

### `#__postinstall_messages`

Stores post-installation notices and enabled/completed state. Core rows are target-installation/version data and should normally be recreated by the target.

### `#__contact_details`, `#__newsfeeds`, banner tables

These are component business tables and are described in [Content Tables](./content-tables.md).

## 12. Runtime/Rebuild Classification

| Data family | Default migration treatment |
|---|---|
| `#__extensions`, `#__schemas` core rows | Recreate via target installation |
| `#__updates` | Rebuild/discover |
| Finder generated index | Rebuild |
| `#__session` | Do not migrate |
| Auth tokens/MFA/WebAuthn | Re-enroll/recreate unless explicitly supported |
| Scheduler task definitions | Migrate selectively after plugin compatibility check |
| Scheduler execution state | Reset/recalculate |
| Action logs | Optional historical/audit migration |
| Privacy requests/consents | Policy/legal decision; preserve when required |
| Mail template customization | Compare-and-migrate selectively |
| Guided tours | Migrate only custom tours intentionally |
| Redirects | Business/SEO data; migrate after normalization |

## 13. Migration Notes

- Install Joomla 5/6-compatible extensions before moving extension-owned business data.
- Map extension identity by `type`, `element`, `folder`, and `client_id`.
- Do not copy Joomla 4 core `#__extensions` or `#__schemas` rows into a newer core database.
- Do not copy `#__updates`, sessions, generated Finder tokens/index mappings, or stale scheduler locks.
- Review `params`, `manifest_cache`, `custom_data`, mail template tags and scheduler configuration for version-specific options.
- Preserve download keys securely and never commit secrets to Git.
- Rebuild Smart Search from canonical content.
- Normalize redirect URLs and validate status codes.
- Decide explicitly whether action logs, administrator messages, privacy records and custom guided tours are in migration scope.
- Compare the real site's schema with installation and update SQL because earlier Joomla 4 minor versions may differ from this 4.4.14 baseline.

[Database Overview](./database-overview.md) · [Menu and Module Tables](./menu-module-tables.md) · [Complete ERD](./complete-erd.md)