# Complete Joomla Feature Inventory Workflow

Execute one step at a time. Do not complete a later step while an earlier required gate is failed or blocked.

## Step 0 — Bind the run

Create `00-inventory-run.csv`. Record the exact project, environment, Joomla/PHP/database versions, source root,
site/admin URLs, source revision, profile, operator, and timestamps. One `inventory_run_id` represents one environment.

Gate: exactly one active binding exists and all required environment fields are known.

## Step 1 — Inventory Joomla implementations

Create `07-implementation-inventory.csv` from database and filesystem evidence. Review `#__extensions`, manifests,
source entry points, service providers, namespaces, Discover state, modules, plugins, templates/overrides, libraries,
packages, CLI jobs, APIs, custom scripts, and background behavior. Separate installed, enabled, published, discoverable,
compatible, and runtime-verified states.

Gate: every in-scope implementation is inventoried or excepted; registry/filesystem discrepancies are explicit.

## Step 2 — Inventory data and integrations

Create `08-data-object-inventory.csv` and `09-external-integration-inventory.csv`.

For data, record owner, object, identifier, relationships, count/size, classification, PII, retention, generated state,
and migration disposition. Include extension/shared tables, stored JSON/HTML/layouts, files, media, and missing expected
objects. For integrations, record direction, protocol, endpoint/host, configuration and secret locations, exchanged data,
privacy impact, retry/timeout behavior, trigger/schedule, enabled state, and runtime status. Never store credentials.

Gate: every in-scope data object and integration has an owner or an owned `UNKNOWN` exception.

## Step 3 — Normalize capabilities

Create `01-feature-inventory.csv`. Derive capabilities from implementations, data, configuration, documentation, and
runtime behavior. Name capabilities rather than folders. Separate materially different behavior and deduplicate multiple
implementations of one capability.

Gate: every active implementation maps to a feature or exclusion; uncertainty remains `UNKNOWN` or `CONDITIONAL`.

## Step 4 — Inventory pages and route classes

Create `02-page-inventory.csv`. Start from `#__menu`, then include component routes, SEF/non-SEF forms, dynamic detail
families, search/filter/pagination, API endpoints, authenticated/admin pages, CLI commands, redirects, language variants,
and meaningful error/empty states. Keep menu identity separate from route identity. Normalize repeated entities into route
classes when implementation and behavior match.

Gate: all published menus and important non-menu routes are represented or excepted; canonical routes are explicit.

## Step 5 — Map usage, dependencies, and access

Create `03-page-feature-map.csv`, `04-feature-dependency-map.csv`, and `11-access-control-map.csv`. Map concrete
implementations, placement, trigger, visibility, language, access, and conditions. Record direct, indirect, conditional,
data, runtime, presentation, external, and authorization dependencies. Record expected ACL decisions by context.

Gate: references resolve; no normalized duplicates exist; dependencies have availability; ACL expectations are explicit.

## Step 6 — Collect evidence

Create `05-feature-evidence.csv` throughout discovery and close its gate here. Evidence may prove any feature, page,
mapping, implementation, data object, integration, ACL record, runtime check, or exception. Record exact subject, source,
reference, observed value, environment, time, collector, and checksum where useful. Keep evidence levels distinct.

Gate: each active feature, critical page, required dependency/integration, and exclusion has evidence.

## Step 7 — Verify runtime behavior

Create `10-route-runtime-verification.csv`. For each critical page and representative dynamic route class, record the
request/command, auth/language context, fixture, expected/actual status, redirects, render marker, PHP/JavaScript errors,
database effects, messages, mail/files, and side effects. Test SEF and non-SEF forms when routing matters.

Gate: critical flows are verified; failures and required checks not run have exceptions.

## Step 8 — Measure coverage and own exceptions

Create `06-feature-coverage.csv` and `12-exception-register.csv`. Every coverage row defines its denominator and formula.
Measure extensions, modules, plugins, menus, routes, features, mappings, data, integrations, ACL contexts, runtime flows,
languages, and admin surfaces as applicable. Register each unknown, ambiguity, blocker, exclusion, mismatch, and failure.

Gate: all areas are 100% reviewed or the remainder is represented by owned exceptions.

## Step 9 — Validate and freeze

Create `13-validation-results.csv` and execute all applicable rules:

1. Required files and exact headers.
2. ID and semantic-key uniqueness.
3. Foreign-reference integrity.
4. Controlled vocabularies.
5. Normalized mapping duplicates.
6. Installed-implementation disposition.
7. Published-menu and non-menu-route disposition.
8. Bidirectional feature/page completeness.
9. Data-object ownership.
10. Required dependency/integration availability.
11. Evidence completeness.
12. Critical runtime and ACL verification.
13. Coverage arithmetic and denominators.
14. Exception ownership and closure.
15. No false `PASS`: unresolved high/critical blockers force `INCOMPLETE` or `BLOCKED`.

Record command/method, expected value, actual value, timestamp, evidence, and result. Set the run to `COMPLETE` only when
all applicable gates pass; otherwise use `INCOMPLETE` or `BLOCKED`.

## Profile completion

`CATALOG` requires Steps 0, 3, 4, 5 (`03` only), 6, and structural validation in Step 9. It must not be presented as a
technical or migration-complete inventory.

`COMPLETE` requires every step and applicable gate. Dependencies, evidence, coverage, implementations, data,
integrations, runtime checks, ACL, exceptions, and validation are mandatory.
