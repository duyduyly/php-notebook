# Joomla Feature Inventory Contract

This directory defines a deterministic inventory contract for one Joomla website or project. It can produce either a
small stakeholder catalogue or a complete technical baseline suitable for migration planning, support handover, and
runtime audit.

> Inventory one environment per `inventory_run_id`. Inventory source and target environments separately; comparison
> between runs belongs to a separate comparison workflow.

## Profiles

| Profile | Required files | Intended use |
|---|---|---|
| `CATALOG` | `00`, `01`, `02`, `03`, `05`, `13` | Stakeholder feature/page catalogue with evidence and structural validation |
| `COMPLETE` | `00` through `13` | Joomla technical inventory, migration baseline, support handover, and audit |

Do not call an inventory `COMPLETE` when a required file or completeness gate is missing. Unknown or blocked semantics
must be represented in `12-exception-register.csv`; never silently omit them or convert them to empty values.

## Reporting model

```text
00 Inventory Run
 ├─ 01 Features ───────────────┐
 ├─ 02 Pages / Route Classes ──┼─ 03 Page-Feature Map
 ├─ 07 Implementations ────────┘       │
 │    ├─ 04 Dependencies               │
 │    ├─ 08 Data Objects               │
 │    ├─ 09 Integrations               │
 │    └─ 11 Access Control             │
 ├─ 05 Evidence (may prove any record) │
 ├─ 10 Runtime Verification ───────────┘
 ├─ 06 Coverage
 ├─ 12 Exceptions
 └─ 13 Validation Results
```

## Canonical outputs

| File | Responsibility |
|---|---|
| `00-inventory-run.csv` | Bind scope, environment, versions, revision, operator, and profile |
| `01-feature-inventory.csv` | Define business/user capabilities, not merely extension names |
| `02-page-inventory.csv` | Define menu pages, non-menu pages, route families, APIs, admin pages, and CLI surfaces |
| `03-page-feature-map.csv` | Map page + feature + implementation usage, placement, and conditions |
| `04-feature-dependency-map.csv` | Record required and conditional technical dependencies |
| `05-feature-evidence.csv` | Store authoritative, static, and runtime proof for any inventory subject |
| `06-feature-coverage.csv` | Measure reviewed, mapped, verified, unknown, and excluded scope with an explicit denominator |
| `07-implementation-inventory.csv` | Inventory extensions, overrides, libraries, jobs, APIs, and custom code |
| `08-data-object-inventory.csv` | Inventory tables, fields, files, assets, stored payloads, and migration disposition |
| `09-external-integration-inventory.csv` | Inventory inbound/outbound services without storing secrets |
| `10-route-runtime-verification.csv` | Record repeatable HTTP/CLI/runtime checks and observed behavior |
| `11-access-control-map.csv` | Record ACL, access levels, authentication contexts, and observed decisions |
| `12-exception-register.csv` | Own every unknown, blocker, exclusion, ambiguity, and manual decision |
| `13-validation-results.csv` | Record deterministic validation rules, commands, expected values, and results |

## Joomla discovery scope

A complete run reviews all applicable surfaces:

- extension registry, manifests, namespaces, service providers, Discover state, and update metadata;
- site/admin components, modules, plugins, templates, overrides, libraries, packages, CLI jobs, APIs, and background tasks;
- menus, aliases, parent paths, SEF/non-SEF routes, redirects, dynamic routes, filters, pagination, authentication,
  administrator routes, language variants, and error routes;
- module instances, positions, menu assignments, publication windows, access, language, and conditions;
- tables/fields, ownership, counts, identifiers, relationships, stored JSON/HTML/layouts, files, media, generated data,
  logs/history, PII, and retention;
- ACL assets/actions, user groups, view levels, authentication and authorization conditions;
- external APIs, mail, payment, analytics, captcha, SFTP, queues, webhooks, cron/CLI, configuration locations, retry and
  timeout behavior;
- runtime outputs, statuses, redirects, PHP/JavaScript errors, writes, messages, mail, files, and side effects.

Implementation names such as `com_content`, `mod_menu`, and `#__cars_car` are discovery signals. Final feature names
should describe capabilities such as `Article Detail`, `Main Navigation`, and `Vehicle Search`.

## Identity and normalization rules

- IDs are stable and never reused: `RUN-*`, `F-*`, `P-*`, `MAP-*`, `DEP-*`, `EV-*`, `COV-*`, `IMP-*`, `DATA-*`,
  `INT-*`, `RV-*`, `ACL-*`, `EXC-*`, and `VAL-*`.
- Semantic keys are stable; database numeric IDs belong in dedicated fields and are not semantic identity.
- Dynamic entities sharing implementation and behavior use one route-class row plus representative runtime fixtures.
- Mapping uniqueness is `(page_id, feature_id, implementation_id, usage_type, position, trigger, condition)`.
- `primary_implementation_id` references `07`; additional implementations are represented through `03` and `04`.
- Use empty only for not-applicable fields. Use `UNKNOWN` when a required value was not determined.
- Store no passwords, tokens, private keys, or session values. Record only a secret/configuration location.

## Evidence levels

| Level | Meaning |
|---|---|
| `VERIFIED` | Observed at runtime or read from an authoritative database/manifest/runtime source |
| `STATIC` | Confirmed in source or configuration but not executed |
| `INFERRED` | Reasoned from evidence; inference is explicitly stated |
| `UNKNOWN` | Insufficient evidence |
| `BLOCKED` | Evidence requires a missing input, authority, dependency, or environment |

Static or inferred evidence cannot be reported as runtime verification.

## Complete-profile gates

A `COMPLETE` run may finish only when:

- every required file exists with the canonical header;
- IDs/keys are unique and foreign references resolve;
- every in-scope implementation maps to a feature or an owned exclusion;
- every published menu and important non-menu route is inventoried or excepted;
- every page has a feature map and every active page-based feature has a page;
- every data/file object has an owner or an explicit shared/unknown exception;
- every required dependency and integration has availability evidence;
- critical routes and representative dynamic classes have runtime verification;
- ACL-sensitive features have expected and observed decisions;
- coverage denominators/formulas are recorded and scoped areas are 100% reviewed or excepted;
- all unknowns, blockers, exclusions, and failed checks have exception records;
- no `PASS` depends on an unresolved high/critical exception or `UNKNOWN`, `INFERRED`, or `BLOCKED` evidence.

See [WORKFLOW.md](./WORKFLOW.md) for execution order and
[CONTROLLED-VOCABULARY.md](./CONTROLLED-VOCABULARY.md) for canonical values.

Run the deterministic validator from the repository root:

```powershell
pwsh -NoProfile -File workspace/inventories/features/workflow/validate-inventory.ps1 `
    -RunDirectory workspace/inventories/features/runs/<inventory-run>
```

The validator returns exit code `0` only when required files, exact headers, IDs, references, selected vocabularies,
mapping uniqueness, coverage arithmetic, and blocking-exception gates pass.

## Directory structure

```text
workflow/
├── README.md
├── WORKFLOW.md
├── CONTROLLED-VOCABULARY.md
├── validate-inventory.ps1
└── templates/
    ├── 00-inventory-run-template.csv
    ├── 01-feature-inventory-template.csv
    ├── 02-page-inventory-template.csv
    ├── 03-page-feature-map-template.csv
    ├── 04-feature-dependency-map-template.csv
    ├── 05-feature-evidence-template.csv
    ├── 06-feature-coverage-template.csv
    ├── 07-implementation-inventory-template.csv
    ├── 08-data-object-inventory-template.csv
    ├── 09-external-integration-inventory-template.csv
    ├── 10-route-runtime-verification-template.csv
    ├── 11-access-control-map-template.csv
    ├── 12-exception-register-template.csv
    └── 13-validation-results-template.csv
```
