# Joomla 5 Extension and System Tables

This document explains Joomla 5.4 extension registration, database update metadata, scheduled tasks and execution logs, action logs, privacy, mail templates, redirects, messages, Smart Search, Schema.org storage, guided tours and other core system tables.

> **Schema baseline:** Joomla 5.4.7.

## Table of Contents

- [1. Extension Registration](#1-extension-registration)
- [2. `#__extensions`](#2-extensions)
- [3. Schema and Update Tables](#3-schema-and-update-tables)
- [4. Action Logs](#4-action-logs)
- [5. Privacy Tables](#5-privacy-tables)
- [6. Mail Templates](#6-mail-templates)
- [7. Scheduled Tasks and Logs](#7-scheduled-tasks-and-logs)
- [8. Redirects and Messages](#8-redirects-and-messages)
- [9. Smart Search](#9-smart-search)
- [10. Schema.org Storage](#10-schemaorg-storage)
- [11. Guided Tours](#11-guided-tours)
- [12. Other Supporting Tables](#12-other-supporting-tables)
- [13. Runtime/Rebuild Classification](#13-runtimerebuild-classification)
- [14. Migration Notes](#14-migration-notes)

## 1. Extension Registration

Installed components, modules, plugins, templates, libraries, packages, files and languages are registered in `#__extensions`.

Registration is separate from business data:

```text
#__extensions.element = com_content → Content component installation
#__content                       → Article business data
```

Third-party extensions may store data in:

1. their own tables;
2. `#__extensions.params` or other extension registration metadata;
3. Joomla core tables such as categories, menus, modules, fields or scheduler tasks;
4. other extension tables.

A complete inventory must scan all four paths.

## 2. `#__extensions`

Important Joomla 5.4 columns include:

| Column | Meaning |
|---|---|
| `extension_id` | Installation-specific ID |
| `package_id` | Parent package ID |
| `name` | Extension display/language name |
| `type` | Extension type |
| `element` | Machine name |
| `changelogurl` | Changelog location |
| `folder` | Plugin group where applicable |
| `client_id` | Site/administrator client |
| `enabled` | Enabled state |
| `access` | Access setting where applicable |
| `protected` | Protected flag |
| `locked` | Uninstall lock |
| `manifest_cache` | Manifest metadata |
| `params` | JSON extension configuration |
| `custom_data` | Extension-specific stored data |
| `checked_out`, `checked_out_time` | Editing lock |
| `ordering` | Ordering, important for plugin execution |
| `state` | Internal state |
| `note` | Administrator note |

Use this logical identity when mapping extensions:

```text
type + element + folder + client_id
```

Do not map by `extension_id` alone.

## 3. Schema and Update Tables

### `#__schemas`

Tracks the installed database schema version for an extension.

### `#__update_sites`

Stores update source definitions, locations, state, last-check metadata and optional query/download-key configuration.

### `#__update_sites_extensions`

Maps extensions to update sites.

### `#__updates`

Cache of updates discovered by Joomla. Rebuild this on the target instead of migrating it.

### Target Rule

For Joomla 5 → Joomla 6:

```text
install/upgrade target core and extensions
  → target creates registration/schema/update metadata
  → build extension identity map
  → migrate reviewed configuration/business data
```

Do not overwrite Joomla 6's core `#__schemas` or core extension rows with Joomla 5 values.

## 4. Action Logs

Joomla 5 uses the action-log family inherited from Joomla 4.

### `#__action_logs`

Stores individual actions with message key/payload, date, extension, user, item and IP metadata.

### `#__action_logs_extensions`

Lists extensions participating in action logging.

### `#__action_log_config`

Defines how logged content types resolve source tables/IDs/titles.

### `#__action_logs_users`

Stores per-user notification/logging preferences.

These are historical audit records, not application source-of-truth data. Retain them only according to operational/compliance requirements.

## 5. Privacy Tables

### `#__privacy_requests`

Stores personal-data export/removal requests and confirmation workflow values.

### `#__privacy_consents`

Stores consent records linked to users.

Privacy data can be legally significant. Do not classify it automatically as disposable runtime data. Define retention/migration requirements before cutover.

## 6. Mail Templates

### `#__mail_templates`

Stores editable mail template variants.

| Column | Meaning |
|---|---|
| `template_id` | Template/event ID |
| `extension` | Owning extension |
| `language` | Language variant |
| `subject` | Subject template |
| `body` | Plain-text body |
| `htmlbody` | HTML body |
| `attachments` | Attachment configuration |
| `params` | JSON supported-tag/configuration metadata |

Do a source-vs-target comparison before copying customizations. Supported template tags and default content can change between Joomla 5 and Joomla 6.

## 7. Scheduled Tasks and Logs

### `#__scheduler_tasks`

Stores task definitions plus execution state.

Key data areas:

```text
Identity       : id, asset_id, title, type
Schedule       : execution_rules, cron_rules
State          : state, last_exit_code, last_execution, next_execution
Counters       : times_executed, times_failed
Locking        : locked
Priority       : priority, ordering, cli_exclusive
Configuration  : params, note
Audit/edit     : created, created_by, checked_out, checked_out_time
```

A task `type` is implemented by a scheduler task plugin. A database task without its compatible plugin is not runnable.

### `#__scheduler_logs`

Joomla 5.4 stores scheduled-task execution history separately.

Verified 5.4.7 fields include:

| Column | Meaning |
|---|---|
| `id` | Log row ID |
| `taskname` | Task display name at execution time |
| `tasktype` | Plugin-defined task type |
| `duration` | Execution duration |
| `jobid` | Execution/job identifier |
| `taskid` | Related scheduled task ID |
| `exitcode` | Task exit code |
| `lastdate` | Last-run timestamp |
| `nextdate` | Planned next-run timestamp |

Logical relation:

```text
#__scheduler_tasks.id → #__scheduler_logs.taskid
```

Treat task definitions and task history differently:

| Data | Default treatment |
|---|---|
| Task definition/config | Selective migration after plugin compatibility check |
| Asset/permissions | Map/rebuild |
| Lock/next-run state | Reset/recalculate |
| Counters | Usually reset unless required |
| `#__scheduler_logs` | Historical/operational scope only |

## 8. Redirects and Messages

### `#__redirect_links`

Stores old URL, target URL, referer, comments, hit count, publication state, timestamps and response header/status code.

Normalize hostnames/paths and verify redirects after migration.

### `#__messages`

Private administrator messages. Remap sender/recipient user IDs if preserving message history.

### `#__messages_cfg`

Per-user administrator-message configuration.

## 9. Smart Search

Joomla 5.4 Smart Search uses these main tables:

| Table | Purpose |
|---|---|
| `#__finder_filters` | Saved filters |
| `#__finder_links` | Indexed content objects |
| `#__finder_links_terms` | Link-to-term mappings |
| `#__finder_logging` | Search logging |
| `#__finder_taxonomy` | Hierarchical search taxonomy |
| `#__finder_taxonomy_map` | Link-to-taxonomy mappings |
| `#__finder_terms` | Search terms |
| `#__finder_terms_common` | Common terms |
| `#__finder_tokens` | Temporary indexing tokens |
| `#__finder_tokens_aggregate` | Temporary aggregates |
| `#__finder_types` | Indexed content types |

Safe default:

```text
migrate canonical content
→ install/enable target Finder plugins
→ preserve only required saved configuration/log history
→ clear target index
→ rebuild Finder index
```

Generated index rows should not be the canonical migration source.

## 10. Schema.org Storage

### `#__schemaorg`

Joomla 5.4 includes core Schema.org storage:

```text
id
itemId
context
schemaType
schema
```

This table contains content-related configuration but is listed here as a system integration because it depends on Schema.org plugins/rendering behavior.

Always resolve:

```text
context + itemId
```

before remapping a business item. Validate `schemaType` and the `schema` payload against Joomla 6's supported structured-data implementation.

See [Content Tables](./content-tables.md) for migration treatment.

## 11. Guided Tours

### `#__guidedtours`

Stores administrator tour definitions and metadata.

### `#__guidedtour_steps`

Stores ordered interactive steps per tour.

Core Joomla tours belong to the target version. Migrate only intentionally customized/custom tours, and do not overwrite newer Joomla 6 core tours blindly.

## 12. Other Supporting Tables

### `#__languages`

Configured content languages with language code, native title, SEF code, state, access and ordering.

### `#__template_overrides`

Template override database metadata. Review it together with filesystem override files.

### `#__overrider`

Language override helper/index data.

### `#__postinstall_messages`

Version-specific post-install messages/state. Target Joomla should generally generate its own core rows.

### Component business tables

`#__contact_details`, `#__newsfeeds`, and banner tables are described in [Content Tables](./content-tables.md).

## 13. Runtime/Rebuild Classification

| Data family | Default migration treatment |
|---|---|
| Core `#__extensions` / `#__schemas` | Target installation owns them |
| `#__updates` | Re-discover |
| Finder generated index | Rebuild |
| `#__session` | Do not migrate |
| Persistent auth/MFA/WebAuthn | Recreate/re-enroll unless supported |
| Scheduler task configuration | Selective migration |
| Scheduler runtime lock/next state | Reset/recalculate |
| `#__scheduler_logs` | Optional historical data |
| Action logs | Optional audit data |
| Privacy records | Retention/compliance decision |
| Mail templates | Compare/selectively migrate customizations |
| Schema.org rows | Migrate by context/item mapping |
| Redirects | Migrate as SEO/business configuration |
| Guided tours | Preserve custom only by default |

## 14. Migration Notes

- Bring the source Joomla 5 installation to a known 5.4.x state before major-version migration and validate extension compatibility.
- Map extensions by identity, not raw IDs.
- Let Joomla 6 create its own core extension/schema/update records.
- Review third-party extension `params`, custom data, update sites and business tables separately.
- Never commit paid download keys, tokens or secrets.
- Reset scheduler locks and recalculate execution state on the target.
- Preserve scheduler logs/action logs only when required.
- Rebuild Finder generated data.
- Normalize redirects and verify response status codes.
- Compare mail template customizations and supported replacement tags.
- Migrate Schema.org rows using `context + itemId`, then verify frontend structured-data output.
- Treat privacy data according to retention/compliance requirements.
- Compare the live schema with Joomla 5.4.7 installation/update SQL before writing final migration mappings.

[Database Overview](./database-overview.md) · [Menu and Module Tables](./menu-module-tables.md) · [Complete ERD](./complete-erd.md)