# Joomla Core Database Migration Groups — Joomla 6

## Migration Rule

> **Inventory = YES**  
> **Mapping decision = YES**

Every Joomla 6 core table must be inventoried and assigned exactly one migration-group decision before migration starts.

This manifest is rebuilt from the **official Joomla CMS 6.1.2 MySQL fresh-install DDL**, not from ERD/table documentation:

- `installation/sql/mysql/base.sql` — **28 tables**
- `installation/sql/mysql/extensions.sql` — **33 tables**
- `installation/sql/mysql/supports.sql` — **15 tables**

```text
Official physical core tables = 76
Tables classified G0-G8       = 76
Duplicate classifications     = 0
Missing tables                = 0
Extra tables                  = 0
Wildcard classifications      = 0
Baseline table coverage       = 100%
```

> `#__scheduler_logs` is the canonical Joomla 6.1.2 table name. Older project documentation that says `#__scheduler_log` is not used as the schema authority.

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
- [Official Schema Coverage](#official-schema-coverage)
- [Migration Order](#migration-order)
- [Completion Gate](#completion-gate)

---

## G0 — System Reference

**Tables:** 6 · **Physical fields:** 55

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__extensions` | `base.sql` | `REFERENCE_ONLY / TARGET_OWNED` |
| `#__schemas` | `base.sql` | `REFERENCE_ONLY / TARGET_OWNED` |
| `#__update_sites` | `base.sql` | `REFERENCE_ONLY / TARGET_OWNED` |
| `#__update_sites_extensions` | `base.sql` | `REFERENCE_ONLY / TARGET_OWNED` |
| `#__updates` | `base.sql` | `REFERENCE_ONLY / TARGET_OWNED` |
| `#__tuf_metadata` | `base.sql` | `REFERENCE_ONLY / TARGET_OWNED` |

**Rule:** Use target installation identities for system/update metadata. Never assume Joomla 3 and Joomla 6 IDs are equal.

---

## G1 — Users and Access Foundation

**Tables:** 6 · **Physical fields:** 46

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__languages` | `base.sql` | `MIGRATE / MAP` |
| `#__usergroups` | `base.sql` | `MIGRATE / MAP` |
| `#__users` | `base.sql` | `MIGRATE / MAP` |
| `#__user_usergroup_map` | `base.sql` | `MIGRATE / MAP` |
| `#__viewlevels` | `base.sql` | `MIGRATE / MAP` |
| `#__user_profiles` | `base.sql` | `MIGRATE / MAP` |

**Rule:** Foundational identity/access data. Group IDs embedded in `#__viewlevels.rules` require mapping.

---

## G2 — Taxonomy and Shared Definitions

**Tables:** 10 · **Physical fields:** 154

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__assets` | `base.sql` | `REBUILD / RECONCILE` |
| `#__categories` | `supports.sql` | `MIGRATE / MAP` |
| `#__tags` | `base.sql` | `MIGRATE / MAP` |
| `#__content_types` | `supports.sql` | `REFERENCE_ONLY / MAP` |
| `#__fields_groups` | `supports.sql` | `MIGRATE / MAP` |
| `#__fields` | `supports.sql` | `MIGRATE / MAP` |
| `#__fields_categories` | `supports.sql` | `MIGRATE / MAP` |
| `#__workflows` | `base.sql` | `RECREATE / MAP` |
| `#__workflow_stages` | `base.sql` | `RECREATE / MAP` |
| `#__workflow_transitions` | `base.sql` | `RECREATE / MAP` |

**Rule:** Prepare taxonomy, ACL definitions, custom-field definitions, and Joomla 6 workflow definitions before main content.

---

## G3 — Main Content

**Tables:** 3 · **Physical fields:** 38

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__content` | `extensions.sql` | `MIGRATE / MAP` |
| `#__content_frontpage` | `extensions.sql` | `MIGRATE / MAP` |
| `#__content_rating` | `extensions.sql` | `MIGRATE / MAP` |

**Rule:** Main article data. Requires stable users, categories, view levels, languages, and asset/workflow strategy.

---

## G4 — Content Relations

**Tables:** 8 · **Physical fields:** 66

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__contentitem_tag_map` | `supports.sql` | `MIGRATE / MAP` |
| `#__fields_values` | `supports.sql` | `MIGRATE / MAP` |
| `#__associations` | `supports.sql` | `MIGRATE / MAP` |
| `#__ucm_base` | `supports.sql` | `REBUILD / VALIDATE` |
| `#__ucm_content` | `supports.sql` | `REBUILD / VALIDATE` |
| `#__history` | `supports.sql` | `ARCHIVE / OPTIONAL_MIGRATE` |
| `#__workflow_associations` | `base.sql` | `GENERATE / MAP` |
| `#__schemaorg` | `extensions.sql` | `MIGRATE / MAP` |

**Rule:** Run after target content IDs are stable. Includes content relations, UCM/history strategy, workflow associations, and Schema.org item data.

---

## G5 — Menu and Presentation

**Tables:** 4 · **Physical fields:** 50

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__template_styles` | `base.sql` | `TRANSFORM / RECREATE` |
| `#__template_overrides` | `base.sql` | `REBUILD / REVIEW` |
| `#__menu_types` | `base.sql` | `MIGRATE / MAP` |
| `#__menu` | `base.sql` | `MIGRATE / MAP` |

**Rule:** Presentation/menu layer. Rewrite embedded IDs in links/params and recreate target-template-specific state where required.

---

## G6 — Modules

**Tables:** 2 · **Physical fields:** 20

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__modules` | `base.sql` | `MIGRATE / MAP` |
| `#__modules_menu` | `base.sql` | `MIGRATE / MAP` |

**Rule:** Module code must exist on Joomla 6 before module instances and menu assignments are migrated.

---

## G7 — Supporting Core Components

**Tables:** 16 · **Physical fields:** 217

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__contact_details` | `extensions.sql` | `MIGRATE / MAP` |
| `#__newsfeeds` | `extensions.sql` | `MIGRATE / MAP` |
| `#__banners` | `extensions.sql` | `MIGRATE / MAP` |
| `#__banner_clients` | `extensions.sql` | `MIGRATE / MAP` |
| `#__banner_tracks` | `extensions.sql` | `ARCHIVE / OPTIONAL_MIGRATE` |
| `#__redirect_links` | `extensions.sql` | `MIGRATE / MAP` |
| `#__messages` | `extensions.sql` | `MIGRATE / OPTIONAL` |
| `#__messages_cfg` | `extensions.sql` | `MIGRATE / OPTIONAL` |
| `#__user_notes` | `base.sql` | `MIGRATE / MAP` |
| `#__privacy_requests` | `extensions.sql` | `MIGRATE / ARCHIVE` |
| `#__privacy_consents` | `extensions.sql` | `MIGRATE / ARCHIVE` |
| `#__mail_templates` | `supports.sql` | `MERGE / RECREATE` |
| `#__scheduler_tasks` | `extensions.sql` | `RECREATE / SELECTIVE` |
| `#__action_logs_extensions` | `extensions.sql` | `TARGET_OWNED / MERGE` |
| `#__action_log_config` | `extensions.sql` | `TARGET_OWNED / MERGE` |
| `#__action_logs_users` | `extensions.sql` | `MIGRATE / REVIEW` |

**Rule:** Business/supporting core components. Some records are optional or target-owned and require explicit scope decisions.

---

## G8 — Runtime, Generated, and Target-Owned Data

**Tables:** 21 · **Physical fields:** 186

| Table | Official DDL | Mapping decision |
|---|---|---|
| `#__session` | `base.sql` | `IGNORE` |
| `#__user_keys` | `base.sql` | `IGNORE` |
| `#__user_mfa` | `base.sql` | `RECREATE / RE-ENROL` |
| `#__webauthn_credentials` | `supports.sql` | `RECREATE / RE-ENROL` |
| `#__scheduler_logs` | `extensions.sql` | `IGNORE / ARCHIVE` |
| `#__action_logs` | `extensions.sql` | `IGNORE / ARCHIVE` |
| `#__finder_filters` | `extensions.sql` | `MIGRATE / RECREATE / REVIEW` |
| `#__finder_links` | `extensions.sql` | `REBUILD` |
| `#__finder_links_terms` | `extensions.sql` | `REBUILD` |
| `#__finder_logging` | `extensions.sql` | `IGNORE / ARCHIVE` |
| `#__finder_taxonomy` | `extensions.sql` | `REBUILD` |
| `#__finder_taxonomy_map` | `extensions.sql` | `REBUILD` |
| `#__finder_terms` | `extensions.sql` | `REBUILD` |
| `#__finder_terms_common` | `extensions.sql` | `TARGET_OWNED / REVIEW` |
| `#__finder_tokens` | `extensions.sql` | `REBUILD` |
| `#__finder_tokens_aggregate` | `extensions.sql` | `REBUILD` |
| `#__finder_types` | `extensions.sql` | `REBUILD` |
| `#__postinstall_messages` | `supports.sql` | `TARGET_OWNED` |
| `#__overrider` | `supports.sql` | `MIGRATE / RECREATE / REVIEW` |
| `#__guidedtours` | `extensions.sql` | `TARGET_OWNED` |
| `#__guidedtour_steps` | `extensions.sql` | `TARGET_OWNED` |

**Rule:** All tables are inventoried, but runtime/security/generated/target-owned data must not be blindly copied. `finder_filters` and `overrider` require review because they can contain user configuration.

---

## Official Schema Coverage

| Official schema file | Tables | Fields |
|---|---:|---:|
| `base.sql` | 28 | 388 |
| `extensions.sql` | 33 | 344 |
| `supports.sql` | 15 | 100 |
| **Total** | **76** | **832** |

### Group coverage

| Group | Tables | Fields |
|---|---:|---:|
| G0 — System Reference | 6 | 55 |
| G1 — Users and Access Foundation | 6 | 46 |
| G2 — Taxonomy and Shared Definitions | 10 | 154 |
| G3 — Main Content | 3 | 38 |
| G4 — Content Relations | 8 | 66 |
| G5 — Menu and Presentation | 4 | 50 |
| G6 — Modules | 2 | 20 |
| G7 — Supporting Core Components | 16 | 217 |
| G8 — Runtime, Generated, and Target-Owned Data | 21 | 186 |
| **Total** | **76** | **832** |

Coverage contract:

```text
Official tables                  = 76
Explicit group decisions         = 76
Official physical fields         = 832
Duplicate table assignments      = 0
Unclassified official tables     = 0
Wildcard groups                  = 0
Baseline table coverage          = 100%
```

---

## Migration Order

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

## Completion Gate

Before this manifest can be used as a migration contract:

```text
Official Joomla 6.1.2 tables discovered = 76 / 76
Tables assigned to exactly one group     = 76 / 76
Missing official tables                  = 0
Extra manifest tables                    = 0
Duplicate group assignments              = 0
Wildcard table entries                   = 0
Unclassified tables                      = 0

TABLE MANIFEST                            = PASS
```

The companion [`joomla-core-migration-fields-v6.md`](04-joomla-core-migration-fields-v6.md) must independently reconcile every official `(table, field)` pair before field coverage can be marked PASS.

> The 76-table / 832-field numbers are the official Joomla 6.1.2 fresh-install baseline. A real target database must still be reconciled against `information_schema.TABLES` and `information_schema.COLUMNS` to detect customization, extension-owned objects, or later Joomla 6.x changes.
