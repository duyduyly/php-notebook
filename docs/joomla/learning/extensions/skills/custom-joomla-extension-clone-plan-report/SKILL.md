---
name: custom-joomla-extension-clone-plan-report
description: Inspect a custom Joomla extension and generate a Markdown clone plan report covering every file, directory, manifest entry, database object, dependency, Discover requirement, and validation step needed to move it without changing business logic.
---

# Custom Joomla Extension Clone Plan Report

## Objective

Inspect one custom Joomla extension in a source project and generate a complete Markdown plan report describing everything that must be cloned into a target Joomla project.

The plan must preserve the original behavior, avoid missing logic, reconstruct the complete required database schema, and make the extension ready for Joomla Discover.

## Required references

Before inspecting the extension or generating the report, read these references in order:

1. [Joomla 6 Extension Structure](https://github.com/duyduyly/php-notebook/blob/joomla/docs/joomla/learning/extensions/joomla-6-extension-structure.md)
2. [`references/README.md`](./references/README.md)
3. [`references/extension-type-paths.md`](./references/extension-type-paths.md)
4. [`references/discover-requirements.md`](./references/discover-requirements.md)
5. [`references/database-schema-checklist.md`](./references/database-schema-checklist.md)
6. [`references/coverage-rules.md`](./references/coverage-rules.md)
7. [`templates/clone-plan-report-template.md`](./templates/clone-plan-report-template.md)

### Reference rules

- Treat the GitHub Joomla 6 structure document as the primary architecture reference.
- Classify the extension type before selecting required paths or structure checks.
- Apply only the requirements relevant to the detected type.
- Do not require Component-only files for Modules, Plugins, Templates, Libraries, Languages, Packages, or File extensions.
- When the source differs from the reference, record the difference and evidence. Do not silently rewrite business logic.
- If repository evidence conflicts with a generic reference, report the conflict and mark it for verification.

## Use this skill when

- Moving a custom Joomla extension between projects.
- Reconstructing an installable or discoverable extension from installed files.
- Creating file, structure, manifest, and database inventories before migration.
- Verifying that a cloned extension contains all original logic.
- Producing a repeatable migration plan without implementing new features.

## Do not use this skill to

- Add features.
- Refactor working business logic.
- Rename classes, methods, routes, tasks, views, tables, columns, or language keys.
- Delete files because they appear unused without evidence.
- Automatically convert Joomla 3 code to Joomla 6 code unless requested separately.

## Required inputs

Resolve these inputs from the repository, filesystem, database, or user-provided context:

| Input | Required |
|---|---:|
| Source project path or repository | Yes |
| Extension technical name | Yes |
| Extension type | Yes |
| Source Joomla version | Yes |
| Target Joomla version | Yes |
| Target project path or repository | Recommended |
| Database schema or database access | Required for database coverage |
| Source and target PHP versions | Recommended |
| Output report path | Recommended |

When a required fact cannot be verified, write `Unknown — verification required`. Never invent paths, table names, versions, or dependencies.

## Non-negotiable rules

1. Preserve business logic exactly unless an approved compatibility change is documented separately.
2. Inspect standard and non-standard paths.
3. Treat the manifest as an installation map, not the only source of truth.
4. Search source code for database tables, shared files, dependencies, and hard-coded paths.
5. Preserve path and filename case exactly.
6. Use checksums to detect unexpected logic changes.
7. Keep source-file, structure, manifest, Discover, database, and logic-preservation coverage separate.
8. Do not claim 100% coverage when evidence is incomplete.
9. Do not copy Joomla-generated IDs blindly when Installer or Discover should recreate them.
10. Never write secrets or production credentials into the report.
11. Report missing or conflicting evidence instead of guessing.
12. A successful Discover operation alone is never sufficient for `PASS`.

## Extension classification

Classify the extension before applying checks:

```text
Joomla Extension
├── Component — MVC application, backend, frontend, optional API and database
├── Module — Dispatcher/helper/layout output in a template position
├── Plugin — Event subscriber inside a plugin group
├── Template — Presentation, positions, assets, and overrides
├── Library — Shared reusable PHP code
├── Language — Translation package
├── Package — Bundle of child extensions
└── File — Arbitrary file collection installed by a manifest
```

Use the primary architecture reference and `references/extension-type-paths.md` to select expected source and target locations.

## Workflow

### 1. Identify the extension

Record:

- Display name.
- Technical name or element.
- Extension type.
- Plugin group when applicable.
- Client: Site, Administrator, API, or multiple clients.
- Manifest path and filename.
- Version and namespace.
- Installed paths.
- Source and target Joomla/PHP versions.

Capture applicable manifest values:

```text
type
client
method
element
folder/group
namespace
version
files
administration
media
languages
install SQL
uninstall SQL
schema updates
scriptfile
updateservers
```

### 2. Build the complete source inventory

Inspect every standard location listed for the detected extension type and search non-standard locations such as:

```text
layouts/
cli/
images/
media/vendor/
libraries/
templates/<template>/html/
administrator/templates/<template>/html/
plugins/
modules/
administrator/modules/
```

For every related file, collect:

| Field | Description |
|---|---|
| Source path | Exact source-project path |
| Target path | Expected target-project path |
| File type | PHP, XML, SQL, JS, CSS, image, language, JSON, other |
| Size | File size when available |
| SHA-256 | Checksum for logic-preservation verification |
| Manifest-declared | Yes or No |
| Required for Discover | Yes, No, or Conditional |
| Clone status | Planned, Copied, Missing, Modified, Excluded |
| Notes | Purpose, dependency, or risk |

Report original, required, cloned, missing, unexpected, and unexpectedly modified file counts.

### 3. Validate the structure

Generate a detected structure tree with inline comments.

Assign each expected item one status:

```text
Present
Missing
Partial
Not applicable
Unexpected
```

Optional items proven unnecessary must not reduce coverage.

### 4. Validate the manifest

Check:

- XML is well-formed.
- Type, client, element, and plugin group are correct.
- Technical name matches installed paths.
- Every declared file and directory exists.
- Required files are not omitted.
- Namespace paths match the actual `src` directories.
- Media and language destinations are valid.
- Installer scripts and SQL paths exist when declared.
- The manifest is located where Joomla Discover expects it.

Produce:

| Check | Expected | Actual | Status | Required action |
|---|---|---|---|---|

### 5. Analyze database requirements

Follow `references/database-schema-checklist.md`.

Search all source files, manifests, installer scripts, and SQL files for database usage, including:

```text
#__
CREATE TABLE
ALTER TABLE
DROP TABLE
INSERT INTO
UPDATE
DELETE FROM
JOIN
FOREIGN KEY
getTable
Table::getInstance
```

Inventory tables, columns, types, nullability, defaults, auto-increment, keys, indexes, constraints, charset, collation, views, triggers, procedures, business data, and Joomla Core ID relationships.

Separate:

- Extension schema.
- Business data.
- Joomla registration data.
- Joomla Core relationship mapping.

### 6. Validate Discover readiness

Follow `references/discover-requirements.md`.

Verify the exact installed manifest path, type, client, element, plugin group, declared files, namespace paths, SQL behavior, and possible `#__extensions` conflicts.

Report exactly one status:

```text
Ready
Conditional
Not ready
```

### 7. Find dependencies and external resources

Search for:

- Related components, modules, plugins, libraries, and packages.
- Composer packages and autoloaders.
- Template overrides and shared layouts.
- Shared media assets.
- CLI scripts, cron jobs, Scheduler tasks, and web-service plugins.
- Environment variables and required PHP extensions.
- External APIs, storage paths, and writable directories.

Record secret names and configuration sources only, never secret values.

### 8. Verify logic preservation

For files not approved for compatibility modification:

- Compare source and target file counts.
- Compare relative paths and filename case.
- Compare SHA-256 checksums.
- Run PHP syntax checks.
- Record every changed file and its approved reason.

Pass condition:

```text
Missing logic files = 0
Unexpected modified logic files = 0
```

### 9. Calculate coverage

Follow `references/coverage-rules.md` and report each category independently:

| Coverage area | PASS target |
|---|---:|
| Source files | 100% |
| Structure | 100% |
| Manifest | 100% |
| Database schema | 100% |
| Logic preservation | 100% |
| Discover readiness | Ready |
| Blocking dependencies | 0 |

Do not use one combined percentage to hide incomplete critical areas.

## Required output

Create one Markdown report from `templates/clone-plan-report-template.md` containing:

1. Executive Summary.
2. Scope and Constraints.
3. Source and Target Environments.
4. Extension Identification.
5. Detected Structure Tree.
6. File Inventory and Counts.
7. Manifest Analysis.
8. Source-to-Target Path Mapping.
9. Database Schema Inventory.
10. Data Migration Requirements.
11. Joomla Registration and Discover Plan.
12. Dependencies and External Resources.
13. Logic-Preservation Verification.
14. Coverage Summary.
15. Missing Items and Risks.
16. Clone Execution Plan.
17. Validation Checklist.
18. Final Readiness Decision.

Use a hierarchical Table of Contents with anchor links.

## Recommended commands

```bash
find <path> -type f | sort
find <path> -type f | wc -l
find <path> -type f -exec sha256sum {} \; | sort
php -l <file.php>
grep -R "#__" <extension-path>
grep -R "com_example\|mod_example\|plg_.*_example" <project-root>
grep -R "require\|include\|bootComponent\|PluginHelper::importPlugin" <extension-path>
mysqldump --no-data <database> <table-list> > schema.sql
```

Exclude generated runtime directories such as cache, tmp, logs, and Git metadata unless evidence shows that the extension intentionally stores required assets there.

## Completion criteria

Use `PASS` only when:

```text
Source files = 100%
Structure = 100%
Manifest = 100%
Database schema = 100%
Logic preservation = 100%
Discover readiness = Ready
Missing required files = 0
Unexpected logic changes = 0
Blocking dependencies = 0
```

Use `INCOMPLETE` when evidence is missing. Use `BLOCKED` when a known missing requirement prevents a safe clone.

## Final self-check

Before returning the report, verify:

- Every reference required by this skill was consulted.
- Every file count is evidence-based.
- Every required path has source and target mapping.
- Every manifest reference was checked.
- Every detected database object has evidence and a clone action.
- Discover readiness is justified separately from runtime correctness.
- Missing information is marked unknown rather than guessed.
- No secret value appears in the report.
- No business logic change is proposed as part of the clone plan.
