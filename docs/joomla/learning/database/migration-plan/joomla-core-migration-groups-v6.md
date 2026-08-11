# Joomla Core Database Migration Groups — Joomla 6

## Migration Rule

> **Inventory = YES**  
> **Mapping decision = YES**

Every Joomla 6 core table must be inventoried and assigned a mapping decision before migration starts.

This document uses the **official Joomla 6.1.2 MySQL installation schema** as the core-table baseline:

- `installation/sql/mysql/base.sql`
- `installation/sql/mysql/extensions.sql`
- `installation/sql/mysql/supports.sql`

**Verified baseline:** `76 physical core tables`

Allowed mapping decisions:

- `MIGRATE`
- `TRANSFORM`
- `LOOKUP`
- `REBUILD`
- `REFERENCE_ONLY`
- `ARCHIVE`
- `IGNORE`
- `TARGET_OWNED`
- `RECREATE`

**Target rules:**

```text
Core tables in official baseline = 76
Tables explicitly classified     = 76
Duplicate classifications        = 0
Unclassified tables              = 0
Wildcard table groups            = 0
```

For a real target database, inventory must still compare the actual Joomla 6 schema against this baseline. Any local customization, extension-owned table, later Joomla 6.x schema change, or unexpected table must be reported separately.

---

## Table of Contents

- [G0 — System Reference](#g0--system-reference)
- [G1 — Users and Access Foundation](#g1--users-and-access-foundation)
- [G2 — Taxonomy and Shared Definitions](#g2--taxonomy-and-shared-definitions)
- [G3 — Main Content](#g3--main-content)
- [G4 — Content Relations](#g4--content-relations)
- [G5 — Menu and Presentation](#g5--menu-and-presentation)
- [G6 — Modules](#g6--modules)
- [G7 — Supporting Core Components](#g7--supporting-core-components)
- [G8 — Runtime, Generated, and Target-Owned Data](#g8--runtime-generated-and-target-owned-data)
- [Recommended Migration Order](#recommended-migration-order)
- [Coverage Manifest](#coverage-manifest)
- [Field Coverage Gate](#field-coverage-gate)
- [Completion Criteria](#completion-criteria)

---

## G0 — System Reference

Used mainly as target reference data. Do not blindly overwrite Joomla 6 installation-owned system rows.

**Tables: 6**

- `#__extensions`
- `#__schemas`
- `#__update_sites`
- `#__update_sites_extensions`
- `#__updates`
- `#__tuf_metadata`

Typical decisions: `REFERENCE_ONLY`, `TARGET_OWNED`, `REBUILD`, or `IGNORE`.

Important:

- Map extensions by stable identity such as `type + element + folder + client_id`.
- Do not assume Joomla 3 and Joomla 6 `extension_id` values are identical.
- Keep Joomla 6 update, schema, and TUF metadata owned by the target installation.

---

## G1 — Users and Access Foundation

Prepare identity, user groups, view levels, profiles, and languages before migrating content that depends on them.

**Tables: 6**

- `#__languages`
- `#__usergroups`
- `#__users`
- `#__user_usergroup_map`
- `#__viewlevels`
- `#__user_profiles`

Important:

- Map groups before user-group assignments.
- Remap group IDs stored inside `#__viewlevels.rules`.
- Validate password compatibility before migrating users.

---

## G2 — Taxonomy and Shared Definitions

Prepare categories, tags, custom fields, ACL structures, and Joomla 6 workflow definitions required by content.

**Tables: 10**

- `#__assets` — special handling; rebuild/reconcile instead of blind copy
- `#__categories`
- `#__tags`
- `#__content_types`
- `#__fields_groups`
- `#__fields`
- `#__fields_categories`
- `#__workflows`
- `#__workflow_stages`
- `#__workflow_transitions`

Important:

- Validate nested-set trees for assets, categories, and tags.
- Use target Joomla 6 workflow/stage/transition IDs.
- Workflow definitions must exist before workflow associations are created.

---

## G3 — Main Content

Migrate primary article data after users, view levels, categories, languages, and workflow definitions are ready.

**Tables: 3**

- `#__content`
- `#__content_frontpage`
- `#__content_rating`

Main dependencies include:

- `#__categories`
- `#__users`
- `#__viewlevels`
- `#__assets`
- `#__languages`

---

## G4 — Content Relations

Migrate content relationships only after the main target content IDs are stable.

**Tables: 8**

- `#__contentitem_tag_map`
- `#__fields_values`
- `#__associations`
- `#__ucm_base`
- `#__ucm_content`
- `#__history`
- `#__workflow_associations`
- `#__schemaorg`

Important:

- `#__fields_values.item_id` is context-dependent.
- Remap tag IDs and content item IDs.
- Treat `#__history` as optional historical data unless explicitly required.
- `#__workflow_associations.item_id` must reference the migrated Joomla 6 content ID.
- `#__workflow_associations.stage_id` must reference a valid Joomla 6 workflow stage.
- Review Schema.org data because it is context/item-ID dependent.

---

## G5 — Menu and Presentation

Menu and presentation data depends on content, extension mapping, access levels, and valid Joomla 6 template styles.

**Tables: 4**

- `#__template_styles`
- `#__template_overrides`
- `#__menu_types`
- `#__menu`

Important:

- Map `component_id` using target `#__extensions`.
- Map or recreate `template_style_id`.
- Rewrite article/category IDs embedded in menu `link`.
- Inspect JSON `params` for embedded IDs.
- Validate menu tree values: `parent_id`, `lft`, `rgt`, `level`, and `path`.
- Treat template override state as target/template-specific data.

---

## G6 — Modules

Migrate module instances after menu IDs and required Joomla 6 extension code are ready.

**Tables: 2**

- `#__modules`
- `#__modules_menu`

Important:

- Compatible module code must exist before migrating module instances.
- Map module IDs and menu IDs.
- Validate target template positions.
- `#__modules_menu.menuid` must reference the mapped Joomla 6 menu ID.

---

## G7 — Supporting Core Components

Migrate or recreate remaining Joomla 6 core business/configuration data as separate sub-batches.

**Tables: 16**

### G7.1 Contacts

- `#__contact_details`

### G7.2 Newsfeeds

- `#__newsfeeds`

### G7.3 Banners

- `#__banners`
- `#__banner_clients`
- `#__banner_tracks`

### G7.4 Redirects

- `#__redirect_links`

### G7.5 Messages

- `#__messages`
- `#__messages_cfg`

### G7.6 User Notes

- `#__user_notes`

### G7.7 Privacy

- `#__privacy_requests`
- `#__privacy_consents`

Typical decision: `MIGRATE`, `ARCHIVE`, or `TARGET_OWNED` depending on business/compliance requirements.

### G7.8 Mail

- `#__mail_templates`

Typical decision: preserve Joomla 6 defaults and merge only required customizations.

### G7.9 Scheduler Configuration

- `#__scheduler_tasks`

Typical decision: `RECREATE` or selectively configure only when the required Joomla 6 task plugin exists.

### G7.10 Action Log Configuration

- `#__action_logs_extensions`
- `#__action_log_config`
- `#__action_logs_users`

Typical decision: keep Joomla 6 defaults or selectively recreate required configuration/user preferences.

---

## G8 — Runtime, Generated, and Target-Owned Data

These tables must still appear in inventory and mapping, but normally should not be copied directly from Joomla 3.

**Tables: 21**

### G8.1 Authentication and Runtime

- `#__session`
- `#__user_keys`
- `#__user_mfa`
- `#__webauthn_credentials`

Typical decisions:

- `#__session` → `IGNORE`
- `#__user_keys` → `IGNORE`
- `#__user_mfa` → `RECREATE` / user re-enrolment
- `#__webauthn_credentials` → `RECREATE` / user re-enrolment

### G8.2 Scheduler and Audit Runtime

- `#__scheduler_logs`
- `#__action_logs`

Typical decisions:

- `#__scheduler_logs` → `IGNORE` / `ARCHIVE`
- `#__action_logs` → `IGNORE` / `ARCHIVE`

### G8.3 Smart Search / Finder Generated Data

- `#__finder_filters`
- `#__finder_links`
- `#__finder_links_terms`
- `#__finder_logging`
- `#__finder_taxonomy`
- `#__finder_taxonomy_map`
- `#__finder_terms`
- `#__finder_terms_common`
- `#__finder_tokens`
- `#__finder_tokens_aggregate`
- `#__finder_types`

Typical decision: `REBUILD` for generated index data. Review `#__finder_filters` separately if saved search filters are business-required.

### G8.4 Installation and Target-Owned UI/System Data

- `#__postinstall_messages`
- `#__overrider`
- `#__guidedtours`
- `#__guidedtour_steps`

Typical decisions:

- `#__postinstall_messages` → `TARGET_OWNED`
- `#__overrider` → `REBUILD` / selectively migrate language overrides
- `#__guidedtours` → `TARGET_OWNED`
- `#__guidedtour_steps` → `TARGET_OWNED`

---

## Recommended Migration Order

```text
G0 System Reference
        ↓
G1 Users / Access Foundation
        ↓
G2 Taxonomy / Shared Definitions / Workflow
        ↓
G3 Main Content
        ↓
G4 Content Relations / Workflow Associations
        ↓
G5 Menu / Presentation
        ↓
G6 Modules
        ↓
G7 Supporting Core Components
        ↓
G8 Runtime / Generated / Target-Owned
```

---

## Coverage Manifest

The official Joomla 6.1.2 MySQL fresh-install schema contains **76 physical core tables** across `base.sql`, `extensions.sql`, and `supports.sql`.

| Group | Table Count |
|---|---:|
| G0 — System Reference | 6 |
| G1 — Users and Access Foundation | 6 |
| G2 — Taxonomy and Shared Definitions | 10 |
| G3 — Main Content | 3 |
| G4 — Content Relations | 8 |
| G5 — Menu and Presentation | 4 |
| G6 — Modules | 2 |
| G7 — Supporting Core Components | 16 |
| G8 — Runtime, Generated, and Target-Owned Data | 21 |
| **Total** | **76** |

Coverage contract:

```text
Official Joomla 6.1.2 core tables = 76
Explicitly listed tables          = 76
Duplicate classifications         = 0
Wildcard classifications          = 0
Unclassified tables               = 0

Baseline table coverage           = 100%
```

---

## Field Coverage Gate

This group manifest proves table classification coverage. It intentionally does not hard-code every column as the final authority.

For the actual Joomla 6 target, scan `information_schema.COLUMNS` and populate `field_inventory` directly from the real database.

Required gate:

```text
Actual target fields discovered   = 100%
Fields inserted into inventory    = 100%
Required target fields resolved   = 100%

Missing fields                    = 0
Duplicate inventory fields        = 0
Unclassified fields               = 0
Unresolved required target fields = 0
```

Recommended reconciliation query concept:

```sql
SELECT
    COUNT(*) AS actual_target_fields
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = '<JOOMLA6_DATABASE>';
```

The inventory count for the same database must match this count exactly before the mapping gate can pass.

---

## Completion Criteria

Before Joomla 6 core migration is considered ready:

```text
Actual target core tables inventoried = 100%
Actual target core fields inventoried = 100%
Core tables classified                = 100%
Mapping decisions completed           = 100%
Required target fields resolved       = 100%

Unclassified tables                   = 0
Unmapped required fields              = 0
Unresolved dependencies               = 0
Unresolved workflow mappings          = 0
Unexplained target tables              = 0
```

Only after the mapping gate passes should migration scripts execute.

> The `76/76` table coverage applies to the official Joomla 6.1.2 fresh-install MySQL schema baseline. The migration inventory must still scan the real target database and flag any additional, missing, customized, third-party, or extension-owned tables before migration.
